//executed on all opportunities after update
//1 SOQL Queries
trigger OppUpdateDealDeskTrigger on Opportunity (after update) 
{
    //## there is a requirement to update various Deal_Desk_Review__c
    //## fields with values from the Opportunity.
    //## This Trigger was added to the Opportunity to meet
    //## that requirement.
    //## See also: OppLIUpdateDealDeskTrigger (on OpportunityLineItem)
    try
    {  
        Deal_Desk_Review__c[] ddarray = new Deal_Desk_Review__c[0];
        
        set<Id> changedOpportunityIdList=new set<Id>();
        for(Opportunity opp:Trigger.new)
        {
            Opportunity oldOpp=Trigger.oldMap.get(opp.Id);
            //process the opportunity if one of the fields are changed
            if(opp.OwnerId!=oldOpp.OwnerId || opp.CloseDate!=oldOpp.CloseDate || opp.Amount!=oldOpp.Amount || 
            opp.StageName!=oldOpp.StageName || opp.Type!=oldOpp.Type)
            {
                changedOpportunityIdList.add(opp.Id);
            }
        }   
        
        //if there are any opportunities with field changes
        if(changedOpportunityIdList.size()>0)
        {
             //## query the associated Deal Desk Review record
            for (Deal_Desk_Review__c dd:[SELECT Id, Name,Opportunity_Name__c FROM Deal_Desk_Review__c
             WHERE Opportunity_Name__c in :changedOpportunityIdList])
            {    
                //get the parent opportunity
                Opportunity opp= Trigger.newMap.get(dd.Opportunity_Name__c);            
                dd.Opportunity_Owner__c = opp.OwnerId;
                dd.Oppty_Close_Date__c = opp.CloseDate;
                dd.Oppty_Amount__c  = opp.Amount;
                dd.Sales_Milestone__c  = opp.StageName;
                dd.Type__c = opp.Type;
                ddarray.add(dd);
                
            }
            if(ddarray.size()>0)
            {    
                update ddarray; 
            }  
        } 
    }
    catch(System.DmlException e)
    {
        for (Integer i =0; i < e.getNumDml(); i++)
        {
            System.debug(e.getDmlMessage(i));
        }
    }
}