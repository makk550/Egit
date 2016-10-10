@isTest
private class Renewals_Scenario_Test {

   static Pagereference pref;
   public static testmethod void testRenewal_oldRPDSiteSelection(){


    Account testaccount =new Account();      
    testaccount.Name ='testaccount';       
    testaccount.GEO__c='Japan';        
    testaccount.Sales_Area__c='Japan';       
    testaccount.Sales_Region__c='Japan';       
    testaccount.Country_Picklist__c='JP-JAPAN';        
    testaccount.Account_Status__c='Submitted';       
    testaccount.Customer_Category__c='Commercial';       
    testaccount.Region_Country__c='JP';        
    testaccount.Enterprise_ID__c='';        
    testaccount.Enterprise_Account_Name__c='';    
    testaccount.Commercial_ID__c='10024';   
    testaccount.SAP_TOPS_Site__c='S'; //check this               
    insert testaccount;

    Renewal_Currency__c renCurrency = new Renewal_Currency__c(name='INR');        
    insert renCurrency;
    
    Active_Contract__c ac = new Active_Contract__c(name='TestAc',Sold_to_party__c=testaccount.id,Renewal_Currency__c=renCurrency.Id);
    insert ac;
    Active_Contract_Product__c acp = new Active_Contract_Product__c(name='ACP',Active_Contract__c=ac.id);
    insert acp;
    
    Opportunity opp =new Opportunity(Name='testopp',AccountId=testaccount.Id,Type='Direct',RPD_Comments__c='Test',
                                      Split_Opportunity__c='No',CurrencyIsoCode='USD',Initial_Billing__c=0.00,StageName='10% - Identification & Qualification',CloseDate=Date.today());
    insert opp;
   
    
    Renewal_Scenario__c rnwlScenario = new Renewal_Scenario__c(Name='testrnwlsc');
    rnwlScenario.Will_Existing_Contracts_be_Respread__c=true;
    rnwlScenario.Revenue_Neutral_with_Time_only_GAP__c='10000';
    rnwlScenario.Remaining_Billing_To_Be_Cancelled_Cred__c=10000;
    rnwlScenario.Proposed_Deal_Time_Only__c=10000;
    rnwlScenario.Pro_Rated_Credit__c=10000;
    rnwlScenario.Opportunity__c=opp.Id;
    rnwlScenario.Analyze_Scenario__c=true;
    rnwlScenario.FY_Start_for_Old_Rev_Stream_Avg__c='2005';
    rnwlScenario.FM_Start_for_Old_Rev_Stream_Avg__c='05';
    rnwlScenario.New_Deal_Time_Amount__c=10000;
    rnwlScenario.New_Deal_NCV_MF_Capacity_Amount__c=10000;
    rnwlScenario.New_Deal_NCV_Amount__c =10000;
    rnwlScenario.New_Deal_Services_Educ_Amount__c=10000;
    rnwlScenario.Pro_Rated_Credit_Note_Amount__c=10000;
    rnwlScenario.New_Deal_Revenue_Date__c=Date.valueOf('2011-05-05');
    rnwlScenario.New_Deal_End_Date__c =Date.valueOf('2011-05-05');
    rnwlScenario.Override_Actual_New_RPD__c = 5000;
    rnwlScenario.Finance_Approval__c = True;
    insert rnwlScenario;
    
    RPD_Contract__c rpdCon = new RPD_Contract__c(Sold_to_Site_ID__c='S 10024',Opportunity__c=opp.id, Contract_Sales_Document_No__c='40100175');
    insert rpdCon;
   
    CA_Product_Renewal__c caProdRenewals = new CA_Product_Renewal__c();
    //caProdRenewals.Sold_to_Site_ID__c='S 10024';
    caProdRenewals.Active_Contract_Product__c=acp.Id;
    caProdRenewals.Renewal_Opportunity__c=opp.Id;
    insert caProdRenewals;
    
    pref = Page.Renewals_scenario;
    pref.getParameters().put('Id',opp.id);
    Test.setCurrentPage(pref);

    Renewals_Scenario controller = new Renewals_Scenario();
    controller.testMeth =true;

    Test.startTest();
    controller.getAnalysedResults();
    controller.submit();
    controller.ExportRenewalScenario();
    controller.returnToOpp();
    controller.ExportOLDRPDResult();
    controller.submitFinance();
    Test.stopTest();   
   }
}