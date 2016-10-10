@isTest(seeAllData = true)
public class testTriggers2{
    public static testMethod void testMethOpp(){
     
     Opportunity opp = new Opportunity();
     try{
        Account acc = new Account();
       acc.Name = 'Test Account';
       acc.Type = 'Customer';
       acc.GEO__c = 'LA';
       acc.Customer_Category__c = 'Enterprise';
       acc.Account_Status__c = 'New';
       insert acc;
    
        
       opp.Name = 'Test Oppty';
       opp.AccountId = acc.Id;
       
       RecordType recopp = [select Id from Recordtype where IsActive=true and SObjectType='Opportunity' and Name='Deal Registration'];
       
       
       opp.Reseller__c= [select id from account where Velocity_Seller__c != null limit 1].id;
       opp.Closedate = System.today();
       opp.StageName = '10% - Identification & Qualification';
       opp.RecordTypeId = recopp.Id;
       opp.Additional_Emails__c = 'test_tadkr01@ca.com;test_xyfctadkr01@ca.com';
       opp.Reseller_Win_Loss_Reason__c = 'Closed By Another Reseller1';
       opp.Reseller_Sales_Milestone__c = 'Closed - sWon';
       opp.closedate = system.today()+1;
       opp.Reseller__c = acc.id;
       opp.CurrencyIsoCode = 'USD';
       opp.Business_Unit__c = 'Data Management';
    //   opp.deal_program_end_date__c= system.today()+2;
       insert opp;
       
       List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
       
       OpportunityLineItem oliObj = new OpportunityLineItem();
           oliObj.OpportunityId = opp.Id;
           oliObj.totalprice = 200;
           oliObj.pricebookentryid = [select id from pricebookentry where currencyISOCode='USD' limit 1].id;
         //  oliObj.Business_Type__c = 'Renewal';
     //  insert oliObj;
     oliList.add(oliObj);
     
     OpportunityLineItem oliObj2 = new OpportunityLineItem();
           oliObj2.OpportunityId = opp.Id;
           oliObj2.totalprice = 200;
           oliObj2.pricebookentryid = oliObj.pricebookentryid;
     //      oliObj2.Business_Unit__c = 'Data Management';
           oliObj2.Business_Type__c = 'Renewal';
      oliList.add(oliObj2);
     
     
     database.insert(oliList,false);
     //  oliObj2.Business_Type__c = 'MF Capacity';
     
         upsert oliObj2;
   }catch(Exception e5){
      }
       
       // FOR Au_CopyQuoteNumberToTR TRIGGER.
    try{   
       Quote_Request__c qrObj = new Quote_Request__c();
       qrObj.Opportunity_Name__c = opp.id;
       qrObj.Request_Status__c = 'Complete';
       qrObj.Trial_Request__c = [select id from Trial_Request__c limit 1].Id;
       insert qrObj;
       update qrObj;
       
       Response__c rpObj = new Response__c();
       rpObj.Name = 'test response';
       rpObj.ProductResp__c = [select id from product2 where isActive = true limit 1].Id;
       insert rpObj;
       //--------------------------------------------------
       
      }catch(Exception e5){
      } 
       
       
       
    }
}