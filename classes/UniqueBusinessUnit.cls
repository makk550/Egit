public class UniqueBusinessUnit
{
    public UniqueBusinessUnit()
    {
    }
    
    public static boolean hasUpdateOpportunityRun = false;
    
    /*
    public void processOpprLineItems(Set<Id> OpprIds)
    {
        //List<OpportunityLineItem> oppLineItemsSet = [SELECT Business_Type__c,Sales_Price_USD__c, Sales_Price_Net_to_CA__c, Stretch__c,Product_Family__c,Business_Unit__c FROM OpportunityLineItem where Opportunityid IN: OppLineItem];
        List<Opportunity> oppList = [SELECT Id,Sales_Coverage_Business_Unit__c,Driving_Sales_Coverage_Business_Unit__c,(SELECT Business_Unit__c,OpportunityId,UnitPrice FROM OpportunityLineItems) FROM Opportunity where Id IN: OpprIds];
        Map<Id,Opportunity> oppUpdate = new Map<Id,Opportunity>();
        Map<String,Double> salesPriceUpdate = new Map<String,Double>();
        Map<Double,List<String>> SummationValue_BU_Map = new Map<Double,List<String>>();

        Set<String> DuplicateSummation = new Set<String>();

        //Map<Id,String> OppId_SalesCoverageBUValue_Map = new Map<Id,String>();
        List<String> drivingSalesUnit = new List<String> {'SERVICE MANAGEMENT','WORKLOAD AUTOMATION','PPM','APPLICATION DELIVERY','SECURITY','ENTERPRISE MANAGEMENT','ECOMMERCE','API MANAGEMENT','MAINFRAME','ERWIN','DOM','EMM','AUTOMATION','OTHER','N/A'};
        //String drivingSalesUnit = 'SERVICE MANAGEMENT,WORKLOAD AUTOMATION,PPM,APPLICATION DELIVERY,SECURITY,ENTERPRISE MANAGEMENT,NEW BUSINESS INNOVATION,L7,MAINFRAME,DATA MANAGEMENT,MDM,OTHER,N/A';
        String val;
        Double i=0.0;

        Set<String> uniqueBusinessUnit = new Set<String>();

        for(Opportunity opty : oppList)
        {
            String finalUnit = '';
            String FirstValue = '';
            String highestValueBU = '';
            boolean isHighest = false;
            for(OpportunityLineItem oppLineItem : opty.OpportunityLineItems)
            {
                if(oppLineItem.Business_Unit__c != null && oppLineItem.Business_Unit__c.length()>0)
                {
                    System.debug(' --- Business Unit -- ' + oppLineItem.Business_Unit__c);
                    uniqueBusinessUnit.add(oppLineItem.Business_Unit__c);
                    System.debug(' --- uniqueBusinessUnit --- ' + uniqueBusinessUnit);
                }

                //Logic for highest value in Driving Sales Coverage Business Unit
                if(oppLineItem.Business_Unit__c !=null &&  oppLineItem.Business_Unit__c !='')
                {
                    if(salesPriceUpdate.containsKey(oppLineItem.Business_Unit__c))
                    {
                        salesPriceUpdate.put(oppLineItem.Business_Unit__c,salesPriceUpdate.get(oppLineItem.Business_Unit__c)+oppLineItem.UnitPrice);
                        System.debug(' ----- salesPriceUpdate.values() contains case --- ' + salesPriceUpdate.values());
                        System.debug(' ----- salesPriceUpdate.keyset() contains case --- ' + salesPriceUpdate.keyset());
                    }
                    else
                    {
                        salesPriceUpdate.put(oppLineItem.Business_Unit__c,oppLineItem.UnitPrice);
                        System.debug(' ----- salesPriceUpdate.values()  --- ' + salesPriceUpdate.values());
                        System.debug(' ----- salesPriceUpdate.keyset() --- ' + salesPriceUpdate.keyset());
                    }
                }


                oppUpdate.put(oppLineItem.OpportunityId,opty);

            }
            if(uniqueBusinessUnit != null)
            {
                for(String s : uniqueBusinessUnit)
                {
                    if(finalUnit=='')
                        finalUnit = s;
                    else
                        finalUnit+=';'+s;
                    System.debug(' --- Final Business Unit after String oper ---' + finalUnit);
                }
                if (finalUnit == null)
                    opty.Sales_Coverage_Business_Unit__c = '';

            }
            opty.Sales_Coverage_Business_Unit__c = finalUnit;

            for(String s:salesPriceUpdate.keySet())
            {

                if(salesPriceUpdate.get(s) > i)
                {
                    System.debug('-----Inside the highest logic loop----');
                    i = salesPriceUpdate.get(s);
                    highestValueBU = s;
                    isHighest = true;
                }
                else if(i == salesPriceUpdate.get(s))
                {
                    System.debug('-----Inside the tie logic loop----');
                    isHighest = false;
                }

                if(SummationValue_BU_Map.containsKey(salesPriceUpdate.get(s)))
                {
                    SummationValue_BU_Map.get(salesPriceUpdate.get(s)).add(s.toUpperCase());
                }
                else
                {
                    SummationValue_BU_Map.put(salesPriceUpdate.get(s),new List<String>());
                    SummationValue_BU_Map.get(salesPriceUpdate.get(s)).add(s.toUpperCase());
                }
            }
            System.debug('-----SummationValue_BU_Map----'+SummationValue_BU_Map);
            //System.debug('-----Highest Value ----'+i);
            //System.debug('-----Highest Value Holding BU----'+highestValueBU);

            if(isHighest)
            {
                opty.Driving_Sales_Coverage_Business_Unit__c = highestValueBU;
            }
            else
            {
                for(Double d:SummationValue_BU_Map.keySet())
                {
                    if(SummationValue_BU_Map.get(d).size()>=2)
                    {
                        DuplicateSummation.addAll(SummationValue_BU_Map.get(d));
                    }
                }
                System.debug('----DuplicateSummation----'+DuplicateSummation);
                System.debug('----drivingSalesUnit-----'+drivingSalesUnit);
                for(String s:drivingSalesUnit)
                {
                    //System.debug('----s----'+s);
                    if(DuplicateSummation.contains(s))
                    {
                        FirstValue = s;
                        System.debug('----FirstValue----'+FirstValue);
                        break;
                    }
                }
                if(FirstValue !='')
                    opty.Driving_Sales_Coverage_Business_Unit__c = FirstValue;
            }

        }
        System.debug('----Before Update ----');
        update oppList;
        System.debug('----After Update ----');
    }*/
    
    public List<Opportunity> processOpprLineItems(List<Opportunity> oppList)
    {
        //List<OpportunityLineItem> oppLineItemsSet = [SELECT Business_Type__c,Sales_Price_USD__c, Sales_Price_Net_to_CA__c, Stretch__c,Product_Family__c,Business_Unit__c FROM OpportunityLineItem where Opportunityid IN: OppLineItem];
        //List<Opportunity> oppList = [SELECT Id,Sales_Coverage_Business_Unit__c,Driving_Sales_Coverage_Business_Unit__c,(SELECT Business_Unit__c,OpportunityId,UnitPrice FROM OpportunityLineItems) FROM Opportunity where Id IN: OpprIds];
        Map<Id,Opportunity> oppUpdate = new Map<Id,Opportunity>();
        Map<String,Double> salesPriceUpdate = new Map<String,Double>();
        Map<Double,List<String>> SummationValue_BU_Map = new Map<Double,List<String>>();

        Set<String> DuplicateSummation = new Set<String>();

        //Map<Id,String> OppId_SalesCoverageBUValue_Map = new Map<Id,String>();
        List<String> drivingSalesUnit = new List<String> {'SERVICE MANAGEMENT','WORKLOAD AUTOMATION','PPM','APPLICATION DELIVERY','SECURITY','ENTERPRISE MANAGEMENT','ECOMMERCE','API MANAGEMENT','MAINFRAME','ERWIN','DOM','EMM','AUTOMATION','OTHER','N/A'};
        //String drivingSalesUnit = 'SERVICE MANAGEMENT,WORKLOAD AUTOMATION,PPM,APPLICATION DELIVERY,SECURITY,ENTERPRISE MANAGEMENT,NEW BUSINESS INNOVATION,L7,MAINFRAME,DATA MANAGEMENT,MDM,OTHER,N/A';
        String val;
        Double i=0.0;

        Set<String> uniqueBusinessUnit = new Set<String>();

        for(Opportunity opty : oppList)
        {
            String finalUnit = '';
            String FirstValue = '';
            String highestValueBU = '';
            boolean isHighest = false;
            for(OpportunityLineItem oppLineItem : opty.OpportunityLineItems)
            {
                if(oppLineItem.Business_Unit__c != null && oppLineItem.Business_Unit__c.length()>0)
                {
                    System.debug(' --- Business Unit -- ' + oppLineItem.Business_Unit__c);
                    uniqueBusinessUnit.add(oppLineItem.Business_Unit__c);
                    System.debug(' --- uniqueBusinessUnit --- ' + uniqueBusinessUnit);
                }

                //Logic for highest value in Driving Sales Coverage Business Unit
                if(oppLineItem.Business_Unit__c !=null &&  oppLineItem.Business_Unit__c !='')
                {
                    if(salesPriceUpdate.containsKey(oppLineItem.Business_Unit__c))
                    {
                        salesPriceUpdate.put(oppLineItem.Business_Unit__c,salesPriceUpdate.get(oppLineItem.Business_Unit__c)+oppLineItem.UnitPrice);
                        System.debug(' ----- salesPriceUpdate.values() contains case --- ' + salesPriceUpdate.values());
                        System.debug(' ----- salesPriceUpdate.keyset() contains case --- ' + salesPriceUpdate.keyset());
                    }
                    else
                    {
                        salesPriceUpdate.put(oppLineItem.Business_Unit__c,oppLineItem.UnitPrice);
                        System.debug(' ----- salesPriceUpdate.values()  --- ' + salesPriceUpdate.values());
                        System.debug(' ----- salesPriceUpdate.keyset() --- ' + salesPriceUpdate.keyset());
                    }
                }


                oppUpdate.put(oppLineItem.OpportunityId,opty);

            }
            if(uniqueBusinessUnit != null)
            {
                for(String s : uniqueBusinessUnit)
                {
                    if(finalUnit=='')
                        finalUnit = s;
                    else
                        finalUnit+=';'+s;
                    System.debug(' --- Final Business Unit after String oper ---' + finalUnit);
                }
                if (finalUnit == null)
                    opty.Sales_Coverage_Business_Unit__c = '';

            }
            opty.Sales_Coverage_Business_Unit__c = finalUnit;

            for(String s:salesPriceUpdate.keySet())
            {

                if(salesPriceUpdate.get(s) > i)
                {
                    System.debug('-----Inside the highest logic loop----');
                    i = salesPriceUpdate.get(s);
                    highestValueBU = s;
                    isHighest = true;
                }
                else if(i == salesPriceUpdate.get(s))
                {
                    System.debug('-----Inside the tie logic loop----');
                    isHighest = false;
                }

                if(SummationValue_BU_Map.containsKey(salesPriceUpdate.get(s)))
                {
                    SummationValue_BU_Map.get(salesPriceUpdate.get(s)).add(s.toUpperCase());
                }
                else
                {
                    SummationValue_BU_Map.put(salesPriceUpdate.get(s),new List<String>());
                    SummationValue_BU_Map.get(salesPriceUpdate.get(s)).add(s.toUpperCase());
                }
            }
            System.debug('-----SummationValue_BU_Map----'+SummationValue_BU_Map);
            //System.debug('-----Highest Value ----'+i);
            //System.debug('-----Highest Value Holding BU----'+highestValueBU);

            if(isHighest)
            {
                opty.Driving_Sales_Coverage_Business_Unit__c = highestValueBU;
            }
            else
            {
                for(Double d:SummationValue_BU_Map.keySet())
                {
                    if(SummationValue_BU_Map.get(d).size()>=2)
                    {
                        DuplicateSummation.addAll(SummationValue_BU_Map.get(d));
                    }
                }
                System.debug('----DuplicateSummation----'+DuplicateSummation);
                System.debug('----drivingSalesUnit-----'+drivingSalesUnit);
                for(String s:drivingSalesUnit)
                {
                    //System.debug('----s----'+s);
                    if(DuplicateSummation.contains(s))
                    {
                        FirstValue = s;
                        System.debug('----FirstValue----'+FirstValue);
                        break;
                    }
                }
                if(FirstValue !='')
                    opty.Driving_Sales_Coverage_Business_Unit__c = FirstValue;
            }

        }
        System.debug('----Before Update ----');
        return oppList;
        
    }
}