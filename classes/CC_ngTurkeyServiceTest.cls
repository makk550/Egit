@IsTest
public class CC_ngTurkeyServiceTest {

  @IsTest
  static void fetchMyCases_should_fetch_my_cases() {
    // Given
    setupCases();
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Contact myContact = setupContact;

    // When
    Case[] cases;
    Test.startTest();
    System.runAs(communityUser()) {
      cases = svc.fetchMyCases();
    }
    Test.stopTest();

    // Then
    System.assertEquals(1, cases.size(), cases);
    for (Case aCase : cases) {
      System.assertEquals(myContact.Id, aCase.Contact.Id);
      assertCaseFields(aCase, false);
    }
  }

  @IsTest
  static void fetchCasesByCriteria_should_fetch_all_cases_by_criteria() {
    // Given
    setupCases();
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Id siteId = CC_TestUtils.testSite.Id;
    CC_ngTurkeyService.CaseSearchCriteria criteria = new CC_ngTurkeyService.CaseSearchCriteria();
    Case[] casesToFind = [SELECT Id, Subject FROM Case WHERE Site_Association__c = :siteId];
    String subject = casesToFind[0].Subject;
    criteria.title = subject;

    // When
    Case[] cases;
    Test.startTest();
    System.runAs(communityUser()) {
      cases = svc.fetchCasesByCriteria(criteria);
    }
    Test.stopTest();

    // Then
    System.assertEquals(2, cases.size(), cases);
    for (Case aCase : cases) {
      System.assertEquals(siteId, aCase.Site_Association__c);
      System.assertEquals(subject, aCase.Subject);
      assertCaseFields(aCase, false);
    }
  }

  @IsTest
  static void CasesData_fetchCasesByCriteriaFlyweight_should_not_fetch_cases_outside_of_site_id_range() {
    // Given
    setupCases();
    CC_ngTurkeyService.CasesData casesDal = new CC_ngTurkeyService.CasesData();
    CC_ngTurkeyService.CaseSearchCriteria criteria = new CC_ngTurkeyService.CaseSearchCriteria();

    // When
    Case[] cases;
    Test.startTest();
    System.runAs(communityUser()) {
      cases = casesDal.fetchCasesByCriteriaFlyweight(null, criteria);
    }
    Test.stopTest();

    // Then
    System.assertEquals(0, cases.size(), cases);
  }

  @IsTest
  static void fetchCaseById_should_fetch_case_by_id() {
    // Given
    Case aCase = setupCase();
    setupCaseComment(aCase.Id);
    CC_ngTurkeyService.I svc = buildTurkeySvc();

    // When
    Case myCase;
    Test.startTest();
    System.runAs(communityUser()) {
      myCase = svc.fetchCaseById(aCase.Id);
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, myCase);
    assertCaseFields(myCase, true);
  }

