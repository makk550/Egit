trigger Renewal_FieldUpdates on Active_Contract_Line_Item__c (before update, before insert ) {

if(Trigger.isupdate)
{
  for(Integer i=0;i<Trigger.new.size();i++)
  {  
     if(trigger.new[i].AOCV__c != trigger.old[i].AOCV__c && trigger.new[i].TRR__c == trigger.old[i].TRR__c && trigger.new[i].stop_sync_trr_lc__c != true )      
     {         
        if(trigger.old[i].AOCV__c==trigger.old[i].TRR__c){
           trigger.new[i].TRR__c=trigger.new[i].AOCV__c;                          
        }        
        else{
             trigger.new[i].stop_sync_trr_lc__c = true;  
        } 
       }
  
     if(trigger.new[i].TRR__c != trigger.old[i].TRR__c  && trigger.new[i].Adjusted_TRR_LC__c == trigger.old[i].Adjusted_TRR_LC__c && trigger.new[i].stop_sync_trr__c != true)
     { 
            if(trigger.old[i].TRR__c==trigger.old[i].Adjusted_TRR_LC__c){
                 trigger.new[i].Adjusted_TRR_LC__c=trigger.new[i].TRR__c;
            }    
            else
            {
                trigger.new[i].stop_sync_trr__c = true;
            }      
     }
     

      if(trigger.new[i].Orig_ATTRF_LC__c != trigger.old[i].Orig_ATTRF_LC__c && trigger.new[i].Adjusted_ATTRF_LC__c == trigger.old[i].Adjusted_ATTRF_LC__c && trigger.new[i].stop_sync_attrf__c != true )
      { 
        if(trigger.old[i].Orig_ATTRF_LC__c==trigger.old[i].Adjusted_ATTRF_LC__c)
        {
                 trigger.new[i].Adjusted_ATTRF_LC__c=trigger.new[i].Orig_ATTRF_LC__c;
                 
         } 
       else
         {
                trigger.new[i].stop_sync_attrf__c = true;
         }  
       }
       
   
  }
}
 if(Trigger.isinsert)
 {
  for(Integer i=0;i<Trigger.new.size();i++){
   
  if(trigger.new[i].TRR__c==null){    
    trigger.new[i].TRR__c=trigger.new[i].AOCV__c;    
   }   
  else{    
     trigger.new[i].stop_sync_trr_lc__c = true;  
   }

   if(trigger.new[i].Adjusted_TRR_LC__c==null){
    trigger.new[i].Adjusted_TRR_LC__c=trigger.new[i].TRR__c;
   }
   else{
     trigger.new[i].stop_sync_trr__c = true;
   }
  
   if(trigger.new[i].Adjusted_ATTRF_LC__c==null){
      trigger.new[i].Adjusted_ATTRF_LC__c=trigger.new[i].Orig_ATTRF_LC__c;
   }
   else{
     trigger.new[i].stop_sync_attrf__c = true;
   } 
 }
 }
}