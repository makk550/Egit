//happenes when an opportunity is created or when an opportunity is updated and the Closed Date or Currency Is Changed On the Opportunity
// 1 SOQL query
//this trigger will update the USD Conversion Rate on the opportunity when a new opportunity is created and 
//when the close date or the Currnecy Code on an existing opportuniyty is changed
trigger UpdateOpportunityUSDCurrencyExchange on Opportunity (before insert, before update) {
    Set<string> currencyCodeList=new Set<string>();
    Date maxCloseDate=null;
    Date MinCloseDate=null;  
    
    for(Opportunity opp:Trigger.new)
    {
        boolean processOpportunity=false;       
        if(Trigger.isInsert)
        {
            processOpportunity=true; 
        }
        else
        {
            Opportunity oldOpp=Trigger.oldMap.get(opp.Id);
            if(opp.CloseDate<>oldOpp.CloseDate || opp.CurrencyIsoCode<>oldOpp.CurrencyIsoCode)
            {
                processOpportunity=true;
            }
        }
        if(processOpportunity)
        {
            currencyCodeList.add(opp.CurrencyIsoCode);
            if(maxCloseDate==null)
            {
                maxCloseDate=opp.CloseDate;
                MinCloseDate=opp.CloseDate;  
            }
            else
            {
                if(opp.CloseDate>maxCloseDate)
                {
                    maxCloseDate=opp.CloseDate;
                }
                else if(opp.CloseDate<MinCloseDate)
                {
                    MinCloseDate=opp.CloseDate; 
                }
            }
        }           
    }
    
    //process if there are any valid opportunities
    if(currencyCodeList.size()>0)
    {
        System.debug('MinCloseDate: '+MinCloseDate);
        System.debug('maxCloseDate: '+maxCloseDate);
        System.debug('Currency: '+currencyCodeList);
        //get Dated Conversion Rates
        List<DatedConversionRate> conversionRates=[Select StartDate, NextStartDate, LastModifiedDate, IsoCode, ConversionRate 
        From DatedConversionRate where IsoCode in:currencyCodeList and StartDate<=:MinCloseDate and NextStartDate>:maxCloseDate];
        
        //update usd conversion Rates on the Opportunity
        for(Opportunity opp:Trigger.new)
        {
            boolean processOpportunity=false;       
            if(Trigger.isInsert)
            {
                processOpportunity=true;
            }
            else
            {
                Opportunity oldOpp=Trigger.oldMap.get(opp.Id);
                if(opp.CloseDate<>oldOpp.CloseDate || opp.CurrencyIsoCode<>oldOpp.CurrencyIsoCode)
                {
                    processOpportunity=true;
                }
            }
            if(processOpportunity)
            {
                for(DatedConversionRate cr:conversionRates)
                {
                    if(opp.CloseDate >= cr.StartDate && opp.CloseDate<cr.NextStartDate && opp.CurrencyIsoCode==cr.IsoCode)
                    {
                        opp.USD_Exchange_Rate__c=cr.ConversionRate;
                    }
                }
            } 
        }   
    }
}