  @IsTest
  static void fetchCaseById_should_throw_error_if_contact_has_no_access_to_site() {
    // Given
    Case aCase = setupCase();
    Test.startTest();
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Site_Association__c site1 = CC_TestUtils.buildNewSite('45678');
    System.runAs(informaticaUser()) {
      insert site1;
    }
    Case anotherCase = CC_TestUtils.buildCase(aCase.ContactId, 'Open');
    anotherCase.Site_Association__c = site1.Id;
    System.runAs(informaticaUser()) {
      insert anotherCase;
    }

    // When
    Exception caught;
    
    try {
      System.runAs(communityUser()) {
        svc.fetchCaseById(anotherCase.Id);
      }
    } catch (Exception ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
  }

  @IsTest
  static void fetchCaseById_should_fetch_public_case_comments() {
    // Given
    Case aCase = setupCase();
    setupCaseComment(aCase.Id);
    Test.startTest();
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    CaseComment privateComment = new CaseComment(ParentId = aCase.Id, CommentBody = 'PrivateComment', IsPublished = false);
    insert privateComment;

    System.assertEquals(2, [SELECT Id FROM CaseComment WHERE ParentId = :aCase.Id].size());

    // When
    Case myCase;
    System.runAs(communityUser()) {
      myCase = svc.fetchCaseById(aCase.Id);
    }
    Test.stopTest();

    // Then
    System.assertEquals(1, myCase.CaseComments.size());
    System.assertNotEquals(privateComment.Id, myCase.CaseComments[0].Id);
  }

  @IsTest
  static void fetchCaseById_should_fetch_known_tasks() {
    // Given
    Case aCase = setupCase();
    Test.startTest();
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Task unknownTask = new Task(WhatId = aCase.Id, Type = 'Unknown');
    insert unknownTask;

    Task[] initialTasks = [SELECT Id, Type FROM Task WHERE WhatId = :aCase.Id];
    System.assertEquals(2, initialTasks.size(), initialTasks);

    // When
    Case myCase;
    System.runAs(communityUser()) {
      myCase = svc.fetchCaseById(aCase.Id);
    }
    Test.stopTest();

    // Then
    System.assertEquals(1, myCase.Tasks.size());
    System.assertNotEquals(unknownTask.Id, myCase.Tasks[0].Id);
  }

  @IsTest
  static void fetchCaseById_should_throw_error_when_id_is_not_found() {
    // Given
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Id fakeCaseId = CC_TestUtils.fakeId(Case.SObjectType);

    // When
    Exception caught;
    Test.startTest();
    try {
      System.runAs(communityUser()) {
        svc.fetchCaseById(fakeCaseId);
      }
    } catch (Exception ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
  }

  @IsTest
  static void fetchCaTechniciansForCases_should_fetch_case_owners_for_cases() {
    // Given
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    User me = [SELECT Id, Name, Phone, Email, Preferred_Contact_Method__c FROM User WHERE Id = :UserInfo.getUserId()];
    Case aCase = new Case(OwnerId = UserInfo.getUserId());

    // When
    User[] caTechs;
    Test.startTest();
    System.runAs(communityUser()) {
      caTechs = svc.fetchCaTechniciansForCases(new Case[]{aCase});
    }
    Test.stopTest();

    // Then
    System.assertEquals(1, caTechs.size());
    System.assertEquals(me.Id, caTechs[0].Id);
    System.assertEquals(me.Name, caTechs[0].Name);
    System.assertEquals(me.Phone, caTechs[0].Phone);
    System.assertEquals(me.Email, caTechs[0].Email);
    System.assertEquals(me.Preferred_Contact_Method__c, caTechs[0].Preferred_Contact_Method__c);
  }

  @isTest
  static void fetchSitesAndProducts_should_fetch_sites_and_products() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();
    CC_TestUtils.setupTestDataToInsertCase();
    Site_Association__c site = CC_TestUtils.testSite;
    Site_Association__c anotherSite = CC_TestUtils.buildNewSite('1234');
    insert anotherSite;
    CA_Product_Controller__c product = CC_TestUtils.testProduct;
    CA_Product_Controller__c gscProduct = CC_TestUtils.createProduct('GLOBAL SERVICE CENTER');

    String siteId = '12345';
    String connectId = 'connectId';
    CC_Layer7ServiceMock l7Mock = buildLayer7Mock(svc);
    l7Mock.callLogger.recordCall(
      'getSitesAndProducts', 
      new Map<String, Object>{'siteId' => siteId, 'connectId' => connectId}, 
      buildJsonData(site.SC_TOPS_ID__c, product.Name, '12345,1234')
    );
  
    // When
    Test.startTest();
    CC_ngTurkeyService.SiteProductAssociation[] spas = svc.fetchSitesAndProducts(siteId, connectId);
    Test.stopTest();
  
    // Then
    l7Mock.callLogger.verify();
    System.assertEquals(2, spas.size());
    // l7 product/site
    System.assertEquals(site.Id, spas[0].site.Id);
    System.assertEquals(site.Name + ' - ' + site.SC_TOPS_ID__c, spas[0].site.Name);
    System.assertEquals(product.Id, spas[0].product.Id);
    System.assertEquals(product.Name, spas[0].product.Name);

    // Global Service Center product/site
    System.assertEquals(site.Id, spas[1].site.Id);
    System.assertEquals(site.Name + ' - ' + site.SC_TOPS_ID__c, spas[1].site.Name);
    System.assertEquals(gscProduct.Id, spas[1].product.Id);
    System.assertEquals(gscProduct.Name, spas[1].product.Name);

    // contact site associations
    Contacts_Site_Association__c[] csas = [SELECT SC_CSA_CONTACTS__c, SC_CSA_SITE__c, SC_CSA_ACTIVE_ON_SITE__c FROM Contacts_Site_Association__c];
    System.assertEquals(2, csas.size());

    Set<Id> csaSfSiteIds = new Set<Id>();
    for (Contacts_Site_Association__c csa : csas) {
      System.assertEquals(svc.contactId, csa.SC_CSA_CONTACTS__c);
      csaSfSiteIds.add(csa.SC_CSA_SITE__c);
      System.assertEquals(true, csa.SC_CSA_ACTIVE_ON_SITE__c);
    }
    System.assert(csaSfSiteIds.contains(site.Id));
    System.assert(csaSfSiteIds.contains(anotherSite.Id));
  }

  static CC_Layer7Service.JsonData buildJsonData(String topsSiteId, String productName, String fullSiteIds) {
    CC_Layer7Service.JsonData jsonData = new CC_Layer7Service.JsonData();
    jsonData.sites_and_products = new CC_Layer7Service.JsonSiteProduct[] {
      new CC_Layer7Service.JsonSiteProduct(topsSiteId, productName)
    };
    jsonData.sites = new CC_Layer7Service.JsonSites(fullSiteIds);
    return jsonData;
  }

  @IsTest
  static void updateContactSiteAssociations_should_update_contact_site_associations() {
    // Given
    Test.startTest();
    CC_ngTurkeyService svc = buildTurkeySvc();
    Contact c = setupContact;
    Site_Association__c siteToAdd = CC_TestUtils.buildNewSite('34567');
    Site_Association__c siteToDeactivate = CC_TestUtils.buildNewSite('23456');
    Site_Association__c siteToLeaveAlone = CC_TestUtils.buildNewSite('12345');
    System.runAs(informaticaUser()) {
      insert new Site_Association__c[] {
        siteToLeaveAlone,
        siteToAdd,
        siteToDeactivate
      };
      insert new Contacts_Site_Association__c[]{
        new Contacts_Site_Association__c(SC_CSA_CONTACTS__c = c.Id, SC_CSA_SITE__c = siteToLeaveAlone.Id, SC_CSA_ACTIVE_ON_SITE__c = true),
        new Contacts_Site_Association__c(SC_CSA_CONTACTS__c = c.Id, SC_CSA_SITE__c = siteToDeactivate.Id, SC_CSA_ACTIVE_ON_SITE__c = true)
      };
    }

    // When
    System.runAs(communityUser()) {
      svc.updateContactSiteAssociations(c.Id, new Set<Id>{siteToAdd.Id, siteToLeaveAlone.Id});
    }
    Test.stopTest();

    // Then
    Contacts_Site_Association__c[] csas = [SELECT SC_CSA_CONTACTS__c, SC_CSA_SITE__c, SC_CSA_ACTIVE_ON_SITE__c FROM Contacts_Site_Association__c WHERE SC_CSA_CONTACTS__c = :c.Id];
    System.assertEquals(3, csas.size());
    Map<Id, Contacts_Site_Association__c> csasBySiteId = new Map<Id, Contacts_Site_Association__c>();
    for (Contacts_Site_Association__c csa : csas) {
      csasBySiteId.put(csa.SC_CSA_SITE__c, csa);
    }
    System.assertEquals(true, csasBySiteId.get(siteToAdd.Id).SC_CSA_ACTIVE_ON_SITE__c);
    System.assertEquals(true, csasBySiteId.get(siteToLeaveAlone.Id).SC_CSA_ACTIVE_ON_SITE__c);
    System.assertNotEquals(true, csasBySiteId.get(siteToDeactivate.Id).SC_CSA_ACTIVE_ON_SITE__c);
  }

  @IsTest
  static void fetchSiteAssociationsByTopsSiteIds_should_fetch_site_associations() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();
    Site_Association__c site1 = CC_TestUtils.buildNewSite('45678');
    Site_Association__c site2 = CC_TestUtils.buildNewSite('23456');
    Site_Association__c site3 = CC_TestUtils.buildNewSite('34567');
    System.runAs(informaticaUser()) {
      insert new Site_Association__c[] {
        site1,
        site3,
        site2
      };
    }

    // When
    Map<String, Site_Association__c> results;
    Test.startTest();
    Set<String> topsSiteIds = new Set<String>{site1.SC_TOPS_ID__c, site2.SC_TOPS_ID__c, site3.SC_TOPS_ID__c};
    System.runAs(communityUser()) {
      results = svc.fetchSiteAssociationsByTopsSiteIds(topsSiteIds);
    }
    Test.stopTest();

    // Then
    System.assertEquals(3, results.size());
    System.assert(results.containsKey(site1.SC_TOPS_ID__c));
    System.assert(results.containsKey(site2.SC_TOPS_ID__c));
    System.assert(results.containsKey(site3.SC_TOPS_ID__c));
  }

