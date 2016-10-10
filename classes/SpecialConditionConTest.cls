@isTest
private class SpecialConditionConTest{
  static testMethod void testSpecialCondition(){
      
       SystemIdUtility.skipAccount = true;
         SystemIdUtility.skipAccountOnMIPSUpdate = true;
         SystemIdUtility.skipProductTriggers = true;
         Account testAccount = new Account() ; 
         testAccount.Name = 'Generic Support Account Test'; 
         testAccount.Enterprise_ID__c = 'AR51855';
         testAccount.BillingStreet = 'Admiralty Ctr';
         testAccount.BillingCountry = 'HK';
         testAccount.BillingCity = 'ADMIRALTY';
         insert testAccount ; 
         
         Contact testContact = new Contact();
         testContact.LastName = 'test' ;
         testContact.FirstName = 'test' ; 
         testContact.Email = 'govda@ca.com';
         testcontact.SC_CONTACT_LDAPID__c='GOVDA01';    
         testContact.Phone = '1234567';
         insert testContact ; 
         
         Site_Association__c testSite = new Site_Association__c();
         testSite.Name = 'FINANCIAL SERVICES & THE TREASURY BUREA';
         testSite.ProviSite__c = 2; 
         testSite.Enterprise_ID__c =  testAccount.Id; 
         testSite.SC_SITE_Sanctioned_Party__c = 'No';
         testSite.SC_TOPS_ID__c = '788689';
         testSite.SC_SITE_Source__c = 'Support' ; 
         testSite.State__c = 'california';
         testSite.Country_picklist__c ='US - UNITED STATES';
         insert testSite ; 
        
        Special_Conditions__c  sc = new Special_Conditions__c();
        sc.Site_Association__c = testSite.id;
        sc.Active__c =true;
        sc.Special_Condition__c ='Condition: Renewal In Progress ( Max 3 Mos.)';
        sc.Start_Date__c =Date.today();
        sc.End_Date__c = Date.today()+1;
        
        insert sc;
        Apexpages.StandardController stdController = new Apexpages.StandardController(testSite);
        SpecialConditionCon con = new SpecialConditionCon(stdController);
        con.selectedSpecId = sc.id;
        con.doDelete();
        
        con.showmore();
        
       
        
      
  }
}