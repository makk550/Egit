public without sharing class CC_ngTurkeyService implements I {
  public interface I {
    Case[] fetchMyCases();
    Case[] fetchCasesByCriteria(CaseSearchCriteria criteria);
    Case fetchCaseById(Id caseId);
    User[] fetchCaTechniciansForCases(Case[] cases);
    SiteProductAssociation[] fetchSitesAndProducts(String siteId, String connectId);
    Case createCase(Case aCase);
    CaseComment addCaseComment(CaseComment caseComment);
    void changeSeverity(Id caseId, String severity, String commentBody);
    void reopenCase(Id caseId, String commentBody);
    void closeCase(Id caseId, String commentBody);
  }

  @TestVisible
  private final String[] caseRequiredFields = new String[]{
    'Subject',
    'Description',
    'Site_Association__c',
    'CA_Product_Controller__c',
    'Severity__c',
    'ContactId'
  };

  private Set<String> validSeverities {
    get {
      if (validSeverities == null) {
        validSeverities = new Set<String>();
        List<Schema.PicklistEntry> ple = Case.Severity__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : ple) {
          validSeverities.add(entry.getValue());
        }
      }
      return validSeverities;
    }
    private set;
  }

  private CasesData casesDal { get; set; }

  @TestVisible
  private Id contactId { get; set; }

  // Service class for API Gateway callouts
  @TestVisible
  private CC_Layer7Service.I l7Svc {
    get {
      if (l7Svc == null) {
        l7Svc = new CC_Layer7Service();
      }  
      return l7Svc;
    } set;
  }

  public CC_ngTurkeyService(Id contactId) {
    this.casesDal = new CasesData();
    this.contactId = contactId;
    if (contactId == null) {
      throw new ValidationException('You must provide a ContactId for security purposes.');
    }
  }

  public Case[] fetchMyCases() {
    CaseSearchCriteria criteria = new CaseSearchCriteria();
    criteria.contactId = this.contactId;
    Case[] cases = fetchCasesByCriteria(criteria);
    return cases;
  }

  public Case[] fetchCasesByCriteria(CaseSearchCriteria criteria) {
    Set<Id> entitledSites = fetchEntitledSites(this.contactId);
    Case[] cases = casesDal.fetchCasesByCriteriaFlyweight(entitledSites, criteria);
    return cases;
  }

  public Case fetchCaseById(Id caseId) {
    Case fetchedCase = casesDal.fetchCaseById(caseId);
    if (fetchedCase == null) {
      throw new ValidationException('You do not have access to this case.');
    }
    validateSiteAccess(fetchedCase.Site_Association__c);
    return fetchedCase;
  }

  public User[] fetchCaTechniciansForCases(Case[] cases) {
    Set<Id> userIds = new Set<Id>();
    for (Case aCase : cases) {
      userIds.add(aCase.OwnerId);
    }
    return [SELECT Id
                  ,Name
                  ,Phone
                  ,Email
                  ,Preferred_Contact_Method__c
            FROM User
            WHERE Id IN :userIds];
  }

  public SiteProductAssociation[] fetchSitesAndProducts(String siteId, String connectId) {
    CC_Layer7Service.JsonData jsonData = l7Svc.getSitesAndProducts(siteId, connectId);
    CC_Layer7Service.JsonSiteProduct[] sitesAndProducts = jsonData.sites_and_products;
    sitesAndProducts.add(new CC_Layer7Service.JsonSiteProduct(siteId, 'GLOBAL SERVICE CENTER'));
    
    // build site ids from full list of sites
    Set<String> siteIds = new Set<String>();
    for (String jsonSiteId : jsonData.sites.siteIds) {
      siteIds.add(CC_Utils.padSiteId(jsonSiteId));
    }
    Set<String> productNames = new Set<String>();
    for (CC_Layer7Service.JsonSiteProduct siteProduct : sitesAndProducts) {
      productNames.add(siteProduct.name);
    }

    Map<String, Site_Association__c> sfSiteMap = fetchSiteAssociationsByTopsSiteIds(siteIds);
    Map<String, CA_Product_Controller__c> sfProductMap = fetchCaProductControllersByProductNames(productNames);

    Set<Id> sfSiteIds = new Set<Id>();
    for (Site_Association__c site : sfSiteMap.values()) {
      sfSiteIds.add(site.Id);
    }

    // side effect! Save contact's entitled sites in SF. This is important because we use these sites for security.
    // update contact site associations using full list of site ids
    updateContactSiteAssociations(this.contactId, sfSiteIds);

    return convertToSiteProductAssociation(sitesAndProducts, sfSiteMap, sfProductMap);
  }

  public Case createCase(Case aCase) {
    aCase.Origin = 'Community';
    aCase.Case_Type__c = 'Standard';
    validateCaseCreate(aCase);
    insert aCase;
    return aCase;
  }

  public CaseComment addCaseComment(CaseComment caseComment) {
    validateCaseCommentCreate(caseComment);
    insert caseComment;
    update new Case(Id = caseComment.ParentId);
    //return [SELECT Id, ParentId, CommentBody, CreatedBy.Name, CreatedDate FROM CaseComment WHERE Id = :caseComment.Id];
    return casesDal.fetchCaseCommentById(caseComment.Id);
  }

  public void closeCase(Id caseId, String commentBody) {
    CaseComment comment = new CaseComment(
      ParentId = caseId,
      CommentBody = 'Request Case Close: \n' + commentBody
    );
    addCaseComment(comment);
    
    Case aCase = new Case(
      Id = caseId
    );
    update aCase;
  }

  public void reopenCase(Id caseId, String commentBody) {
    CaseComment comment = new CaseComment(
      ParentId = caseId,
      CommentBody = 'Request Case Reopen: \n' +commentBody
    );
    addCaseComment(comment);

    Case aCase = new Case(
      Id = caseId,
      Reason_for_Reopen__c = 'Case Reopen Requested',
      Troubleshooting_Stage__c = '1. Problem Identification',
      Next_Action_Due_Date__c = DateTime.now().addHours(25),
      Next_Action__c = 'Pending CA Support'
    );
    update aCase;
  }

  public void changeSeverity(Id caseId, String newSeverity, String commentBody) {
    Case existingCase = casesDal.fetchCaseById(caseId);

    String[] validationErrors = new String[]{};
    checkSeverity(validationErrors, newSeverity);
    if (newSeverity == '1' && existingCase.Severity__c != '1') {
      validationErrors.add('Cannot change case severity to "1"');
    }
    throwValidationError(validationErrors);
    
    CaseComment comment = new CaseComment(
      ParentId = caseId,
      CommentBody = 'User Changed Severity from ' + existingCase.Severity__c + ' to ' + newSeverity + ': \n' + commentBody
    );
    addCaseComment(comment);

    Case aCase = new Case(
      Id = caseId,
      Severity__c = newSeverity
    );
    update aCase;
  }

  @TestVisible
  private void updateContactSiteAssociations(Id contactId, Set<Id> siteIds) {
    Contacts_Site_Association__c[] csas = casesDal.fetchContactSiteAssociations(contactId);
    Set<Id> newSites = siteIds;
    Map<Id, Contacts_Site_Association__c> csasBySiteId = new Map<Id, Contacts_Site_Association__c>();
    Contacts_Site_Association__c[] upsertCsas = new Contacts_Site_Association__c[]{};
    for (Contacts_Site_Association__c csa : csas) {
      csasBySiteId.put(csa.SC_CSA_SITE__c, csa);
      if (!newSites.contains(csa.SC_CSA_SITE__c)) {
        // deactivate this csa
        upsertCsas.add(new Contacts_Site_Association__c(Id = csa.Id, SC_CSA_ACTIVE_ON_SITE__c = false));
      }
    }
    
    for(Id siteId: siteIds){
      Contacts_Site_Association__c csa =  csasBySiteId.get(siteId);
      if (csa == null) {
        // add new csa for this site
        upsertCsas.add(new Contacts_Site_Association__c(SC_CSA_CONTACTS__c = contactId, SC_CSA_SITE__c = siteId));
      } else if (csa.SC_CSA_ACTIVE_ON_SITE__c == false) {
        // reactivate old csa for this site
        upsertCsas.add(new Contacts_Site_Association__c(Id = csa.Id, SC_CSA_ACTIVE_ON_SITE__c = true));
      }
    }

    upsert upsertCsas;
  }

  @TestVisible
  private Map<String, Site_Association__c> fetchSiteAssociationsByTopsSiteIds(Set<String> topsSiteIds) {
    Map<String, Site_Association__c> sfSiteMap = new Map<String, Site_Association__c>(); 
    for (Site_Association__c site : [SELECT Id, Name, SC_TOPS_ID__c FROM Site_Association__c WHERE SC_TOPS_ID__c IN :topsSiteIds]) {
      sfSiteMap.put(site.SC_TOPS_ID__c, site);
    }
    return sfSiteMap;
  }

  @TestVisible
  private Map<String, CA_Product_Controller__c> fetchCaProductControllersByProductNames(Set<String> productNames) {
    Map<String, CA_Product_Controller__c> sfProductMap = new Map<String, CA_Product_Controller__c>();

    // fetch all prodcut controllers
    //CA_Product_Controller__c[] sfProducts = [SELECT Id, Name FROM CA_Product_Controller__c WHERE Name IN : productNames ORDER BY Name ASC];
    //for (CA_Product_Controller__c sfProduct : sfProducts) {
    //  sfProductMap.put(sfProduct.Name, sfProduct);
    //}

    // fetch only valid ca product controllers
    // HACK: workaround the component handling logic in AutoAssign.trigger
    CA_Product_Component__c[] components = [SELECT CA_Product_Controller__r.Id, CA_Product_Controller__r.Name FROM CA_Product_Component__c 
      WHERE CA_Product_Controller__r.Name in :productNames 
      AND Default_Component_for_this_CA_Product__c = true 
      AND (component_expiration_date__c >= :System.today() OR component_expiration_date__c = null OR Internal_Presentation_Only__c = true) 
      ORDER BY CA_Product_Controller__r.Name];
    for (CA_Product_Component__c component : components) {
      sfProductMap.put(component.CA_Product_Controller__r.Name, (CA_Product_Controller__c)component.CA_Product_Controller__r);
    }

    return sfProductMap;
  }

  // convert API Gateway results to SiteProductAssociation objects
  @TestVisible
  private SiteProductAssociation[] convertToSiteProductAssociation(CC_Layer7Service.JsonSiteProduct[] siteProducts, Map<String, Site_Association__c> sfSiteMap, Map<String, CA_Product_Controller__c> sfProductMap) {
    SiteProductAssociation[] returnList = new List<SiteProductAssociation>();
    for (CC_Layer7Service.JsonSiteProduct siteProduct : siteProducts) {
      String siteId = CC_Utils.padSiteId(siteProduct.site_id);
      SiteProductAssociation spAssociation = new SiteProductAssociation(
        sfSiteMap.get(siteId), 
        sfProductMap.get(siteProduct.name)
      );
      if (spAssociation.isValid()) {
        returnList.add(spAssociation);
      } else {
        log.warn('Ignoring invalid Site/Product Association: Site ID:' + siteId + ', Produce Name: ' + siteProduct.name);
      }
    }
    return returnList;
  }

  private Set<Id> fetchEntitledSites(Id contactId) {
    Contacts_Site_Association__c[] csas = casesDal.fetchContactSiteAssociations(contactId);
    Set<Id> entitledSites = new Set<Id>();
    for (Contacts_Site_Association__c csa : csas) {
      if (csa.SC_CSA_ACTIVE_ON_SITE__c == true) {
        entitledSites.add(csa.SC_CSA_SITE__c);
      }
    }
    return entitledSites;
  }

  private void validateCaseAccess(Id caseId) {
    Case fetchedCase = [SELECT ID, Site_Association__c FROM Case WHERE ID = :caseId];
    validateSiteAccess(fetchedCase.Site_Association__c);
  }

  private void validateSiteAccess(ID siteId) {
    Set<Id> entitledSites = fetchEntitledSites(this.contactId);
    if (!entitledSites.contains(siteId)) {
      throw new ValidationException('You do not have access to this case.');
    }
  }

  private void validateCaseCreate(Case aCase) {
    String[] validationErrors = new String[]{};
    checkRequiredFields(validationErrors, aCase);
    checkSeverity(validationErrors, aCase.Severity__c);
    if (aCase.Severity__c == '1') {
      validationErrors.add('Cannot create a case with severity "1"');
    }
    throwValidationError(validationErrors);
    validateSiteAccess(aCase.Site_Association__c);
  }

  private void checkRequiredFields(String[] validationErrors, Case aCase) {
    String[] missingFields = new String[]{};
    for (String field : caseRequiredFields) {
      String value = String.valueOf(aCase.get(field));
      if (aCase.get(field) == null || String.isBlank(value)) {
        missingFields.add(field);
      }
    }
    if (missingFields.size() > 0) {
      validationErrors.add('Missing required fields: ' + String.join(missingFields, ', '));
    }
  }

  private void checkSeverity(String[] validationErrors, String severity) {
    if (!validSeverities.contains(severity)) {
      validationErrors.add('Severity "' + severity + '" is invalid');
    }
  }

  private void validateCaseCommentCreate(CaseComment aCaseComment) {
    String[] validationErrors = new String[]{};

    // validate case comment body is not blank
    String value = aCaseComment.CommentBody;
    if(aCaseComment.CommentBody == null || String.isBlank(value)){
      validationErrors.add('Missing required fields: CommentBody');
    }
    throwValidationError(validationErrors);
    validateCaseAccess(aCaseComment.ParentId);
  }

  private void throwValidationError(String[] validationErrors) {
    if (validationErrors.size() > 0) {
      throw new ValidationException().fromErrors(validationErrors);
    }
  }

  public class CaseSearchCriteria {
    public String caseNumber {get;set { caseNumber = String.escapeSingleQuotes(value); }}
    public String title {get;set { title = String.escapeSingleQuotes(value); }}
    public String contactEmail {get;set { contactEmail = String.escapeSingleQuotes(value); }}
    public String status {get;set { status = String.escapeSingleQuotes(value); }}
    public String severity {get;set { severity = String.escapeSingleQuotes(value); }}
    public Id product {get;set;}
    public DateTime createdDateFrom {get;set;}
    public DateTime createdDateTo {get;set;}
    public DateTime lastModifiedDateFrom {get;set;}
    public DateTime lastModifiedDateTo {get;set;}
    public Id contactId {get;set;}
    public String[] buildClauses() {
      String[] clauses = new String[]{};
      if (this.caseNumber != null) {
        clauses.add('CaseNumber LIKE \'%' + this.caseNumber + '%\'');
      }
      if (this.title != null) {
        clauses.add('Subject LIKE \'%' + this.title + '%\'');
      }
      if (this.contactEmail != null) {
        clauses.add('Contact.Email LIKE \'%' + this.contactEmail + '%\'');
      }
      if (this.status != null) {
        clauses.add('Status = \'' + this.status + '\'');
      }
      if (this.severity != null) {
        clauses.add('Severity__c = \'' + this.severity + '\'');
      }
      if (this.product != null) {
        clauses.add('CA_Product_Controller__c = \'' + this.product + '\'');
      }
      if (this.createdDateFrom != null) {
        clauses.add('CreatedDate >= ' + this.createdDateFrom.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.sssZ'));
      }
      if (this.createdDateTo != null) {
        clauses.add('CreatedDate <= ' + this.createdDateTo.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.sssZ'));
      }
      if (this.lastModifiedDateFrom != null) {
        clauses.add('LastModifiedDate >= ' + this.lastModifiedDateFrom.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.sssZ'));
      }
      if (this.lastModifiedDateTo != null) {
        clauses.add('LastModifiedDate <= ' + this.lastModifiedDateTo.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.sssZ'));
      }
      if (this.contactId != null) {
        clauses.add('ContactId = \'' + this.contactId + '\'');
      }
      return clauses;
    }
  }

  public class SiteProductAssociation {
    public CA_Product_Controller__c product {get; set;}
    public Site_Association__c site {get; set;}
    public SiteProductAssociation(Site_Association__c site, CA_Product_Controller__c product) {
      if (site != null && !site.Name.endsWith(' - ' + site.SC_TOPS_ID__c)) {
        site.Name += ' - ' + site.SC_TOPS_ID__c;
      }
      this.site = site;
      this.product = product;
    }
    public Boolean isValid() {
      return product != null && site != null;
    }
  }

  public class ValidationException extends Exception {
    public String[] errors { get; private set; }
    public ValidationException fromErrors(String[] validationErrors) {
      String message = 'Validation errors: ' + String.join(validationErrors, ', ');
      ValidationException ex = new ValidationException(message);
      ex.errors = validationErrors;
      return ex;
    }
  }

  public without sharing class CasesData {

    private String[] fieldsCasesFlyweight = new String[] {
      'Id'
      ,'Business_Impact__c'
      ,'CA_Product_Controller__c'
      ,'CaseNumber'
      ,'ContactId'
      ,'CreatedDate'
      ,'ClosedDate'
      ,'Description'
      ,'LastModifiedDate'
      ,'OwnerId'
      ,'Severity__c'
      ,'Status'
      ,'Subject'
      ,'Next_Action__c'
      ,'CA_Product_Controller__r.Name'
      ,'Contact.Email'
      ,'Site_Association__r.Name'
      ,'(SELECT Portal_View_Date__c FROM Case_Portal_Views__r ORDER BY Portal_View_Date__c DESC LIMIT 1)'
    };

    private String[] fieldsCaseComment = new String[]{
      'Id', 
      'ParentId', 
      'CommentBody', 
      'CreatedBy.Name', 
      'CreatedDate'
    };

    private String[] fieldsCasesFull = concatLists(fieldsCasesFlyweight, new String[] {
      '(SELECT ' + String.join(fieldsCaseComment, ', ') +
        ' FROM CaseComments' +
        ' WHERE IsPublished = true ' +
        ' ORDER BY CreatedDate DESC) '
      ,'(SELECT Id' +
            ',Type' +
            ',Due_Date_SLO__c' +
            ',CallBackEndTime__c' +
        ' FROM Tasks' +
        ' WHERE Type IN (\'Initial Callback\', \'Workaround\', \'Resolution\'))'
    });

    private String[] concatLists(String[] list1, String[] list2) {
      String[] newList = new List<String>(list1);
      newList.addAll(list2);
      return newList;
    }

    public Case[] fetchCasesByCriteriaFlyweight(Set<Id> entitledSites, CaseSearchCriteria criteria) {
      String soql = 'SELECT ' + String.join(fieldsCasesFlyweight, ', ') + ' FROM Case';
      String[] clauses = criteria.buildClauses();
      if (entitledSites == null) {
        entitledSites = new Set<Id>();
      }
      clauses.add('Site_Association__c IN :entitledSites');
      soql += ' WHERE ' + String.join(clauses, ' AND ');
      soql += ' ORDER BY LastModifiedDate DESC';
      soql+= ' LIMIT ' + CC_Settings.caseSearchMaxResults;
      return Database.query(soql);
    }

    public Case fetchCaseById(Id caseId) {
      String soql = 'SELECT ' + String.join(fieldsCasesFull, ', ') + ' FROM Case';
      soql += ' WHERE Id = :caseId';
      Case[] cases = Database.query(soql);
      if (cases.size() > 0) {
        return cases[0];
      }
      return null;
    }

    public CaseComment fetchCaseCommentById(Id commentId) {
      String soql = 'SELECT ' + String.join(fieldsCaseComment, ', ') + ' FROM CaseComment';
      soql += ' WHERE Id = :commentId';
      CaseComment[] comments = Database.query(soql);
      if (comments.size() > 0) {
        return comments[0];
      }
      return null;
    }

    public Contacts_Site_Association__c[] fetchContactSiteAssociations(Id contactId) {
      return [SELECT SC_CSA_CONTACTS__c
                    ,SC_CSA_SITE__c
                    ,SC_CSA_ACTIVE_ON_SITE__c 
              FROM Contacts_Site_Association__c 
              WHERE SC_CSA_CONTACTS__c = :contactId];
    }
  }
}