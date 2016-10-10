@isTest (SeeAllData = true)
public class TestCaseHandler{ 
 
  private static Site_Association__c testSite ; 
  private static Site_Association__c excludedSite;
  private static CA_Product_Controller__c testCAProduct ; 
  private static Contact testContact ; 
  private static User supportUser ; 
  private static Offering_Business_Rules__c offeringBusinessRulesObj;
  private static Offering_Business_Rules__c offeringBusinessRulesObj2;
 
  public static User createDataUser(){
         Profile adminProfile = [select Id from Profile where Name = '1.0 CA Sys Admin Commit & PR Non-SSO' limit 1];
         User testUser = [select Id from User where  isActive = true AND ProfileId = :adminProfile.Id limit 1];
         return testUser ;
  }
  public static  void createTestData () {
         
     Account testAccount = new Account() ; 
     testAccount.Name = 'HONG KONG GOVERNMENT'; 
     testAccount.Enterprise_ID__c = 'AR51855';
     testAccount.BillingStreet = 'Admiralty Ctr';
     testAccount.BillingCountry = 'HK';
     testAccount.BillingCity = 'ADMIRALTY';
     insert testAccount ; 
     
     testContact = new Contact();
     testContact.LastName = 'Darcy' ;
     testContact.FirstName = 'Brian' ; 
     testContact.Email = 'Brian@test.com';
     insert testContact ; 
      
     testSite = new Site_Association__c();
     testSite.Name = 'FINANCIAL SERVICES & THE TREASURY BUREA';
     testSite.Enterprise_ID__c =  testAccount.Id; 
     testSite.SC_SITE_Sanctioned_Party__c = 'No';
     testSite.SC_TOPS_ID__c = '788689111';
     testSite.SC_SITE_Source__c = 'Support' ; 
     testSite.Country_picklist__c ='US - UNITED STATES';
     insert testSite ;  
     
     testCAProduct = new CA_Product_Controller__c();
     //testCAProduct.Name = 'APPLICATION PERFORMANCE MANAGEMENT' ;
     testCAProduct.Name = 'testtest' ;
     insert testCAProduct ; 
     
     CA_Product_Component__c testCAComponent = new CA_Product_Component__c();
     testCAComponent.Name = 'APPLICATION PERFORMANCE MANAGEMENT CEMINT';
     testCAComponent.CA_Product_Controller__c = testCAProduct.Id ; 
     testCAComponent.Default_Component_for_this_CA_Product__c = true;
     insert testCAComponent;
     
     Emails_List__c email = new Emails_List__c();
     email.Name = 'greg.petras@nyfixtest.com' ;
     insert email ; 
     Sites_List__c site = new Sites_List__c();
     site.Name = '123456' ;
     insert site ; 
     Products_List__c product = new Products_List__c();
     product.Name = 'TSEECT';
     insert product;
     
     excludedSite = new Site_Association__c();
     excludedSite.Name = 'FINANCIAL SERVICES & THE TREASURY BUREA';
     excludedSite.Enterprise_ID__c =  testAccount.Id; 
     excludedSite.SC_SITE_Sanctioned_Party__c = 'No';
     excludedSite.SC_TOPS_ID__c = '123456111';
     excludedSite.SC_SITE_Source__c = 'Support' ; 
     excludedSite.Country_picklist__c ='US - UNITED STATES';
     excludedSite.State__c = 'california';
     insert excludedSite ; 
     // US150326  Commenting starts
   //  Certifications__c certificateObj = new Certifications__c();
    // certificateObj.Active__c = true;
    // certificateObj.CA_Product__c = testCAProduct.Id;
    // certificateObj.Certification_End_Date__c = system.today().addDays(10);
    // certificateObj.Certification_Start_Date__c = system.today();
    // certificateObj.Certification_Level__c = 'Certified';
    // certificateObj.Contact__c = testContact.Id;
    // insert certificateObj;
      // US150326  Commenting  ends
     offeringBusinessRulesObj = new Offering_Business_Rules__c();     
     offeringBusinessRulesObj.Offering_Code__c = 'Code 123'; 
     insert offeringBusinessRulesObj; 
     
     List<Offering_Feature__c> offeringFeatureList = new List<Offering_Feature__c>();

     Offering_Feature__c offeringObject = new Offering_Feature__c();
     offeringObject.Case_Severity__c = '3';
     offeringObject.Offering_Business_Rules__c = offeringBusinessRulesObj.Id;
     //offeringObject.SLO__c = '1';
     offeringObject.SLO_Type__c = 'Standard';
     offeringObject.SLO_Value__c = '2';
     offeringObject.Type__c = 'Certified Bypass Routing';
     offeringObject.Unit__c = 'Minutes';
     offeringFeatureList.add(offeringObject);

     Offering_Feature__c offeringObject1 = new Offering_Feature__c();
     offeringObject1.Case_Severity__c = '3';
     offeringObject1.Offering_Business_Rules__c = offeringBusinessRulesObj.Id;
     offeringObject1.SLO_Type__c = 'Standard';
     offeringObject1.SLO_Value__c = '2';
     offeringObject1.Type__c = 'Workaround';
     offeringObject1.Unit__c = 'Minutes';
     offeringFeatureList.add(offeringObject1);


    Offering_Feature__c offeringObject2 = new Offering_Feature__c();
     offeringObject2.Case_Severity__c = '3';
     offeringObject2.Offering_Business_Rules__c = offeringBusinessRulesObj.Id;
     offeringObject2.SLO_Type__c = 'Standard';
     offeringObject2.SLO_Value__c = '2';
     offeringObject2.Type__c = 'Resolution';
     offeringObject2.Unit__c = 'Minutes';
     offeringFeatureList.add(offeringObject2);

    offeringBusinessRulesObj2 = new Offering_Business_Rules__c();     
    offeringBusinessRulesObj2.Offering_Code__c = 'Code 234'; 
    insert offeringBusinessRulesObj2; 
    
     Offering_Feature__c offeringObject3 = new Offering_Feature__c();
     offeringObject3.Case_Severity__c = '3';
     offeringObject3.Offering_Business_Rules__c = offeringBusinessRulesObj2.Id;
     offeringObject3.SLO_Type__c = 'Standard';
     offeringObject3.SLO_Value__c = '2';
     offeringObject3.Type__c = 'Initial Callback';
     offeringObject3.Unit__c = 'Minutes';
     offeringFeatureList.add(offeringObject3);
     insert offeringFeatureList;
        
     Profile adminProfile = [select Id from Profile where Name = '1.0 CA Sys Admin Commit & PR']; 
     supportUser = [select Id from User where IsActive = true AND  ProfileId = :adminProfile.Id limit 1] ;   
  }  
  
