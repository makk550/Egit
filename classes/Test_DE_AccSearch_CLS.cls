@istest(SeeAllData=true) 
private class Test_DE_AccSearch_CLS{

    static testMethod void unitTestAccSearch()
    {
        PageReference pageRef = Page.DE_AccSearch_VFP;
        //ApexPages.setCurrentPage(pageRef);
        Test.startTest();
        Account testAccnew = new Account(Name='Test Account',
        RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller/Distributor Account').getRecordTypeId());
        
        insert(testAccnew);
        
       Lead l = new Lead();
       l.FirstName = 'test lead';
       l.LastName = 'test lead';
       l.Status = 'Pursuing';
       l.Meeting_Rating__c = 'N/A';
       l.Company = 'CA';
       l.Country_Picklist__c = 'SA - Saudi Arabia';
       l.City = 'Dammam';
       l.State = 'Eastern';
       l.Street = 'street 2312';
       
       l.RecordTypeId= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CA Global Lead').getRecordTypeId();
       insert l;

       Site_Association__c newSite = new Site_Association__c(Site_Status__c = 'Approved', SAP_Site_ID__c = '999999' , System__c = 'S',Street__c = 'Street', 
            Country_Picklist__c = 'US - United States', State__c = 'FL - Florida', Postal_Code__c = '45623',City__c = 'City',  
            Region__c = 'APJ' ,DUNS_Number__c = '656818705',DUNS_Name__c = 'ABACUS DISTRIBUTION SYSTEMS LTD.',Area__c = 'HONG KONG/TAIWAN',
            Territory_Country__c = 'TAIWAN',GP_DUNS_NUMBER__c = '675708655',GP_NAME__c = 'ABACUS DISTRIBUTION SYSTEMS TAIWAN LTD');
       insert newsite;
       
       
       ID hdnAccountID = testAccnew.id;
       String hdnAccountName = testAccnew.name;
       ID leadid = l.id;
       
        ApexPages.currentPage().getParameters().put('namefield', 'thePage:theForm:theBlock:'+hdnAccountName);
        ApexPages.currentPage().getParameters().put('idfield', 'thePage:theForm:theBlock:'+hdnAccountID);
        ApexPages.currentPage().getParameters().put('lid', leadid);
        ApexPages.currentPage().getParameters().put('sid', newsite.Id);
        
        DE_AccSearch_CLS srchController = new DE_AccSearch_CLS();
        
        srchController.gotoPrevAccSrch();
        srchController.gotoPrevScreen();
        srchController.loadheader();
        srchController.getCountries();
        srchController.getStateRegionsForCANADA();
        srchController.getStateRegionsFor_US();
        
        srchController.accountName = 'Test 123';
        srchController.physicalCountry  = 'US - United States';
        srchController.physicalState = 'Florida';
        srchController.physicalStateUS = 'Florida';
        srchController.isTaqProcess = false;
        srchController.selAccId1 = testAccnew.Id;
        srchController.selAccId = '132665238';
        
        srchController.SearchAcc();
        srchController.SearchNext();
        
        srchController.selectAccId();
        srchController.selectAccDuns();
        srchController.nextPage();
        
        /*
        DE_AccResWithDuns_CLS testAcc = new DE_AccResWithDuns_CLS();
        testAcc.accName=srchController.accountName;      
        testAcc.street='lane 123';      
        testAcc.city ='scottsdale';      
        testAcc.state =srchController.physicalState;      
        testAcc.country =srchController.physicalCountry;      
        testAcc.zipCode='47512478';      
        testAcc.geo='NA';      
        testAcc.GPAccNo='122221';      
        testAcc.GPAccName='test';      
        testAcc.opparea='ANZ';      
        testAcc.salReg='RIO';      
        testAcc.GPSeg='Other';     
        testAcc.territory='BARBADOS';      
        testAcc.segment='Growth';      
        testAcc.coverMod='Territory'; 
        testAcc.accDunsNo='1232334';
        
        srchController.objacc = new DE_AccResWithDuns_CLS();
        srchController.objacc = testAcc;
        */
       Test.stopTest();  
        
        srchController.createTaqAccount();
        
        
    }
}