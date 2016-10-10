global without sharing class CC_ngTurkeyController {

  /* PUBLIC PROPERTIES */
  
  public static User currentUser {
    get {
      if (currentUser == null) {
        Id currentUserId = UserInfo.getUserId();
        currentUser = [SELECT Id, FirstName, LastName, TimeZoneSidKey, LDAP_Date_Format__c, LDAP_Time_Format__c, LDAP_Roles__c, Contact.Id, Contact.SC_CONTACT_LDAPID__c, Contact.SC_CONTACT_LDAP_DEFAULT_SITE_ID__c FROM User WHERE ID = :currentUserId];
      }
      return currentUser;
    }
    set;
  }

  // Used to pass context data to angular
  public static String userContext {
    get {
      return JSON.serialize(new Map<String, Object>{
        'userId' => currentUser.Id,
        'firstName' => currentUser.FirstName,
        'lastName' => currentUser.LastName,
        'contactId' => currentUser.Contact.Id,
        'defaultSiteId' => currentUser.Contact.SC_CONTACT_LDAP_DEFAULT_SITE_ID__c,
        'connectId' => currentUser.Contact.SC_CONTACT_LDAPID__c,
        'dateTimeFormat' => userDateTimeFormat,
        'timezoneOffsetInMillis' => userTimezoneOffsetInMillis
      });
    }
  }

  public static Boolean debugEnabled {
    get { return CC_Settings.debugEnabled; }
  }

  public static String csoBaseUrl {
    get { return CC_Settings.csoUrl; }
  }

  /* PRIVATE PROPERTIES */

  private static Integer userTimezoneOffsetInMillis {
    get {
        TimeZone tz = UserInfo.getTimeZone();
        Date newDate = Date.today();
        Time newTime = Time.newInstance(0, 0, 0, 0);
        return tz.getOffset(Datetime.newInstanceGmt(newDate, newTime));
    }
  }

  private static String userDateTimeFormat {
    get {
      String dateFormat = currentUser.LDAP_Date_Format__c;
      String timeFormat = currentUser.LDAP_Time_Format__c;
      if (dateFormat != null && timeFormat != null) {
        return dateFormat + ' ' + timeFormat;
      }
      return '';
    }
  }

  // Service class for all things SF related
  @TestVisible
  private static CC_ngTurkeyService.I turkeySvc {
    get {
      if (turkeySvc == null) {
        turkeySvc = new CC_ngTurkeyService(currentUser.Contact.Id);
      }
      return turkeySvc;
    }
    set;
  }

  // Service class for search.ca.com callouts
  @TestVisible
  private static CC_SearchItService.I searchItSvc {
    get {
      if (searchItSvc == null) {
        searchItSvc = new CC_SearchItService();
      }  
      return searchItSvc;
    } set;
  }

  /* PUBLIC WEB SERVICES */

  // Fetch Sites and Products from API Gateway and transform into SF Site_Assocaitions and Product_Controllers
  @RemoteAction
  global static List<Object> fetchSitesAndProducts() {
    log.debug(currentUser);
    String siteId = currentUser.Contact.SC_CONTACT_LDAP_DEFAULT_SITE_ID__c;
    String connectId = currentUser.Contact.SC_CONTACT_LDAPID__c;
    CC_ngTurkeyService.SiteProductAssociation[] spas = turkeySvc.fetchSitesAndProducts(siteId, connectId);
    log.debug(spas);
    return (List<Object>)spas;
  }

  // Fetch cases owned by the current user
  @RemoteAction
  global static Case[] fetchMyCases() {
    Case[] foundCases = turkeySvc.fetchMyCases();
    log.debug(foundCases);
    return foundCases;
  }

  /* Fetch cases by search criteria, limited to current user's entitled sites
      Params:
        caseNumber (String)
        title (String)
        contactEmail (String)
        status (String)
        severity (String)
        product (ID) - CA_Product_Controller ID
        createdDateFrom (Timestamp)
        createdDateTo (Timestamp)
        lastModifiedDateFrom (Timestamp)
        lastModifiedDateTo (Timestamp)
  */
  @RemoteAction
  global static Case[] fetchCasesByCriteria(Map<String, Object> searchParams) {
    CC_ngTurkeyService.CaseSearchCriteria criteria = dataToSearchCriteria(searchParams);
    Case[] foundCases = turkeySvc.fetchCasesByCriteria(criteria);
    log.debug(foundCases);
    return foundCases;
  }

  // Fetch a single case for the case details page
  @RemoteAction
  global static Map<String, Object> fetchCase(Id caseId) {
    log.debug(caseId);
    Case myCase = turkeySvc.fetchCaseById(caseId);

    Map<Id, User> caTechnicians = new Map<Id, User>(turkeySvc.fetchCaTechniciansForCases(new Case[]{myCase}));
    Map<String, Object> jsonCase = toJson(myCase);
    User caTech = caTechnicians.get(myCase.OwnerId);
    jsonCase.put('Owner', toJson(caTech));


    // side effect! create a portal view record whenever we fetch a case by id.
    Datetime viewDate = Datetime.now();
    registerPortalView(myCase.Id, viewDate);
    log.debug(jsonCase);
    return jsonCase;
  }

  // Find related support content to display on the create case page
  @RemoteAction
  global static CC_SearchItService.SearchItResults findSupportArticles(Map<String, String> data) {
    String title = data.get('title');
    Id productId = data.get('productId');
    return searchItSvc.doSearch(title, productId);
  }

  /* Create a new case for the current user
      Params:
        businessImpact (String)
        description (String, required)
        severity (String, required)
        title (String, required)
        siteId (ID, required) - CA_Product_Controller ID
        productId (ID, required) - Site_Association ID
        productName (String, required) - used to create comment
        release (String) - used to create comment
        servicePack (String) - used to create comment
        operatingSystem (String) - used to create comment
  */
  @RemoteAction
  global static Id createCase(Map<String, Object> caseData) {
    log.debug(caseData);
    Savepoint sp = Database.setSavepoint();
    try {
      Case cleanCase = dataToCase(caseData);
      Case newCase = turkeySvc.createCase(cleanCase);
      CaseComment newCaseComment = buildNewCaseComment(caseData, newCase.Id);
      turkeySvc.addCaseComment(newCaseComment);
      log.debug(newCase);
      return newCase.Id;
    } catch (Exception ex) {
      Database.rollback(sp);
      throw buildCommunityException(ex);
    }
  }

  /* Create comment on specified case
      Params:
        caseId (ID, required) - SF ID of case
        comment (String, required) - Text for comment
  */
  @RemoteAction
  global static CaseComment createCaseComment(Map<String, String> data) {
    log.debug(data);
    CaseComment comment = new CaseComment(
      ParentId = data.get('caseId'),
      CommentBody = data.get('comment')
    );
    return turkeySvc.addCaseComment(comment);
  }

  /* Request case close for specified case
      Params:
        caseId (ID, required) - SF ID of case
        comment (String, required) - Text for comment
  */
  @RemoteAction
  global static void closeCase(Map<String, String> data) {
    log.debug(data);
    Id caseId = data.get('caseId');
    String commentBody = data.get('comment');
    turkeySvc.closeCase(caseId, commentBody);
  }

  /* Change severity for specified case
      Params:
        caseId (ID, required) - SF ID of case
        severity (String, required) - new severity for this case (i.e. 2,3,4)
        comment (String, required) - Text for comment
  */
  @RemoteAction
  global static void changeSeverity(Map<String, String> data) {
    log.debug(data);
    Id caseId = data.get('caseId');
    String newSeverity = data.get('newSeverity');
    String commentBody = data.get('comment');
    turkeySvc.changeSeverity(caseId, newSeverity, commentBody);
  }

  /* Request reopen of previously closed case
      Params:
        caseId (ID, required) - SF ID of case
        comment (String, required) - Text for comment
  */
  @RemoteAction
  global static void reopenCase(Map<String, String> data) {
    log.debug(data);
    Id caseId = data.get('caseId');
    String commentBody = data.get('comment');
    turkeySvc.reopenCase(caseId, commentBody);
  }


  /* PUBLIC METHODS */
  public PageReference redirect(){  
    Boolean accessGranted = false;
    PageReference redirectToPage = null;
    CC_LDAPRoles roles = new CC_LDAPRoles();
    if(currentUser.LDAP_Roles__c != null){
      accessGranted = roles.allowAccessToCustomerCommunity(currentUser.LDAP_Roles__c);
    }
    if(accessGranted == false){
      redirectToPage = Page.CC_RedirectToCSO;
    }
    return redirectToPage;
  }

  /* PRIVATE METHODS */

  // asynchronously insert a portal view record for this case
  private static void registerPortalView(Id caseId, Datetime viewDate) {
    System.enqueueJob(new RegisterPortalViewAsync(caseId, viewDate));
  }

  // convert generic object to map
  private static Map<String, Object> toJson(Object obj) {
    return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
  }

  // convert map to a Case object
  private static Case dataToCase(Map<String, Object> data) {
    Case cleanCase = new Case(
      Business_Impact__c = (String)data.get('businessImpact')
      ,ContactId = currentUser.Contact.Id
      ,Description = (String)data.get('description')
      ,Severity__c = (String)data.get('severity')
      ,Subject = (String)data.get('title')
      ,Site_Association__c = (Id)data.get('siteId')
      ,CA_Product_Controller__c = (Id)data.get('productId')
    );
    return cleanCase;
  }

  @TestVisible
  private static CC_ngTurkeyService.CaseSearchCriteria dataToSearchCriteria(Map<String, Object> data) {
    CC_ngTurkeyService.CaseSearchCriteria criteria = new CC_ngTurkeyService.CaseSearchCriteria();
    if (data.containsKey('caseNumber')) {
      criteria.caseNumber = (String)data.get('caseNumber');
    } else {
      if (data.containsKey('title')) {
        criteria.title = (String)data.get('title');
      }
      if (data.containsKey('contactEmail')) {
        criteria.contactEmail = (String)data.get('contactEmail');
      }
      if (data.containsKey('status')) {
        criteria.status = (String)data.get('status');
      }
      if (data.containsKey('severity')) {
        criteria.severity = String.valueOf(data.get('severity'));
      }
      if (data.containsKey('product')) {
        criteria.product = (Id)data.get('product');
      }
      if (data.containsKey('createdDateFrom')) {
        criteria.createdDateFrom = dateStringToDateTime((String)data.get('createdDateFrom'));
      }
      if (data.containsKey('createdDateTo')) {
        criteria.createdDateTo = dateStringToDateTime((String)data.get('createdDateTo'));
      }
      if (data.containsKey('lastModifiedDateFrom')) {
        criteria.lastModifiedDateFrom = dateStringToDateTime((String)data.get('lastModifiedDateFrom'));
      }
      if (data.containsKey('lastModifiedDateTo')) {
        criteria.lastModifiedDateTo = dateStringToDateTime((String)data.get('lastModifiedDateTo'));
      }
    }
    return criteria;
  }

  private static DateTime dateStringToDateTime(String dateString) {
    String normalizedDateString = dateString.replace('T', ' ');
    return DateTime.valueOfGmt(normalizedDateString);
  }

  // convert map to case comment
  private static CaseComment buildNewCaseComment(Map<String, Object> data, Id caseId) {
    CaseComment newCaseComment = new CaseComment(ParentId = caseId);
    String commentBody = '';
    String productName = (String)data.get('productName');
    commentBody += 'Product: ' + productName;
    String release = (String)data.get('release');
    if (release != null) {
      commentBody += ', Release: ' + release;
    }
    String servicePack = (String)data.get('servicePack');
    if (servicePack != null) {
      commentBody += ', Service Pack: ' + servicePack;
    }
    String os = (String)data.get('operatingSystem');
    if (os != null) {
      commentBody += ', Operating System: ' + os;
    }
    newCaseComment.CommentBody = commentBody;
    return newCaseComment;
  }

  // build exception to throw
  private static CommunityException buildCommunityException(Exception ex) {
    String exceptionMessage = 'Error in Salesforce Community Case Management: ';
    exceptionMessage += ex.getTypeName() + ' - ' + ex.getMessage();
    exceptionMessage += '\nLine Number: ' + ex.getLineNumber();
    exceptionMessage += '\nStack Trace: ' + ex.getStackTraceString();
    CommunityException cex = new CommunityException(exceptionMessage, ex);
    log.error(cex);
    if (CC_Settings.debugEnabled) {
      return cex;
    } else {
      return new CommunityException('Error in Salesforce Community Case Management', ex);
    }
  }

  /* OTHER CLASSES */

  public class CommunityException extends Exception {
  }

  public class RegisterPortalViewAsync implements Queueable {
    Id caseId;
    Datetime viewDate;
    public RegisterPortalViewAsync(Id caseId, Datetime viewDate) {
      this.caseId = caseId;
      this.viewDate = viewDate;
    }
    public void execute(QueueableContext context) {
      insert new Case_Portal_View__c(Case__c = caseId, Portal_View_Date__c = viewDate);
    }
  }
}