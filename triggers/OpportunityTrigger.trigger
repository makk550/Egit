trigger OpportunityTrigger on Opportunity(after delete, after insert, after update, before delete, before insert, before update)
{

    if(SystemIdUtility.skipOpportunityTriggers)
            return;


    TriggerFactory.createHandler(Opportunity.sObjectType);
}