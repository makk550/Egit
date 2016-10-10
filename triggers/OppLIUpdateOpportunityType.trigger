trigger OppLIUpdateOpportunityType on OpportunityLineItem (after insert,after delete) 
    {
    
    
          if(SystemIdUtility.skipOpportunityLineItemTriggers)
            return;
    
        List<OpportunityLineItem> lst_oppli = new List<OpportunityLineItem>();
        List<Active_Contract_Product__c> lst_oppli_detach = new List<Active_Contract_Product__c>();
        RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('New Opportunity');
        id recid = rec.RecordType_Id__c;
        RecordTypes_Setting__c rec2 = RecordTypes_Setting__c.getValues('Acquisition');
        id recid2 = rec2.RecordType_Id__c;
        Set<id> delIds = new Set<id>();    
        Set<ID> prdids = new Set<ID>();
        Set<ID> oppids = new Set<ID>();
        Set<ID> acpDelOLI= new Set<ID>();
        //Renewals collections
        Set<Id> SetOppIds =New Set<Id>();  
        Set<id> OLIDelIds = new Set<id>();
        List<Opportunity> UpdateOpp= new List<Opportunity>();
        //store all the opportunity ids
        if(Trigger.isInsert)
        {
            for(OpportunityLineItem oli : Trigger.new)
            {
                oppids.add(oli.OpportunityId);
                //Renewals
                if(oli.Business_Type__c == 'Renewal')
                    SetOppIds.add(oli.OpportunityId);                                 
            }
        }
        else if(Trigger.isDelete)
        {
            for(OpportunityLineItem oli : Trigger.old)
            {
              oppids.add(oli.OpportunityId);                    
              acpDelOLI.add(oli.Active_Contract_Product__c);
              delIds.add(oli.id); 
            //Renewals
               if(oli.Business_Type__c == 'Renewal')
                    {
                            SetOppIds.add(oli.OpportunityId);                                                               
                            OLIDelIds.add(oli.id);
                     }
                
            }   
            //Make the Converted to Opportunity Flag false for all the ACP tied to the OLIs deleted
            if(acpDelOLI.size()>0)
            {          
                lst_oppli_detach =[ select  id,Opportunity__c , Converted_To_Opportunity__c  from Active_Contract_Product__c where  id in: acpDelOLI];
                for(Integer i=0;i<lst_oppli_detach.size();i++)
                {
                    lst_oppli_detach[i].Converted_To_Opportunity__c = false;
                }
                database.update(lst_oppli_detach,false);     
            }
        }

        //fetch the line item details
        if(oppids.size()>0)
        {
             Map<Id,Opportunity> map_opp = new Map<Id,Opportunity>([select Id,Opportunity_Type__c from Opportunity where Id in:oppids and ((RecordTypeId=:recid) OR (RecordTypeId=:recid2)  OR RecordType.Name = 'Deal Registration' )  ]);

            lst_oppli = [select Business_Type__c, Active_Contract_Product__r.Dismantle_Date__c, Active_Contract_Product__r.Active_Contract__r.Contract_Term_Months__c, 
                        Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, 
                        Id,PricebookEntry.product2Id, PricebookEntry.Product2.Upfront_Revenue_Eligible__c, PricebookEntry.Product2.Family, OpportunityId    
                        from OpportunityLineItem where OpportunityId in: map_opp.keyset() and id not in: delIds]; 
           
            if(map_opp.size()>0) //IF 1 - start
            {
                if(lst_oppli.size() == 0) ////IF 2 - start
                {
                    //if there are no lineitems to an opportunity, set the Opportunity Type to null
                    List<Opportunity> oplst = map_opp.values();
                    for(Integer i=0;i<oplst.size();i++)
                    {
                        oplst[i].Opportunity_Type__c = null;
                        //oplst[i].MF_Product_Count__c = 0;---***---
                        //oplst[i].Upfront_Product_Count__c = 0;---***---
                      
                    }
                    update oplst;
                    return;
                } //IF 2 - End
                 //Anitha from Here Sprint 3 - Upfront Autopopulate -> To get the Prod Count & Upfront Prod Count
                else //Else 2 - start
                {
                    Map<id,Set<string>> mapOppIdProdFamily = new Map<id,set<string>>(); //FY13 
                    Map<Id,Integer> mapOpptyMFProdCount = new Map<Id,Integer>();
                    Map<Id,Integer> mapOpptyUpfrontProdCount = new Map<Id,Integer>();
                    Map<id,RenewalValues> mapOppIdRenewalValues = new Map<id,RenewalValues>();

                    for(OpportunityLineItem oli:lst_oppli)
                    {   
                     

                        //Associating a set of all product families tied to the Opportunity Products to the Opp - start
                        Set<string> setFamily = mapOppIdProdFamily.get(oli.opportunityid);
                        if(setFamily == null) setFamily = new Set<string>();
                        setFamily.add(((oli.PricebookEntry.Product2.Family == 'Renewal' || oli.PricebookEntry.Product2.Family == 'Time' || oli.PricebookEntry.Product2.Family == 'Mainframe Capacity' || oli.Business_Type__c == 'Renewal') ?'Renewal':oli.PricebookEntry.Product2.Family));
                        mapOppIdProdFamily.put(oli.opportunityid, setfamily);
                        //Associating a set of all product families tied to the Opportunity Products to the Opp - end
                
                        //Upfront Start
                        if(oli.Business_Type__c== 'MF Capacity')  //Counter for MF Capacity Products
                        {   integer mfProdCount = MapOpptyMFProdCount.get(oli.opportunityid);
                            if(mfProdCount == null) {mfProdCount = 0;}
                            mfProdCount++;  MapOpptyMFProdCount.put(oli.opportunityid,mFProdCount);
                        }
                        if(oli.PricebookEntry.Product2.Upfront_Revenue_Eligible__c == 'Yes')  //Counter for Upfront Eligible Products
                        {   integer upfrontProdCount = MapOpptyUpfrontProdCount.get(oli.opportunityid);
                            if(upfrontProdCount == null) {upfrontProdCount = 0;}
                            if(oli.Business_Type__c != 'Renewal' && oli.Business_Type__c != 'MF Capacity'){
                               upfrontProdCount++; 
                            }
                             MapOpptyUpfrontProdCount.put(oli.opportunityid,upfrontProdCount);
                        }
                        //Upfront End


                        //Renewals Start
                        if(SetOppIds.contains(oli.opportunityid))
                        {   
                            RenewalValues oRenewalValues = mapOppIdRenewalValues.get(oli.OpportunityId);
                            if(oRenewalValues == null) oRenewalValues = new RenewalValues();
                            if(oRenewalValues.Original_Expiration_Date == null ||  oRenewalValues.Original_Expiration_Date > oli.Active_Contract_Product__r.Dismantle_Date__c)
                                {   oRenewalValues.Original_Expiration_Date = oli.Active_Contract_Product__r.Dismantle_Date__c;
                                    oRenewalValues.Original_Deal_Term_Months = oli.Active_Contract_Product__r.Active_Contract__r.Contract_Term_Months__c; 
                                }           
                            if(oli.Active_Contract_Product__r.Active_Contract__r.Status_Formula__c != 'Validated')
                                 oRenewalValues.isValidated =  false;
                            mapOppIdRenewalValues.put(oli.OpportunityId,oRenewalValues);
                        }
                        //Renewals End
                    }
                    List<Opportunity> lstUpdateOpps = map_opp.values();
                
                    for(Opportunity opp: lstUpdateOpps)
                    {
                        //Upfront Start
                        //opp.MF_Product_Count__c = (MapOpptyMFProdCount.keyset().contains(opp.id)? MapOpptyMFProdCount.get(opp.id):0);---***---
                        //opp.Upfront_Product_Count__c  = (MapOpptyUpfrontProdCount.keyset().contains(opp.id)? MapOpptyUpfrontProdCount.get(opp.id):0);---***---
                        //Upfront End  
                        //Calculate the Opportunity Type of the Opp
                        opp.Opportunity_Type__c = calculateOpportunityType(mapOppIdProdFamily.get(opp.id));
                        //Renewals -start
                        if(SetOppIds.contains(opp.id))
                        {   
                            RenewalValues oRenewalValues = mapOppIdRenewalValues.get(opp.id);
                            if(oRenewalValues == null) oRenewalValues = new RenewalValues();
                            if(oRenewalValues.Original_Expiration_Date != null) 
                                    opp.Original_Expiration_Date__c = oRenewalValues.Original_Expiration_Date;
                            if(oRenewalValues.Original_Deal_Term_Months != null)
                                     opp.Original_Deal_Term_Months__c = oRenewalValues.Original_Deal_Term_Months;
                            opp.Finance_Valuation_Status__c = (oRenewalValues.isValidated?'Validated':'Not Validated');
                            opp.rpd_status__c = 'Requested'; //Moved over from trigger 
                        }
                        //Renewals - end


                    }
                if(lstUpdateOpps.size() > 0)
                    Database.update(lstUpdateOpps, false);
                           
               
            } //Else 2 - end
        }//IF 1 - end                               
 }
        
public class RenewalValues
{
    Boolean isValidated{get;set;}
    Decimal Original_Deal_Term_Months{get;set;}
    Date Original_Expiration_Date{get;set;}
    public RenewalValues()
    {
        isValidated = true;
        Original_Deal_Term_Months = 0;
    }
}

public string calculateOpportunityType(set<string> setType)
{
    if(setType == null || setType.size() == 0) //Empty StrType if no family -type associated
        return '';
    string strtype = '';
    if(setType.size() == 1)
    { 
        if(setType.contains('Product'))
            strtype = 'PNCV';
        else if(setType.contains('Renewal'))
            strtype = 'Renewal';
        else if(setType.contains('Services'))
            strtype = 'Services';
        else if(setType.contains('Support'))
            strtype = 'Support';
        else if(setType.contains('Education'))
            strtype = 'Standalone Education';
    }
    else if(setType.size() == 2)
    {
            if(setType.contains('Product') && setType.contains('Renewal'))
                 strtype = 'Renewal w/Products';
            else if(setType.contains('Product') && setType.contains('Services'))
                 strtype = 'PNCV w/Services';
            else if(setType.contains('Product') && setType.contains('Support'))
                 strtype = 'PNCV w/Support';
            else if(setType.contains('Product') && setType.contains('Education'))
                 strtype = 'PNCV w/Education';
            else if(setType.contains('Renewal') && setType.contains('Services'))
                 strtype = 'Renewal w/Services';
            else if(setType.contains('Renewal') && setType.contains('Support'))
                 strtype = 'Renewal w/Support';
            else if(setType.contains('Renewal') && setType.contains('Education'))
                 strtype = 'Renewal w/Education';
            else if(setType.contains('Services') && setType.contains('Education'))
                 strtype = 'Services w/Education';
            else if(setType.contains('Education') && setType.contains('Support'))
                 strtype = 'Education w/Support';
            else if(setType.contains('Services') && setType.contains('Support'))
                 strtype = 'Services w/Support';
    }
   else if(setType.size() == 3)
   { 
            if(setType.contains('Product') && setType.contains('Renewal') && setType.contains('Services'))
                strtype = 'Renewal w/Products & Services';
            else if(setType.contains('Product') && setType.contains('Renewal') && setType.contains('Support'))
                strtype = 'Renewal w/Products & Support';
            else if(setType.contains('Product') && setType.contains('Renewal') && setType.contains('Education'))
                strtype = 'Renewal w/Products & Education';
            else if(setType.contains('Product') && setType.contains('Services') && setType.contains('Support'))
                strtype = 'PNCV w/Services & Support';
            else if(setType.contains('Product') && setType.contains('Services') && setType.contains('Education'))
                strtype = 'PNCV w/Services & Education';
            else if(setType.contains('Product') && setType.contains('Support') && setType.contains('Education'))
                strtype = 'PNCV w/Education & Support';
            else if(setType.contains('Renewal') && setType.contains('Services') && setType.contains('Support'))
                strtype = 'Renewal w/Services & Support';
            else if(setType.contains('Renewal') && setType.contains('Services') && setType.contains('Education'))
                strtype = 'Renewal w/Services & Education';
            else if(setType.contains('Renewal') && setType.contains('Support') && setType.contains('Education'))
                strtype = 'Renewal w/Education & Support';
            else if(setType.contains('Services') && setType.contains('Support') && setType.contains('Education'))
                strtype = 'Services w/Education & Support';
    }
    else
    { 
   
             if(setType.contains('Product') && setType.contains('Services') && setType.contains('Support') && setType.contains('Education'))
                strtype = 'PNCV w/Services, Education & Support';
            else if(setType.contains('Renewal') && setType.contains('Services') && setType.contains('Support') && setType.contains('Education'))
                strtype = 'Renewal w/Services, Education & Support';
            else if(setType.contains('Renewal') && setType.contains('Services') && setType.contains('Product') && setType.contains('Education'))
                strtype = 'Renewal w/Products, Services & Education';
            else if(setType.contains('Renewal') && setType.contains('Support') && setType.contains('Product') && setType.contains('Education'))
                strtype = 'Renewal w/Products, Education & Support';
            else if(setType.contains('Renewal') && setType.contains('Support') && setType.contains('Product') && setType.contains('Services'))
                strtype = 'Renewal w/Products, Services & Support';
            else if(setType.contains('Product') && setType.contains('Renewal') && setType.contains('Services') && setType.contains('Support') && setType.contains('Education'))
                strtype = 'Renewal w/Products, Services, Education & Support';
    }
    return strType;      
}



}