  @IsTest
  static void fetchCaProductControllersByProductNames_should_fetch_ca_product_controllers() {
    // Given
    CC_TestUtils.setupTestDataToInsertCase();
    CC_ngTurkeyService svc = buildTurkeySvc();
    CA_Product_Controller__c validProduct = CC_TestUtils.testProduct;
    CA_Product_Controller__c invalidProduct = new CA_Product_Controller__c(Name='Bad Product');
    insert new CA_Product_Controller__c[] {invalidProduct};

    // When
    Map<String, CA_Product_Controller__c> results;
    Test.startTest();
    Set<String> productNames = new Set<String>{validProduct.Name, invalidProduct.Name, 'FakeProductName'};
    System.runAs(communityUser()) {
      results = svc.fetchCaProductControllersByProductNames(productNames);
    }
    Test.stopTest();

    // Then
    System.assertEquals(1, results.size());
    System.assert(results.containsKey(validProduct.Name));
  }

  @IsTest
  static void createCase_should_create_new_case() {
    // Given
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Contact myContact = setupContact;
    CC_TestUtils.setupTestDataToInsertCase();
    setupContactSiteAssociation();
    Case myCase = new Case(
      Business_Impact__c = 'Business Impact'
      ,ContactId = myContact.Id
      ,Description = 'Description'
      ,Severity__c = '3'
      ,Subject = 'Title'
      ,Site_Association__c = CC_TestUtils.testSite.Id
      ,CA_Product_Controller__c = CC_TestUtils.testProduct.Id
    );

    // When
    Test.startTest();
    Case result;
    System.runAs(communityUser()) {
      result = svc.createCase(myCase);
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, result.Id);
    System.assertEquals('Community', result.Origin);
    System.assertEquals('Standard', result.Case_Type__c);
  }

