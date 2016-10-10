@isTest(seeAllData = true)
public class Test_CreateOpportunity {    
    
    public static User createPartnerUser(){        
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner User with Sales Tools'];
                
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.BillingState = 'NY';   
        ac.Customer_Category__c = 'Enterprise';   
        ac.GEO__c='NA';
        ac.Enterprise_ID__c = '1234te';       
        ac.Enterprise_Account_Name__c = 'rdName';
        ac.RecordTypeId =SystemIdUtility.getTerritoryAcctRecordTypeId();
        ac.Commercial_ID__c = 'asdf';
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con; 
        
        User partnerUser = new User(alias = 'test123', email='test123@noemail.com',emailencodingkey='UTF-8',
                                    lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                                    profileid = p.Id, country='United States',IsActive =true,ContactId = con.Id,
                                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com',firstName= 'test');
        
        insert partnerUser;         
        return partnerUser;        
    }
    
    public static User createPartnerUserDisti(){        
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner User with Sales Tools'];
                
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.BillingState = 'NY';   
        ac.Customer_Category__c = 'Enterprise';   
        ac.GEO__c='NA';
        ac.Enterprise_ID__c = '1234te';       
        ac.Enterprise_Account_Name__c = 'rdName';
        ac.RecordTypeId =SystemIdUtility.getTerritoryAcctRecordTypeId();
        ac.Commercial_ID__c = 'asdf';
        ac.Solution_Provider_Type__c = 'Distributor';
        insert ac; 
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con; 
        
        User partnerUser = new User(alias = 'test123D', email='test123Disti@noemail.com',emailencodingkey='UTF-8',
                                    lastname='TestingDisti', languagelocalekey='en_US',localesidkey='en_US',
                                    profileid = p.Id, country='United States',IsActive =true,ContactId = con.Id,
                                    timezonesidkey='America/Los_Angeles', username='testerDisti@noemail.com',firstName= 'testDisti');
        
        insert partnerUser;         
        return partnerUser;        
    }
    
    public static Opportunity createTestOpp(String oppType){
        SystemIdUtility.skipOpportunityTriggers = true;
        SystemIdUtility.skipOpportunityLineItemTriggers  = true;
        String currencyIsoCode = 'USD';
        
        Id recid = SystemIdUtility.getResellerDistRecordTypeId();        
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
        ID SMBRecTypeId= RecordTypes_Setting__c.getValues('SMB').RecordType_Id__c; 
        System.debug('SMBRecTypeId:'+SMBRecTypeId);
        
        Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA',
                                           Alliance__c = true,Alliance_CAM_PMFKey__c = 'ABCDE01', Velocity_Seller__c = true,Service_Provider__c = true,
                                           Solution_Provider__c = true,Solution_Provider_CAM_PMFKey__c = 'ABCDE01', Primary_RTM_Data_Management__c = true,
                                           Service_Provider_CAM_PMFKey__c = 'ABCDE01',Velocity_Seller_CAM_PMFKey__c = 'ABCDE01');        
        //Test.Starttest();
        insert resellerAcct; 
       
        System.debug('resellerAcct:'+resellerAcct.Id);
        Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct; 
        // Test.Stoptest(); 
        System.debug('smbAcct:'+smbAcct.Id);
        RecordType recopp = [select Id from Recordtype where IsActive=true and SObjectType='Opportunity' and Name='New Opportunity'];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Oppty';
        if(oppType == '2 Tier') opp.What_is_your_Role__c = 'Reseller';
        opp.Did_the_deal_originate_from_a_campaign__c = 'Yes';
        opp.AccountId = smbAcct.Id;
        opp.Reseller__c= resellerAcct.Id;
        opp.Closedate = System.today();
        opp.StageName = '10% - Identification & Qualification';
        opp.CurrencyIsoCode = currencyIsoCode;
        opp.RecordTypeId = recopp.Id;
        opp.Type =  oppType;//'1 Tier';
        insert opp;
        System.debug('opp:'+opp.Id);
        return opp;
    }  
    