  static testmethod void testInsertCase () {
     system.runAs(createDataUser()){
        createTestData();
     }     
     system.runAs(supportUser){  
          
        Test.StartTest();   

         List<Case> caseList = new List<Case>();

        Case case1 = TestCaseHandler.prepareCase(offeringBusinessRulesObj.Id,'Code 123','1');
        Case case2 = TestCaseHandler.prepareCase(offeringBusinessRulesObj.Id,'Code 123','2');
        Case case3 = TestCaseHandler.prepareCase(offeringBusinessRulesObj2.Id,'Code 234','3');
        Case case4 = TestCaseHandler.prepareCase(offeringBusinessRulesObj.Id,'Code 123','4');

        Case case5 = TestCaseHandler.prepareCase(null,null,'1');
        Case case6 = TestCaseHandler.prepareCase(null,null,'2');
        Case case7 = TestCaseHandler.prepareCase(null,null,'3');
        Case case8 = TestCaseHandler.prepareCase(null,null,'4');

        caseList.add(case1);
        caseList.add(case2);
        caseList.add(case3);
        caseList.add(case4);
        caseList.add(case5);
        caseList.add(case6);
        caseList.add(case7);
        caseList.add(case8);
        insert caseList; 

        case2.Next_Action_Due_Date__c = System.today()+3;
        update case2;

         case2.Next_Action__c = 'Pending CA-Sales';
         case2.Troubleshooting_Stage__c = 'Solution Provided';
         case2.Category__c='Administrative';
         case2.Subcategory__c='Services';   
         case2.Reason='Defect - New';
         case2.Resolution__c='Test';         
         update case2;

        Test.StopTest();
     }   
  }
      static testmethod void testDeleteCase (){
         try{
              delete [select Id from Case where Status ='Open' limit 1];
            }catch(exception e){}   
      }

      private static Case prepareCase(Id offeringNameId,String offeringCodeRef,String severity){
            Case caseRec = new Case();
            caseRec.Site_Association__c = testSite.Id ;
            caseRec.subject = 'Test Subject' ; 
            caseRec.Description = 'Test Description' ; 
            caseRec.ContactId = testContact.Id ; 
            caseRec.CA_Product_Controller__c = testCAProduct.Id; 
            caseRec.Next_Action__c ='Pending CA';
            caseRec.Next_Action_Due_Date__c = System.Today()+1;
            caseRec.Origin = 'Phone Call';       
            caseRec.Troubleshooting_Stage__c = 'Problem Identification';     
            caseRec.Severity__c = severity;
            if(offeringNameId!=null){
                caseRec.Offering_Name__c = offeringNameId;
                caseRec.Offering_Code_Ref__c = offeringCodeRef;
            }
            if(severity == '1'){
                caseRec.Sev_1_Impact_c__c = 'Production Down';
                caseRec.Production_Down_Status__c = 'Investigating';
            }
            return caseRec;
      }
 
}