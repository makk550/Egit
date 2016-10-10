@isTest(seealldata = true)
private class testmethod_opportunity
{
    
    /*static testmethod void OpportunityUpdate()
    {
        SystemIdUtility.skipOpportunityTriggers = true;
SystemIdUtility.skipOpportunityLineItemTriggers  = true;
        
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
        //Get the opportunity recordtype id
        Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
        Id oppAquRecId = oppRecType.get('Acquisition').getRecordTypeId();
        
        Product2 prd1 = new Product2(Name='Prd1',Family='Product',Market_Focus_Area__c='SECURITY',IsActive=true);
        Product2 prd2 = new Product2(Name='Prd2',Family='Time',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd3 = new Product2(Name='Prd3', Family='MainframeCapacity',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd4 = new Product2(Name='Prd4', Family='Services',Market_Focus_Area__c='MAINFRAME',IsActive=true);
        Product2 prd5 = new Product2(Name='Prd5', Family='Support',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd6 = new Product2(Name='Prd6', Family='Education',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2[] prd = new Product2[]{prd1,prd2,prd3,prd4,prd5,prd6};
        insert prd;
        
        Pricebook2 pb = new Pricebook2();
        pb = [Select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe4 = new PricebookEntry(Product2Id=prd[3].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe5 = new PricebookEntry(Product2Id=prd[4].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe6 = new PricebookEntry(Product2Id=prd[5].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3,pbe4,pbe5,pbe6};
        insert pbe; 
        
        Account acc = new Account(Name='Test_Acc1', recordtypeid = SystemIdUtility.getResellerDistRecordTypeId(), Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',
        BillingStreet='XYZ',BillingCountry='USA',BillingCity='New York');
        insert acc;
       
       
       ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
       ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
       Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
        insert resellerAcct;                        
       Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct;
       
       //Anitha
        Account distributorAccount = new Account(); //Reseller/Distributor Account
        distributorAccount.Name = 'Test AniAccount';
        distributorAccount.CurrencyIsoCode = 'USD';
        distributorAccount.Account_Type__c = 'Distributor';
        distributorAccount.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId(); 
        insert distributorAccount;      

        Account distributer = new Account();
        distributer.Name = 'Test Account';
        distributer.BillingState = 'NY';   
        distributer.Customer_Category__c = 'Reseller';
        distributer.Account_Status__c = 'Approved';
        distributer.Reseller_Type__c = 'Value';
        distributer.CPMS_ID__c = '1900';
        distributer.BillingState = 'NY';
        distributer.Reseller_Disti_Regional_ID__c = '12';
        distributer.Reseller_Distributor_Name__c = 'rdName';
        distributer.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId();                

             
        System.debug('=========='+ SystemIdUtility.getResellerDistRecordTypeId());
        insert distributer;
        System.debug('=========='+ distributer.id);

        SystemIdUtility.skipOpportunityTriggers=true;
        Opportunity opp1 = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp1',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='10% -Identification & Qualification',Initial_Billing__c=2,Ent_Comm_Account__c=smbAcct.Id);       
        Opportunity opp2 = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp2',RecordTypeId=oppRecId,CloseDate=System.today()+5,StageName='50%-Proposal Created',Initial_Billing__c=2,Ent_Comm_Account__c=smbAcct.Id);
        Opportunity opp3 = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp3',RecordTypeId=oppAquRecId ,CloseDate=System.today()+5,StageName='50%-Proposal Created',Initial_Billing__c=2,Ent_Comm_Account__c=smbAcct.Id);
      
      
        //  Opportunity opp3 = new Opportunity(AccountId=distributer.Id,Name='OppAni',RecordTypeId=oppAquRecId ,CloseDate=System.today()+5,StageName='50%-ProposalCreated',Initial_Billing__c=2,Distributor_6__c=distributorAccount.Id);
       // Opportunity[] opp = new Opportunity[]{opp1,opp2,opp3};
       Opportunity[] opp = new Opportunity[]{opp1,opp2, opp3};
       
        insert opp;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[1].Id);
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[2].Id);        
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[3].Id);
        OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[4].Id);
        OpportunityLineItem oli6 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[5].Id);        
        OpportunityLineItem oli7 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[4].Id);
        OpportunityLineItem oli8 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[5].Id);
        OpportunityLineItem oli9 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[3].Id);        
        OpportunityLineItem oli10 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem oli11 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[1].Id);
        OpportunityLineItem oli12 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[2].Id);        
        OpportunityLineItem oli13 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1,oli2,oli3,oli4,oli5,oli6,oli7,oli8,oli9,oli10,oli11,oli12,oli13};        
        insert oli;
        
        delete oli[0];
        
        opp[0].CloseDate = System.today()+7;
        opp[1].StageName = '100%-Contract Signed';
        update opp;
        
    }*/
    
