//trigger to enforce Rejection Reason required during approval process for MDF Request.

trigger MDF_Request_beforeUpdate on SFDC_MDF__c (before update) {
     
      MDF_RejectionReasonMandatoryOnRequest ClassVar= new MDF_RejectionReasonMandatoryOnRequest();
      ClassVar.validateRejectionReason(Trigger.old,Trigger.new);   

}