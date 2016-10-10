trigger NewLogoTrigger on OpportunityLineItem (after insert) 
{
    System.debug('---In NewLogoTrigger----' + SystemIdUtility.skipOpportunityLineItemTriggers);
    
    if(SystemIdUtility.skipOpportunityLineItemTriggers)
        return;        
    
    List<OpportunityLineItem> myOppLineItemsList = [Select Id, OpportunityId, CreatedDate FROM OpportunityLineItem where id IN :Trigger.newMap.KeySet()];
    
    Set<Id> myOppsIdsSet = new Set<Id>();
    
    for(OpportunityLineItem myLineItem : myOppLineItemsList)  
    {
        myOppsIdsSet.add(myLineItem.OpportunityId);
    }
    
    List<Opportunity> myOpportunities = [Select Id, AccountID, CloseDate, CreatedDate FROM Opportunity where id IN :myOppsIdsSet];
    List<Opportunity> OppsCreatedToday = new List<Opportunity>();
    Set<Id> myAccountIds = new Set<Id>();
    Set<Id> OppCreatedTodaySet = new Set<Id>();
    
    for(Opportunity myOppty : myOpportunities)
    {
        Datetime myOppCreateDateTime = myOppty.CreatedDate;
        Date myOppCreateDate = myOppCreateDateTime.date();
        if(myOppCreateDate.isSameDay(Date.today()))
        {
            OppsCreatedToday.add(myOppty);
            myAccountIds.add(myOppty.AccountId);
            OppCreatedTodaySet.add(myOppty.Id);
        }
    }
    
    if(OppCreatedTodaySet.size() > 0)
    {
        List<Account> myAccounts = [Select Id, GU_DUNS_NUMBER__c, Enterprise_ID__c from Account where id IN :myAccountIds];
        Map<Id, String> accountIdMap = new Map<Id, String>();
        Map<Id, String> globalParentIdMap = new Map<Id, String>(); 
        for(Account tmpAccount : myAccounts)
        {
            accountIdMap.put(tmpAccount.Id, tmpAccount.Id);
            globalParentIdMap.put(tmpAccount.Id, tmpAccount.GU_DUNS_NUMBER__c);        
        }
    
        Map<Id, String> productMap = new Map<Id, String>();
        Map<Id, String> priceBookMap = new Map<Id, String>();
        Map<Id, String> OppLIMap = new Map<Id, String>();
        Map<Id, List<Id>> OppMap = new Map<Id, List<Id>>();
            
        List<OpportunityLineItem> relevantOppLineItems = [Select Id, OpportunityId, PricebookEntryId from OpportunityLineItem where OpportunityId IN : OppCreatedTodaySet];
        for(OpportunityLineItem tmpLineItem : relevantOppLineItems)
        {
            OppLIMap.put(tmpLineItem.Id, tmpLineItem.PricebookEntryId);
            if(OppMap.containsKey(tmpLineItem.OpportunityId))
            {
                List<Id> OppLIList = OppMap.get(tmpLineItem.OpportunityId);
                OppLIList.add(tmpLineItem.Id);
                OppMap.put(tmpLineItem.OpportunityId, OppLIList);            
            }
            else
            {
                List<Id> OppLIList = new List<Id>();
                OppLIList.add(tmpLineItem.Id);
                OppMap.put(tmpLineItem.OpportunityId, OppLIList);
            }
        }    
        List<PricebookEntry> myPriceBooks = [Select Product2Id from PricebookEntry where id IN : OppLIMap.values()];
        for(PricebookEntry tmpPriceBook : myPriceBooks)
        {
            priceBookMap.put(tmpPriceBook.Id, tmpPriceBook.Product2Id);
        }
        List<Product2> myProduct2 = [Select CSU2__c from Product2 where id IN : priceBookMap.values()];
        for(Product2 tmpPrd : myProduct2)
        {
            productMap.put(tmpPrd.Id, tmpPrd.CSU2__c);
        }
        
        List<String> xmlStrings = new List<String>();
        for(Opportunity prepOpp : OppsCreatedToday)
        {
            String createdDate = ''+prepOpp.CreatedDate.date();
            String closedDate = ''+prepOpp.CloseDate;
            createdDate = createdDate.replace(' 00:00:00', '');            
            closedDate = closedDate.replace(' 00:00:00', '');            
            String xmlString = '<opportunity><id>'+prepOpp.Id+'</id><createDate>'+createdDate+'</createDate>';
            xmlString = xmlString + '<closeDate>'+closedDate+'</closeDate><opportunityProducts>';
            List<Id> myLISet = OppMap.get(prepOpp.Id);
            for(Id LiId : myLISet)
            {
              xmlString = xmlString + '<opportunityProduct><id>'+LiId+'</id><gbu2>'+productMap.get(priceBookMap.get(OppLIMap.get(LiId)))+'</gbu2></opportunityProduct>';  
            }
            xmlString = xmlString + '</opportunityProducts><accountId>';
            xmlString = xmlString + accountIdMap.get(prepOpp.AccountId) + '</accountId><globalParentId>';
            xmlString = xmlString + globalParentIdMap.get(prepOpp.AccountId) + '</globalParentId></opportunity>';
            xmlStrings.add(xmlString);
            System.debug('xmlString is ' + xmlString);
        }
        if(!system.isBatch())
          NewLogoHandler.callEAIforNewLogo(xmlStrings);
    }
}