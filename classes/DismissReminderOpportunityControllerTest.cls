@isTest(SeeAllData=true)
public class DismissReminderOpportunityControllerTest {
      
    @isTest static void testclickdismissreminder(){
        RecordType rt = new RecordType();
        rt = [select id from RecordType where Name='New Opportunity' and isActive = true and sObjectType = 'Opportunity' limit 1];
   
        Account acc = new Account();
            acc.Name = 'test CAAcc';
            acc.Country_Picklist__c = 'AL - ALBANIA';
            acc.Account_Status__c = 'New';
            acc.Geo__c = 'EMEA';
            acc.BillingStreet='Arlington';
            acc.BillingCity='NY';
            acc.BillingCountry='US';
            insert acc;
         Contact c = new Contact();
              c.FirstName = 'test contact';
              c.LastName = 'test contact';      
              c.AccountId = acc.Id;
        insert c;
        Opportunity opp = new Opportunity();
        opp.Name = 'opptest9';
        if(rt.Id != null)
                opp.RecordTypeId = rt.Id;
        opp.Transaction_Type__c = 'Direct';
        opp.Contract_Type__c ='ELA';
        opp.CloseDate =System.today()+1;
        opp.CurrencyIsoCode='USD';
        opp.Inside_Outside__c ='Inside';
        opp.Reseller_Sales_Milestone__c ='20% - Researching';
        opp.AccountId=acc.Id;
        opp.Deal_Review__c = 'BLACK - No Assets';
        opp.stageName = 'Negotiation';
        insert opp;
        PageReference ref = new PageReference('/apex/OpportunityViewOverride?id= :opp.Id');
		Test.setCurrentPage(ref);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(opp);
        ApexPages.currentPage().getParameters().put('id',opp.Id);
        DismissReminderOpportunityController disremider = new DismissReminderOpportunityController(sc);
        PageReference temppageref=disremider.clickdismissreminder();
        
        
    }
}