  @IsTest
  static void createCase_should_throw_error_if_contact_has_no_access_to_site() {
    // Given
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Contact myContact = setupContact;
    CC_TestUtils.setupTestDataToInsertCase();
    Case myCase = CC_TestUtils.buildCase(myContact.Id, 'Open');
    Site_Association__c site1 = CC_TestUtils.buildNewSite('45678');
    System.runAs(informaticaUser()) {
      insert site1;
    }
    myCase.Site_Association__c = site1.Id;

    // When
    Test.startTest();
    Exception caught;
    try {
      System.runAs(communityUser()) {
        svc.createCase(myCase);
      }
    } catch (Exception ex) {
      caught = ex;
    } 
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
  }

  @IsTest
  static void createCase_should_validate_case_required_fields_on_create() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();

    // When
    Test.startTest();
    CC_ngTurkeyService.ValidationException caught;
    try {
      System.runAs(communityUser()) {
        svc.createCase(new Case());
      }
    } catch (CC_ngTurkeyService.ValidationException ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
    Set<String> missingFields = new Set<String>();
    for (String error :caught.errors) {
      if (error.startsWith('Missing required fields: ')) {
        missingFields = new Set<String>(error.substringAfter(': ').split(', '));
      }
    }
    for (String field : svc.caseRequiredFields) {
      System.assert( missingFields.contains(field) );
    }
  }

  @IsTest
  static void createCase_should_validate_case_severity_on_create() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();

    // When
    Test.startTest();
    CC_ngTurkeyService.ValidationException caught;
    try {
      System.runAs(communityUser()) {
        svc.createCase(new Case(Severity__c = 'bad'));
      }
    } catch (CC_ngTurkeyService.ValidationException ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
    Set<String> errors = new Set<String>(caught.errors);
    System.assert( errors.contains('Severity "bad" is invalid') );
  }

  @IsTest
  static void createCase_should_validate_case_severity_1_on_create() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();

    // When
    Test.startTest();
    CC_ngTurkeyService.ValidationException caught;
    try {
      System.runAs(communityUser()) {
        svc.createCase(new Case(Severity__c = '1'));
      }
    } catch (CC_ngTurkeyService.ValidationException ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
    Set<String> errors = new Set<String>(caught.errors);
    System.assert( errors.contains('Cannot create a case with severity "1"') );
  }

