trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete) {
    if(SystemIdUtility.skipOpportunityLineItemTriggers)
        return;
        
    TriggerFactory.createHandler(OpportunityLineItem.sObjectType);
}