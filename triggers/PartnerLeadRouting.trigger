trigger PartnerLeadRouting on Lead (before insert) {
   List<Lead> leadList = new List<Lead>();
   for(Lead l:trigger.new){
    if(l.BU__c != NULL || l.MKT_Solution_Set__c != NULL){
        leadlist.add(l);
    }
   }
   
   if(leadlist.size()>0){
      ext_PartnerLeadRouting obj = new ext_PartnerLeadRouting ();
      obj.matchPLRR(leadlist);
   }
        
}