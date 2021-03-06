/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_OpportunitySummery {
    static testMethod void testOpportunitySummery() 
    {
    SystemIdUtility.skipOpportunityTriggers = true;
SystemIdUtility.skipOpportunityLineItemTriggers  = true;
       String currencyIsoCode = 'USD';
       
       Id recid = SystemIdUtility.getResellerDistRecordTypeId();
       
       /*
       Account acc = new Account();
       acc.Name = 'Test Account';
       acc.Type = 'Customer';
       acc.GEO__c = 'LA';
       acc.Customer_Category__c = 'Enterprise';
       acc.Account_Status__c = 'New';
       acc.Commercial_Id__c = 'asdf';
       acc.recordtypeid = recid;
       insert acc;
       */
       
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
        ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
        Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
                insert resellerAcct;                
                
        Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
                insert smbAcct;
               
       RecordType recopp = [select Id from Recordtype where IsActive=true and SObjectType='Opportunity' and Name='New Opportunity'];
       
       Opportunity opp = new Opportunity();
       opp.Name = 'Test Oppty';
       opp.AccountId = smbAcct.Id;
       opp.Reseller__c= resellerAcct.Id;
       opp.Closedate = System.today();
       opp.StageName = '10% - Identification & Qualification';
       opp.CurrencyIsoCode = currencyIsoCode;
       opp.RecordTypeId = recopp.Id;
       insert opp;
       
       List<Product2> productList = new List<Product2>();
       
       productList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'SA', Family = 'Product', ProductCode = 'testProdCode1'));
       productList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'VSA', Family = 'Support', ProductCode = 'testProdCode1'));
       productList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'PPM', Family = 'Services', ProductCode = 'testProdCode1'));
       productList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'SEC', Family = 'Education', ProductCode = 'testProdCode1'));
       productList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'MAINFRAME', Family = 'Renewal', ProductCode = 'testProdCode1'));
       
       insert productList;
       
       Pricebook2 pb = [SELECT Id from Pricebook2 p Where isStandard = true]; //Get Id of standard pricebook
       List<Pricebookentry> pbeLIST = new List<Pricebookentry>() ;  
       pbeLIST.add(new Pricebookentry(pricebook2Id=pb.Id,Product2Id = productList[0].Id,isactive = true, CurrencyIsoCode = CurrencyIsoCode, UnitPrice = 0.0));
       pbeLIST.add(new Pricebookentry(pricebook2Id=pb.Id,Product2Id = productList[1].Id,isactive = true, CurrencyIsoCode = CurrencyIsoCode, UnitPrice = 0.0));
       pbeLIST.add(new Pricebookentry(pricebook2Id=pb.Id,Product2Id = productList[2].Id,isactive = true, CurrencyIsoCode = CurrencyIsoCode, UnitPrice = 0.0));
       pbeLIST.add(new Pricebookentry(pricebook2Id=pb.Id,Product2Id = productList[3].Id,isactive = true, CurrencyIsoCode = CurrencyIsoCode, UnitPrice = 0.0));
       pbeLIST.add(new Pricebookentry(pricebook2Id=pb.Id,Product2Id = productList[4].Id,isactive = true, CurrencyIsoCode = CurrencyIsoCode, UnitPrice = 0.0));
       
       insert pbeLIST;
       
       Pricebook2 customPB = new Pricebook2 (name = 'Test Price bookOP', Description = 'desc', isactive = true);
       insert customPB;
        
       List<Pricebookentry> priceBookEntryList = new List<Pricebookentry>();
        
       priceBookEntryList.add( new Pricebookentry(
                               pricebook2Id = customPB.Id,
                               Product2Id = productList[0].Id,
                               UnitPrice = 0.0,
                               Isactive = true,
                               CurrencyIsoCode = CurrencyIsoCode));
                               
       priceBookEntryList.add( new Pricebookentry(
                               pricebook2Id = customPB.Id,
                               Product2Id = productList[1].Id,
                               UnitPrice = 0.0,
                               Isactive = true,
                               CurrencyIsoCode = CurrencyIsoCode));
       
       priceBookEntryList.add( new Pricebookentry(
                               pricebook2Id = customPB.Id,
                               Product2Id = productList[2].Id,
                               UnitPrice = 0.0,
                               Isactive = true,
                               CurrencyIsoCode = CurrencyIsoCode));                    
       
       priceBookEntryList.add( new Pricebookentry(
                               pricebook2Id = customPB.Id,
                               Product2Id = productList[3].Id,
                               UnitPrice = 0.0,
                               Isactive = true,
                               CurrencyIsoCode = CurrencyIsoCode));
       
       priceBookEntryList.add( new Pricebookentry(
                               pricebook2Id = customPB.Id,
                               Product2Id = productList[4].Id,
                               UnitPrice = 0.0,
                               Isactive = true,
                               CurrencyIsoCode = CurrencyIsoCode));
       insert priceBookEntryList;
              
       List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
       PricebookEntry[] pbe = [Select Id from PricebookEntry where IsActive=: true and CurrencyIsoCode =: opp.CurrencyIsoCode limit 1]; 
       optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = opp.Id,QUANTITY = 1,
                               PRICEBOOKENTRYID = priceBookEntryList[0].Id,
                               UNITPRICE = 6000000,                               
                               BUSINESS_TYPE__C = 'Capacity'
                               ));
       optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = opp.Id,QUANTITY = 1,
                               PRICEBOOKENTRYID = priceBookEntryList[1].Id,
                               UNITPRICE = 6000000,                               
                               BUSINESS_TYPE__C = 'Capacity'
                               ));
       optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = opp.Id,QUANTITY = 1,
                               PRICEBOOKENTRYID = priceBookEntryList[2].Id,
                               UNITPRICE = 6000000,                               
                               BUSINESS_TYPE__C = 'Capacity'
                               ));
       optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = opp.Id,QUANTITY = 1,
                               PRICEBOOKENTRYID = priceBookEntryList[3].Id,
                               UNITPRICE = 6000000,                               
                               BUSINESS_TYPE__C = 'Capacity'
                               ));
       optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = opp.Id,QUANTITY = 1,
                               PRICEBOOKENTRYID = priceBookEntryList[4].Id,
                               UNITPRICE = 6000000,                               
                               BUSINESS_TYPE__C = 'Capacity'
                               ));
                               
       insert optyLineItemList;
       
       //Test Opportunity_Summary VF AND Controller  .... START
       
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        OpportunitySummary controller = new OpportunitySummary(std);
        Test.setCurrentPage(Page.Opportunity_Summary);
        controller.getmatrix();
        //Test Opportunity_Summary VF AND Controller  .... END
        
    }
}