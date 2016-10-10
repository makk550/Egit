trigger SetProductMaterialId on Quote_Product_Report__c (before insert, after insert) {
    
    System.debug('++++Inside Quote Product Trigger+++');
    
    //Exising code. Added Context switching
    if(trigger.isInsert && trigger.isBefore){
    	
    	System.debug('++++Inside Existing Trigger block+++');
    	
     	Set<String> ProductMaterialNameSet = new Set<String>();
	    for(Quote_Product_Report__c QPR:trigger.New){
	        if(QPR.EAI_Product_Material__c != null){
	            ProductMaterialNameSet.add(QPR.EAI_Product_Material__c);
	        }        
	    }
	    List<Product_Material__c> PMList = [select Id,Name from Product_Material__c where Name IN: ProductMaterialNameSet];
	    Map<String,Id> ProductMaterialNameAndIdMap = new Map<String,Id>();
	    if(PMList != null && PMList.size()>0){
	        for(Product_Material__c PM:PMList){
	            ProductMaterialNameAndIdMap.put(PM.Name,PM.Id);
	        } 
	    }
	    for(Quote_Product_Report__c QPR:trigger.New){
	        if(ProductMaterialNameAndIdMap.containsKey(QPR.EAI_Product_Material__c)){
	            QPR.Product_Material__c = ProductMaterialNameAndIdMap.get(QPR.EAI_Product_Material__c);
	        }
	    }
	    
    }    
    
    //Education QQ - Code for rollup count of royalty flag and migration/upgrade
    if(trigger.isInsert && trigger.isAfter)
    {
    	
    	System.debug('++++Inside New Trigger block+++');
    	Set<Id>  quoteIdSet = new Set<Id>();
    	
	    List<scpq__SciQuote__c>  quoteListUpdatableForRoyalty = new List<scpq__SciQuote__c>();
	    List<scpq__SciQuote__c>  quoteListUpdatableForUpgrade = new List<scpq__SciQuote__c>();  
	    
	    	    	
        for(Quote_Product_Report__c qpr : Trigger.new)
        {
        	System.debug('++++Inside Trigger Quote is going to added+++'+qpr.Sterling_Quote__c);
            quoteIdSet.add(qpr.Sterling_Quote__c);
        }
	   
	   	    
	    Map<ID,scpq__SciQuote__c> quoteMap = new Map<ID,scpq__SciQuote__c> ([Select Id,Royalties__c,Migration_Upgrade__c from scpq__SciQuote__c WHERE ID IN :quoteIdSet]);
	    for(scpq__SciQuote__c quoteObj : [Select ID,name,(Select ID FROM Quote_Products_Reporting__r where Royalty_Product__c = True) from scpq__SciQuote__c WHERE ID IN :quoteIdSet])
	    { 
	        quoteMap.get(quoteObj.ID).Royalties__c = quoteObj.Quote_Products_Reporting__r.size();     
	        System.debug('++++Inside Trigger Royalty Size+++'+quoteObj.Quote_Products_Reporting__r.size());   
	        quoteListUpdatableForRoyalty.add(quoteMap.get(quoteObj.id));
	    }
	    for(scpq__SciQuote__c quoteObj1 : [Select ID,name,(Select ID FROM Quote_Products_Reporting__r where Bus_Transaction_Type__c = 'Time - Product Migration') from scpq__SciQuote__c WHERE ID IN :quoteIdSet])
	    {         
	        quoteMap.get(quoteObj1.ID).Migration_Upgrade__c = quoteObj1.Quote_Products_Reporting__r.size();
	        System.debug('++++Inside Trigger BTType Size+++'+quoteObj1.Quote_Products_Reporting__r.size()); 
	        quoteListUpdatableForUpgrade.add(quoteMap.get(quoteObj1.id));
	    }
	    
	    if(quoteListUpdatableForRoyalty != NULL && quoteListUpdatableForRoyalty.size() > 0)
	        UPDATE quoteListUpdatableForRoyalty;
	    if(quoteListUpdatableForUpgrade != NULL && quoteListUpdatableForUpgrade.size() > 0)
	        UPDATE quoteListUpdatableForUpgrade;	
	} 
    
    
   
}