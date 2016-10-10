trigger Update_OpportunityOnLeadConversion_Trigger on Lead (after update) {

        if(SystemIdUtility.isLeadUpdate1 != true)
        {
            List<Lead> leadList = new List<Lead>();
            List<String> lstLead = new List<String>();
            List<Opportunity> oppsList = new List<Opportunity>();
            set<String> convertedOppIds = new set<String>();
            // instantiate the AutoLeadConversion utility class 
            
           
            boolean condition1;
            boolean condition2;
            boolean condition3;  
            boolean condition_old;
            integer i=0;        
            // create the leads list
            for(Lead ld:Trigger.New) {
                system.debug('ld record='+ld);
                condition1 = ld.IsConverted;
                system.debug('condition1='+condition1);
                system.debug('ld.isconverted='+ld.isconverted);
                
                condition2 = (ld.ConvertedOpportunityId != null) ? true:false;
                system.debug('ld.ConvertedOpportunityId='+ld.ConvertedOpportunityId);
                condition3 = SystemIdUtility.IsIndirectLeadRecordType(ld.recordTypeId)||SystemIdUtility.IsDeal_RegistrationRecordType(ld.recordTypeId);
                condition_old = (trigger.old[i].isconverted  != true) ;
          
                System.debug(logginglevel.Debug,'Printing lead details : '+ld.IsConverted+','+ld.Name+','+ld.ConvertedOpportunityId);
                
                // if all the above conditions pass, then add the lead to the list and update its converted opps.  
                if(condition1 && condition2 && condition3 && condition_old)
                {
                    convertedOppIds.add(ld.ConvertedOpportunityId);
                    leadList.add(ld);
                    lstLead.add(ld.Id);
                    
                } 
                i++;              
            }
            if(convertedOppIds.size()>0)  
            {                
                //Moved the logic to future method to minimize queries                
                FutureProcessor.UpdateOpportunity_OnLeadConversion(lstLead,convertedOppIds);
                SystemIdUtility.isLeadUpdate1 = true;
            }   
        
        }
         
}
// Trigger to update opportunity on Auto lead conversion
// This trigger would use a maximum of 5 SOQL calls, 3 DML statements.
/*trigger Update_OpportunityOnLeadConversion_Trigger on Lead (after update) {

    List<Lead> leadList = new List<Lead>();
    List<Opportunity> oppsList = new List<Opportunity>();
    set<Id> convertedOppIds = new set<Id>();
    // instantiate the AutoLeadConversion utility class 
    AutoLeadConversion alConversion = new AutoLeadConversion(); 
    boolean condition1;
    boolean condition2;
    boolean condition3; 
    boolean old_condition; //Added so that it executes only first time after conversion 
    integer index=0;         
    // create the leads list
    for(Lead ld:Trigger.New) {
        condition1 = ld.IsConverted;
        condition2 = (ld.ConvertedOpportunityId != null) ? true:false;
        condition3 = SystemIdUtility.IsIndirectLeadRecordType(ld.recordTypeId);
           if(Trigger.isUpdate)
            old_condition = ld.isconverted &&  (trigger.old[index].isconverted == false);
        else
            old_condition = true;
        System.debug(logginglevel.Debug,'Printing lead details : '+ld.IsConverted+','+ld.Name+','+ld.ConvertedOpportunityId);
        
        // if all the above conditions pass, then add the lead to the list and update its converted opps.  
        if(condition1 && condition2 && condition3 && old_condition)
        {
            convertedOppIds.add(ld.ConvertedOpportunityId);
            leadList.add(ld);
        }  
        index++;             
    }
    if(convertedOppIds.size()>0)
    {
        //SOQL #1,#2 : retrieve the list of opportunities and the associated account details
        //Two Opportunity fields are added Pricebook2Id ,CurrencyIsoCode---- these are required for OpportunityLineItem generation  Req#537, IDC Pune Balasaheb Wani
        oppsList = [Select Id,AccountId,Account_Contact__c,Account.Aggregate_Account__c,Account.Account_Status__c,RecordTypeId,StageName,Reseller_Contact__c,Ent_Comm_Account__c,Volume_Account__c,Pricebook2Id ,CurrencyIsoCode 
                    from Opportunity 
                    where Id in :convertedOppIds];
        System.debug(logginglevel.Debug,'0 : The oppList is :'+oppsList);
        
        // update the opp List with Volume Account, Commercial Account & Account Contact details
        oppsList = alConversion.updateAccountDetails(oppsList,leadList);
    
        for(integer i = 0;i < leadList.size();i++) 
        {
            for(integer j = 0;j<oppsList.size();j++) 
            {
                if(oppsList.get(j).Id == leadList.get(i).ConvertedOpportunityId)
                {
                    // update the opp. record type, Deal type
                    if(leadList.get(i).BU__c != null)
                    {
                        if(leadList.get(i).BU__c.equalsIgnoreCase('RMDM'))
                        {                   
                            oppsList.get(j).RecordTypeId = SystemIdUtility.getIndirectRMDMRecordTypeId();
                            oppsList.get(j).Deal_Type__c=SystemIdUtility.getRmdmDealType(); 
                        }
                        else if(leadList.get(i).BU__c.equalsIgnoreCase('ISBU'))
                        {
                            oppsList.get(j).RecordTypeId = SystemIdUtility.getIndirectISBURecordTypeId();
                            oppsList.get(j).Deal_Type__c=SystemIdUtility.getIsbuDealType(); 
                        }
                        else if(leadList.get(i).BU__c.equalsIgnoreCase('Value'))
                        {
                            oppsList.get(j).RecordTypeId = SystemIdUtility.getIndirectVALUERecordTypeId();
                            oppsList.get(j).Deal_Type__c=SystemIdUtility.getValueDealType();
                        }
                    }

                    // update the opp. Milestone
                    if(leadList.get(i).BU__c == 'RMDM' || leadList.get(i).BU__c == 'ISBU')
                        oppsList.get(j).StageName = SystemIdUtility.getVolOppMilestone();
                    else if(leadList.get(i).BU__c == 'Value')
                        oppsList.get(j).StageName = SystemIdUtility.getValueOppMilestone();
                
                    // update the opp. Account
                    oppsList.get(j).AccountId = leadList.get(i).Reseller__c;
                     
                     // map the ISOCurrencyCode    
                     if(leadList.get(i).CurrencyIsoCode != null) 
                        oppsList.get(j).CurrencyIsoCode = leadList.get(i).CurrencyIsoCode;      
                    
                    // map the Reseller_Estimated_Value__c on the lead to opp. amount and opp. reseller est. amount
                    if(leadList.get(i).Reseller_Estimated_Value__c != null)
                    {
                        oppsList.get(j).Amount = leadList.get(i).Reseller_Estimated_Value__c;
                        oppsList.get(j).Reseller_Estimated_Value__c = leadList.get(i).Reseller_Estimated_Value__c;
                    }
                    
                    // map the reseller close date to opp. close date & opp. reseller close date
                    if(leadList.get(i).Reseller_Close_Date__c != null && leadList.get(i).Reseller_Close_Date__c > Date.today())
                    {
                        oppsList.get(j).CloseDate = leadList.get(i).Reseller_Close_Date__c;                 
                        oppsList.get(j).Reseller_Close_Date__c = leadList.get(i).Reseller_Close_Date__c;                    
                    }
                    // update the opportunity success flag
                    oppsList.get(j).Auto_Lead_Conversion_Status__c = 'Success';                

                    //Related to CR:13865765
                    //update the opportunity's Lead id field (added by Afzal on 9th June 2009)
                    //BEGIN
                    oppsList.get(j).Lead_ID__c = leadList.get(i).Id;
                    //END 

                    break;  
                }
            }
        }
    
        System.debug(logginglevel.Debug,'3 : The oppList is :'+oppsList);
    
        // upsert all the opportunity records
        try
        {    
            //setting the opt_allOrNoneparameter to false because even if 1 record update fails, 
            //the remainder of the DML operation need to succeed
            Database.SaveResult[] oppUpdateResult = Database.update(oppsList,false); 
            for(Database.SaveResult res:oppUpdateResult)
            {
                if(res.IsSuccess()==false)
                {
                    System.debug(logginglevel.Debug,'Failed to Update Opportunity: '+res.errors[0].Message);
                }
            }
        }
        catch(DmlException dmlEx) {
            System.debug(logginglevel.Debug,'DmlException is : '+dmlEx);
            // catch any DML exception during the upsert call   
        }    
        // process the oppUpdateResult here ....
        
        //Req 537 copying Lead Product information to Opportunity Line Item Information
        //Accenture IDC Balasaheb Wani 24 Aug,2010
        //Functionality Description It will extract data from Lead Product fields and Create corresponding Opportunity Line Item entries after Lead Conversion
        //Price Book Used is CA Product List
        //Total # of SOQL 2
        //Total # of DML 1
        //***************Starts ********
        //System.debug('--------Lead LIST -----' + leadList);
        //System.debug('--------OPPORTUNITY LIST ---' +oppsList);
        //System.debug('--------OPPORTUNITY LIST ---SIZE ' +oppsList.size() + '-----------LEAD SIZE-------' + leadList.size());
        List<OpportunityLineItem> lstOplineItems=new List<OpportunityLineItem>();
        String strCAPriceBookId=[Select p.Name, p.IsActive, p.Id From Pricebook2 p where p.Name ='CA Product List' limit 1].Id;
        for(integer i = 0;i < leadList.size();i++) 
        {
            for(integer j = 0;j<oppsList.size();j++) 
            {
                if(oppsList.get(j).Id == leadList.get(i).ConvertedOpportunityId)
                {
                   //System.Debug('-----------INSIDE INNER LOOOP -------------');
                   //System.Debug('-------------Products STRING-----------'+leadList.get(i).Product__c);
                   //Check for Product string , If product String is Null
                   // Then Skip OPL creation
                    if(leadList.get(i).Product__c != null )
                    {
                        String arrProdsLines=leadList.get(i).Product__c;
                        // Extract Products ID from Product string and Put them into Set , It will used for querying Pricbook entry 
                        // 1 SOQL 
                        set<Id> prdIds = new set<Id>();
                        for(string strPrdIdPair : arrProdsLines.split('='))
                        {
                            prdIds.add(strPrdIdPair.split(':')[0]);
                        }
                     //  System.Debug('Set off products Id---------------------' + prdIds);
                     // System.debug('Opporunity fields--------------Price Book===='+oppsList.get(j).Pricebook2Id+'=====CURRENCY CODE======'+oppsList.get(j).CurrencyIsoCode);
                       string strPriceBookId='';
                       //If PriceBook Entry in Opportunity is Blank , Then use 'CA Product List' as price book 
                       if(oppsList.get(j).Pricebook2Id== null)
                       {
                          //strPriceBookId=[Select p.Name, p.IsActive, p.Id From Pricebook2 p where p.Name ='CA Product List' limit 1].Id;
                          strPriceBookId=strCAPriceBookId;
                       }
                        // Adding pricebooks and Respective ProductId in Map 
                        Map<Id,PricebookEntry> mapPbe=new Map<Id,PricebookEntry>();
                        for(PricebookEntry pbe :[Select p.Id,p.Product2Id, p.Pricebook2Id, p.Name From PricebookEntry p where p.Product2Id in : prdIds and p.Pricebook2Id=: strPriceBookId  and p.CurrencyIsoCode=:oppsList.get(j).CurrencyIsoCode and p.IsActive = true])
                            {
                                mapPbe.put(pbe.Product2Id,pbe);
                            }
                     //   System.debug('Map of Price Book Entries------------------' + mapPbe);
                        // mapPbe Contains products Id and Corresponding PriceBookEntries
                        //Opporunity Line Item for each Products Id 
                        for(string strPrdIdPair : arrProdsLines.split('='))
                        {
                            if(mapPbe.containsKey(strPrdIdPair.split(':')[0]))
                            {
                       //       System.Debug('----------Inside OPL BLOCK---------------------');
                                OpportunityLineItem objOpl=new OpportunityLineItem();
                                objOpl.OpportunityId=oppsList.get(j).Id;
                                objOpl.PricebookEntryId=mapPbe.get(strPrdIdPair.split(':')[0]).Id;
                                objOpl.UnitPrice=decimal.valueOf(strPrdIdPair.split(':')[1]);       
                                lstOplineItems.add(objOpl);
                            }
                        }
                    }
                }
            }
        }
        //System.debug('List off Opportunity Line Items----------------To Insert -----'+lstOplineItems);
        //Adding to Database
        //If Op Line Item List contains some data , pushed to database
        if(lstOplineItems.size() > 0)
        {
            try
            {    
                    Database.SaveResult[] oppLineItemtResult =Database.insert(lstOplineItems); 
                for(Database.SaveResult res:oppLineItemtResult)
                {
                    if(res.IsSuccess()==false)
                    {
                        System.debug(logginglevel.Debug,'Failed to Update Opportunity Line Items: '+res.errors[0].Message);
                    }
                }
            }
            catch(DmlException dmlEx)
            {
                System.debug(logginglevel.Debug,'DmlException is : '+dmlEx);
                // catch any DML exception during the upsert call   
            }
        }   
         //**********Req 537Ends here *******
    }            
}*/