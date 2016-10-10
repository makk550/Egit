trigger xMattersAlert on Case (after insert, before update) {
   if (Trigger.isInsert) {   //insert 
if(trigger.New[0].Severity__c == '1') 
    {
   
   String endpoint = 'https://catech-poc.na5.xmatters.com/api/integration/1/functions/a11c8142-a726-4f5d-bb9f-dc8719160a3d/triggers';
    
   String caseid = '"Case ID":' + '"' + trigger.New[0].Id + '"';
   String description = '"Description":' + '"' + trigger.New[0].Description + '"';
   String priority = '"Priority":' + '"' + trigger.New[0].Priority + '"';
   String status = '"Status":' + '"' + trigger.New[0].Status + '"';
   List<CA_Product_Controller__c> caProductName = [Select Name from CA_Product_Controller__c where Id =:trigger.New[0].CA_Product_Controller__c limit 1];
   String product ='"Product":' + '"' + caProductName[0].Name + '"';
   String accountid = trigger.New[0].AccountID;
    String recordid = '"ID":' + '"' + trigger.New[0].Id + '"';
    String payload ='{' + recordid +',' + description +',' + caseid +',' + priority +',' + status +', ' + product +'}';
    
    // Methods defined as TestMethod do not support Web service callouts
    if (!Test.isRunningTest()) {
      xmattersreq.xRESTCall (endpoint,payload);
    }
    }
   }
    else if (Trigger.isUpdate &&  UtilityFalgs.xmatteralert ==false) { //update
        
     UtilityFalgs.xmatteralert =true;
        If (trigger.New[0].Severity__c!=Trigger.old[0].Severity__c && trigger.New[0].Severity__c == '1')
    {
   
   String endpoint = 'https://catech-poc.na5.xmatters.com/api/integration/1/functions/a11c8142-a726-4f5d-bb9f-dc8719160a3d/triggers';
   String caseid = '"Case ID":' + '"' + trigger.New[0].Id + '"';
   String description = '"Description":' + '"' + trigger.New[0].Description + '"';
   String priority = '"Priority":' + '"' + trigger.New[0].Priority + '"';
   String status = '"Status":' + '"' + trigger.New[0].Status + '"';
   List<CA_Product_Controller__c> caProductName = [Select Name from CA_Product_Controller__c where Id =:trigger.New[0].CA_Product_Controller__c limit 1];
   String product ='"Product":' + '"' + caProductName[0].Name + '"';
   String accountid = trigger.New[0].AccountID;
    String recordid = '"ID":' + '"' + trigger.New[0].Id + '"';
    String payload ='{' + recordid +',' + description +',' + caseid +',' + priority +',' + status +', ' + product +'}';
    
    // Methods defined as TestMethod do not support Web service callouts
   if (!Test.isRunningTest()) {
      xmattersreq.xRESTCall (endpoint,payload);
    }
   }
   }
}