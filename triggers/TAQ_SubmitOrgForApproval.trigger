trigger TAQ_SubmitOrgForApproval on TAQ_Org_Quota__c (before insert, before update, after insert, after update) {
  
   if(SystemIdUtility.skipTAQ_OrgQuota) //Global Setting defined in Custom Settings to make the Trigger not execute for either a specific user or all the org
        return;
  
   if(CA_TAQ_Account_Approval_Class.EXECUTED_ORGQUOTA_COUNT > 3)
     return;
  
  if(Trigger.isBefore)
  {
  
  if(TAQ_SubmitOrgApprovalClass.isExecuted ==false)
  {
  
  // FY13 1.1 - SUBMIT TAQ ORG RECORDS FOR APPROVAL WHEN TAQ ORG QUOTA IS MODIFED.-START
   List<TAQ_Org_Quota__c> taqOrgIds = new List<TAQ_Org_Quota__c>();
   List<Id> savedNotApprovedIds = new List<Id>();
   
   for(TAQ_Org_Quota__c toq: trigger.new)
   {
      if(toq.Submit_for_approval__c == true)
      {
        taqOrgIds.add(toq);
      }
      else
      {
          savedNotApprovedIds.add(toq.TAQ_Organization__c);
      }
   }
   if(taqOrgIds.size()>0){
     TAQ_SubmitOrgApprovalClass submitObj = new TAQ_SubmitOrgApprovalClass();
     submitObj.submitforApproval(taqorgIds);
   }
   if(savedNotApprovedIds.size() > 0)
   {
       List<TAQ_Organization__c> orgRecs;
       orgRecs = [SELECT Id, Approval_Status__c from TAQ_Organization__c where Id in: savedNotApprovedIds]; 
       for(TAQ_Organization__c taqOrg1 : orgRecs)
       {
           taqOrg1.Approval_Status__c = 'Saved - Not Approved';
       }
       database.update(orgRecs, false);
   }
  }
   
   for(TAQ_Org_Quota__c toq: trigger.new)
   {
      if(!toq.Submit_for_Approval__c)
        toq.Submit_for_Approval__c = true;
   } 
}
else if(Trigger.isAfter)
{
 
  if(TAQ_SubmitOrgApprovalClass.orgRecs <> null && TAQ_SubmitOrgApprovalClass.orgRecs.size() > 0)
  {
  
          database.update(TAQ_SubmitOrgApprovalClass.orgRecs, false);
          TAQ_SubmitOrgApprovalClass.orgRecs = null;
          
  }
  
}


 // TO BYPASS SAVED - NOT APPROVED ON TAQ ORG RECORD.
   if(trigger.isInsert){
      for(TAQ_Org_Quota__c eachQuota: trigger.new){
        if(eachQuota.TAQ_Organization__c != null && 
        !CA_TAQ_Account_Approval_Class.SELECTED_STATUS.containsKey(eachQuota.TAQ_Organization__c)){
               CA_TAQ_Account_Approval_Class.SELECTED_STATUS.put(eachQuota.TAQ_Organization__c,'FROM ORG QUOTA');
        }
      }
   }
      


  CA_TAQ_Account_Approval_Class.EXECUTED_ORGQUOTA_COUNT++;  
  // FY13 1.1 - SUBMIT TAQ ORG RECORDS FOR APPROVAL WHEN TAQ ORG QUOTA IS MODIFED.-END   
}