    public static PriceBook2 getPriceBook2(){
       //Pricebook2 customPB = new Pricebook2 (name = 'Test Price bookOP', Description = 'desc', isactive = true);
       //insert customPB;
      // Id = Test.getStandardPricebookId();
       Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];       
       return pbook;
    }
    
    public static List<Product2> createProducts(){
        List<Product2> prodList = new List<Product2>();        
        prodList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'SA', Family = 'Product', ProductCode = 'testProdCode1'));
        prodList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'VSA', Family = 'Support', ProductCode = 'testProdCode1'));
        prodList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'PPM', Family = 'Services', ProductCode = 'testProdCode1'));
        prodList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'SEC', Family = 'Education', ProductCode = 'testProdCode1'));
        prodList.add(new Product2(Name = 'Test Product1', Market_Focus_Area__c = 'MAINFRAME', Family = 'Renewal', ProductCode = 'testProdCode1'));        
        insert prodList;
        return prodList;
  }
    
    public static List<Pricebookentry> createPriceBookEntryList(){
        String currencyIsoCode = 'USD';
        Id pbeId= Test.getStandardPricebookId();
        Pricebook2 customPB = Test_CreateOpportunity.getPriceBook2();
        List<Product2> productList = Test_CreateOpportunity.createProducts();
        
        List<Pricebookentry> priceBookEntryList = new List<Pricebookentry>();        
        priceBookEntryList.add( new Pricebookentry(
            pricebook2Id = pbeId,//customPB.Id,
            Product2Id = productList[0].Id,
            UnitPrice = 0.0,
            Isactive = true,
            CurrencyIsoCode = CurrencyIsoCode,
            UseStandardPrice = false));
        
        priceBookEntryList.add( new Pricebookentry(
            pricebook2Id = pbeId,//customPB.Id,
            Product2Id = productList[1].Id,
            UnitPrice = 0.0,
            Isactive = true,
            CurrencyIsoCode = CurrencyIsoCode,
            UseStandardPrice = false));
        
        priceBookEntryList.add( new Pricebookentry(
            pricebook2Id = pbeId,//customPB.Id,
            Product2Id = productList[2].Id,
            UnitPrice = 0.0,
            Isactive = true,
            CurrencyIsoCode = CurrencyIsoCode,
            UseStandardPrice = false));
        
        priceBookEntryList.add( new Pricebookentry(
            pricebook2Id = pbeId,//customPB.Id,
            Product2Id = productList[3].Id,
            UnitPrice = 0.0,
            Isactive = true,
            CurrencyIsoCode = CurrencyIsoCode,
            UseStandardPrice = false));
        
        priceBookEntryList.add( new Pricebookentry(
            pricebook2Id = pbeId,//customPB.Id,
            Product2Id = productList[4].Id,
            UnitPrice = 0.0,
            Isactive = true,
            CurrencyIsoCode = CurrencyIsoCode,
            UseStandardPrice = false));
          
        insert priceBookEntryList;
         System.debug('priceBookEntryList:'+priceBookEntryList);
         return priceBookEntryList;
    }
    
    public static List<OpportunityLineItem> createOpportunityLineItemList(Id oppId){
        
        List<PricebookEntry> priceBookEntryList = Test_CreateOpportunity.createPriceBookEntryList();       
        
        List<OpportunityLineItem> optyLineItemList = new List<OpportunityLineItem>();
        
        optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = oppId,QUANTITY = 1,
                                                     PRICEBOOKENTRYID = priceBookEntryList[0].Id,
                                                     UNITPRICE = 6000000,                               
                                                     BUSINESS_TYPE__C = 'Capacity',Deal_Registration__c = 'Yes'
                                                    ));
        optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = oppId,QUANTITY = 1,
                                                     PRICEBOOKENTRYID = priceBookEntryList[1].Id,
                                                     UNITPRICE = 6000000,                               
                                                     BUSINESS_TYPE__C = 'Capacity',Deal_Program_Eligibility_Status__c = 'Sepearte Program'
                                                    ));
        optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = oppId,QUANTITY = 1,
                                                     PRICEBOOKENTRYID = priceBookEntryList[2].Id,
                                                     UNITPRICE = 6000000,                               
                                                     BUSINESS_TYPE__C = 'Capacity'
                                                    ));
        optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = oppId,QUANTITY = 1,
                                                     PRICEBOOKENTRYID = priceBookEntryList[3].Id,
                                                     UNITPRICE = 6000000,                               
                                                     BUSINESS_TYPE__C = 'Capacity'
                                                    ));
        optyLineItemList.add(new OpportunityLineItem(OPPORTUNITYID = oppId,QUANTITY = 1,
                                                     PRICEBOOKENTRYID = priceBookEntryList[4].Id,
                                                     UNITPRICE = 6000000,                               
                                                     BUSINESS_TYPE__C = 'Capacity'
                                                    ));        
        insert optyLineItemList;
        System.debug('optyLineItemList:'+optyLineItemList);
        return optyLineItemList;
    }
    
    static testMethod void testOpplineRemoteActions_PRM(){
        User pUser = Test_CreateOpportunity.createPartnerUser();
        System.runAs(pUser){
           
            Opportunity opp = Test_CreateOpportunity.createTestOpp('1 Tier');
           
            System.debug('Opportunity :'+opp);
            //Test_CreateOpportunity.createOpportunityLineItemList(opp.Id);
        }
           
    }

}