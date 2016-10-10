@IsTest
private class CC_ngTurkeyControllerTest {

  @IsTest
  static void currentUser_should_get_current_user() {
    User currentUser = CC_ngTurkeyController.currentUser;
    System.assertEquals(UserInfo.getUserId(), currentUser.Id);
  }

  @IsTest
  static void userContext_should_get_json_string(){
    CC_ngTurkeyController.currentUser = new User(
      Id = CC_TestUtils.fakeId(User.SObjectType), 
      FirstName = 'Howard',
      LastName = 'TheDuck',
      Contact = new Contact(
        Id = CC_TestUtils.fakeId(Contact.SObjectType),
        SC_CONTACT_LDAP_DEFAULT_SITE_ID__c = '12345',
        SC_CONTACT_LDAPID__c = 'abcde'
        ),
      LDAP_Date_Format__c = 'dateFormat',
      LDAP_Time_Format__c = 'timeFormat'
      );
    Map<String, Object> userContext = (Map<String, Object>)JSON.deserializeUntyped(CC_ngTurkeyController.userContext);

    System.assert(userContext.containsKey('userId'));
    System.assertEquals(CC_ngTurkeyController.currentUser.Id,userContext.get('userId'));
    System.assert(userContext.containsKey('firstName'));
    System.assertEquals(CC_ngTurkeyController.currentUser.FirstName,userContext.get('firstName'));
    System.assert(userContext.containsKey('lastName'));
    System.assertEquals(CC_ngTurkeyController.currentUser.LastName,userContext.get('lastName'));
    System.assert(userContext.containsKey('contactId'));
    System.assertEquals(CC_ngTurkeyController.currentUser.Contact.Id,userContext.get('contactId'));
    System.assert(userContext.containsKey('defaultSiteId'));
    System.assertEquals(CC_ngTurkeyController.currentUser.Contact.SC_CONTACT_LDAP_DEFAULT_SITE_ID__c,userContext.get('defaultSiteId'));
    System.assert(userContext.containsKey('connectId'));
    System.assertEquals(CC_ngTurkeyController.currentUser.Contact.SC_CONTACT_LDAPID__c,userContext.get('connectId'));
    System.assert(userContext.containsKey('dateTimeFormat'));
    System.assertEquals('dateFormat timeFormat',userContext.get('dateTimeFormat'));
    //System.assert(userContext.containsKey('csoBaseUrl'));
    System.assertEquals(CC_Settings.csoUrl, CC_ngTurkeyController.csoBaseUrl);
    System.assert(userContext.containsKey('timezoneOffsetInMillis'));
    System.assert(userContext.get('timezoneOffsetInMillis') instanceof Long);
  }

  @IsTest
  static void fetchSitesAndProducts_should_fetch_sites_and_products() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    String siteId = 'siteId';
    String connectId = 'connectId';
    Id contactId = CC_TestUtils.fakeId(Contact.SObjectType);
    turkeySvcMock.callLogger.recordCall(
      'fetchSitesAndProducts', 
      new Map<String, Object>{'siteId' => siteId, 'connectId' => connectId}, 
      new CC_ngTurkeyService.SiteProductAssociation[] {
        new CC_ngTurkeyService.SiteProductAssociation(
          new Site_Association__c(Name = 'Site1', SC_TOPS_ID__c = '12345'),
          new CA_Product_Controller__c()
          )
        });

    User currentUser = new User(Contact = new Contact(Id = contactId, SC_CONTACT_LDAP_DEFAULT_SITE_ID__c = siteId, SC_CONTACT_LDAPID__c = connectId));
    CC_ngTurkeyController.currentUser = currentUser;

    // When
    Test.startTest();
    CC_ngTurkeyService.SiteProductAssociation[] spas = (CC_ngTurkeyService.SiteProductAssociation[])CC_ngTurkeyController.fetchSitesAndProducts();
    Test.stopTest();

