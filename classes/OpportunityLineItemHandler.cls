public class OpportunityLineItemHandler implements ITrigger{
    public void bulkBefore(){
        OpportunityLineItemGateway.loadOpportunityLineItemBulkValues();
    }
    public void bulkAfter(){
        OpportunityLineItemGateway.loadOpportunityLineItemBulkValues();
    }
    public void beforeInsert(SObject so){
        OpportunityLineItem oli = (OpportunityLineItem)so;
        Map<Id,PriceBookEntry> pbeMap = OpportunityLineItemGateway.pbeMap;
        //OppLIPullUpfront
        oli.Upfront_Revenue_Eligible__c =(oli.PricebookEntryId <> null && pbeMap.get(oli.PricebookEntryId) <> null && pbeMap.get(oli.PricebookEntryId).Product2 <> null  && pbeMap.get(oli.PricebookEntryId).Product2.Upfront_Revenue_Eligible__c  <> null && pbeMap.get(oli.PricebookEntryId).Product2.Upfront_Revenue_Eligible__c == 'Yes');
        flagProduct(oli);
    }
    public void beforeUpdate(SObject oldSo, SObject so){
        OpportunityLineItem oli = (OpportunityLineItem)so;
        flagProduct(oli);
    }
    public void beforeDelete(SObject so){
        OpportunityLineItem oli = (OpportunityLineItem)so;
        //AddProductsToOpportunity
        if(UserInfo.getUserType()!='PowerPartner' && oli.Partner_Added__c == true)
            oli.addError('Internal Users can not delete products added by partners.');
        
    }
    public void afterInsert(SObject so){
    system.debug('ObjectName:'+so);
        OpportunityLineItem oli = (OpportunityLineItem)so;
        //OLISetOppStatusToReneqested & OppLIAttachDetachRenewals
    system.debug('oli.business_type__c:'+oli.business_type__c);
        if(oli.business_type__c == 'Renewal'){
            Opportunity opp = OpportunityLineItemGateway.getOpportunitytoUpdate(oli.OpportunityId);
            system.debug('oli.OpportunityId:'+oli.OpportunityId);
            opp.rpd_status__c = 'Requested';
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
            OpportunityLineItemGateway.opportunitiesToUpdate.put(opp.id,opp);
        }
    }
    public void afterUpdate(SObject oldSo, SObject so){
    }
    public void afterDelete(SObject so){
        OpportunityLineItem oli = (OpportunityLineItem)so;
        
        //OLISetOppStatusToReneqested & OppLIAttachDetachRenewals
        Opportunity opp = OpportunityLineItemGateway.getOpportunitytoUpdate(oli.OpportunityId);
        if(oli.business_type__c == 'Renewal'){
            opp.rpd_status__c = 'Requested';
            decimal pr = opp.Projected_renewal__c;
            if(pr == null)
                pr =0;
            pr -= oli.UnitPrice;
            opp.Projected_renewal__c = pr;
        }
        decimal ppr = opp.Partner_Sales_Price__c;                    
        if(ppr == null)
            ppr = 0;
        if(oli.Partner_Added__c == true)
           ppr -= oli.UnitPrice;                    
        opp.Partner_Sales_Price__c = ppr;
        OpportunityLineItemGateway.opportunitiesToUpdate.put(opp.id,opp);
    }
    public void andFinally(){
        if(Trigger.isAfter)
        system.debug('TestOppValues'+OpportunityLineItemGateway.opportunitiesToUpdate.values());
        try{
        update OpportunityLineItemGateway.opportunitiesToUpdate.values();
        }
        Catch(DMLException e){
            
            
        }
        
        
        if(Trigger.isInsert && Trigger.isAfter){
            System.debug('xmlstring======================'+OpportunityLineItemGateway.xmlStrings);

            // To handle batch
            if(!system.isBatch() && !Test.isRunningTest())
            NewLogoHandler.callEAIforNewLogo(OpportunityLineItemGateway.xmlStrings);
        }
    }
    private static void flagProduct(OpportunityLineItem oli){
        Map<Id,PriceBookEntry> pbeMap = OpportunityLineItemGateway.pbeMap;
        //Nimsoft flag and Layer7 Product flag
        if((oli.Nimsoft_Product_Flag__c == false || oli.L7_Product_Flag__c == false) && (pbeMap.get(oli.PricebookEntryId) != null && pbeMap.get(oli.PricebookEntryId).Product2 != null && pbeMap.get(oli.PricebookEntryId).Product2.name != null)){
            String product2Name = pbeMap.get(oli.PricebookEntryId).Product2.name;
            product2Name=product2Name.toLowerCase();                 
            if((product2Name.contains('nimsoft')) || (product2Name.contains('cloud service management')) || (product2Name.contains('unified infrastructure management')))
                oli.Nimsoft_Product_Flag__c=true;
                String   product2MarketFocusArea= pbeMap.get(oli.PricebookEntryId).Product2.Market_Focus_Area__c;// ILT for FY16 by YEDRA01
                if(product2MarketFocusArea!=null)
            product2MarketFocusArea = product2MarketFocusArea.toLowerCase();// ILT for FY16 by YEDRA01

            if((product2Name.contains('layer')) || (product2Name.contains('api portal on-premise')) || (product2Name.contains('api management')) || (product2Name.contains('api gateway')) || (product2Name.contains('ilt') && product2MarketFocusArea.contains('api management')))//changes ILT for FY16 by YEDRA01
                oli.L7_Product_Flag__c=true;
        }
    }
}