  @IsTest
  static void addCaseComment_should_add_a_case_comment(){
    //Given
    Case aCase = setupCase();
    CaseComment aCaseComment = new CaseComment(ParentId = aCase.Id, CommentBody = 'Body');
    CC_ngTurkeyService.I svc = buildTurkeySvc();

    //When
    CaseComment result;
    Test.startTest();
    System.runAs(communityUser()) {
      result = svc.addCaseComment(aCaseComment);
    }
    Test.stopTest();

    //Then
    System.assertNotEquals(null, result.Id);
    System.assertNotEquals(null, result.ParentId);
    System.assertNotEquals(null, result.CommentBody);
    System.assertNotEquals(null, result.CreatedDate);
    //System.assertNotEquals(null, result.CreatedBy.Name, result);
    //System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :aCase.Id AND Subject = 'Case Update'].size());
  }

  @IsTest
  static void addCaseComment_should_throw_error_if_contact_has_no_access_to_site(){
    //Given
    Test.startTest();
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Contact myContact = setupContact;
    Site_Association__c site1 = CC_TestUtils.buildNewSite('45678');
    System.runAs(informaticaUser()) {
      insert site1;
    }
    CC_TestUtils.setupTestDataToInsertCase();
    Case anotherCase = CC_TestUtils.buildCase(myContact.Id, 'Open');
    anotherCase.Site_Association__c = site1.Id;
    System.runAs(informaticaUser()) {
      insert anotherCase;
    }
    CaseComment aCaseComment = new CaseComment(ParentId = anotherCase.Id, CommentBody = 'Body');

    //When
    Exception caught;
    try {
      System.runAs(communityUser()) {
        svc.addCaseComment(aCaseComment);
      }
    } catch (Exception ex) {
      caught = ex;
    }
    Test.stopTest();

    //Then
    System.assertNotEquals(null, caught);
  }

  @IsTest
  static void addCaseComment_should_fail_if_comment_has_no_body(){
    //Given
    Case aCase = setupCase();
    CaseComment aCaseComment = new CaseComment(ParentId = aCase.Id);
    CC_ngTurkeyService.I svc = buildTurkeySvc();

    //When
    Test.startTest();
    CC_ngTurkeyService.ValidationException caught;
    try {
      System.runAs(communityUser()) {
        svc.addCaseComment(aCaseComment);
      }
    } catch (CC_ngTurkeyService.ValidationException ex) {
      caught = ex;
    }
    Test.stopTest();

    //Then
    System.assertNotEquals(null, caught);
    Set<String> errors = new Set<String>(caught.errors);
    System.assert( errors.contains('Missing required fields: CommentBody') );
  }

  @IsTest
  static void closeCase_should_request_case_close(){
    //Given
    Case aCase = setupCase();
    CC_ngTurkeyService.I svc = buildTurkeySvc();

    //When
    Test.startTest();
    System.runAs(communityUser()) {
      System.runAs(communityUser()) {
        svc.closeCase(aCase.Id, 'Close Me');
      }
    }
    Test.stopTest();

    //Then
    System.assertEquals(1, [SELECT Id FROM CaseComment WHERE ParentId = :aCase.Id AND CommentBody LIKE 'Request Case Close:%'].size());
  }

  @IsTest
  static void changeSeverity_should_change_severity() {
    // Given
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Case aCase = setupCase();
    String severity = '2';
    String commentBody = 'Imma comment';
    System.assertNotEquals(severity, aCase.Severity__c);

    // When
    Test.startTest();
    System.runAs(communityUser()) {
      svc.changeSeverity(aCase.Id, severity, commentBody);
    }
    Test.stopTest();

    // Then
    Case result = [SELECT Severity__c FROM Case WHERE ID = :aCase.Id];
    System.assertEquals(severity, result.Severity__c);

    String sevComment = 'User Changed Severity from ' + aCase.Severity__c + ' to ' + severity + '%';
    CaseComment[] comments = [SELECT CommentBody FROM CaseComment WHERE ParentId = :aCase.Id AND CommentBody LIKE :sevComment];
    System.assertEquals(1, comments.size());
  }

  @IsTest
  static void changeSeverity_should_validate_case_severity_on_update() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();
    Id caseId = setupCase().Id;
    String severity = 'bad';
    String commentBody = 'Imma comment';

