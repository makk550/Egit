trigger OppUpdateAggregateInfo on Opportunity (before insert, before update) {
    Set<ID> volumeCustomerIdList=new Set<ID>();
    for(Opportunity opp:Trigger.New)
    {      
    
        //new opportunity
        if(Trigger.isInsert)
        {
            if(opp.Volume_Account__c!=null && opp.Aggregate_Account__c==null)
            {
                volumeCustomerIdList.add(opp.Volume_Account__c);
            } 
                              
            //Fy12 Change update CPM owner with Oppertunity owner for Renewals.            
             if(opp.CPM_Owner__c == null && opp.Business_Type__c!=null)         
               opp.CPM_Owner__c = opp.OwnerId;
        }
        //existing opportunity
        else
        {
            Opportunity oldOpportunity=Trigger.oldMap.get(opp.Id);
            if(opp.Volume_Account__c!=null &&  opp.Volume_Account__c!=oldOpportunity.Volume_Account__c)
            {
                volumeCustomerIdList.add(opp.Volume_Account__c);
            }
        }       
    } 
    if(volumeCustomerIdList.size()>0)
    {
        List<Volume_Customer__c> volumeCustomers=[Select Id,Account__c
        from Volume_Customer__c where Id in:volumeCustomerIdList];
        for(Opportunity opp:Trigger.New)
        {   
            boolean processOpportunity=false;   
            //new opportunity
            if(trigger.isinsert)
            {
                if(opp.Volume_Account__c!=null && opp.Aggregate_Account__c==null)
                {
                    processOpportunity=true;
                }
            }
            //existing opportunity
            else
            {
                Opportunity oldOpportunity=Trigger.oldMap.get(opp.Id);
                if(opp.Volume_Account__c!=null &&  opp.Volume_Account__c!=oldOpportunity.Volume_Account__c)
                {
                    processOpportunity=true;
                }
            }   
            if(processOpportunity==true)
            {
                for(Volume_Customer__c vc:volumeCustomers)
                {
                    if(opp.Volume_Account__c==vc.Id)
                    {
                        opp.Aggregate_Account__c=vc.Account__c;
                        //opp.Agg_Acct_Area__c=vc.Agg_Acct_Area__c;
                        //opp.Agg_Acct_Region__c=vc.Agg_Acct_Region__c;
                        //opp.Agg_Acct_Territory_Country__c=vc.Agg_Acct_Territory_Country__c;
                    }
                }
            }   
        }       
    }
}