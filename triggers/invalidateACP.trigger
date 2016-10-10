trigger invalidateACP on Active_Contract_Product__c (before insert, before update) {
    for(Active_Contract_Product__c acp : trigger.new)
    {
        if(acp.name == 'Services')
        acp.Reason_for_invalidation__c = 'Invalid – Professional Services';
        else if(acp.name == 'Training')
        acp.Reason_for_invalidation__c = 'Invalid – Education';
    }
}