    // Then
    turkeySvcMock.callLogger.verify();
    System.assertEquals(1, spas.size());
  }

  @IsTest
  static void fetchMyCases_should_fetch_my_cases() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    turkeySvcMock.callLogger.recordCall(
      'fetchMyCases', 
      null, 
      new Case[] {
        buildCase(),
        buildCase(),
        buildCase()
        });

    // When
    Test.startTest();
    Case[] cases = CC_ngTurkeyController.fetchMyCases();
    Test.stopTest();

		// Then
    System.assertEquals(3, cases.size(), cases);
    turkeySvcMock.callLogger.verify();
  }

  @IsTest
  static void fetchCasesByCriteria_should_fetch_cases_by_criteria() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    turkeySvcMock.callLogger.recordCall(
      'fetchCasesByCriteria', 
      null, 
      new Case[] {
        buildCase(),
        buildCase(),
        buildCase()
        });
    Id fakeSiteId = CC_TestUtils.fakeId(Site_Association__c.SObjectType);

    DateTime dt = DateTime.newInstance(2016, 6, 1, 0, 0, 0);
    String dateString = dt.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.sssZ');

    Map<String, Object> searchParams = new Map<String, Object>{
      'title' => 'title'
      ,'contactEmail' => 'contactEmail'
      ,'status' => 'status'
      ,'severity' => 1
      ,'product' => fakeSiteId
      ,'createdDateFrom' => dateString
      ,'createdDateTo' => dateString
      ,'lastModifiedDateFrom' => dateString
      ,'lastModifiedDateTo' => dateString
    };

    // When
    Test.startTest();
    Case[] cases = CC_ngTurkeyController.fetchCasesByCriteria(searchParams);
    Test.stopTest();

    // Then
    System.assertEquals(3, cases.size(), cases);
    turkeySvcMock.callLogger.verify();
    CC_ngTurkeyService.CaseSearchCriteria criteria = (CC_ngTurkeyService.CaseSearchCriteria)turkeySvcMock.callLogger.getCall('fetchCasesByCriteria').params.get('criteria');
    System.assertEquals(null, criteria.caseNumber);
    System.assertEquals(searchParams.get('title'), criteria.title);
    System.assertEquals(searchParams.get('contactEmail'), criteria.contactEmail);
    System.assertEquals(searchParams.get('status'), criteria.status);
    System.assertEquals(String.valueOf(searchParams.get('severity')), criteria.severity);
    System.assertEquals(searchParams.get('product'), criteria.product);
    System.assertEquals(dt, criteria.createdDateFrom);
    System.assertEquals(dt, criteria.createdDateTo);
    System.assertEquals(dt, criteria.lastModifiedDateFrom);
    System.assertEquals(dt, criteria.lastModifiedDateTo);
  }

  @IsTest
  static void search_criteria_does_not_fuck_up_dates() {
    String inDate = '2016-07-24T06:00:00.000Z';
    CC_ngTurkeyService.CaseSearchCriteria scriteria = CC_ngTurkeyController.dataToSearchCriteria(new Map<String, Object>{
      'createdDateTo' => inDate
      });
    System.assertEquals('CreatedDate <= 2016-07-24T06:00:00.000+0000', scriteria.buildClauses()[0]);
  }

  @IsTest
  static void fetchCasesByCriteria_should_fetch_cases_by_criteria_case_number_only() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    turkeySvcMock.callLogger.recordCall(
      'fetchCasesByCriteria', 
      null, 
      new Case[] {
        buildCase(),
        buildCase(),
        buildCase()
        });
    Id fakeSiteId = CC_TestUtils.fakeId(Site_Association__c.SObjectType);
    Datetime now = DateTime.now();
    Map<String, Object> searchParams = new Map<String, Object>{
      'caseNumber' => 'caseNumber'
      ,'title' => 'title'
      ,'contactEmail' => 'contactEmail'
      ,'status' => 'status'
      ,'severity' => 'severity'
      ,'product' => fakeSiteId
      ,'createdDateFrom' => now
      ,'createdDateTo' => now
      ,'lastModifiedDateFrom' => now
      ,'lastModifiedDateTo' => now
    };

    // When
    Test.startTest();
    Case[] cases = CC_ngTurkeyController.fetchCasesByCriteria(searchParams);
    Test.stopTest();

    // Then
    System.assertEquals(3, cases.size(), cases);
    turkeySvcMock.callLogger.verify();
    CC_ngTurkeyService.CaseSearchCriteria criteria = (CC_ngTurkeyService.CaseSearchCriteria)turkeySvcMock.callLogger.getCall('fetchCasesByCriteria').params.get('criteria');
    System.assertEquals(searchParams.get('caseNumber'), criteria.caseNumber);
    System.assertEquals(null, criteria.title);
    System.assertEquals(null, criteria.contactEmail);
    System.assertEquals(null, criteria.status);
    System.assertEquals(null, criteria.severity);
    System.assertEquals(null, criteria.product);
    System.assertEquals(null, criteria.createdDateFrom);
    System.assertEquals(null, criteria.createdDateTo);
    System.assertEquals(null, criteria.lastModifiedDateFrom);
    System.assertEquals(null, criteria.lastModifiedDateTo);
  }

  @IsTest
  static void fetchCase_should_fetch_case_by_id_with_owner_details() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();

    Id fakeUserId = CC_TestUtils.fakeId(User.SObjectType);
    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);
    turkeySvcMock.callLogger.recordCall(
      'fetchCaseById', 
      new Map<String, Object>{'caseId' => fakeCaseId}, 
      new Case(Id = fakeCaseId, OwnerId = fakeUserId));
    turkeySvcMock.callLogger.recordCall(
      'fetchCaTechniciansForCases', 
      null, 
      new User[] {new User(Id = fakeUserId)});

    // When
    Test.startTest();
    Map<String, Object> jsonCase = CC_ngTurkeyController.fetchCase(fakeCaseId);
    Test.stopTest();

    // Then
    System.assert( jsonCase != null );
    System.assert( jsonCase.get('Id') == fakeCaseId );
    System.assert( jsonCase.get('OwnerId') == fakeUserId );
    System.assert( jsonCase.containsKey('Owner') );
    System.assert( ((Map<String, Object>)jsonCase.get('Owner')).get('Id') == fakeUserId );

    Case[] casesParam = (Case[])turkeySvcMock.callLogger.getCall('fetchCaTechniciansForCases').params.get('cases');
    System.assertEquals(fakeUserId, casesParam[0].OwnerId);
    turkeySvcMock.callLogger.verify();
  }

  @IsTest
  static void findSupportArticles_should_fetch_support_articles() {
    // Given
    CC_SearchItServiceMock searchItMock = buildSearchItMock();
    String title = 'title';
    Id productId = CC_TestUtils.fakeId(CA_Product_Controller__c.SObjectType);
    CC_SearchItService.SearchItResults searchItResults = new CC_SearchItService.SearchItResults(null, null, null);
    searchItMock.callLogger.recordCall(
      'doSearch',
      new Map<String, Object>{ 'title' => title, 'productId' => productId },
      searchItResults
      );
    Map<String, String> data = new Map<String, String>{
      'title' => title,
      'productId' => productId
    };

    // When
    CC_SearchItService.SearchItResults results = CC_ngTurkeyController.findSupportArticles(data);

    // Then
    searchItMock.callLogger.verify();
    System.assertEquals(searchItResults, results);
  }

  @IsTest
  static void createCase_should_create_clean_case() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    Case aCase = buildCase();

    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);
    Case returnCase = aCase.clone();
    returnCase.Id = fakeCaseId;
    turkeySvcMock.callLogger.recordCall('createCase', null, returnCase);
    turkeySvcMock.callLogger.recordCall('addCaseComment', null, new CaseComment());

    User currentUser = new User(Contact = new Contact(Id = CC_TestUtils.fakeId(Contact.SObjectType)));
    CC_ngTurkeyController.currentUser = currentUser;

    // When
    Map<String, Object> caseData = new Map<String, Object>{
      'businessImpact' => aCase.Business_Impact__c
      ,'description' => aCase.Description
      ,'severity' => aCase.Severity__c
      ,'title' => aCase.Subject
      ,'siteId' => aCase.Site_Association__c
      ,'productId' => aCase.CA_Product_Controller__c
      ,'productName' => 'My Product'
      ,'release' => 'N/A'
      ,'servicePack' => 'N/A'
      ,'operatingSystem' => 'N/A'
    };
    Test.startTest();
    Id result = CC_ngTurkeyController.createCase(caseData);
    Test.stopTest();

    // Then
    turkeySvcMock.callLogger.verify();
    Case caseParam = (Case)turkeySvcMock.callLogger.getCall('createCase').params.get('aCase');
    System.assertEquals(aCase.Business_Impact__c, caseParam.Business_Impact__c);
    System.assertEquals(aCase.Description, caseParam.Description);
    System.assertEquals(aCase.Severity__c, caseParam.Severity__c);
    System.assertEquals(aCase.Subject, caseParam.Subject);
    System.assertEquals(aCase.Site_Association__c, caseParam.Site_Association__c);
    System.assertEquals(aCase.CA_Product_Controller__c, caseParam.CA_Product_Controller__c);
    System.assertEquals(currentUser.Contact.Id, caseParam.ContactId);
    System.assertEquals(null, caseParam.Id);

    CaseComment caseCommentParam = (CaseComment)turkeySvcMock.callLogger.getCall('addCaseComment').params.get('caseComment');
    System.assertEquals(null, caseCommentParam.Id);
    System.assertEquals('Product: My Product, Release: N/A, Service Pack: N/A, Operating System: N/A', caseCommentParam.CommentBody);
  }

  @IsTest
  static void createCase_should_throw_community_exception_on_error() {
    CC_ngTurkeyController.CommunityException caught;
    try {
      CC_ngTurkeyController.createCase(null);
      } catch (CC_ngTurkeyController.CommunityException cex) {
        caught = cex;
      }
      System.assertNotEquals(null, caught);
    }

    @IsTest
    static void createCaseComment_should_create_case_comment() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);
    CaseComment comment = new CaseComment(ParentId = fakeCaseId, CommentBody = 'Comment');
    CaseComment commentClone = comment.clone();
    commentClone.Id = CC_TestUtils.fakeId(CaseComment.SObjectType);
    turkeySvcMock.callLogger.recordCall('addCaseComment', new Map<String, Object> {'caseComment' => comment}, commentClone);

    Map<String, String> commentData = new Map<String, String>{
      'caseId' => (String)fakeCaseId,
      'comment' => 'Comment'
    };
    // When
    Test.startTest();
    CaseComment result = CC_ngTurkeyController.createCaseComment(commentData);
    Test.stopTest();

    // Then
    turkeySvcMock.callLogger.verify();
    System.assertEquals(commentClone.Id, result.Id);
  }

  @IsTest
  static void closeCase_should_close_case() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);
    String commentBody = 'commentBody';
    turkeySvcMock.callLogger.recordCall('closeCase', new Map<String, Object> {'caseId' => fakeCaseId, 'commentBody' => commentBody}, null);

    // When
    Test.startTest();
    CC_ngTurkeyController.closeCase(new Map<String, String> {'caseId' => fakeCaseId, 'comment' => commentBody});
    Test.stopTest();

    // Then
    turkeySvcMock.callLogger.verify();
  }

  @IsTest
  static void reopenCase_should_reopen_case() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);
    String commentBody = 'commentBody';
    turkeySvcMock.callLogger.recordCall('reopenCase', new Map<String, Object> {'caseId' => fakeCaseId, 'commentBody' => commentBody}, null);

    // When
    Test.startTest();
    CC_ngTurkeyController.reopenCase(new Map<String, String> {'caseId' => fakeCaseId, 'comment' => commentBody});
    Test.stopTest();

    // Then
    turkeySvcMock.callLogger.verify();
  }

  @IsTest
  static void changeSeverity_should_change_severity() {
    // Given
    CC_ngTurkeyServiceMock turkeySvcMock = buildTurkeyMock();
    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);
    String severity = '2';
    String commentBody = 'commentBody';
    turkeySvcMock.callLogger.recordCall('changeSeverity', new Map<String, Object> {'caseId' => fakeCaseId, 'newSeverity' => severity, 'commentBody' => commentBody}, null);

    // When
    Test.startTest();
    CC_ngTurkeyController.changeSeverity(new Map<String, String> {'caseId' => fakeCaseId, 'newSeverity' => severity, 'comment' => commentBody});
    Test.stopTest();

    // Then
    turkeySvcMock.callLogger.verify();
  }

  @IsTest
  static void it_should_redirect_to_cso_page_if_role_not_allowed(){
    CC_TestUtils.enableUserDml();
    User u = CC_TestUtils.buildUser();
    insert u;
    CC_Settings.allowAccessRoles = new Set<String>{'role 2', 'another role'};
    CC_ngTurkeyController controller = new CC_ngTurkeyController();
    System.runAs(u){
      PageReference expected = Page.CC_RedirectToCSO;
      PageReference reference = controller.redirect();
      System.assertEquals(expected.getUrl() ,reference.getUrl());
    }
  }

  @IsTest
  static void it_should_go_to_turkey_page_if_role_is_allowed(){
    CC_TestUtils.enableUserDml();
    User u = CC_TestUtils.buildUser();
    insert u;
    CC_Settings.allowAccessRoles = new Set<String>{'sc_test', 'another role'};
    CC_ngTurkeyController controller = new CC_ngTurkeyController();
    System.runAs(u){
      CC_ngTurkeyController.currentUser = null;
      PageReference reference = controller.redirect();
      System.assertEquals(null,reference);
    }
  }

  @IsTest
  static void redirect_should_handle_null_roles(){
    CC_ngTurkeyController controller = new CC_ngTurkeyController();
    CC_ngTurkeyController.currentUser = new User();
    PageReference reference = controller.redirect();
    PageReference expected = Page.CC_RedirectToCSO;
    System.assertEquals(expected.getUrl() ,reference.getUrl());
  }

  private static void mockFetchCase(CC_ngTurkeyServiceMock turkeySvcMock, Id fakeCaseId) {
    Id fakeUserId = CC_TestUtils.fakeId(User.SObjectType);
    turkeySvcMock.callLogger.recordCall(
      'fetchCaseById', 
      new Map<String, Object>{'caseId' => fakeCaseId}, 
      new Case(Id = fakeCaseId, OwnerId = fakeUserId));
    turkeySvcMock.callLogger.recordCall(
      'fetchCaTechniciansForCases', 
      null, 
      new User[] {new User(Id = fakeUserId)});
  }

  private static Case buildCase() {
    return new Case(
      Id = CC_TestUtils.fakeId(Case.SObjectType),
      Business_Impact__c = 'Business_Impact__c',
      Description = 'Description',
      Severity__c = '3',
      Subject = 'Subject',
      Site_Association__c = CC_TestUtils.fakeId(Site_Association__c.SObjectType),
      CA_Product_Controller__c = CC_TestUtils.fakeId(CA_Product_Controller__c.SObjectType),
      Title__c = 'Title__c'
      );
  }

  private static CC_ngTurkeyServiceMock buildTurkeyMock() {
    CC_ngTurkeyServiceMock turkeySvcMock = new CC_ngTurkeyServiceMock();
    CC_ngTurkeyController.turkeySvc = turkeySvcMock;
    return turkeySvcMock;
  }

  private static CC_SearchItServiceMock buildSearchItMock() {
    CC_SearchItServiceMock mock = new CC_SearchItServiceMock();
    CC_ngTurkeyController.searchItSvc = mock;
    return mock;
  }
}