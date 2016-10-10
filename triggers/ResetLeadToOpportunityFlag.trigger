//the Lead_to_Oppty__c flag is used to indicate that an opportunity was created as a result of lead conversion.
//the opportunity is exempted from some validation rules for the first couple of minitues because an automated process 
//rearaanges the opportunity and we don't want the process to fail. This trigger will uncheck this flag so that the Opportunity 
//is validated after the automated process is completed
trigger ResetLeadToOpportunityFlag on Opportunity (before update) 
{
    for(Opportunity opp: Trigger.new)
    {
        if(opp.Lead_to_Oppty__c)
        {
            Decimal timeDiffierence=CPMSIntegartionUtility.getDateTimeDiffInHours(DateTime.now(),opp.CreatedDate);
            if(timeDiffierence>.2)
            {
                opp.Lead_to_Oppty__c=false;
            }
        }
    }
}