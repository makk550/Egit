trigger updateOppPdt on Active_Contract_Product__c (after update) {
List<OpportunityLineItem> oppitem = new List<OpportunityLineItem>();
List<CA_Product_Renewal__c> renewalContractProd = new List<CA_Product_Renewal__c>();
//  Set<Id> oppProdsIds = new Set<Id>(); 
Map<Id,Active_Contract_Product__c> oppProdsIds = new Map<Id,Active_Contract_Product__c>();  
Map<Id,Decimal > oppIds = new Map<Id,Decimal >(); 
 
if(Trigger.isUpdate)
{

for (Active_Contract_Product__c acp : [Select id,  Active_Contract__r.Contract_Term_Months__c from Active_Contract_Product__c where id in : Trigger.NewMap.KeySet()])
{
    oppIds.put(acp.Id,  acp.Active_Contract__r.Contract_Term_Months__c  );
}
 
for(Integer i=0;i<Trigger.new.size();i++) {
        if(Trigger.new[i].ATTRF_CRV__c != Trigger.old[i].ATTRF_CRV__c                 
            || Trigger.new[i].OCV__c != Trigger.old[i].OCV__c
            || Trigger.new[i].AOCV__c != Trigger.old[i].AOCV__c
            || Trigger.new[i].Raw_Maint_Calc_LC__c != Trigger.old[i].Raw_Maint_Calc_LC__c
            || Trigger.new[i].Active_Contract__r.Contract_Term_Months__c != Trigger.old[i].Active_Contract__r.Contract_Term_Months__c
            || Trigger.new[i].Dismantle_Date__c != Trigger.old[i].Dismantle_Date__c 
            || Trigger.new[i].Segmentation__c != Trigger.old[i].Segmentation__c )  
          {             
              if(Trigger.new[i].id!= null)
                {
                  oppProdsIds.put(Trigger.new[i].Id,Trigger.new[i]);
                }         
     }
     }
     }
if(oppProdsIds.size()>0)
{
        for(OpportunityLineItem lineitm:[select ATTRF__c,Contract_Length__c,Old_TRR__c ,Original_CV__c,Original_Deal_Term_Months__c,Original_Expiration_Date__c ,Raw_Maintenance__c,Active_Contract_Product__c  from opportunitylineitem  where Active_Contract_Product__c in:oppProdsIds.keyset()]){
           lineitm.ATTRF__c = oppProdsIds.get(lineitm.Active_Contract_Product__c).ATTRF_CRV__c;

           lineitm.Old_TRR__c = oppProdsIds.get(lineitm.Active_Contract_Product__c).AOCV__c;
           lineitm.Original_CV__c = oppProdsIds.get(lineitm.Active_Contract_Product__c).OCV__c;

           lineitm.Original_Expiration_Date__c  = oppProdsIds.get(lineitm.Active_Contract_Product__c).Dismantle_Date__c;
           lineitm.Raw_Maintenance__c  = oppProdsIds.get(lineitm.Active_Contract_Product__c).Raw_Maint_Calc_LC__c;
           lineitm.Segmentation__c = oppProdsIds.get(lineitm.Active_Contract_Product__c).Segmentation__c;              
           
           if (oppIds.size()>0 )
           {
               lineitm.Contract_Length__c = oppIds.get(lineitm.Active_Contract_Product__c);            
               lineitm.Original_Deal_Term_Months__c  = oppIds.get(lineitm.Active_Contract_Product__c);
           }    
           system.debug('@@@@@@@@'+ lineitm );
           oppitem.add(lineitm); 
        }
           /************ Renewal COntract Products *******************/
        for(CA_Product_Renewal__c RenewalLineItem:[select Active_Contract_Product__c,ATTRF__c,Raw_Maintenance__c,TRR__c  from CA_Product_Renewal__c  where Active_Contract_Product__c in:oppProdsIds.keyset()]){
                                   
           RenewalLineItem.ATTRF__c = oppProdsIds.get(RenewalLineItem.Active_Contract_Product__c).ATTRF_CRV__c;
           RenewalLineItem.Raw_Maintenance__c = oppProdsIds.get(RenewalLineItem.Active_Contract_Product__c).Raw_Maint_Calc_LC__c;
           RenewalLineItem.TRR__c = oppProdsIds.get(RenewalLineItem.Active_Contract_Product__c).AOCV__c;           
            
           system.debug('@@@@@@@@'+ RenewalLineItem);
           renewalContractProd.add(RenewalLineItem); 
        }
}
 if(oppitem.size()>0)
  Database.update(oppitem,false);
 if(renewalContractProd.size() > 0)
   Database.update(renewalContractProd,false);
}