    static testmethod void testVF()
    {
        
        
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
        //Get the opportunity recordtype id
        Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
        
        Product2 prd1 = new Product2(Name='Prd1', Family='Product',Market_Focus_Area__c='SECURITY',IsActive=true);
        Product2 prd2 = new Product2(Name='Prd2', Family='Time',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd3 = new Product2(Name='Prd3', Family='MainframeCapacity',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd4 = new Product2(Name='Prd4', Family='Services',Market_Focus_Area__c='MAINFRAME',IsActive=true);
        Product2 prd5 = new Product2(Name='Prd5', Family='Support',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd6 = new Product2(Name='Prd6', Family='Education',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2[] prd = new Product2[]{prd1,prd2,prd3,prd4,prd5,prd6};
        insert prd;
        
        Pricebook2 pb = new Pricebook2();
        pb = [Select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe4 = new PricebookEntry(Product2Id=prd[3].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe5 = new PricebookEntry(Product2Id=prd[4].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe6 = new PricebookEntry(Product2Id=prd[5].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3,pbe4,pbe5,pbe6};
        insert pbe; 
        
        /*Account acc = new Account(Name='Test_Acc1', RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId(), Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',
        BillingStreet='XYZ',BillingCountry='USA',BillingCity='New York');
        SystemIdUtility.isneeded = true;
        insert acc;
        */
        
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();


ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();



Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
        insert resellerAcct;                
        
Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct;
        
        Account enterpriseAccount = new Account();
        enterpriseAccount.Name = 'Test Account';
        enterpriseAccount.BillingState = 'NY';   
        enterpriseAccount.Customer_Category__c = 'Enterprise';
        enterpriseAccount.Account_Status__c = 'Approved';       
        enterpriseAccount.BillingState = 'NY';
        enterpriseAccount.GEO__c='NA';
        enterpriseAccount.Enterprise_ID__c = '1234te';
        enterpriseAccount.Enterprise_Account_Name__c = 'rdName';
        enterpriseAccount.Reseller_Disti_Regional_ID__c = 'PA75344';
        enterpriseAccount.Reseller_Distributor_Name__c = 'APJ DM Test';
        enterpriseAccount.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId();     

                          
        insert enterpriseAccount;      
        
        Opportunity opp = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp1',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='10% -Identification & Qualification',Initial_Billing__c=2);
        insert opp; 
        
        OpportunityLineItem oli1_1 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem oli1_2 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[1].Id);
        OpportunityLineItem oli1_3 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[3].Id);
        OpportunityLineItem oli1_4 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[4].Id);
        OpportunityLineItem oli1_5 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[5].Id);
        //OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1_3,oli1_4,oli1_5};
        
        PageReference opplinewpage1 = Page.OppLineItempage;
        opplinewpage1.getParameters().put('producttype','Product');
        opplinewpage1.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage1);
        ApexPages.StandardController stdcon1 = new ApexPages.StandardController(oli1_1);
        OppLineItemcontroller opplicontroller1 = new OppLineItemcontroller(stdcon1);
        opplicontroller1.addmore_prds();
        opplicontroller1.saveproducts();
        
        PageReference opplinewpage2 = Page.OppLineItempage;
        opplinewpage2.getParameters().put('producttype','Renewal');
        opplinewpage2.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage2);
        ApexPages.StandardController stdcon2 = new ApexPages.StandardController(oli1_2);
        OppLineItemcontroller opplicontroller2 = new OppLineItemcontroller(stdcon2);
        opplicontroller2.addmore_ren();
        opplicontroller2.saveproducts();
        /*
        PageReference opplinewpage3 = Page.AddOfferingsPage;
        opplinewpage3.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage3);
        ApexPages.StandardController stdcon3 = new ApexPages.StandardController(oli1_3);
        offeringscontroller opplicontroller3 = new offeringscontroller(stdcon3);
        opplicontroller3.saveproducts();
        
        ApexPages.StandardController stdcon4 = new ApexPages.StandardController(oli1_4);
        offeringscontroller opplicontroller4 = new offeringscontroller(stdcon4);
        opplicontroller4.saveproducts();
        
        ApexPages.StandardController stdcon5 = new ApexPages.StandardController(oli1_5);
        offeringscontroller opplicontroller5 = new offeringscontroller(stdcon5);
        opplicontroller5.saveproducts();
        */
        /*PageReference opplinewpage3 = Page.OppLineitem_View_Edit;
        opplinewpage3.getParameters().put('retURL',opp[0].Id);
        opplinewpage3.getParameters().put('id',oli[0].Id);
        Test.setCurrentPage(opplinewpage3);
        ApexPages.StandardController stdcon3 = new ApexPages.StandardController(oli[0]);
        OppLineitem_View_Edit_controller opplicontroller3 = new 

OppLineitem_View_Edit_controller(stdcon3);
        */
        
    }
    
      static testmethod void OpportunityUpdate1()
    {
        SystemIdUtility.skipOpportunityLineItemTriggers = true;
        SystemIdUtility.skipAccount = true;
        
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
        //Get the opportunity recordtype id
        Id oppRecId = oppRecType.get('Acquisition').getRecordTypeId();
        
        Product2 prd1 = new Product2(Name='Prd1',Family='Product',Market_Focus_Area__c='SECURITY',IsActive=true);
        Product2 prd2 = new Product2(Name='Prd2',Family='Time',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd3 = new Product2(Name='Prd3',Family='MainframeCapacity',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd4 = new Product2(Name='Prd4', Family='Services',Market_Focus_Area__c='MAINFRAME',IsActive=true);
        Product2 prd5 = new Product2(Name='Prd5', Family='Support',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd6 = new Product2(Name='Prd6', Family='Education',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2[] prd = new Product2[]{prd1,prd2,prd3,prd4,prd5,prd6};
        insert prd;
        
        Pricebook2 pb = new Pricebook2();
        pb = [Select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe4 = new PricebookEntry(Product2Id=prd[3].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe5 = new PricebookEntry(Product2Id=prd[4].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe6 = new PricebookEntry(Product2Id=prd[5].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3,pbe4,pbe5,pbe6};
        insert pbe; 
        
        Account acc = new Account(Name='Test_Acc1',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',
        BillingStreet='XYZ',BillingCountry='USA',BillingCity='New York');
        SystemIdUtility.isneeded = true;
        insert acc;
        
        Account enterpriseAccount = new Account();
        enterpriseAccount.Name = 'Test Account';
        enterpriseAccount.BillingState = 'NY';   
        enterpriseAccount.Customer_Category__c = 'Enterprise';
        enterpriseAccount.Account_Status__c = 'Approved';       
        enterpriseAccount.BillingState = 'NY';
        enterpriseAccount.GEO__c='NA';
        enterpriseAccount.Enterprise_ID__c = '1234te';
        enterpriseAccount.Enterprise_Account_Name__c = 'rdName';
        enterpriseAccount.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();     

                          
        insert enterpriseAccount;      
        
        Opportunity opp1 = new Opportunity(AccountId=acc.Id,Name='Opp1',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='10% - Identification & Qualification',Initial_Billing__c=2,Ent_Comm_Account__c=acc.Id);
        Opportunity opp2 = new Opportunity(AccountId=acc.Id,Name='Opp2',RecordTypeId=oppRecId,CloseDate=System.today()+5,StageName='50%-Proposal Created',Initial_Billing__c=2);
        Opportunity opp3 = new Opportunity(AccountId=acc.Id,Name='Opp2',RecordTypeId=oppRecId,CloseDate=System.today()+5,StageName='50%-Proposal Created',Initial_Billing__c=2);
        Opportunity opp4 = new Opportunity(AccountId=acc.Id,Name='Opp2',RecordTypeId=oppRecId,CloseDate=System.today()+5,StageName='50%-Proposal Created',Initial_Billing__c=2);
        Opportunity[] opp = new Opportunity[]{opp1,opp2,opp3,opp4};        
        insert opp; 
        
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[1].Id);
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[2].Id);
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[3].Id);
        OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[4].Id);
        OpportunityLineItem oli6 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[5].Id);
        OpportunityLineItem oli7 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[4].Id);
        OpportunityLineItem oli8 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[5].Id);
        OpportunityLineItem oli9 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[3].Id);
        OpportunityLineItem oli10 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem oli11 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[1].Id);
        OpportunityLineItem oli12 = new OpportunityLineItem(OpportunityId=opp[1].Id,PricebookEntryId = pbe[2].Id);
        OpportunityLineItem oli13 = new OpportunityLineItem(OpportunityId=opp[0].Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1,oli2,oli3,oli4,oli5,oli6,oli7,oli8,oli9,oli10,oli11,oli12,oli13};
        
