@isTest(SeeAllData=true)
public class BusinessPlanNewTest {
  
  public static Business_Plan_New__c populateTestData()
  {
    Id testuserId = Userinfo.getUserId();
    
    Account acc = new Account(aggregate_account__c = 'No' , spf__approved_for_partner_finder__c = false , not_eligible_for_shark_tank_leads__c = false , recordtypeid = '01230000001L55eAAC' , hq__c = false , is_primary_account__c = true , reference_account__c = false ,
     account_plan_sync__c = false , mvp_account__c = false , account_owner_name__c = 'Daniel Zeidler' ,
      agreement_attached__c = false , customer_success_story_attached__c = false , solution_provider__c = false ,
       geo__c = 'NA' , currencyisocode = 'USD' , comments__c = 'line1\nline2' , aocv__c = 0.000 ,
        territory_country_text__c = 'EA_MIDATLANTIC' , velocity_seller__c = false ,
         solution_provider_type__c = 'Reseller' , name = 'Dan Inc' , ela__c = false , 
         eligible_for_mdf__c = false , received_last_lead__c = false , partner_agreement_attached__c = false , 
         region_country__c = 'US' , partner_enablement_addendum_attached__c = false , segment__c = 'Large-New' , 
         company_overview__c = 'This is an awesome company,\nI really mean it,\nits going to be a fortune 100 company one day!' , send_site_request__c = false , 
         sales_requests_not_to_call_account__c = false , alliance__c = false , region_text__c = 'NA' , 
         business_plan_attached__c = false , customer_pricesheet__c = false , 
         partner_spotlight_attached__c = false , spf__partner_finder_recommended_flag__c = false ,
          area_text__c = 'EAST' , service_provider__c = false , account_status__c = 'New' ,
           ocv__c = 0.000 , press_release_attached__c = false , coverage_model__c = 'Account Team' , 
           solution_catalog_submission_attached__c = false , sales_region__c = 'EA_MIDATLANTIC' , 
           d_b_hq__c = false , check_account_access__c = false , isexcludedfromrealign = false , 
           dla_attached__c = false , sales_area__c = 'EAST' , country_picklist__c = 'US - UNITED STATES' , 
           sent_to_mdm__c = false , auto_assignment_enabled__c = false , billingcountry = 'US' , 
           pds_addendum_attached__c = false , site_request_flag__c = false , create_opp_grid__c = false);
           acc.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();
    acc.BillingStreet='Street';
    acc.BillingCountry='US';
    acc.BillingCity='Islandia';         
    insert acc;
    
    TAQ_Account__c myTaq = new TAQ_Account__c();
    myTaq.View_Acc_Record__c = acc.Id;
    myTaq.country_picklist__c = 'US - UNITED STATES';    
    insert myTaq;
    
    Business_Plan_New__c bp = new Business_Plan_New__c();
    bp.Account__c=acc.id;
    bp.Alliance__c=true;
    bp.Service_Provider__c=true;
    bp.Solution_Provider__c=true;
    bp.Data_Management__c=true;
    bp.DM_Program_Level__c='true';
    bp.Plan_Fiscal_Year__c='FY 2015';
    bp.CA_Business_Plan_Owner__c='005300000045UXA';
    bp.NA__c=true;
    bp.EMEA__c=true;
    bp.LA__c=true;
    bp.APJ__c=true;

    

    insert bp;
    return bp;
  }

  static void submitforApp(Business_Plan_New__c bp)
  {
      bp.Status__c='Pending Approval';
      update bp;
  }
  
