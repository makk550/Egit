@isTest 
private class DE_Stnd_New_Over_CLS_Test{

static testMethod void ValidateRedirect(){
    List<RecordTypes_Setting__c> rectypes = new List<RecordTypes_Setting__c>();
    RecordTypes_Setting__c rec1 = new RecordTypes_Setting__c(Name = 'SMB', SObject_Name__c = 'Account', RecordType_Id__c = '01230000001L55jAAC');
    rectypes.add(rec1);  
      
    RecordTypes_Setting__c rec2 = new RecordTypes_Setting__c(Name = 'Territory Covered Account', SObject_Name__c = 'Account', RecordType_Id__c = '01230000001L55o');
   rectypes.add(rec2); 
    
    RecordTypes_Setting__c rec3 = new RecordTypes_Setting__c(Name = 'Account Team Covered Account', SObject_Name__c = 'Account', RecordType_Id__c = '01230000001L55e');
    rectypes.add(rec3); 
      
    RecordTypes_Setting__c rec4 = new RecordTypes_Setting__c(Name = 'Reseller/Distributor Account', SObject_Name__c = 'Account', RecordType_Id__c = '01230000000GaFd');
   rectypes.add(rec4); 
   
   RecordTypes_Setting__c rec5 = new RecordTypes_Setting__c(Name = 'Commercial Account', SObject_Name__c = 'Account', RecordType_Id__c = '01230000000GaFY');
   rectypes.add(rec5); 
   
    RecordTypes_Setting__c rec6 = new RecordTypes_Setting__c(Name = 'CA Enterprise Account', SObject_Name__c = 'Account', RecordType_Id__c = '01230000000DNfM');
    rectypes.add(rec6); 
    
    RecordTypes_Setting__c rec7 = new RecordTypes_Setting__c(Name = 'Technology Partner', SObject_Name__c = 'Account', RecordType_Id__c = '01230000000f5Sl');
   rectypes.add(rec7); 
   
    RecordTypes_Setting__c rec8 = new RecordTypes_Setting__c(Name = 'Support Account', SObject_Name__c = 'Account', RecordType_Id__c = '012190000008V0S');
   rectypes.add(rec8); 
   
   insert rectypes;
   
         ApexPages.currentPage().getParameters().put('RecordType', '012190000008V0S');   
         Account acc= new Account(Name='CA ITC',BillingCity='asd',BillingCountry='US',BillingStreet='asd',Account_Status__c='New');
            insert acc;
         ApexPages.StandardController sc = new ApexPages.standardController(acc);           
         DE_Stnd_New_Over_CLS butcontr = new DE_Stnd_New_Over_CLS (sc);
         butcontr.redir();
         ApexPages.currentPage().getParameters().put('RecordType', '01230000000DNfM'); 
          Account acc1= new Account(Name='CA1 ITC',BillingCity='asd',BillingCountry='CANADA',BillingStreet='asd',Account_Status__c='New');
          insert acc1;        
         ApexPages.StandardController sc1 = new ApexPages.standardController(acc1);       
         DE_Stnd_New_Over_CLS butcontr1 = new DE_Stnd_New_Over_CLS (sc1);
         butcontr1.redir();
          ApexPages.currentPage().getParameters().put('RecordType', '01230000000f5Sl'); 
          Account acc2= new Account(Name='CA1 ITC',BillingCity='asd',BillingCountry='CANADA',BillingStreet='asd',Account_Status__c='New');
          insert acc2;        
         ApexPages.StandardController sc2 = new ApexPages.standardController(acc2);       
         DE_Stnd_New_Over_CLS butcontr2 = new DE_Stnd_New_Over_CLS (sc2);
         butcontr2.redir();
        
}
}