trigger Ttest on Test__c ( after delete, before insert) {

  system.debug('========'+Trigger.Old);
  system.debug('========'+Trigger.New);

}