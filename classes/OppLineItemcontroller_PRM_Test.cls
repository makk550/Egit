@isTest(seeAllData = true)
public class OppLineItemcontroller_PRM_Test{

 static testMethod void testNewProductMethods(){
        
        User pUser = Test_CreateOpportunity.createPartnerUser();
        System.runAs(pUser){
        SystemIdUtility.skipOpportunityTriggers = true;
        SystemIdUtility.skipOpportunityLineItemTriggers  = true;
        
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
        ID SMBRecTypeId= RecordTypes_Setting__c.getValues('SMB').RecordType_Id__c; 
        String oppType = '1 Tier';
        String currencyIsoCode = 'USD';
         Test.Starttest();
         Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA',
                                           Alliance__c = true,Alliance_CAM_PMFKey__c = 'ABCDE01', Velocity_Seller__c = true,Service_Provider__c = true,
                                           Solution_Provider__c = true,Solution_Provider_CAM_PMFKey__c = 'ABCDE01', Primary_RTM_Data_Management__c = true,
                                           Service_Provider_CAM_PMFKey__c = 'ABCDE01',Velocity_Seller_CAM_PMFKey__c = 'ABCDE01');        
        
        insert resellerAcct; 
       Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct; 
        
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
        
        Test.Stoptest();

        List<OpportunityLineItem> oppLtmList = Test_CreateOpportunity.createOpportunityLineItemList(opp.Id);
        ApexPages.currentPage().getParameters().put('oppid',opp.Id);

        ApexPages.Standardcontroller stdcontroller = new ApexPages.Standardcontroller(new OpportunityLineItem());
        OppLineItemcontroller_PRM OppLineItemClass = new OppLineItemcontroller_PRM(stdcontroller);
        OppLineItemcontroller_PRM.productwrapper pw = new OppLineItemcontroller_PRM.productwrapper();
        OppLineItemClass.searchString = 'Agile';
        OppLineItemcontroller_PRM.findSearchResult('Agile',opp.Id);
        OppLineItemClass.fetchBUproduct();
        OppLineItemClass.fetchPG();
        OppLineItemClass.Searchproducts();
        OppLineItemClass.saveDeal();
        OppLineItemClass.saveAndReturn();
        OppLineItemClass.addProduct();
        OppLineItemClass.addProduct2();
        OppLineItemClass.addAndReturn();        
        OppLineItemClass.addAndStay();        
        OppLineItemClass.refreshSelectProducts();        
        OppLineItemClass.checkBeforeDelete();        
        OppLineItemClass.deleteProducts();
        OppLineItemClass.checkBeforeRefreshProductTable(); 
        OppLineItemClass.refreshProductTable(); 
        OppLineItemClass.checkBeforeSearchByProductGroup(); 
        OppLineItemClass.searchByProductGroup(); 
        OppLineItemClass.getproductgroup();                                         
        OppLineItemClass.SetBU();
        OppLineItemClass.checkbefore();
        OppLineItemClass.checkBeforeReturn();
        OppLineItemClass.checkBeforeSearch(); 
        OppLineItemClass.checkBeforeClear();
        OppLineItemClass.continueClear();
        OppLineItemClass.closePopup();
        OppLineItemClass.cancel();
        OppLineItemClass.getDealEligibleProgramList();   
        OppLineItemClass.populateIsoCodeConversionMap();
        OppLineItemClass.getPrdctGrpPrgrmRelation();
        OppLineItemClass.getProgRanks(oppLtmList);
        OppLineItemClass.getMaxRankAndHeader(oppLtmList);
        OppLineItemClass.setEligibleOrSeparateStatus(oppLtmList);
        OppLineItemClass.progForEachProdCall();
        OppLineItemClass.addProgForEachProd(oppLtmList,True);
        //OppLineItemClass.refreshopp();                        
        OppLineItemClass.getPrgNumberfromNameMap('testProgName');   
        OppLineItemClass.dealEligibleStatusChange();   
        //OppLineItemClass.redirectToDetailPage();   
        
        }

                             
 }

}