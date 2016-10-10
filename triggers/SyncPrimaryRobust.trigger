trigger SyncPrimaryRobust on scpq__SciQuote__c (after insert, after update) { 
    for(scpq__SciQuote__c quote: Trigger.new) 
    { 
        if(quote.CA_Primary_Flag__c == true) 
        { 
            for(List<scpq__SciQuote__c> oldPrimaries: [select Id, CA_Primary_Flag__c from scpq__SciQuote__c 
                                             where (CA_Primary_Flag__c = true) AND 
                                             (scpq__OpportunityId__c = :quote.scpq__OpportunityId__c) AND 
                                             (Id != :quote.Id)]) 
            { 
                for(scpq__SciQuote__c oldPrimary: oldPrimaries) 
                { 
                    oldPrimary.CA_Primary_Flag__c = false; 
                } 
            
                update oldPrimaries; 
            } 
        } 
    } // end for 
    
    /*// ---------- The following code was added for CR: 193720506 ---------- (begin)
    // Trigger.new does not contain the data of fields in related objects so we must query it
    Map<Id, Decimal> quoteToRate = new map<Id, Decimal>();
    for (scpq__SciQuote__c quote : [SELECT Id, scpq__OpportunityId__r.Renewal__r.Renewal_Currency__r.Conversion_Rate__c 
                                     FROM scpq__SciQuote__c
                                     WHERE Id IN :trigger.new
                                         AND scpq__OpportunityId__r.Renewal__r.Renewal_Currency__r.Conversion_Rate__c != null 
                                         AND scpq__OpportunityId__r.Renewal__r.Renewal_Currency__r.Conversion_Rate__c != 0
                                         AND CA_Primary_Flag__c = True] )
    {
        quoteToRate.put(quote.Id, quote.scpq__OpportunityId__r.Renewal__r.Renewal_Currency__r.Conversion_Rate__c);                                      
    }
    // -------------------------------------------------------------------- (End)*/
    
    //update the oppty  field based on the primary quote field  
    List<Opportunity> opplist = new List<Opportunity>();
        for(scpq__SciQuote__c q:Trigger.new ){
        if(q.CA_Primary_Flag__c == True){
            Opportunity opp = new Opportunity(id=q.scpq__OpportunityId__c);
                if (q.CA_Total_ATTRF__c <> null &&  q.CA_Realization_Rate__c <> null)
                    opp.New_Annual_Time__c = (q.CA_Total_ATTRF__c * q.CA_Realization_Rate__c )/100;
                else 
                    opp.New_Annual_Time__c=0; 
            opp.RR_Percentage__c = q.CA_Realization_Rate__c;      
            opp.New_TRR__c = q.CA_New_TRR__c; 
            opp.TRR_Percentage__c = q.CA_TRR_Percent__c;
            
            /*// ---------- The following code was added for CR: 193720506 ---------- (begin)
            Decimal conversionRate = quoteToRate.get(q.Id);
            if(conversionRate != null)
            {
              if(opp.New_TRR__c != null)
                opp.New_TRR_USD__c = opp.New_TRR__c / conversionRate;
              if(opp.New_Annual_Time__c != null)
                opp.New_Annual_Time_USD__c = opp.New_Annual_Time__c / conversionRate;
            }
            // -------------------------------------------------------------------- (End)*/
              
            opplist.add(opp);
        } // end if 
    } //end for    
    update opplist;
    
     


}