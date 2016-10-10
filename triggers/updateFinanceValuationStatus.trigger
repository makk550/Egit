trigger updateFinanceValuationStatus on Opportunity (before update) {
    Map<Id, List<OpportunityLineItem>> mapopli = new Map<Id, List<OpportunityLineItem>>();
    Set<Id> setOpp = new Set<Id>();
    List<Opportunity> listOpp = trigger.new;

    for(Opportunity opp: listOpp)
    {
        setOpp.add(opp.id);
    }
    List<OpportunityLineItem> listOppLI = [Select Id, Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, OpportunityId from OpportunityLineItem where OpportunityId in: setOpp and Business_Type__c = 'Renewal'];
    for(OpportunityLineItem oppli : listOppLI)
    {
        List<OpportunityLineItem> newlistOppLI = mapopli.get(oppli.OpportunityId);
        if(newlistOppLI==null)
        {
            newlistOppLI = new List<OpportunityLineItem>();
            mapopli.put(oppli.OpportunityId, newlistOppLI);      
        }
        newlistOppLI.add(oppli);
    }
    
    Set<String> status_value = new Set<String>();
    Boolean isValidated = true;
    if(trigger.isupdate && trigger.isbefore)
    {
        for(Opportunity opp: trigger.new)
        {
            List<OpportunityLineItem> oppli_list = mapopli.get(opp.id);
            if(oppli_list != null && oppli_list.size() > 0)
            for(OpportunityLineItem ol: oppli_list)
                status_value.add(ol.Active_Contract_Product__r.Active_Contract__r.Status_Formula__c);
            if(status_value != null && status_value.size() > 0)
            {
                System.debug('status_value - '+status_value);     
                if(status_value.contains('In Progress') || status_value.contains('Assigned') || status_value.contains('In Scope'))
                    isValidated =  false;   
                opp.Finance_Valuation_Status__c = (isValidated?'Validated':'Not Validated');
                system.debug(opp.Finance_Valuation_Status__c);
            }
            else
            {
                opp.Finance_Valuation_Status__c = '';
            }           
        }
    }
}