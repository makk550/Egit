@isTest
private class Renewal_editOppProduct_test {

    static testMethod void OppTest() {
               
        //RecordType recopp = [select Id from Recordtype where IsActive=true and SObjectType='Opportunity' and Name='New Opportunity'];
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;        
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();          
        Id recopp = oppRecType.get('New Opportunity').getRecordTypeId(); 
        
        Schema.DescribeSObjectResult accresult = Schema.SObjectType.Account;        
        Map<String,Schema.RecordTypeInfo> accRecType = accresult.getRecordTypeInfosByName();          
        
           //recordtype[] recs = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType ='account' and r.name in ('SMB','Reseller/Distributor Account')];
                    id res = accRecType.get('Reseller/Distributor Account').getRecordTypeId();
                    id com = accRecType.get('SMB').getRecordTypeId();
                    /*for(recordtype rec: recs)
                        if(rec.name == 'SMB')
                                com = rec.id;
                        else
                                res = rec.id;*/
                    account a = new account(name ='we', recordtypeid =res);
                    a.customer_Category__c= 'Reseller';
                    a.hq__c= true;
                    a.Commercial_Account_Name__c='test 11111114'  ;
                    a.Commercial_ID__c= 'test 11111115';
                    a.Country_Picklist__c= 'JP - JAPAN';
                    a.GEO__c= 'JAPAN';
                    a.Sales_Area__c= 'JAPAN';
                    a.Sales_Region__c= 'JAPAN';
                    a.Billingstate= 'A';
                    a.Billingcity= 'B';
                    a.Billingstreet= 'C';
                    insert a;
        SystemIdUtility.skipOpportunityLineItemTriggers = true;
        Opportunity opp = new Opportunity(RecordTypeId=recopp,Reseller__c = a.Id,
         Name = 'TestOpp' ,
         StageName = 'test' , 
         CloseDate = Date.today(),
         New_Deal_Term_months__c = 12, 
         Stretch_Deal_Term_Months__c = 8,
         Stretch_Sales_Price_Gap_Reason__c = 'Technical Problems',
         Business_Type__c = 'High Touch',
         Projected_Renewal__c = 12345.0);
         insert opp;
                 
        Pricebook2 pb2 = [SELECT Id  FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        /*Pricebook2 pb2 = new Pricebook2 (name = 'Test Price bookOP', Description = 'desc', isactive = true);
       insert pb2;*/
        Product2 prod2 = new Product2(Name = 'testprod');                    
        insert prod2;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = prod2.Id , UnitPrice = 100.00, IsActive = TRUE);                    
        insert pbe;
        
        OpportunityLineItem oppli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1);                    
        insert oppli;
        
        List<OpportunityLineItem> OppItmList =new List<OpportunityLineItem>();
        for(integer i=0;i<15;i++)
        {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, UnitPrice = 200 );
            OppItmList.add(oli);
            i=i++;
        }
           insert OppItmList;
        
        CA_Product_Renewal__c ca =new CA_Product_Renewal__c(Name ='TestCA',Renewal_Opportunity__c = opp.Id,Quote__C ='testquote');
        insert ca;
        
        Opportunity retOpp = [Select id, Quote_Number__c, Contract_Number_EU4cast__c,name,New_Deal_Term_months__c, 
                                     Total_Raw_Maintenance_Cacl__c, Stretch_Deal_Term_Months__c, Stretch_Sales_Price_Gap_Reason__c, 
                                     Business_Type__c, Projected_Renewal__c
                        From Opportunity where id = :opp.Id LIMIT 1];   
        retOpp.Quote_Number__c = '7897946';   
        retOpp.Contract_Number_EU4cast__c='7897946'; 
        retOpp.New_Deal_Term_months__c = 24;
       Test.startTest();                                      
        update retOpp;
        
        OpportunityLineItem retOppLI = [SELECT Id,UnitPrice,Stretch__c,Quote_Number__c,Contract_Number__c FROM OpportunityLineItem  WHERE Id = :oppli.Id LIMIT 1];
        retOppLI.UnitPrice = retOpp.Projected_Renewal__c;
        retOppLI.Stretch__c = 15000.0;
        update retOppLI;
       
        CA_Product_Renewal__c rwnpdt =[select Id, Quote__C, Contract_No__c, Projected_Renewal__c,Active_Contract_Product__c from CA_Product_Renewal__c where Renewal_Opportunity__c =:opp.Id]; 
         rwnpdt.Quote__C = retOpp.Quote_Number__c;   
         rwnpdt.Contract_No__c =retOpp.Contract_Number_EU4cast__c;
         
        update rwnpdt;
        
          
       
        PageReference pageRef = Page.Renewal_editOppProduct;
        Test.setCurrentPage(pageRef);
        
        
                    
        ApexPages.StandardController con = new ApexPages.StandardController(new Opportunity(id=opp.Id));        
        
        pageRef.getParameters().put('Id',opp.Id);
        Renewal_editOppProduct ctrl = new Renewal_editOppProduct(con);
        
        PageReference pg =new PageReference('/'+opp.id);
        pg.setRedirect(true);
       
        ctrl.PopulateRenewalProducts();
        ctrl.acpage =5;
        ctrl.PageSize =10;
        ctrl.setSortDirection('ASC');
        ctrl.setPageSize(5);
        ctrl.ContractNo = 12345.0;
        ctrl.getOppItmList();
        ctrl.applyFilter();
        ctrl.npages = 10;
        ctrl.Product_Name_Filter ='testprod';
        ctrl.Orig_Exp_Date_Filter ='';
       
        ctrl.Raw_Maint_Calc_Filter='';
        ctrl.Sales_Price_Filter='';        
        ctrl.Quote_Filter='';
        ctrl.Contract_Filter='';
        ctrl.BusinessType_Filter='';
         Test.stopTest(); 
       // ctrl.mainMethod();
        ctrl.opp_temp = opp;
        ctrl.setOppItmList(OppItmList);
        ctrl.getOppItmList();
        ctrl.getPageSize();
        ctrl.ViewData();   
        ctrl.clearFilter();
        ctrl.ContractNo = 456123.0;
       // ctrl.updateOpportunity();
        //ctrl.updateProducts();
        ctrl.next();
        ctrl.previous();
        ctrl.getHasNext();
        ctrl.getHasPrevious();
        ctrl.getResultSize();
        ctrl.getSortDirection(); 
        ctrl.clearFilter();
        ctrl.quote ='1213';
        ctrl.showMsg = false;
        
        
        
        }  
        
        
    }