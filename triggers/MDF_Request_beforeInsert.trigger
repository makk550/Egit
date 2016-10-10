//trigger to populate the approvers on MDF Request.

trigger MDF_Request_beforeInsert on SFDC_MDF__c (before insert) {
     
      MDF_PopulateApproversForRequest ClassVar=new MDF_PopulateApproversForRequest();
      ClassVar.PopulateApproversOnMDFRequest(Trigger.new);   

}