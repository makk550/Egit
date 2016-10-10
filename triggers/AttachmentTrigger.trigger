trigger AttachmentTrigger on Attachment (after insert) {
    if(UserInfo.getUserId().contains(Label.saas_ops_integration_user))
     return;  
   if(trigger.isAfter){  
     Schema.DescribeSObjectResult result = External_RnD__c.sObjectType.getDescribe();
     String keyPrefix = result.getKeyPrefix();
     for(Attachment attachmentFile : Trigger.new){
         if(attachmentFile.ParentId!=null && String.valueof(attachmentFile.ParentId).startsWith( result.getKeyPrefix())){
             CalloutToCSM.createAttachemnt(attachmentFile.Id);
         }
     }
   }  

}