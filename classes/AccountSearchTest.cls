@isTest
private class AccountSearchTest{
 @isTest(SeeAllData=true)   
 static void runTestCases() 
    { 
    
    recordtype[] recs = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType ='account' and r.name in ('Commercial Account','CA Enterprise Account')];
    id ent = SystemIdUtility.getAccountTeamAcctRecordTypeId();
    id com = SystemIdUtility.getSMBAcctRecordTypeId();
    /*for(recordtype rec: recs)
        if(rec.name == 'Commercial Account')
                com = rec.id;
        else
                ent = rec.id; */
                        
    
    account p = new account(name = 'par', recordtypeid = ent);
    p.customer_Category__c= 'MSP';
    p.hq__c= true;
    p.Commercial_Account_Name__c='test 11111111'  ;
    p.Commercial_ID__c= 'test 11111112';
    p.Country_Picklist__c= 'CA - CANADA';
    p.GEO__c= 'NA';
    p.Sales_Area__c= 'CANADA';
    p.Sales_Region__c= 'CANADA';
    p.Billingstate= 'A';
    p.Billingcity= 'B';
    p.Billingstreet= 'C';
    
    
    
    insert p;
    account a = new account(name ='we', recordtypeid = com);
    a.parentId = p.Id;
    a.customer_Category__c= 'AAM';
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
   
    p.GEO__c= 'NA';
    P.Customer_Category__c = 'ASASAS 111';
    p.Sales_Area__c= 'NA';
    p.Sales_Region__c= 'NA_CORPORATE';
    Update p;
    
  
    
    ctrlAccountFilter cls = new ctrlAccountFilter();
    cls.accname= 'wells';
  //  cls.recType= '';
    cls.custCat= 'aaaa';
    cls.parentId= p.Id;
    cls.hq= true;
    cls.commAccName='test 11111111'  ;
    cls.commId= 'test 11111112';
    cls.countryPick= 'CA - CANADA';
    cls.geo= 'NA';
    cls.salesArea= 'CANADA';
    cls.salesRegion= 'CANADA';
    cls.state= 'A';
    cls.city= 'B';
    cls.street= 'C';
    
    cls.go();
    cls.search();
    
    ApexPages.currentPage().getParameters().put('Id',a.Id);
    
    ctrlAccounts cls2 = new ctrlAccounts();
    
  
    
    }
    @isTest(SeeAllData=true)
    static void runTestCases2() 
    { 
    
    recordtype[] recs = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType ='account' and r.name in ('Commercial Account','CA Enterprise Account')];
    id ent = SystemIdUtility.getAccountTeamAcctRecordTypeId();
    id com = SystemIdUtility.getSMBAcctRecordTypeId();
    /*for(recordtype rec: recs)
        if(rec.name == 'Commercial Account')
                com = rec.id;
        else
                ent = rec.id; */
                        
    
    account p = new account(name = 'par', recordtypeid = ent);
    p.customer_Category__c= 'MSP';
    p.hq__c= true;
    p.Commercial_Account_Name__c='test 11111111'  ;
    p.Commercial_ID__c= 'test 11111112';
    p.Country_Picklist__c= 'CA - CANADA';
    p.GEO__c= 'NA';
    p.Sales_Area__c= 'CANADA';
    p.Sales_Region__c= 'CANADA';
    p.Billingstate= 'A';
    p.Billingcity= 'B';
    p.Billingstreet= 'C';
    insert p;
    
    user[] users = [select id from user where isactive = true limit 10];
    List<AccountTeamMember> lst = new List<AccountTeamMember>();
    for(user usr:users)
    {
      lst.add(new AccountTeamMember(UserId = usr.Id, TeamMemberRole ='CSA', accountId = p.id));
    }
    try
    {
        insert lst;
    }
    catch (exception e) 
    {
        System.debug('Error...');
    }
   
    
    account a = new account(name ='we', recordtypeid = com);
    
    a.customer_Category__c= 'AAM';
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
   
    a.parentId = p.Id;
    Update a;
 
 }
 
 @isTest(SeeAllData=true)
 static void runOppStageTestCases() 
    {       
            //ID COMM = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType ='account' and r.name in ('SMB') LIMIT 1].iD; //Commented THAAN04_PRM5.5Release

            //Added this to get Reseller/Distributor Account record type ID as Reseller__c Account can be only of this type
            ID COMM = [Select r.Name, r.Id From RecordType r where r.Name='Reseller/Distributor Account' limit 1].Id;
            ID rectypeid = [Select r.Name, r.Id From RecordType r where r.Name='SMB' limit 1].Id;
            
            account a = new account(name ='we', recordtypeid = rectypeid);
            
            account reselleracc = new account (name = 'testacc', recordtypeid = COMM);
            
            a.customer_Category__c= 'AAM';
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
            
            Opportunity opp = new Opportunity();
            opp.accountid = a.id;
            opp.Reseller__c= reselleracc.id;
            opp.name = 'test';
            opp.stagename = '60% - Proposal';
            opp.CloseDate = date.today();
            insert opp;
            
            contact con = new contact (firstname = 'testconname', lastname = 'lastname', AccountId = a.id);
            insert con;
            
            OpportunityContactRole oppcon = new OpportunityContactRole(IsPrimary = true, OpportunityId = opp.id, contactId = con.id);
            insert oppcon ;
            
        
        opp.stagename = '70%-Pricing Agreement';
        update opp;
        
        delete a;
        
     }
    

 }