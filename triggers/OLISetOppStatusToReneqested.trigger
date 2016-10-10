//Set Opportunity Status to requested on every attach/detach of ca product renewals
trigger OLISetOppStatusToReneqested on OpportunityLineItem (before insert, before delete) 
{ 
      Set<id> oppIds  = new Set<id>();
      List<OpportunityLineItem> lstTrg;
      if(trigger.isInsert)
          lstTrg = Trigger.New;
      else
          lstTrg = Trigger.Old;    
    

      for(OpportunityLineItem  lineItem_ACP :lstTrg)    
                {
                    if(lineItem_ACP.business_type__c == 'Renewal')
                         oppIds.add(lineItem_ACP.OpportunityId);
                }
                
      if(oppIds.size() > 0)
      {  
                    
          List<Opportunity> lst = new List<Opportunity>();
          for(id vid:oppIds)
          {
              lst.add(new Opportunity(id=vId,rpd_status__c = 'Requested'));
          }
          update lst;          
     }
}