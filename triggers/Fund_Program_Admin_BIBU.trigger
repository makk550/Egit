trigger Fund_Program_Admin_BIBU on Fund_Programs_Admin__c (before insert, before update) {
    
    MDF_Utils.populateOwnerOnProgramAdmin(Trigger.new);
}