/*******************
*Purpose :Trigger To Update the Finance Valuation Status of Affected Opportunities in Case the Valuation Status of the record is changed 
 *Vauation Status Field depends on fields : Invalid__c In_Progress__c,CRV_Process_completed__c,Finance_Owner__c ,Valuation_Tier_Override__c, Original_Valuation_Tier__c
* 
 * Author : Saba 
 * Date : 10/10/2011
* *************************/
trigger Renewal_UpdateOppFinanceValuation on Active_Contract__c (after update,after insert) 
{

  List<Active_Contract__c> lstACLValuationChanged = new List<Active_Contract__c>();
  for(Active_Contract__c ac: Trigger.new)
    {   
        if(Trigger.isupdate)
        {
        Active_Contract__c ac_old = Trigger.OldMap.get(ac.id);
        if(ac_old.Invalid__c <> ac.Invalid__c ||
           ac_old.In_Progress__c <> ac.In_Progress__c ||
           ac_old.CRV_Process_completed__c <> ac.CRV_Process_completed__c || 
           ac_old.Finance_Owner__c <> ac.Finance_Owner__c || 
           ac_old.Valuation_Tier_Override__c <> ac.Valuation_Tier_Override__c || 
           ac_old.Original_Valuation_Tier__c <> ac.Original_Valuation_Tier__c)
        {
            lstACLValuationChanged.add(ac);          
            
        }
        }
        if(Trigger.isinsert)
        lstACLValuationChanged.add(ac);             
    }       

    if(lstACLValuationChanged.size() > 0)
    {
        List<OpportunityLineItem> lst_OLI = [Select Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, OpportunityId 
                                                        FROM OpportunityLineItem where Active_Contract__c in : lstACLValuationChanged and Business_Type__c = 'Renewal' ];    
        Set<ID> oppIDs= new Set<ID>();
        For(OpportunityLineItem  opp1:lst_OLI)
        oppIDs.add(opp1.OpportunityId);
        List<OpportunityLineItem> lst_opp_OLI = [Select Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, OpportunityId 
                                                        FROM OpportunityLineItem where OpportunityId in : oppIDs and Business_Type__c = 'Renewal'];
                                       
        System.debug('lst_opp_OLI.size()-'+lst_opp_OLI.size());
        for(OpportunityLineItem ol: lst_opp_OLI)
        System.debug('1111-'+ol.Active_Contract_Product__r.Active_Contract__r.Status_Formula__c);

        Map<id,Set<String>> mOppOLI = new Map<id,Set<String>>();
  
        if(lst_opp_OLI <> null && lst_opp_OLI.size() >0)
        {
        
             Set<String> status_values;   
            for(OpportunityLineItem oli_temp: lst_opp_OLI)
            {
                status_values = mOppOLI.get(oli_temp.OpportunityId);
                if(status_values ==null)
                    status_values = new Set<String>();
                status_values.add(oli_temp.Active_Contract_Product__r.Active_Contract__r.Status_Formula__c);    
                mOppOLI.put(oli_temp.OpportunityId,status_values);
            }
        }
        List<Opportunity> UpdateOpps = new List<Opportunity>(); 
        for(Id oppId:  mOppOLI.keySet())
        {   
                Opportunity opp = new Opportunity(id=oppId);
                Boolean isValidated = true;
                Set<String> status_value=mOppOLI.get(oppId);
                System.debug('2222-'+status_value);
               
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
                
                UpdateOpps.add(opp);
        }
           
        if(UpdateOpps <> null && UpdateOpps.size() > 0)
        {
            Database.Update(UpdateOpps, false);
            //update UpdateOpps;
        }
    }
}