trigger UpdatePartnerLocations on Product_Alignment__c (after insert,after update,after delete) {
    
  /*
    If product alignment record is created/edited/ deleted and it is Partner approved and Authorized Product.
       Then 
          Fetch Partner Locator records based on Route and update soultions with product group.        
  */ 
  //---------CODE START FOR FY15 Requirement on Business Plan Focus Field-----------
         
         Set<Id> AccountIdSet = new Set<Id>();
         Set<Id> SolutionProviderAccountIdSet = new Set<Id>();
         Set<Id> ServiceProviderAccountIdSet = new Set<Id>();
         Set<Id> DataManagementAccountIdSet = new Set<Id>();
         Map<String,Boolean> ProdGroup_BPFValue_Map = new Map<String,Boolean>();
         if(Trigger.isAfter){
             if(trigger.isUpdate){
                 for(Integer i=0;i<trigger.new.size();i++){
                     if((trigger.old[i].Product_Group__c != trigger.new[i].Product_Group__c) || (trigger.old[i].Business_Plan__c != trigger.new[i].Business_Plan__c)){
                         if(trigger.new[i].RTM__c.equalsIgnoreCase('Solution Provider'))
                             SolutionProviderAccountIdSet.add(trigger.new[i].Related_Account__c);
                         if(trigger.new[i].RTM__c.equalsIgnoreCase('Service Provider'))
                             ServiceProviderAccountIdSet.add(trigger.new[i].Related_Account__c);
                         if(trigger.new[i].RTM__c.equalsIgnoreCase('Data Management'))
                             DataManagementAccountIdSet.add(trigger.new[i].Related_Account__c);
                         
                         if(!ProdGroup_BPFValue_Map.containsKey(trigger.old[i].Product_Group__c))
                             ProdGroup_BPFValue_Map.put(trigger.new[i].Product_Group__c,trigger.new[i].Business_Plan__c);  
                             
                     }
                 }   
                 System.debug('++++++ProdGroup_BPFValue_Map++++++'+ProdGroup_BPFValue_Map); 
                 
             }
             if(trigger.isInsert){
                 for(Integer i=0;i<trigger.new.size();i++){
                     if(trigger.new[i].RTM__c!=null){
                         if(trigger.new[i].RTM__c.equalsIgnoreCase('Solution Provider'))
                             SolutionProviderAccountIdSet.add(trigger.new[i].Related_Account__c);
                         if(trigger.new[i].RTM__c.equalsIgnoreCase('Service Provider'))
                             ServiceProviderAccountIdSet.add(trigger.new[i].Related_Account__c);
                         if(trigger.new[i].RTM__c.equalsIgnoreCase('Data Management'))
                             DataManagementAccountIdSet.add(trigger.new[i].Related_Account__c); 
                     }
                 } 
             }
             System.debug('+++++SolutionProviderAccountIdSet++++++'+SolutionProviderAccountIdSet);
             System.debug('++++++ServiceProviderAccountIdSet++++++'+ServiceProviderAccountIdSet);
             System.debug('++++++DataManagementAccountIdSet++++++'+DataManagementAccountIdSet);
             if((SolutionProviderAccountIdSet != null && SolutionProviderAccountIdSet.size()>0) || (ServiceProviderAccountIdSet != null && ServiceProviderAccountIdSet.size()>0) || (DataManagementAccountIdSet != null && DataManagementAccountIdSet.size()>0)){                 
                 UpdateBusinessPlanFocus.LogicTriggeredFromProductAlignment(SolutionProviderAccountIdSet,ServiceProviderAccountIdSet,DataManagementAccountIdSet,ProdGroup_BPFValue_Map);
             }
         }
         
         
     //---------CODE END FOR FY15 Requirement on Business Plan Focus Field-------------
    
    if(SystemIdUtility.skipUpdatePartnerLocations ==false)
    {
    
    Set<Id> accntIds = new Set<Id>();
    Map<String,Id> prodAlgnmntsModified = new Map<String,Id>();
    
    Map<String,String> prodMap= new Map<String,String>();    
    List <Partner_Location__c> updPartnLocations = new List <Partner_Location__c>();
    

    
    
   if(Trigger.isInsert || Trigger.isUpdate){
    for(Integer i=0; i<trigger.new.size(); i++){
        
        if(Trigger.isInsert && Trigger.new[i].Partner_Approved__c && Trigger.new[i].Authorized_Agreement__c && 
           (Trigger.new[i].Route_To_Market__c != null)){
            
            String key = Trigger.new[i].Related_Account__c+'-'+Trigger.new[i].RTM__c;
            String val = prodMap.get(key);
            String prdGrp ='';
            
            if(Trigger.new[i].Country__c == 'JP' && Trigger.new[i].JP_Product_Group__c!=null){
                               
               prdGrp = Trigger.new[i].JP_Product_Group__c;         
            }         
            else if(Trigger.new[i].Product_Group__c!=null) {          
               
               prdGrp =Trigger.new[i].Product_Group__c;
            }
            
            if(prdGrp!=''){
              if(val!=null ){
               if(!val.contains(prdGrp))
                 val =val+';'+prdGrp;
              }                            
             else             
              val=prdGrp;   
            }
            
            prodMap.put(key, val); 
            accntIds.add(Trigger.new[i].Related_Account__c);  
                    
        }
        else if( (Trigger.isUpdate && (Trigger.new[i].Partner_Approved__c!= Trigger.old[i].Partner_Approved__c || 
                 Trigger.new[i].Authorized_Agreement__c != Trigger.old[i].Authorized_Agreement__c || 
                 Trigger.new[i].Route_To_Market__c!= Trigger.old[i].Route_To_Market__c || 
                 Trigger.new[i].JP_Product_Group__c != Trigger.old[i].JP_Product_Group__c || 
                 Trigger.new[i].Product_Group__c!= Trigger.old[i].Product_Group__c))){
                    
                 prodAlgnmntsModified.put(Trigger.new[i].Related_Account__c+'-'+Trigger.new[i].RTM__c,Trigger.new[i].Related_Account__c);
                                    
        }
        
    }
  }
  if(Trigger.isDelete){
    for(Integer i=0; i<trigger.old.size(); i++){
        prodAlgnmntsModified.put(Trigger.old[i].Related_Account__c+'-'+Trigger.old[i].RTM__c,Trigger.old[i].Related_Account__c);    
    }
    
  }  
    
    
    
    
    
    if(prodAlgnmntsModified.size()>0 && prodAlgnmntsModified.values()!=null){
    
      List <Product_Alignment__c> prodAlignments = [select Related_Account__c,RTM__c,Product_Group__c,JP_Product_Group__c,Country__c
                                                    from Product_Alignment__c where Related_Account__c in:prodAlgnmntsModified.values() 
                                                    and Partner_Approved__c = True and
                                                    Authorized_Agreement__c = True and Route_To_Market__c != null]; 
    
    
          for(Product_Alignment__c prodAlignment : prodAlignments) {
          
            String key = prodAlignment.Related_Account__c+'-'+prodAlignment.RTM__c;
            String val = prodMap.get(key);
            String prdGrp ='';
            
            if(prodAlignment.Country__c == 'JP' && prodAlignment.JP_Product_Group__c!=null){
                               
               prdGrp = prodAlignment.JP_Product_Group__c;         
            }         
            else if(prodAlignment.Product_Group__c!=null) {          
               
               prdGrp =prodAlignment.Product_Group__c;
            }
            
            if(prdGrp!=''){
              if(val!=null ){
               if(!val.contains(prdGrp))
                 val =val+';'+prdGrp;
              }                            
             else             
              val=prdGrp;   
            }
            
            prodMap.put(key, val); 
            accntIds.add(prodAlignment.Related_Account__c);  
          
          }                                                   
    }
      
       
   if(accntIds.size()>0){
    List <Partner_Location__c> partnerLocationList = [Select Id, Account__c, CA_Solutions__c,Route_to_market__c from Partner_Location__c
        where Account__c IN :accntIds and Route_to_market__c!=null];
  
        
    for(Partner_Location__c partnLoc : partnerLocationList) {
                    
        String caSolns = '';
        if(Trigger.isInsert)
           caSolns = partnLoc.CA_Solutions__c;
                 
        List<String> lstRTM = new List<String>();
        lstRTM  = partnLoc.Route_to_market__c.split(';');       
        
        for (integer i=0 ; i < lstRTM.size();i++){  
            
           String prodGrp=prodMap.get(partnLoc.Account__c+'-'+lstRTM.get(i));
           
           if(prodGrp!=null){
                    
            if(Trigger.isInsert){   
             List<String> lstProdGrp = new List<String>();
             lstProdGrp  = prodGrp.split(';');
                        
             for (integer j=0 ; j < lstProdGrp.size(); j++){
            
                if(caSolns!=null){
                  if(!caSolns.contains(lstProdGrp.get(j)))
                     caSolns = caSolns+';'+lstProdGrp.get(j);                   
                }               
                else{
                    caSolns=lstProdGrp.get(j);  
                }
                                
             }   
             
            }
             else{              
                  if(caSolns!=null && caSolns!='')
                    caSolns = caSolns+';'+prodGrp; 
                  else
                    caSolns = prodGrp;
             }
                        
           }  
                  
        }   
        
        List<String> lstSolns = new List<String>();
        if(caSolns!=null)
          lstSolns  = caSolns.split(';');
        
        String solutions='';
        
         for (integer i=0 ; i < lstSolns.size();i++){
            
            if(solutions !=''){                
               if(!solutions.contains(lstSolns.get(i))) 
                   solutions = solutions +';'+ lstSolns.get(i);         
            }                
            else 
               solutions = lstSolns.get(i);  
            
         }
                  
         if(solutions != partnLoc.CA_Solutions__c){
             partnLoc.CA_Solutions__c = solutions;
             updPartnLocations.add(partnLoc);
         }       
    }
    
    
   }
    
      
    if(updPartnLocations.size()>0)
       database.update(updPartnLocations,False);
           
}
}