        insert oli;
              
        
        //Anitha
        Account distributorAccount = new Account(); //Reseller/Distributor Account
        distributorAccount.Name = 'Test AniAccount';
        distributorAccount.CurrencyIsoCode = 'USD';
        distributorAccount.Account_Type__c = 'Distributor';
        distributorAccount.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId(); 
        insert distributorAccount;      

        Account resellerAccount = new Account(); //Reseller/Distributor Account
        resellerAccount.Name = 'Test AniAccount';
        resellerAccount.CurrencyIsoCode = 'USD';
        resellerAccount.Account_Type__c = 'Reseller';
        resellerAccount.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId(); 
        insert resellerAccount;
        
        Account partnerAccount = new Account(); 
        partnerAccount.Name = 'Test AniAccount';
        partnerAccount.CurrencyIsoCode = 'USD';
        partnerAccount.Account_Type__c = 'MSP';
        partnerAccount.Service_Provider__c = true;
        partnerAccount.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId(); 
        insert partnerAccount;
        
        Account allianceAccount = new Account(); 
        allianceAccount.Name = 'Test AniAccount';
        allianceAccount.CurrencyIsoCode = 'USD';
        allianceAccount.Alliance__c = true;
        allianceAccount.Account_Type__c = 'Alliance - influence';
        allianceAccount.RecordTypeId = SystemIdUtility.getResellerDistRecordTypeId(); 
        insert allianceAccount;
        