    // When
    Test.startTest();
    CC_ngTurkeyService.ValidationException caught;
    try {
      System.runAs(communityUser()) {
        svc.changeSeverity(caseId, severity, commentBody);
      }
    } catch (CC_ngTurkeyService.ValidationException ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
    Set<String> errors = new Set<String>(caught.errors);
    System.assert( errors.contains('Severity "bad" is invalid') );
  }

  @IsTest
  static void changeSeverity_should_validate_case_severity_1_on_update() {
    // Given
    CC_ngTurkeyService svc = buildTurkeySvc();
    Id caseId = setupCase().Id;
    String severity = '1';
    String commentBody = 'Imma comment';

    // When
    Test.startTest();
    CC_ngTurkeyService.ValidationException caught;
    try {
      System.runAs(communityUser()) {
        svc.changeSeverity(caseId, severity, commentBody);
      }
    } catch (CC_ngTurkeyService.ValidationException ex) {
      caught = ex;
    }
    Test.stopTest();

    // Then
    System.assertNotEquals(null, caught);
    Set<String> errors = new Set<String>(caught.errors);
    System.assert( errors.contains('Cannot change case severity to "1"') );
  }

  @IsTest
  static void reopenCase_should_reopen_case() {
    // Given
    CC_ngTurkeyService.I svc = buildTurkeySvc();
    Case aCase = setupCase();
    String commentBody = 'Body';

    // When
    Test.startTest();
    System.runAs(communityUser()) {
      svc.reopenCase(aCase.Id, commentBody);
    }
    Test.stopTest();

    // Then
    Case result = [SELECT Reason_for_Reopen__c, Troubleshooting_Stage__c FROM Case WHERE ID = :aCase.Id];
    System.assertEquals('Case Reopen Requested', result.Reason_for_Reopen__c);
    System.assertEquals('1. Problem Identification', result.Troubleshooting_Stage__c);

    CaseComment[] comments = [SELECT CommentBody FROM CaseComment WHERE ParentId = :aCase.Id AND CommentBody LIKE 'Request Case Reopen:%'];
    System.assertEquals(1, comments.size());
  }

  @isTest
  static void CaseSearchCriteria_should_build_clauses() {
    // Given
    CC_ngTurkeyService.CaseSearchCriteria criteria = new CC_ngTurkeyService.CaseSearchCriteria();
    criteria.caseNumber = 'caseNumber';
    criteria.title = 'title';
    criteria.contactEmail = 'contactEmail';
    criteria.status = 'status';
    criteria.severity = 'severity';
    criteria.product = CC_TestUtils.fakeId(Site_Association__c.SObjectType);
    DateTime now = DateTime.now();
    criteria.createdDateFrom = now;
    criteria.createdDateTo = now;
    criteria.lastModifiedDateFrom = now;
    criteria.lastModifiedDateTo = now;
    criteria.contactId = CC_TestUtils.fakeId(Contact.SObjectType);
  
    // When
    Test.startTest();
    Set<String> clauses = new Set<String>(criteria.buildClauses());
    Test.stopTest();
  
    // Then
    System.assert(clauses.contains('CaseNumber LIKE \'%' + criteria.caseNumber + '%\''));
    System.assert(clauses.contains('Subject LIKE \'%' + criteria.title + '%\''));
    System.assert(clauses.contains('Contact.Email LIKE \'%' + criteria.contactEmail + '%\''));
    System.assert(clauses.contains('Status = \'' + criteria.status + '\''));
    System.assert(clauses.contains('Severity__c = \'' + criteria.severity + '\''));
    System.assert(clauses.contains('CA_Product_Controller__c = \'' + criteria.product + '\''));
    String nowStr = now.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.sssZ');
    System.assert(clauses.contains('CreatedDate >= ' + nowStr), clauses);
    System.assert(clauses.contains('CreatedDate <= ' + nowStr));
    System.assert(clauses.contains('LastModifiedDate >= ' + nowStr));
    System.assert(clauses.contains('LastModifiedDate <= ' + nowStr));
    System.assert(clauses.contains('ContactId = \'' + criteria.contactId + '\''));
  }

  @isTest
  static void CaseSearchCriteria_should_build_clauses_empty() {
    // Given
    CC_ngTurkeyService.CaseSearchCriteria criteria = new CC_ngTurkeyService.CaseSearchCriteria();
  
    // When
    Test.startTest();
    Set<String> clauses = new Set<String>(criteria.buildClauses());
    Test.stopTest();
  
    // Then
    System.assertEquals(0, clauses.size());
  }

