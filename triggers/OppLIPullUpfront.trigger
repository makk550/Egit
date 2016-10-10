/*** For setting the upfront eligible flag on OLI
****/

trigger OppLIPullUpfront on OpportunityLineItem (before insert) 
{

   if(SystemIdUtility.skipOpportunityLineItemTriggers)
      return;


    set<id> pricebookids = new set<id>();

    for(OpportunityLineItem oli: trigger.new)
    {
        pricebookids.add(oli.PricebookEntryId);
    }
    
    Map<id,PricebookEntry> mProd = new Map<id,PricebookEntry>([Select id,PricebookEntry.Product2Id, PricebookEntry.Product2.Upfront_Revenue_Eligible__c from PricebookEntry where id in :pricebookids]);
    
    for(OpportunityLineItem oli: trigger.new)
    {
        oli.Upfront_Revenue_Eligible__c =(oli.PricebookEntryId <> null && mProd.get(oli.PricebookEntryId) <> null && mProd.get(oli.PricebookEntryId).Product2 <> null  && mProd.get(oli.PricebookEntryId).Product2.Upfront_Revenue_Eligible__c  <> null && mProd.get(oli.PricebookEntryId).Product2.Upfront_Revenue_Eligible__c == 'Yes');
       
    }
}