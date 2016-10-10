@isTest
private class testMethods_TrialRequest
{
  static testmethod void testTrialRequest()
  {
        
     //Opportunity opp = [Select Id, RecordType.Name, AccountId from Opportunity Where Recordtype.Name = 'New Opportunity' AND StageName = '10% - Identification & Qualification' limit 1];
     RecordType[] recacc = [select Id from Recordtype where IsActive=true and SObjectType='Account' and Name in ('Account Team Covered Account')];
     /*Account acc1 = new Account(Name='TestAcc1',Geo__c='NA',RecordTypeId=SystemIdUtility.getResellerDistRecordTypeId(),Enterprise_Id__c='NAACC001',Enterprise_Account_Name__c='EAcc',Customer_Category__c='Reseller',Commercial_ID__c =  '12',Commercial_Account_Name__c = 'caName');
     insert acc1;*/
    ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
    ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
    Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
            insert resellerAcct;                        
    Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
            insert smbAcct;
         
     RecordType recopp = [select Id from Recordtype where IsActive=true and SObjectType='Opportunity' and Name='New Opportunity'];
     Opportunity opp = new Opportunity(RecordTypeID=recopp.Id,AccountId=smbAcct.Id,Reseller__c = resellerAcct.Id, CloseDate=System.today()+2,Name='TestOpp',New_Deal_Term_months__c = 2,StageName='10%-Qualified Renewal');
     insert opp; 
     if(opp != null)
     {
          
         Trial_Request__c trialRequest = new Trial_Request__c();
         trialRequest.Account_Name__c = opp.AccountId;
         trialRequest.Opp_Name__c = opp.Id;
         trialRequest.Request_Type__c = 'Trial Request';
         trialRequest.Request_Status__c = 'New';
         trialRequest.Record_Type__c = opp.RecordType.Name;
         insert  trialRequest;
         
         //trialRequest.Request_Status__c = 'Accepted'; 
         trialRequest.OwnerId = UserInfo.getUserId() ;
         update trialRequest;
         
         
         //trialRequest.Request_Status__c = 'Approved';
         update trialRequest;
        
        // opp.StageName = 'Closed - Lost';
        // update opp;
         
         //Quote_Request__c quoteRequest = [Select Id From Quote_Request__c Trial_Request__c WHERE Trial_Request__c=:trialRequest.Id Limit 1 ];
         //quoteRequest.Request_Status__c ='Complete';
         //quoteRequest.Quote_Number__c ='12345';
         //update quoteRequest;
         
         
     }   
        
   }
}