  static void setupCases() {
    Account acct = setupAccount;
    Contact myContact = setupContact;
    Contact anotherContact = myContact.clone();
    anotherContact.Id = null;
    anotherContact.Email += '.notme';
    anotherContact.SC_CONTACT_LDAPID__c = '23456';
    insert anotherContact;

    CC_TestUtils.setupTestDataToInsertCase();

    Case[] cases = new Case[] {
      CC_TestUtils.buildCase(myContact.Id, 'Open')
      ,CC_TestUtils.buildCase(anotherContact.Id, 'Open')
    };
    insert cases;
    setupContactSiteAssociation();
  }

  static Case setupCase() {
    CC_TestUtils.setupTestDataToInsertCase();
    Contact myContact = setupContact;
    Case aCase = CC_TestUtils.buildCase(myContact.Id, 'Open');
    insert aCase;
    setupContactSiteAssociation();
    return aCase;
  }

  static void setupCaseComment(Id caseId) {
    insert new CaseComment(ParentId = caseId, IsPublished = true);
  }

  static void setupContactSiteAssociation() {
    System.runAs(informaticaUser()) {
      insert new Contacts_Site_Association__c(SC_CSA_CONTACTS__c = setupContact.Id, SC_CSA_SITE__c = CC_TestUtils.testSite.Id, SC_CSA_ACTIVE_ON_SITE__c = true);
    }
  }

  static Account setupAccount {
    get {
      if (setupAccount == null) {
        setupAccount = CC_TestUtils.buildAccount('MuhCount');
        insert setupAccount;
      }
      return setupAccount;
    }
    set;
  }

  static Contact setupContact {
    get {
      if (setupContact == null) {
        Account acct = setupAccount;
        setupContact = new Contact(LastName = 'Jones', Email = UserInfo.getUserEmail(), AccountId = acct.Id, SC_CONTACT_LDAPID__c = '12345');
        insert setupContact;
      }
      return setupContact;
    }
    set;
  }

  private static CC_ngTurkeyService buildTurkeySvc() {
    Contact myContact = setupContact;
    return new CC_ngTurkeyService(myContact.Id);
  }

  private static CC_Layer7ServiceMock buildLayer7Mock(CC_ngTurkeyService svc) {
    CC_Layer7ServiceMock l7Mock = new CC_Layer7ServiceMock();
    svc.l7Svc = l7Mock;
    return l7Mock;
  }

  private static User communityUser() {
    return [SELECT Id FROM User WHERE ProfileId = :CC_Settings.communityUserProfileId AND IsActive = true AND Case_Validation_Bypass__c = false LIMIT 1];
  }

  private static User informaticaUser() {
    String[] informaticaUsers = Label.Informatica_userid.split(',');
    return [SELECT ID FROM User WHERE ID in :informaticaUsers and isactive = true LIMIT 1];
  }

  private static void assertCaseFields(Case aCase, Boolean allFields) {
    System.assertNotEquals(null, aCase.Id);
    System.assertNotEquals(null, aCase.Business_Impact__c, aCase);
    System.assertNotEquals(null, aCase.CaseNumber);
    System.assertNotEquals(null, aCase.ContactId);
    System.assertNotEquals(null, aCase.CreatedDate);
    if (aCase.ClosedDate == null) {
      System.assertEquals(null, aCase.ClosedDate);
    }
    System.assertNotEquals(null, aCase.Description);
    System.assertNotEquals(null, aCase.LastModifiedDate);
    System.assertNotEquals(null, aCase.OwnerId);
    System.assertNotEquals(null, aCase.Severity__c);
    System.assertNotEquals(null, aCase.Status);
    System.assertNotEquals(null, aCase.Subject);
    System.assertNotEquals(null, aCase.Next_Action__c);
    System.assertNotEquals(null, aCase.CA_Product_Controller__r.Name);
    System.assertNotEquals(null, aCase.Contact.Email);
    System.assertNotEquals(null, aCase.Site_Association__r.Name);
    System.assertEquals(1, aCase.Case_Portal_Views__r.size(), aCase.Case_Portal_Views__r);
    if (allFields == true) {
      System.assertEquals(1, aCase.CaseComments.size(), aCase.CaseComments);
      // community user cannot query tasks object
      //System.assertEquals(1, aCase.Tasks.size(), aCase.Tasks);
    }
  }
}