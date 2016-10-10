trigger OppLIAttachDetachRenewals on OpportunityLineItem (after insert,after delete) 
{
    if(SystemIdUtility.skipTrigger || SystemIdUtility.skipOpportunityLineItemTriggers) //Do not run while Opportunity Generation
        return;
          
    Set<id> oppids = new Set<id>();
    Set<id> oppdelids = new Set<id>();
    Set<id> acpids = new Set<id>();
    
    if(Trigger.isInsert)
    {
        for(OpportunityLineItem oli : Trigger.new)
        {
            if(oli.Business_Type__C == 'Renewal')
            {    oppids.add(oli.OpportunityId);
            }
        }
    }
    else if(Trigger.isDelete)
    {
        for(OpportunityLineItem oli : Trigger.old)
        {
           if(oli.Business_Type__C == 'Renewal')
            {    
                oppids.add(oli.OpportunityId);
                oppdelids.add(oli.OpportunityId);
                if(oli.Active_Contract_Product__c <> null)
                    acpids.add(oli.Active_Contract_Product__c);
                
            }
            else
            {
               oppids.add(oli.OpportunityId);  //for partners
            }
        }   
    }

     //UPDATE THE SALES PRICE
    if(OppIds.size() > 0)
    {
        Map<id,Opportunity> mOpp = new Map<id, Opportunity>([Select id, Projected_renewal__C,Partner_Sales_Price__c  from Opportunity where id in : OppIds]);
        if(Trigger.isInsert)
        {  //added some lines by vasantha to calculate partner sales price.
            for(OpportunityLineItem oli : Trigger.new)
            {
                if(oli.Business_Type__C == 'Renewal')
                {   
                    Opportunity opp = mOpp.get(oli.OpportunityId);
                    decimal pr = opp.Projected_renewal__c;
                    decimal ppr = opp.Partner_Sales_Price__c;
                    if(pr == null)
                        pr =0;
                    if(ppr == null)
                        ppr =0;
                    pr += oli.UnitPrice;                                                            
                    if(oli.Partner_Added__c == true)
                      ppr += oli.partner_sales_price__c;                    
                    opp.Projected_renewal__c = pr;
                    opp.Partner_Sales_Price__c = ppr;
                    mOpp.put(oli.OpportunityId,opp);
                }                
            }
        }
        else if(Trigger.isDelete)
        {
            for(OpportunityLineItem oli : Trigger.old)
            {
               if(oli.Business_Type__C == 'Renewal')
                {   Opportunity opp = mOpp.get(oli.OpportunityId);
                    system.debug('In Renewal' + opp.Partner_Sales_Price__c);
                    decimal pr = opp.Projected_renewal__c;
                    decimal ppr = opp.Partner_Sales_Price__c;                    
                    if(pr == null)
                        pr =0;
                    if(ppr == null)
                        ppr = 0;
                    pr -= oli.UnitPrice;
                    if(oli.Partner_Added__c == true)
                       ppr -= oli.Partner_Sales_Price__c;
                    opp.Projected_renewal__c = pr;
                    opp.Partner_Sales_Price__c = ppr;
                    mOpp.put(oli.OpportunityId,opp);
                }  
                else
                {
                   
                    Opportunity opp = mOpp.get(oli.OpportunityId);
                   system.debug('asdfasdfsda' + opp.Partner_Sales_Price__c); 
                    decimal ppr = opp.Partner_Sales_Price__c;                    
                    if(ppr == null)
                        ppr = 0;
                    if(oli.Partner_Added__c == true)
                       ppr -= oli.Partner_Sales_Price__c;                    
                    opp.Partner_Sales_Price__c = ppr;
                    mOpp.put(oli.OpportunityId,opp);
                }              
            }   
        }

        if(mOpp.values().size() > 0)
                update mOpp.values();
    
    }

   if(acpids.size() > 0)
   {    
     List<CA_Product_Renewal__c> lstCAProd = [select id,name from CA_Product_Renewal__c where Renewal_Opportunity__c in:oppdelids and Active_Contract_Product__c in:acpids];
     if(lstCAProd <> null &&lstCAProd.size() > 0  )
                 delete lstCAProd;
     //FY13-start            
      List<Active_Contract_Product__c> lstACP = [Select id, Converted_to_Opportunity__c, Opportunity__c, 
                                                        Opportunity_Product__c, Renewal_Contract_Product__c
                                                   FROM Active_Contract_Product__c WHERE id in : acpids ];
      
      for(Active_Contract_Product__c acp : lstACP)
      {
        acp.Opportunity_Product__c = null;
        acp.Opportunity__c = null;
        acp.Renewal_Contract_Product__c = null;
        acp.Converted_to_Opportunity__c = false;
      }
      
      update lstACP;
      //FY13-end
   }              


}