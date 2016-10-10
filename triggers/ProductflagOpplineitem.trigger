trigger ProductflagOpplineitem  on OpportunityLineItem(before Insert,before Update){
    Set<id> priceBookEntryIdSet=new Set<Id>();
    List<OpportunityLineItem> opptyLineItemList=new List<OpportunityLineItem>();
     
    for(OpportunityLineItem oppLnItem:trigger.new){
        if(oppLnItem.L7_Product_Flag__c==false || oppLnItem.Nimsoft_Product_Flag__c == false){
            priceBookEntryIdSet.add(oppLnItem.PricebookEntryId);
            opptyLineItemList.add(oppLnItem);
        }        
    }
    
    Map<Id,PricebookEntry> priceBookEntryMap=new Map<Id,PricebookEntry>([Select Id,name,Product2.Name from PricebookEntry where Id in:priceBookEntryIdSet]);
   
     for(OpportunityLineItem oppLnItem:opptyLineItemList){
         PricebookEntry pbe=priceBookEntryMap.get(oppLnItem.PricebookEntryId);         
         if(pbe!=null){
             String product2Name=pbe.Product2.Name;
             if(product2Name!=null&&product2Name!=''){
                 product2Name=product2Name.toLowerCase();                 
                 if(product2Name.contains('layer')){
                     oppLnItem.L7_Product_Flag__c=true;
                 }
                 if((product2Name.contains('nimsoft')) || (product2Name.contains('cloud service management'))){
                     oppLnItem.Nimsoft_Product_Flag__c=true;
                 }                                  
            } 
         } 
     }//

}