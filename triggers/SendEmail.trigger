trigger SendEmail on Partner_Registration__c (after Insert) {

 for (Partner_Registration__c u : Trigger.new){
 
     String langCode=Language_Keys__c.getValues(u.Preferred_language__c)!=null ? Language_Keys__c.getValues(u.Preferred_language__c).Language_Key__c:'en_US';
     
     PRM_Email_Notifications.sendEmailByCapability('On-Boarding',u.Id,langCode,'Partner Registration');

 }  

}