  static void Approved(Business_Plan_New__c bp)
  {
      bp.Status__c='Approved';
      update bp;
  }  
  
static testMethod void testEP() 
{
  Business_Plan_New__c bp = populateTestData();
  ApexPages.StandardController sc = new ApexPages.standardController(bp);
  BusinessPlanControllerExtension e = new BusinessPlanControllerExtension (sc);
  
      bp.NA_Operating_Areas__c=null;
    bp.EMEA_Operating_Areas__c=null;
    bp.LA_Operating_Areas__c=null;
    bp.APJ_Operating_Areas__c=null;
    bp.NA_Countries__c=null;
    bp.LA_Countries__c=null;
    bp.EMEA_Countries__c=null;
    bp.APJ_Countries__c=null;
  
  BusinessPlanControllerExtension.BPTrainingContact bpc = new BusinessPlanControllerExtension.BPTrainingContact(new Contact(), '');
  BusinessPlanControllerExtension.ProductGroup pg = new BusinessPlanControllerExtension.ProductGroup(1, 'Alliance', 'b', 'c', 'd');
  BusinessPlanControllerExtension.ProductGroup pg2 = new BusinessPlanControllerExtension.ProductGroup(1, 'Solution Provider', 'b', 'c', 'd');
  BusinessPlanControllerExtension.ProductGroup pg3 = new BusinessPlanControllerExtension.ProductGroup(1, 'Service Provider', 'b', 'c', 'd');
  BusinessPlanControllerExtension.ProductGroup pg4 = new BusinessPlanControllerExtension.ProductGroup(1, 'Data Management', 'b', 'c', 'd');      
  pg.AddPNCVTarget(1.00, 1.00, 1.00, 1.00);
  pg.AddSNCVTarget(1.00, 1.00, 1.00, 1.00);
  pg.AddENCVTarget(1.00, 1.00, 1.00, 1.00);
  
  BP_Training_Contact__c newBPC = new BP_Training_Contact__c();
  List<BP_Training_Course__c> newList = new List<BP_Training_Course__c>();
  BP_Training_Course__c myCourse = new BP_Training_Course__c();
  newList.add(myCourse);
  
  e.AddedPGs.add(pg);
  e.AddedPGs.add(pg2);
  e.AddedPGs.add(pg3);
  e.AddedPGs.add(pg4);    
  
 
  
  pg.AddBPTrainingContacts(newBPC);
  //pg.AddBPTrainingCourses(newList);
  //addToMap();
  e.getPartnerProgramLevel();
  e.getDMProgramLevel();
  e.calcPlanPeriod();
  e.getRTMs();
  e.getBUs();
  e.getProductGroups();
  e.clearBUPG();
  e.clearBookingBUPG();
  e.AddProduct();
  e.revQ1=1.0;
  e.revQ2=1.0;
  e.revQ3=1.0;
  e.revQ4=1.0;
  //e.selectedRevType='SNCV';
  //e.AddBookingTarget();
  //e.selectedRevType='PNCV';
  //e.AddBookingTarget();
  //e.selectedRevType='ENCV';
  //e.AddBookingTarget();    
  e.getRelatedPG();
  System.debug('getRelatedPG:'+e.getRelatedPG());
  e.getAlliancePGs();
  e.getSolProPGs();
  e.getSerProPGs();
  e.getDMPGs();
  //e.getBookingBUs();
  //e.getBookingPGs();
  //e.getRevenueTypes();
  //e.Save();
  e.WWClick();
  //e.clickedTab();
  e.nextTab() ;
  e.profileTabChangeCheck();
//  e.tabChangeChecks('5');
  e.getReadableLanguage('en_US');
  e.getInDraft();
  e.delSolutionCounter = 2;
  e.delSolRow();
  e.editPage();
  e.currentTab = '1';
  e.intendedTab = '3';
  e.clickedTab();
  e.currentTab = '2';
  e.nextTab() ;
  e.clickedTab();
  e.currentTab = '4';

  e.clickedTab();
  e.clickedViewTab();
  e.nextTab() ;
  e.nextViewTab();   
  e.currentTab = '2'; 
  e.prevTab();
  e.prevViewTab();
  e.showSPQuestions();
  e.getKey();
  submitforApp(bp);
  Approved(bp);
  List<BP_Training_Contact__c> mylist = new List<BP_Training_Contact__c>();
  pg.AddBPTrainingContactsList(mylist);
  e.delAllTrRow();
  e.delSolTrRow();
  e.delSerTrRow();
  e.delDMTrRow();
  e.getTrainingRTMs();
  e.getTrainingPGs();
  e.clearTrainingPG();
  e.getResourceTypes();
  
   e.TrainingRTM =  'Alliance' ;
  e.TrainingPG = 'c';
  
  e.AddTrainingRows();
  e.getTrAlliancePGs();
  e.getTrSolProPGs();
  e.getTrSerProPGs();
  e.getTrDMPGs();      
  
  List<BP_Solutions__c> bpList = new List<BP_Solutions__c>();
  BPHistory history = new BPHistory(bp);
  history.createBPHistory(e.delPGSoln,e.addedPGSoln,e.delTrainingContactMap,e.addedTrainingContactMap,e.AddedPGs,bpList);
        
  Test.setMock(HttpCalloutMock.class, new BPApprovalTriggerHandler_MockCallout('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/apexrest/addBPVersion/'));
  BPApprovalTriggerHandler.addPDFAttach(UserInfo.getSessionId(),String.valueOf(bp.Id));
  
  
}
    
    static testMethod void testBPSolutionTrigger(){
        Business_Plan_New__c bp1 = populateTestData();
        BP_Solutions__c bpSol = new BP_Solutions__c(Business_Plan__c=bp1.Id);
        insert bpSol;		        
    }
    
}