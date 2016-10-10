public class OpportunityLineItemGateway{
    public static Map<Id,Opportunity> opportunitiesToUpdate = new Map<Id,Opportunity>();
    public static Map<Id,PricebookEntry> pbeMap;
    public static Map<Id,Opportunity> oppMap;
    public static List<String> xmlStrings;
    public static decimal oppSalesPrice;
    public static Map<Id,List<String>> oppId_ProductGroup_Map = new Map<Id,List<String>>();
    public static Map<String,Decimal> isoCodeToConversionRate=new Map<String,Decimal>();
    
    
    public static void loadOpportunityLineItemBulkValues(){
        List<OpportunityLineItem> lstTrigger;
        Set<Id> priceBookEntryIdSet=new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,String> acpIdMap = new Map<Id,String>();
        Set<Id> oliDelOppIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> updateOppIds = new Set<Id>();
        List<OpportunityLineItem> bpOliList = new List<OpportunityLineItem>();
        if(trigger.isDelete)
            lstTrigger = Trigger.Old;
        else
            lstTrigger = Trigger.New;
        for(OpportunityLineItem oli: lstTrigger){
            system.debug('TestlstTrigger'+lstTrigger);
            system.debug('testOppId'+oli.opportunityId);
            OpportunityLineItem oldOli;
            if(Trigger.isUpdate)
                oldOli = (OpportunityLineItem)Trigger.OldMap.get(oli.id);
            
            priceBookEntryIdSet.add(oli.PricebookEntryId);
            
            system.debug('TestbeforeOppIds'+oppIds);
            oppIds.add(oli.opportunityId);
            system.debug('TestafterOppIds'+oppIds);
            
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isDelete)){
                if(oli.Business_Type__C == 'Renewal')
                    setOppIds.add(oli.OpportunityId);
            }
            
            //OppLIAttachDetachRenewals
            if(Trigger.isDelete && Trigger.isAfter){
                
                if(oli.Business_Type__C == 'Renewal'){
                    oliDelOppIds.add(oli.OpportunityId);
                    if(oli.Active_Contract_Product__c != null)
                        acpIdMap.put(oli.Active_Contract_Product__c,'Renewal');
                }
                else if(oli.Active_Contract_Product__c != null){
                    acpIdMap.put(oli.Active_Contract_Product__c,'Non Renewal');
                }
            }
            if(Trigger.isAfter && (Trigger.isInsert || (Trigger.isUpdate  && (oli.business_type__c != oldOli.business_type__c || oli.UnitPrice != oldOli.UnitPrice)) || Trigger.isDelete))
            {
                updateOppIds.add(oli.OpportunityId);
            }
            if(Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate  && oli.Product_Group__c != oldOli.Product_Group__c)))
            {
                bpOliList.add(oli);
                
            }
        }
        system.debug('---------------------'+pricebookentryidset);
        pbeMap = new Map<id,PricebookEntry>([Select id,name,Product2Id,Product2.Upfront_Revenue_Eligible__c,Product2.name,Product2.CSU2__c,Product2.Product_Group__c,Product2.Market_Focus_Area__c from PricebookEntry where id in :priceBookEntryIdSet]);//Product2.Market_Focus_Area__c  Added in Query for ILT for FY16 by YEDRA01
        system.debug('pbeMap---------------'+pbeMap);
        oppMap = new Map<id,Opportunity>([Select Id,Deal_Registration_Program__c,Deal_Registration_Program__r.Partner_Friendly_Name__c,Deal_Program__c,CurrencyIsoCode,AccountID,CloseDate,CreatedDate,Type,Account.GU_DUNS_NUMBER__c,Projected_renewal__C,Partner_Sales_Price__c,Sales_Coverage_Business_Unit__c,Deal_Registration_Status__c,Driving_Sales_Coverage_Business_Unit__c,Reseller_Product_Name__c,Reseller_Estimated_Value__c,RecordTypeId,Reseller__c,Partner__c,StageName
                                          ,MinMaxError__c,Deal_Registration_Program__r.Min_Deal_Value__c,Deal_Registration_Program__r.Max_Deal_Value__c,Deal_Registration_Program__r.CurrencyIsoCode,
                                          (select Business_Type__c, Active_Contract_Product__r.Dismantle_Date__c, Active_Contract_Product__r.Active_Contract__r.Contract_Term_Months__c, 
                                          Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c,Business_Unit__c,UnitPrice ,Partner_Sales_Price__c, 
                                          Id,PricebookEntry.product2Id, PricebookEntry.name, PricebookEntry.Product2.Upfront_Revenue_Eligible__c, PricebookEntry.Product2.Family, OpportunityId ,Deal_Program_Eligibility_Status__c
                                             
                                          from OpportunityLineItems) FROM Opportunity where id IN :oppIds]);
        system.debug('oppMap---------------'+oppMap);
        
        //Adding for 3186 -
        
            System.debug('$$$5 Entering 4');
            for(Opportunity o : oppMap.values()){
                if(opportunitiesToUpdate.containsKey(o.Id)){
                    Opportunity o1 = opportunitiesToUpdate.get(o.Id);
                    System.debug('o1:'+o1);
                    String o1_dealRegPgmName = o1.Deal_Registration_Program__r.Partner_Friendly_Name__c;
                    if(o.Deal_Program__c != o1_dealRegPgmName){
                        System.debug('$$$5 Adding opp o to map opportunitiesToUpdate');
                        opportunitiesToUpdate.put(o.id,o);
                    }
                }
            }
       
        
        
        //OppLIAttachDetachRenewals && OppLIUpdateOpportunityType
        if(Trigger.isDelete && Trigger.isAfter && acpIdMap.keySet().size()>0){
            Set<Id> acpIds = new Set<Id>();
            List<Active_Contract_Product__c> acpList = new List<Active_Contract_Product__c>();
            for(Id acpId : acpIdMap.keySet()){
                if(acpIdMap.get(acpId) == 'Renewal'){
                    acpList.add(new Active_Contract_Product__c(id=acpId,Opportunity_Product__c = null,Opportunity__c = null,Renewal_Contract_Product__c = null,Converted_to_Opportunity__c = false));
                    acpIds.add(acpId);
                }
                else
                    acpList.add(new Active_Contract_Product__c(id=acpId,Converted_to_Opportunity__c = false));
            }
            if(oliDelOppIds.size()>0 && acpIds.size()>0){
                List<CA_Product_Renewal__c> prodRenewalList = [Select id,name from CA_Product_Renewal__c where Active_Contract_Product__c IN :acpIds and Renewal_Opportunity__c IN :oliDelOppIds];
                if(prodRenewalList.size()>0) delete prodRenewalList;
            }
            update acpList;
        }        
        
        //OppLIUpdateOpportunityType
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isDelete)){
            for(Opportunity o : oppMap.values()){
                Set<String> setFamily = new Set<String>();
                Integer mfProdCount = 0;
                Integer upfrontProdCount = 0;
                Boolean isValidated=true;
                Decimal Original_Deal_Term_Months=0;
                Date Original_Expiration_Date;
                Opportunity opp;
                if(opportunitiesToUpdate.containsKey(o.Id))
                    opp = opportunitiesToUpdate.get(o.Id);
                else    
                    opp = o;
                if(SetOppIds.contains(opp.id))   
                    opp.rpd_status__c = 'Requested'; //Moved over from trigger 
                if(o.OpportunityLineItems.size()==0){
                    opp.Opportunity_Type__c = null;    
                    opportunitiesToUpdate.put(opp.id,opp);
                }
                else{
                    for(OpportunityLineItem oli:o.OpportunityLineItems){
                        //Associating a set of all product families tied to the Opportunity Products to the Opp - start
                        setFamily.add(((oli.PricebookEntry.Product2.Family == 'Renewal' || oli.PricebookEntry.Product2.Family == 'Time' || oli.PricebookEntry.Product2.Family == 'Mainframe Capacity' || oli.Business_Type__c == 'Renewal') ?'Renewal':oli.PricebookEntry.Product2.Family));
                        //Associating a set of all product families tied to the Opportunity Products to the Opp - end
                        //Upfront Start
                        if(oli.Business_Type__c== 'MF Capacity')  //Counter for MF Capacity Products
                            mfProdCount++;
                        if(oli.PricebookEntry.Product2.Upfront_Revenue_Eligible__c == 'Yes' && oli.Business_Type__c != 'Renewal' && oli.Business_Type__c != 'MF Capacity')  //Counter for Upfront Eligible Products
                            upfrontProdCount++; 
                        //Upfront End
                        //Renewals Start
                        if(SetOppIds.contains(oli.opportunityid)){   
                            if(Original_Expiration_Date == null ||  oli.Active_Contract_Product__r.Dismantle_Date__c < Original_Expiration_Date){   
                                Original_Expiration_Date = oli.Active_Contract_Product__r.Dismantle_Date__c;
                                Original_Deal_Term_Months = oli.Active_Contract_Product__r.Active_Contract__r.Contract_Term_Months__c; 
                            }           
                            if(oli.Active_Contract_Product__r.Active_Contract__r.Status_Formula__c != 'Validated')
                                 isValidated =  false;
                        }
                    }
                    opp.Opportunity_Type__c = calculateOpportunityType(setFamily);
                    if(SetOppIds.contains(opp.id)){   
                        opp.Original_Expiration_Date__c = Original_Expiration_Date;
                        opp.Original_Deal_Term_Months__c = Original_Deal_Term_Months;
                        opp.Finance_Valuation_Status__c = isValidated?'Validated':'Not Validated';
                    }
                    opportunitiesToUpdate.put(opp.id,opp);
                }    
            }
        }
        
        //NewLogoTrigger
        if(Trigger.isInsert && Trigger.isAfter){
            Map<Id,List<OpportunityLineItem>> oppOliMap = new Map<Id,List<OpportunityLineItem>>();
            for(OpportunityLineItem oli: lstTrigger){
            
            
            
            System.debug('Opportunity Created Today---------'+oppMap.get(oli.OpportunityId).createdDate+'============='+Date.today()+'---------'+oppMap.get(oli.OpportunityId).createdDate.date().isSameDay(Date.today()));                     System.debug('Opportunity Created Today---------'+oppMap.get(oli.OpportunityId).createdDate+'============='+Date.today()+'---------'+oppMap.get(oli.OpportunityId).createdDate.isSameDay(Date.today()));
                if(oppMap.get(oli.OpportunityId).createdDate.date().isSameDay(Date.today())){
               
                    if(!oppOliMap.containsKey(oli.OpportunityId)){
                        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                        oliList.add(oli);
                        oppOliMap.put(oli.OpportunityId,oliList);
                    }else{
                        List<OpportunityLineItem> oliList = oppOliMap.get(oli.OpportunityId);
                        oliList.add(oli);
                        oppOliMap.put(oli.OpportunityId,oliList);
                    }
                }
            }
            xmlStrings = new List<String>();
            for(Id oppId : oppOliMap.keySet()){
                Opportunity prepOpp = oppMap.get(oppId);
                String createdDate = ''+prepOpp.CreatedDate.date();
                String closedDate = ''+prepOpp.CloseDate;
                createdDate = createdDate.replace(' 00:00:00', '');            
                closedDate = closedDate.replace(' 00:00:00', '');            
                String xmlString = '<opportunity><id>'+prepOpp.Id+'</id><createDate>'+createdDate+'</createDate>';
                xmlString = xmlString + '<closeDate>'+closedDate+'</closeDate><opportunityProducts>';
                List<OpportunityLineItem> oliList = oppOliMap.get(oppId);
                for(OpportunityLineItem oli : oliList)
                    xmlString = xmlString + '<opportunityProduct><id>'+oli.id+'</id><gbu2>'+pbeMap.get(oli.PricebookEntryId).Product2.CSU2__c+'</gbu2></opportunityProduct>';
                xmlString = xmlString + '</opportunityProducts><accountId>';
                xmlString = xmlString + prepOpp.AccountId + '</accountId><globalParentId>';
                xmlString = xmlString + prepOpp.Account.GU_DUNS_NUMBER__c + '</globalParentId></opportunity>';
                xmlStrings.add(xmlString);
                System.debug('xmlString is ' + xmlString);
            }
        }
        
        //UniqueValue_BusinessUnit_Oppr
        if(Trigger.isAfter){
            if(updateOppIds.size()>0){
                List<Opportunity> oppList = new List<Opportunity>();
                for(Id oppId : updateOppIds){
                    oppList.add(getOpportunitytoUpdate(oppId));
                }
                UniqueBusinessUnit UBU = new UniqueBusinessUnit();
                List<Opportunity> oppsToUpdate = UBU.processOpprLineItems(oppList);
                for(Opportunity opp : oppsToUpdate){
                    opportunitiesToUpdate.put(opp.id,opp);
                }
            }
        }
        //BusinessPlanFocus
        if(Trigger.isBefore && !Trigger.isDelete){
            if(bpOliList.size()>0){
                Set<String> openOppStageNameSet = new Set<String>{'10% - Identification & Qualification','20% - Researching','40% - Plan Confirmed','60% - Initial Proposal','80% - Preliminary Agreement','90% - Agreement Finalized'};
                List<Opportunity> oppList = new List<Opportunity>();
                for(OpportunityLineItem oli : bpOliList){
                    
                    System.debug('test1------------'+pbeMap+'test2------------------'+oli.Pricebookentryid+'test3'+oli);
                    system.debug('TestoppMap'+oppMap);
                    if(openOppStageNameSet.contains((oppMap.get(oli.OpportunityId).StageName)))
                        oppList.add(oppMap.get(oli.OpportunityId));
                    if(pbeMap.size()>0){
                        if(!oppId_ProductGroup_Map.containsKey(oli.OpportunityId)){
                            oppId_ProductGroup_Map.put(oli.OpportunityId,new List<String>());
                            
                            oppId_ProductGroup_Map.get(oli.OpportunityId).add(pbeMap.get(oli.PriceBookEntryId).Product2.Product_Group__c);
                        }else{
                            oppId_ProductGroup_Map.get(oli.OpportunityId).add(pbeMap.get(oli.PriceBookEntryId).Product2.Product_Group__c);
                        }
                    }
                }
                if(oppList.size()>0){
                    processOpportunityLineItems(oppList,bpOliList);
                }
            }
        }
        //AddProdcutsToOpportunity
        if(Trigger.isAfter){
            system.debug('AddProdcutsToOpportunity');
            Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity; 
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            Id dealRegistrationRecordTypeId = rtMapByName.get('Deal Registration').getRecordTypeId();    
            for(Opportunity o : oppMap.values()){
                
                if(o.Deal_Registration_Status__c != 'Sale Approved'){
                    Double price = 0;
                    String pbeName = '';
                    Opportunity opp;
                    /*Commenting this for AR 3186 because opportunitiesToUpdate is not getting newly inserted oli
                      if(opportunitiesToUpdate.containsKey(o.Id))
                        opp = opportunitiesToUpdate.get(o.Id);
                    else   */
                        opp = o;
                    if(opp.OpportunityLineItems.size()>0){
                        for(OpportunityLineItem oli : opp.OpportunityLineItems){
                            if(oli.UnitPrice != null && oli.Deal_Program_Eligibility_Status__c=='Eligible')
                                price = price + oli.UnitPrice;
                            if(oli.PricebookEntry.Name != null && oli.Deal_Program_Eligibility_Status__c=='Eligible'){
                                if(pbeName == '')
                                    pbeName = oli.PricebookEntry.Name; 
                                else
                                    pbeName = pbeName + ', ' + oli.PricebookEntry.Name; 
                            }   
                        }
                    }
                    if(Trigger.isUpdate){
                        if(opp.Reseller_Estimated_Value__c != price)
                            opp.Reseller_Estimated_Value__c = price;
                        if(opp.Reseller_Product_Name__c != pbeName)
                            opp.Reseller_Product_Name__c = pbeName;
                    }
                    else{
                        opp.Reseller_Estimated_Value__c = price;
                        opp.Reseller_Product_Name__c = pbeName;
                    }
                    
                    //comparison - iso code
                    for(CurrencyType ct : [SELECT IsoCode, ConversionRate FROM CurrencyType]){
                      isoCodeToConversionRate.put(ct.IsoCode, ct.ConversionRate);
                    }
                    oppSalesPrice = opp.Reseller_Estimated_Value__c;
                     if(opp.Deal_Registration_Program__c != null && opp.CurrencyIsoCode!= opp.Deal_Registration_Program__r.CurrencyIsoCode )
                     {
                       oppSalesPrice = opp.Reseller_Estimated_Value__c*isoCodeToConversionRate.get(opp.Deal_Registration_Program__r.CurrencyIsoCode);
                     }
                    if(opp.Deal_Registration_Program__c != null && oppSalesPrice>=opp.Deal_Registration_Program__r.Min_Deal_Value__c && oppSalesPrice<=opp.Deal_Registration_Program__r.Max_Deal_Value__c)
                    { 
                         opp.MinMaxError__c = false; 
                         }
                    else
                    {
                      
                      opp.MinMaxError__c = true;
                    }
                    system.debug('Testvaluesss------------------>'+opportunitiesToUpdate);
                    opportunitiesToUpdate.put(opp.id,opp);
                }
            }
        }
    }
    
    public static Opportunity getOpportunitytoUpdate(Id oppId){
        Opportunity opp;
        if(opportunitiesToUpdate.containsKey(oppId))
            opp = opportunitiesToUpdate.get(oppId);
        else    
            opp = oppMap.get(oppId);
        return opp;    
    }
    
    public static string calculateOpportunityType(set<string> setType)
    {
    system.debug('TestsetType:'+setType);

        if(setType == null || setType.size() == 0) //Empty StrType if no family -type associated
            return '';
        string strtype = '';
                system.debug('Teststrtype:'+strtype);
        if(setType.size() == 1)
        { 
            system.debug('TestsetType1:'+setType);
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
                                system.debug('TestFinalstrtype:'+strtype);
        }
        else if(setType.size() == 2)
        {
                system.debug('TestsetType2:'+setType);

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
                        system.debug('Teststrtype2:'+strtype);
        }
       else if(setType.size() == 3)
       { 
                system.debug('TestsetType3:'+setType);       

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
                        system.debug('Teststrtype3:'+strtype);
        }
        else
        { 
                system.debug('TestsetType4:'+setType);   

                if(setType.contains('Product') && setType.contains('Services') && setType.contains('Support') && setType.contains('Education') && !setType.contains('Renewal'))
                    strtype = 'PNCV w/Services, Education & Support';
                else if(setType.contains('Renewal') && setType.contains('Services') && setType.contains('Support') && setType.contains('Education') && !setType.contains('Product'))
                    strtype = 'Renewal w/Services, Education & Support';
                else if(setType.contains('Renewal') && setType.contains('Services') && setType.contains('Product') && setType.contains('Education') && !setType.contains('Support'))
                    strtype = 'Renewal w/Products, Services & Education';
                else if(setType.contains('Renewal') && setType.contains('Support') && setType.contains('Product') && setType.contains('Education')&& !setType.contains('Services'))
                    strtype = 'Renewal w/Products, Education & Support';
                else if(setType.contains('Renewal') && setType.contains('Support') && setType.contains('Product') && setType.contains('Services')&& !setType.contains('Education'))
                    strtype = 'Renewal w/Products, Services & Support';
                else if(setType.contains('Product') && setType.contains('Renewal') && setType.contains('Services') && setType.contains('Support') && setType.contains('Education'))
                    strtype = 'Renewal w/Products, Services, Education & Support';
                system.debug('Teststrtype4:'+strtype);    
        }
        return strType;      
    }
    
    public static void processOpportunityLineItems(List<Opportunity> oppList,List<OpportunityLineItem> oliList){
        //List<opportunity> oppList = [select Id,Type,Reseller__c,AccountId,Partner__c from opportunity where Id IN: OppIds AND StageName IN: OpenOppStageNameSet];
        //Set<Id> Account_Id_Set = new Set<Id>();
        Map<Id,String> AccountId_RTM_Map = new Map<Id,String>();
        Map<Id,List<Opportunity>> AccountId_OppList_Map = new Map<Id,List<Opportunity>>();
        
        
        if(oppList != null && oppList.size()>0){
            System.debug('+++++oppList++++++'+oppList);
            for(Opportunity opp:oppList){
                if((opp.Type == '1 Tier' || opp.Type == '2 Tier') && opp.Reseller__c != null){
                    //Account_Id_Set.add(opp.Reseller__c);
                    AccountId_RTM_Map.put(opp.Reseller__c,'Solution Provider');
                    if(!AccountId_OppList_Map.containskey(opp.Reseller__c)){
                        AccountId_OppList_Map.put(opp.Reseller__c,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.Reseller__c).add(opp);
                    }else{
                        AccountId_OppList_Map.put(opp.Reseller__c,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.Reseller__c).add(opp);
                    }
                        
                }
                if(opp.Type == 'xSP' && opp.AccountId != null){
                    //Account_Id_Set.add(opp.AccountId);
                    AccountId_RTM_Map.put(opp.AccountId,'Service Provider');
                    if(!AccountId_OppList_Map.containskey(opp.AccountId)){
                        AccountId_OppList_Map.put(opp.AccountId,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.AccountId).add(opp);
                    }else{
                        AccountId_OppList_Map.put(opp.AccountId,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.AccountId).add(opp);
                    }
                }
                if(opp.Type == 'Direct' && opp.Partner__c != null){
                    //Account_Id_Set.add(opp.Partner__c);
                    AccountId_RTM_Map.put(opp.Partner__c,'Service Provider');
                    if(!AccountId_OppList_Map.containskey(opp.Partner__c)){
                        AccountId_OppList_Map.put(opp.Partner__c,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.Partner__c).add(opp);
                    }else{
                        AccountId_OppList_Map.put(opp.Partner__c,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.Partner__c).add(opp);
                    }
                }
                if(opp.Type == 'ERWIN' && opp.Reseller__c != null){
                    //Account_Id_Set.add(opp.Reseller__c);
                    AccountId_RTM_Map.put(opp.Reseller__c,'Data Management');
                    if(!AccountId_OppList_Map.containskey(opp.Reseller__c)){
                        AccountId_OppList_Map.put(opp.Reseller__c,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.Reseller__c).add(opp);
                    }else{
                        AccountId_OppList_Map.put(opp.Reseller__c,new List<Opportunity>());
                        AccountId_OppList_Map.get(opp.Reseller__c).add(opp);
                    }
                }
                
            }
            
            
            System.debug('+++++AccountId_OppList_Map++++++'+AccountId_OppList_Map);
            List<Route_To_Market__c> RTMList = [select Id,Account__c,RTM__c from Route_To_Market__c where RTM__c IN: AccountId_RTM_Map.values() AND Account__c IN: AccountId_RTM_Map.keySet()];
            System.debug('+++++RTMList++++++'+RTMList);
            Set<Id> RTMIdSet = new Set<Id>();
            if(RTMList != null && RTMList.size()>0){
                for(Route_To_Market__c rtm:RTMList){
                    if(AccountId_RTM_Map.get(rtm.Account__c)==rtm.RTM__c){
                        RTMIdSet.add(rtm.Id);
                    }
                }
            }
            
            System.debug('+++++RTMIdSet++++++'+RTMIdSet);
            Map<Id,Map<String,boolean>> OppId_ProductGroup_BPF_Map = new Map<Id,Map<String,boolean>>();
            List<Product_Alignment__c> productAlignmentList = [select Id,Business_Plan__c,Related_Account__c,Product_Group__c from Product_Alignment__c where Route_To_Market__c IN: RTMIdSet];
            System.debug('+++++productAlignmentList++++++'+productAlignmentList);
            if(productAlignmentList != null && productAlignmentList.size()>0){
                for(Product_Alignment__c PA:productAlignmentList){
                    System.debug('+++++PA++++++'+PA);
                    if(AccountId_OppList_Map.containsKey(PA.Related_Account__c)){
                        System.debug('+++++111++++++');
                        for(Opportunity op:AccountId_OppList_Map.get(PA.Related_Account__c)){
                            System.debug('+++++op.Id++++++'+op.Id);
                            if(oppId_ProductGroup_Map.containsKey(op.Id)){
                                System.debug('+++++222++++++');
                                for(String prodGroup:oppId_ProductGroup_Map.get(op.Id)){
                                    System.debug('+++++prodGroup++++++'+prodGroup);
                                    System.debug('+++++PA.Business_Plan__c++++++'+PA.Business_Plan__c);
                                    System.debug('++++++++PA.Product_Group__c+++++++'+PA.Product_Group__c);
                                    if(prodGroup.equalsIgnoreCase(PA.Product_Group__c) && PA.Business_Plan__c){
                                        System.debug('+++++333++++++');
                                        if(!OppId_ProductGroup_BPF_Map.containsKey(op.Id)){
                                            OppId_ProductGroup_BPF_Map.put(op.Id,new Map<String,boolean>());
                                            OppId_ProductGroup_BPF_Map.get(op.Id).put(prodGroup,PA.Business_Plan__c);
                                            System.debug('+++++JJJ++++++'+OppId_ProductGroup_BPF_Map);
                                        }else{                                        
                                            OppId_ProductGroup_BPF_Map.get(op.Id).put(prodGroup,PA.Business_Plan__c);
                                            System.debug('+++++KKK++++++'+OppId_ProductGroup_BPF_Map);
                                        }                                
                                    }
                                }
                            }
                        }                
                    }
                }
            }
            
            System.debug('+++++OppId_ProductGroup_BPF_Map++++++'+OppId_ProductGroup_BPF_Map);
            if(oliList != null && oliList.size()>0){
                for(OpportunityLineItem oli:oliList){
                    if(OppId_ProductGroup_BPF_Map.containsKey(oli.OpportunityId)){
                        System.debug('+++++444++++++');
                        if(OppId_ProductGroup_BPF_Map.get(oli.OpportunityId).containsKey(pbeMap.get(oli.PriceBookEntryId).Product2.Product_Group__c)){
                            System.debug('+++++555++++++');
                            oli.Business_Plan_Focus__c = OppId_ProductGroup_BPF_Map.get(oli.OpportunityId).get(pbeMap.get(oli.PriceBookEntryId).Product2.Product_Group__c);
                        }else
                            oli.Business_Plan_Focus__c = false;
                    }else{
                        oli.Business_Plan_Focus__c = false;
                    }
                }
           }
        
          
        }
         
    }
}