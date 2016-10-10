@isTest
private class TestUniqueBusinessUnit {
    @isTest(seeAllData='true')
    static void testSCBUandDSCBU(){
        
        //SystemIdUtility.skipAccount = true;
        //SystemIdUtility.skipProductTriggers = true;
        SystemIdUtility.skipOpportunityLineItemTriggers = true;
        //SystemIdUtility.skipOpportunityTriggers = true;
        
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
         Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
         Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
         
         ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
         
         Product2 prd1 = new Product2(Name='Prd1', Family='Product',Market_Focus_Area__c='Test1',IsActive=true);
         Product2 prd2 = new Product2(Name='Prd2', Family='Time',Market_Focus_Area__c='Test2',IsActive=true);
         Product2 prd3 = new Product2(Name='Prd3', Family='Time',Market_Focus_Area__c='Test2',IsActive=true);
         Product2[] prd = new Product2[]{prd1,prd2,prd3};
         insert prd;
         //delete prd[2];
         
        Pricebook2 pb = new Pricebook2();
        pb = [Select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3};
        insert pbe;
        //delete pbe[2];
        
        Account smbAcc = new Account(RecordTypeId= SMBRecTypeId, Name='testAcc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcc;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(AccountId=smbAcc.id, Name='testOpp1',StageName = 'Closed - Lost',RecordTypeId=oppRecId,CloseDate=System.today(),Initial_Billing__c=2,Deal_Lost_to__c='CA');
         oppList.add(opp1);
         insert oppList;
         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=opp1.Id,PricebookEntryId = pbe[0].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=opp1.Id,PricebookEntryId = pbe[1].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1,oli2};
        insert oli;
        //delete oli[1];
        
       // List<Id> oppId = new List<Id>();
       set<id> oppId = new set<id>();
        oppId.add(oppList.get(0).Id);
        
        UniqueBusinessUnit UBU = new UniqueBusinessUnit();
        //UBU.processOpprLineItems(oppId);
        UBU.processOpprLineItems(oppList);
    }
}