        opp[0].CloseDate = System.today()+7;
        //opp[0].Distributor_6__c = distributorAccount.Id;
        opp[1].StageName = '100%-Contract Signed';
        //opp[1].Reseller__c = resellerAccount.Id;
        opp[2].Partner__c = partnerAccount.Id;
        opp[3].Partner_1__c = allianceAccount.Id;
        //update opp;
        
        
    }
    
    static testmethod void testVF1()
    {
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
        //Get the opportunity recordtype id
        Id oppRecId = oppRecType.get('Acquisition').getRecordTypeId();
        
        Product2 prd1 = new Product2(Name='Prd1',Family='Product',Market_Focus_Area__c='SECURITY',IsActive=true);
        Product2 prd2 = new Product2(Name='Prd2',Family='Time',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd3 = new Product2(Name='Prd3', Family='MainframeCapacity',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd4 = new Product2(Name='Prd4', Family='Services',Market_Focus_Area__c='MAINFRAME',IsActive=true);
        Product2 prd5 = new Product2(Name='Prd5', Family='Support',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd6 = new Product2(Name='Prd6', Family='Education',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2[] prd = new Product2[]{prd1,prd2,prd3,prd4,prd5,prd6};
        insert prd;
        
        Pricebook2 pb = new Pricebook2();
        pb = [Select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe4 = new PricebookEntry(Product2Id=prd[3].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe5 = new PricebookEntry(Product2Id=prd[4].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe6 = new PricebookEntry(Product2Id=prd[5].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3,pbe4,pbe5,pbe6};
        insert pbe; 
        
        Account enterpriseAccount = new Account();
        enterpriseAccount.Name = 'Test Account';
        enterpriseAccount.BillingState = 'NY';   
        enterpriseAccount.Customer_Category__c = 'Enterprise';
        enterpriseAccount.Account_Status__c = 'Approved';       
        enterpriseAccount.BillingState = 'NY';
        enterpriseAccount.GEO__c='NA';
        enterpriseAccount.Enterprise_ID__c = '1234te';
        enterpriseAccount.Enterprise_Account_Name__c = 'rdName';
        enterpriseAccount.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();     
        enterpriseAccount.BillingCountry='USA';
                          
        insert enterpriseAccount;      
        
        Account acc = new Account(Name='Test_Acc1',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',
        BillingStreet='XYZ',BillingCountry='USA',BillingCity='New York');
        insert acc;
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Opp1',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='10% -Identification & Qualification',Initial_Billing__c=2);
        insert opp; 
        contact con = new contact (firstname = 'testconname', lastname = 'lastname', AccountId = acc.id);
        insert con;
            
        OpportunityContactRole oppcon = new OpportunityContactRole(IsPrimary = true, OpportunityId = opp.id, contactId = con.id);
        insert oppcon ;
        
        OpportunityLineItem oli1_1 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[0].Id);
        OpportunityLineItem oli1_2 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[1].Id);
        OpportunityLineItem oli1_3 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[3].Id);
        OpportunityLineItem oli1_4 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[4].Id);
        OpportunityLineItem oli1_5 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[5].Id);
        //OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1_3,oli1_4,oli1_5};
        
        PageReference opplinewpage1 = Page.OppLineItempage;
        opplinewpage1.getParameters().put('producttype','Product');
        opplinewpage1.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage1);
        ApexPages.StandardController stdcon1 = new ApexPages.StandardController(oli1_1);
        OppLineItemcontroller opplicontroller1 = new OppLineItemcontroller(stdcon1);
        opplicontroller1.addmore_prds();
        opplicontroller1.saveproducts();
        
        PageReference opplinewpage2 = Page.OppLineItempage;
        opplinewpage2.getParameters().put('producttype','Renewal');
        opplinewpage2.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage2);
        ApexPages.StandardController stdcon2 = new ApexPages.StandardController(oli1_2);
        OppLineItemcontroller opplicontroller2 = new OppLineItemcontroller(stdcon2);
        opplicontroller2.addmore_ren();
        opplicontroller2.saveproducts();
        opplicontroller2.addmore_prds();
        opplicontroller2.renfamily = 'Services';
        //opplicontroller2.fetchrenewalbu();
        opplicontroller2.fetchfamily();
        //OpportunityLineItem ol12 = opplicontroller2.calculateUFLicenseFee(oli1_1);
       
       }
    
}