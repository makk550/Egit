public with sharing class ChangePOCRequestStatusController
{
 private ApexPages.StandardController ext;
 private Map<String, List<String>> allowedValues =  new Map<String, List<String>>();
 private final Trial_Request__c tr;
 private String newStatus = null;
 public String oldStatus{get; set;}
 // Constructor
 public ChangePOCRequestStatusController(ApexPages.StandardController sc)
 {
     ext = sc;
     //tr = (Trial_Request__c) ext.getRecord();
     tr =[select request_status__c, id from trial_request__c where id =:ApexPages.currentPage().getParameters().get('id')];
     oldStatus = tr.request_status__c;
     
     allowedValues.put('Approval Denied', new List<String>{'Cancelled'});     
     allowedValues.put('Extension for Approval', new List<String>{'Extension Approved','Approval Denied','Cancelled'});
     allowedValues.put('Extension Approved', new List<String>{'Extension for Approval','Cancelled','POC Executed'});
     allowedValues.put('Pending DDR  Review', new List<String>{'DDR Request Approved','Cancelled','Complete'});
     allowedValues.put('DDR Request Approved', new List<String>{'Complete','On Hold','Cancelled','POC Executed'});
     
     allowedValues.put('On Hold', new List<String>{'Cancelled','POC Executed'});
     allowedValues.put('Not Approved', new List<String>{'Cancelled','On Hold'});
     allowedValues.put('In Process', new List<String>{'Cancelled','Ordered'});
     allowedValues.put('Available', new List<String>{'Ordered','Cancelled'});
     allowedValues.put('Ordered', new List<String>{'Complete','Cancelled'});

     allowedValues.put('Complete', new List<String>{'POC Executed','Extension for Approval','Cancelled'});
     allowedValues.put('New', new List<String>{'Request for Approval','Cancelled'});
     allowedValues.put('Request for Approval', new List<String>{'Request Approved','Approval Denied','Cancelled'});

     allowedValues.put('Request Approved', new List<String>{'Cancelled'});
     allowedValues.put('Terms Denied', new List<String>{'Cancelled'});
     allowedValues.put('Pending Entitlement', new List<String>{'Cancelled'});
     allowedValues.put('Pending Fulfillment', new List<String>{'Cancelled'});
     allowedValues.put('Pending Unknown', new List<String>{'Cancelled'});
     
 
     
 }
 public String getnewStatus()
 {
 return newStatus;
 }
 
 public void setnewStatus(String newVal)
 {
 newStatus= newVal;
 }
 
 public List<SelectOption> getavailableValues() {
 
            List<SelectOption> options = new List<SelectOption>();
            
            if(allowedValues.get(oldStatus)==null)
            options.add(new SelectOption('---None---','---None---'));
            else
            {
            for(String s: allowedValues.get(oldStatus))       
            options.add(new SelectOption(s,s));
            }
            //options.sort();
            System.debug('Available Picklist Map'+allowedValues);
            System.debug('Available Next Picklist'+options);
            return options;
        }
        
       
        
     public PageReference doSave()
     {
     
   
    // tr =[select request_status__c, id from trial_request__c where id =:ApexPages.currentPage().getParameters().get('id')];
     //PageReference p = new PageReference('/apex/ChangePOCRequestStatus?id='+ tr.Id);
     
     System.debug(' New Status FROM POC'+ newStatus);
     
     system.debug('Old Status FROM POC'+oldStatus);
     
      if(!Schema.sObjectType.Trial_Request__c.fields.Request_Status__c.isUpdateable() || !Trial_Request__c.sObjectType.getDescribe().isUpdateable() )
         {
            tr.Request_Status__c.addError('You do not have access to perform that opperation');
            return null;
         }
      if(newStatus != null && newStatus !='---None---')
         {
             tr.Request_Status__c = newStatus;
             
             try {
             update tr;
             return ext.view();
              }
             catch(exception e)
             { 
             //tr.addError(e.getMessage());
             ApexPages.addMessages(e);
             
             //e.setMessage();
             }
             tr.Request_Status__c = oldStatus;
             // Error: There is no record to save. R: Save operation is called more than once.
             
         }
        
     return null;
     }
     
     public PageReference doCancel()
     {
     return ext.view();
     }
            
}