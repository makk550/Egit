@isTest
private class CreateExternalRndClass_test{
    
   static testMethod void createTestData(){
       Id saasRecordTypeId = Schema.SObjectType.External_RnD__c.getRecordTypeInfosByName().get('Saas Ops Incident').getRecordTypeId();
       External_RnD__c extRnd = new External_RnD__c();
       extRnd.recordtypeId = saasRecordTypeId ;
       extRnd.Description__c='test Description';
       insert extRnd;
       
       Apexpages.StandardController stdController = new Apexpages.StandardController(extRnd); 
       CreateExternalRndClass  createExtRnd = new CreateExternalRndClass(stdController);
       createExtRnd.continueRedirect();
       createExtRnd.getRecordTypes();
       createExtRnd.selectedRecordTypeID=saasRecordTypeId ;
        createExtRnd.continueRedirect();
        Id externalRecordTypeId = Schema.SObjectType.External_RnD__c.getRecordTypeInfosByName().get('External RnD').getRecordTypeId();
        createExtRnd.selectedRecordTypeID=externalRecordTypeId ;
         createExtRnd.continueRedirect();
       
   }
}