trigger UpdateOpportunity on OpportunityLineItem (after insert, after update, after delete) {
    if(SystemIdUtility.skipOpportunityLineItemTriggers)
        return;
        
    if(UniqueBusinessUnit.hasUpdateOpportunityRun)
        return;
    UniqueBusinessUnit.hasUpdateOpportunityRun = true;
    Set<Id> oppIdSet = new Set<Id>();
    if(!Trigger.isDelete){
        for(OpportunityLineItem oli : Trigger.New)
            oppIdSet.add(oli.opportunityid);
    }
    if(Trigger.isDelete){
        for(OpportunityLineItem oli : Trigger.Old)
            oppIdSet.add(oli.opportunityid);
    }
    Map<Id,Opportunity> updateOppMap = new Map<Id,Opportunity>([SELECT Id,Sales_Coverage_Business_Unit__c,Driving_Sales_Coverage_Business_Unit__c, Reseller_Product_Name__c, Reseller_Estimated_Value__c, RecordTypeId,(SELECT Business_Unit__c,OpportunityId,UnitPrice FROM OpportunityLineItems) FROM Opportunity where Id IN: OppIdSet]);
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
    Set<Id> oppIds = new Set<Id>();
    if(Trigger.isInsert){
        for(OpportunityLineItem oppLineItems : Trigger.New){
            System.debug('---Before oppIds ---' + oppIds);        
            oppIds.add(oppLineItems.OpportunityId);
        }
    }
    if(Trigger.isUpdate){
        for(Integer i=0;i<trigger.new.size();i++){        
            if((trigger.old[i].Business_Unit__c != trigger.new[i].Business_Unit__c) || (trigger.old[i].UnitPrice != trigger.new[i].UnitPrice)){
                oppIds.add(trigger.new[i].OpportunityId);
            }
        }
    }
    if(Trigger.isDelete){
        for(OpportunityLineItem oppLineItems : Trigger.Old){
            System.debug('---Before oppIds ---' + oppIds);
            oppIds.add(oppLineItems.OpportunityId);        
        }
    }
    if(oppIds != null && oppIds.size()>0){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Id oppId : oppIds){
            oppList.add(updateOppMap.get(oppId));
        }
        UniqueBusinessUnit UBU = new UniqueBusinessUnit();
        oppsToUpdate = UBU.processOpprLineItems(oppList);
    }   
    if(oppsToUpdate != null && oppsToUpdate.size()>0){
        for(Opportunity opp : oppsToUpdate){
            updateOppMap.put(opp.id,opp);    
        }
    }
     //-----CODE START FOR FY15 Business Plan Focus field Update Requirement-------------
    public Set<Id> OppLineItemIdSet = new Set<Id>();
   
    if(Trigger.isAfter && !Trigger.isDelete){
        for(Integer i=0;i<trigger.new.size();i++){
            System.debug('+++++++Product group1111++++++'+trigger.new[i].Product_Group__c);
            if(Trigger.isUpdate && (trigger.old[i].Product_Group__c != trigger.new[i].Product_Group__c)){
                OppLineItemIdSet.add(trigger.new[i].Id);
            }else if(Trigger.isInsert){
                OppLineItemIdSet.add(trigger.new[i].Id);
            }
        }
        if(OppLineItemIdSet != null && OppLineItemIdSet.size()>0){
            //UpdateBusinessPlanFocus UBPF = new UpdateBusinessPlanFocus();
            //UpdateBusinessPlanFocus.LogicTriggeredBy = 'OpportunityLineItem';
            //System.debug('++++OppLineItemIdSet+++++'+OppLineItemIdSet);
            UpdateBusinessPlanFocus.LogicTriggeredFromOpportunityLineItem(OppLineItemIdSet);
            //UpdateBusinessPlanFocus.LogicTriggeredFromOpportunityLineItem(OppLineItemIdSet);
        }   
    }       
    //-----CODE END FOR FY15 Business Plan Focus field Update Requirement-------------
    
    if(Trigger.isDelete)    
    {
        User currentUser = [Select Id,UserType,ContactId, IsPortalEnabled, AccountId From User WHERE Id = :UserInfo.getUserId() LIMIT 1];       
        if(currentUser.UserType != 'PowerPartner')
        {
            for(OpportunityLineItem lineItem : Trigger.old){
                if(lineItem.Partner_Added__c == true)
                    lineItem.addError('Internal Users can not delete products added by partners.'); 
            }
        }
        return;
    }   
    
    List<Id> prodIds = new List<Id>();
    Map<Id,Id> oppLineItem_Prod_Map = new Map<Id,Id>();
    Map<Id,String> opp_Product_Map = new Map<Id,String>();
     
    Set<Id> oppsIds = new Set<Id>();
    Map<Id,Double> oppId_unitprice_map = new Map<Id,Double>();
    RecordTypes_Setting__c dealRegistrationRecordType = RecordTypes_Setting__c.getValues('Deal Registration');
    Id dealRegistrationRecordTypeId = dealRegistrationRecordType.RecordType_Id__c;
    System.Debug('RRRRRRRRRRRRRRRRRRRRRRRRRRRRR ' + oppLineItem_Prod_Map + ' ' + opp_Product_Map);

    List<Opportunity> opportunities = new List<Opportunity>();
    for(Opportunity o : updateOppMap.values()){
        if(o.RecordTypeId == dealRegistrationRecordTypeId)
            opportunities.add(o);
    }
    
    for(Opportunity opp : opportunities){
        oppsIds.add(opp.Id);
    }
    List<OpportunityLineItem> oppLineItems = [Select Id,OpportunityId, Partner_Sales_Price__c, PricebookEntryId from OpportunityLineItem where OpportunityId IN :oppsIds];
    for(OpportunityLineItem tempLineItem : oppLineItems) {
        prodIds.add(tempLineItem.PricebookEntryId);
        oppLineItem_Prod_Map.put(tempLineItem.PricebookEntryId,tempLineItem.OpportunityId);
        
        if(oppId_unitprice_map.containsKey(tempLineItem.OpportunityId)) {
            Double price = oppId_unitprice_map.get(tempLineItem.OpportunityId);
            if(tempLineItem.Partner_Sales_Price__c != null){
                 price = price + tempLineItem.Partner_Sales_Price__c;
                 oppId_unitprice_map.put(tempLineItem.OpportunityId,price); 
            }
        } else {
            oppId_unitprice_map.put(tempLineItem.OpportunityId,tempLineItem.Partner_Sales_Price__c);
        }
    }
    if(prodIds.size() > 0){
        List<PricebookEntry> products = [SELECT Id,Name FROM PricebookEntry WHERE Id IN :prodIds];
        for(PricebookEntry prod :products){
            if(opp_Product_Map.get(oppLineItem_Prod_Map.get(prod.Id)) == null){
                opp_Product_Map.put(oppLineItem_Prod_Map.get(prod.Id),prod.Name);
            }
            else{
                opp_Product_Map.put(oppLineItem_Prod_Map.get(prod.Id), opp_Product_Map.get(oppLineItem_Prod_Map.get(prod.Id)) + ',' + prod.Name);
            }
        }   
    }
    System.debug('Estimated value ---'+oppId_unitprice_map);
    //Map<Id,Opportunity> oppUpdates = new Map<Id,Opportunity>();        
    for(Opportunity opp : opportunities){
        if(Trigger.isUpdate){
            if(opp.Reseller_Product_Name__c <> opp_Product_Map.get(opp.Id)){
                opp.Reseller_Product_Name__c = opp_Product_Map.get(opp.Id);
                updateOppMap.put(opp.Id,opp);         
            }
            if(opp.Reseller_Estimated_Value__c <> oppId_unitprice_map.get(opp.Id)){
                opp.Reseller_Estimated_Value__c = oppId_unitprice_map.get(opp.Id);      
                updateOppMap.put(opp.Id,opp);     
            }
        }
        else{
            if(opp_Product_Map.containsKey(opp.Id)){
                opp.Reseller_Product_Name__c = opp_Product_Map.get(opp.Id);
                updateOppMap.put(opp.Id,opp);
            }
            if(oppId_unitprice_map.containsKey(opp.Id)){
                opp.Reseller_Estimated_Value__c = oppId_unitprice_map.get(opp.Id);
                updateOppMap.put(opp.Id,opp);
            } 
        }
    }
    update updateOppMap.values();   
    
}