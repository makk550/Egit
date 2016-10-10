@isTest
private class testCPQtrigger
{
    @isTest(SeeAllData=true)
    private static void testCPQ()
    {
    Id recid = SystemIdUtility.getResellerDistRecordTypeId();
/*    account acc = new account(name = 'wells', recordtypeid = recId);
    insert acc; 
    */
    
    ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();


ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();



Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
        insert resellerAcct;                
        
Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct;
    
    opportunity opp = new opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,name='test opp',closedate=system.today(),stagename='10% - Identification & Qualification');
    insert opp;
    scpq__SciQuote__c  sc = new scpq__SciQuote__c (CA_Primary_Flag__c=true,name='test',scpq__OpportunityId__c=opp.id, scpq__OrderHeaderKey__c ='2131313', scpq__SciLastModifiedDate__c=system.today());
    insert sc;
    scpq__SciQuote__c  sc2 = new scpq__SciQuote__c (name='test2',scpq__OpportunityId__c=opp.id, scpq__OrderHeaderKey__c ='2131314', scpq__SciLastModifiedDate__c=system.today());
    insert sc2;
    
    
    }
}