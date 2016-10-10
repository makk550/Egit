//Updates the fields on Opportuninty Line Items
//Updates the status field on Service request to closed when the opportunity is closed - SFDC 7.2
trigger UpdateLineitems on Opportunity (after update) 
{
    try{

    RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('New Opportunity');
    Id oppRecId = rec.RecordType_Id__c;
      
    RecordTypes_Setting__c rec2 = RecordTypes_Setting__c.getValues('Acquisition');
    Id oppRecId2 = rec2.RecordType_Id__c;
    
    Map<Id,Opportunity> map_opp = new Map<Id,Opportunity>();
    String strFamily = '';
    //Added for SFDC 7.2 Service Request - Saba 2/22/2011
    Set<Id> closedOpps = new Set<Id>(); 

    //Added For RFP - Start
     Set<id> setOppsWon = new Set<id>();
     Set<id> setOppsClosed = new Set<id>();
     for(Opportunity Opp: Trigger.New)
            {
                if(Opp.RecordTypeId == oppRecId)//Only For New Opp
                    {    
                    if(Opp.StageName <> Trigger.Oldmap.get(Opp.id).StageName && Opp.StageName == 'Closed - Lost')
                        setOppsClosed.add(opp.id);    
                    else if(Opp.StageName <> Trigger.Oldmap.get(Opp.id).StageName && Opp.StageName == '100% - Contract Signed')
                        setOppsWon.add(opp.id);
                    }    
            }
            
           if(setOppsClosed.size() > 0 || setOppsWon.size() > 0)
           {
              List<RFP__c> lstRFP = [Select id, Opp_Status__c, Opportunity__c From RFP__c where Opportunity__c in : setOppsClosed or Opportunity__c in: setOppsWon ];
              if(lstRFP.size() > 0)
              {
              
                      for(RFP__C rfp: lstRFP)
                      {
                          if(setOppsClosed.contains(rfp.Opportunity__c))
                              rfp.Opp_Status__c = 'Lost';
                          else
                              rfp.Opp_Status__c = 'Won';
                      } 
                  update lstRFP;
              }  
           }
            
    //Added For RFP - Edd

    if(oppRecId != null || oppRecId2 != null)
    {
        for(Integer i=0;i<Trigger.new.size();i++)
        {
            //check if the opportunity record type is the new one
            if(Trigger.new[i].RecordTypeId == oppRecId || Trigger.new[i].RecordTypeId ==  oppRecId2)
            {
                //check if either the close date or the stagename is changed, Only then proceed
                //COMMENT BY MOHAMMAD AFZAL, CR:189381545, 06/02/2010
                //if((Trigger.new[i].IsClosed || Trigger.new[i].CloseDate != Trigger.old[i].CloseDate) || (Trigger.new[i].StageName != Trigger.old[i].StageName) || (Trigger.new[i].Inside_Outside__c != Trigger.old[i].Inside_Outside__c))
                    map_opp.put(Trigger.new[i].Id,Trigger.new[i]);
                  
                  //Added for SFDC 7.2 Service Request - Saba 2/22/2011  
                  if(trigger.new[i].probability <> trigger.old[i].probability && (trigger.new[i].Probability ==0 || trigger.new[i].Probability == 100 ))
                    {
                        closedOpps.add(trigger.new[i].id); 
                    }
            }
        }
        
        //Added for SFDC 7.2 Service Request - Saba 2/22/2011  
        if(closedOpps.size() > 0)
        {
            List<Services_Request__c> lstSR = new List<Services_Request__c>();
            lstSR = [Select Services_Request_Status__c from Services_Request__c where    Oppty_Name__c in : closedOpps];    
            for(Services_Request__c sr:lstSR)
                sr.Services_Request_Status__c = 'Closed';
            
            update lstSR; 
        }
        
        system.debug('map_opp --> ' + map_opp.size());
        if(map_opp.size()>0)
        {
            //fetch the opportunity line items
            List<OpportunityLineItem> lst_oppli = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lst_groupBy = new List<OpportunityLineItem>();
            lst_oppli = [select Opportunity.Opportunity_Type__c,OpportunityId,Id,PricebookEntry.Product2Id,PricebookEntry.Product2.Family from OpportunityLineItem where OpportunityId in:map_opp.keySet()  order by OpportunityId , PricebookEntry.Product2.Family];
            //lst_groupBy = [select OpportunityId,count(*) from OpportunityLineItem where OpportunityId in:map_opp.keySet() group by OpportunityId]
             system.debug('lst_oppli --> ' + lst_oppli.size());
            String strOppType = '';
            Map<Id,Integer> map_StartIndex = new Map<Id,Integer>();
            Map<Id,Integer> map_EndIndex = new Map<Id,Integer>();
            if(lst_oppli.size()>0)
            {
                  Id prevOpp;
                  String  prevFamily;
                  Integer startIndex;
                  Integer endIndex;
                  prevOpp =  lst_oppli[0].OpportunityId;
                  prevFamily =  lst_oppli[0].PricebookEntry.Product2.Family;
                  startIndex  = 0;
                for(Integer j=0;j<lst_oppli.size();j++)
                {                                    
                    if(prevOpp == lst_oppli[j].OpportunityId)
                    {
                      endIndex = j; 
                      map_StartIndex.put(prevOpp,startIndex);
                      map_endIndex.put(prevOpp,endIndex);
                    }
                    else
                    {
                      map_StartIndex.put(prevOpp,startIndex);
                      map_endIndex.put(prevOpp,endIndex);
                      startIndex = j;
                      prevOpp = lst_oppli[j].OpportunityId;
                      endIndex = j;
                    }                    
                     //system.debug ('Map ------> ' + map_Index) ;
                }    
                  
                List<OpportunityLineItem> updlineitems = new List<OpportunityLineItem>();
                for(Integer k=0;k<lst_oppli.size();k++)
                {                                         
                    strOppType = lst_oppli[k].Opportunity.Opportunity_Type__c + '';
                    strFamily = lst_oppli[k].PricebookEntry.Product2.Family;
                    //update the closedate and sales milestone on the lineitem, only if they belong to products or renewals famitlies.
                    if(strFamily == 'Support' || strFamily == 'Education' || strFamily == 'Product' || strFamily == 'Time' || strFamily == 'Mainframe Capacity' || strFamily == 'Renewal' || strFamily == 'Services')
                    {
                        Opportunity op = map_opp.get(lst_oppli[k].OpportunityId);
                        //lst_oppli[k].Close_Date__c = op.CloseDate;
                        
                        //ADDED BY AFZAL FOR CR # 189408280
                        if(strFamily != 'Education' &&  strFamily != 'Services') //Exclude Offering excepting Support
                        {
                            //lst_oppli[k].Sales_Milestone__c = op.StageName;   //commented by vasantha for the CR: 191010340
                            //lst_oppli[k].Probability__c = op.Probability;
                        }//ADDED BY AFZAL FOR CR:189365666, 06/03/2010
                        else if(strOppType.startsWith('Services') || strOppType.startsWith('Standalone') || 
                            strOppType.startsWith('Education') || strOppType.startsWith('Support')){
                            //lst_oppli[k].Sales_Milestone__c = op.StageName;      //commented by vasantha for the CR: 191010340
                            //lst_oppli[k].Probability__c = op.Probability;
                        }
                        //System.debug(op.ForecastCategory);
                        //lst_oppli[k].Forecast_Category__c = op.ForecastCategory;
                        
                        //UPDATING FORECAST CATEGORY
                        //ADDED BY AFZAL FOR CR # 189381545 
                        /*if(lst_oppli[k].Probability__c!=null){ 
                            if(lst_oppli[k].Probability__c ==0) //SFDC 7.1- requirement # 974 change by saba
                                lst_oppli[k].Forecast_Category__c = 'Omitted';
                            else if(lst_oppli[k].Probability__c<=60) //SFDC 7.1- requirement # 974 change by saba
                                lst_oppli[k].Forecast_Category__c = 'Pipeline';
                            else if(lst_oppli[k].Probability__c ==80)  //SFDC 7.1- requirement # 974 change by saba
                                lst_oppli[k].Forecast_Category__c = 'Best Case';
                            else if(lst_oppli[k].Probability__c==90)
                                lst_oppli[k].Forecast_Category__c = 'Commit';
                            else if(lst_oppli[k].Probability__c==100)
                                lst_oppli[k].Forecast_Category__c = 'Closed';
                            else
                                lst_oppli[k].Forecast_Category__c = 'Closed';
                        }*/
                                                        
                        //System.debug(lst_oppli[k].Forecast_Category__c);
                        //had to add this manually since for 90% the values was not getting set correctly .... 
                        //Opp was showing value as 'Forecast' in trigger ... and on UI showing 'Commit'

                        //COMMENTED BY AFZAL, FOR CR # 189381545 
                        //if(lst_oppli[k].Probability__c == 90)
                            //lst_oppli[k].Forecast_Category__c = 'Commit';
                            
                        if(op.StageName == '100% - Contract Signed')
                        {
                            //lst_oppli[k].Won_line_item__c = true;
                            //lst_oppli[k].Closed_line_item__c = false;
                        }
                        else if(op.StageName == 'Closed - Lost')
                        {
                            //lst_oppli[k].Won_line_item__c = false;
                            //lst_oppli[k].Closed_line_item__c = true;
                            //lst_oppli[k].Sales_Milestone__c = op.StageName;
                            //lst_oppli[k].Probability__c = op.Probability;
                        }
                        else
                        {
                            //lst_oppli[k].Won_line_item__c = false;
                            //lst_oppli[k].Closed_line_item__c = false;
                        }

                          String st ;
                          //st = map_Index.get(lst_oppli[k].OpportunityId);
                          //Integer startIndex;
                          //Integer endIndex;

                                                                             
                            /*
                            if(lst_oppli[map_StartIndex.get(lst_oppli[k].OpportunityId)].PricebookEntry.Product2.Family  == lst_oppli[map_endIndex.get(lst_oppli[k].OpportunityId)].PricebookEntry.Product2.Family)
                            {
                                 system.debug('if strFamily --> ' + strFamily);
                                 system.debug('if op.CloseDate--> ' + op.CloseDate);
                                 //lst_oppli[k].Close_Date__c = op.CloseDate;
                                 //lst_oppli[k].Inside_Outside__c = op.Inside_Outside__c;
                                 //lst_oppli[k].Sales_Milestone__c = op.StageName;
                            }
                            else if(strFamily == 'Product' || strFamily == 'Mainframe Capacity')
                            {
                               system.debug('else strFamily --> ' + strFamily);
                               system.debug('else op.CloseDate--> ' + op.CloseDate);
                              //lst_oppli[k].Close_Date__c = op.CloseDate;
                              //lst_oppli[k].Inside_Outside__c = op.Inside_Outside__c;
                              //lst_oppli[k].Sales_Milestone__c = op.StageName;
                            }
                             */
                        //COMMENTED BY AFZAL, FOR CR # 189408280 
//                        if(strFamily!= 'Services')
//                        {
//                        }

                        //UPDATING FISCAL PERIOD
                        //ADDED BY AFZAL FOR CR # 189379562 
                        /*if(lst_oppli[k].Close_Date__c!=null){
                            Integer yr = lst_oppli[k].Close_Date__c.year();
                            String fiscalperiod = '';
                            if((lst_oppli[k].Close_Date__c).month() >= 1 && (lst_oppli[k].Close_Date__c).month() <= 3)
                                fiscalperiod = 'Q4-'+ yr;
                            else if((lst_oppli[k].Close_Date__c).month() >= 4 && (lst_oppli[k].Close_Date__c).month() <= 6)
                                fiscalperiod = 'Q1-'+ (yr+1);
                            else if((lst_oppli[k].Close_Date__c).month() >= 7 && (lst_oppli[k].Close_Date__c).month() <= 9)
                                fiscalperiod = 'Q2-'+ (yr+1);
                            else if((lst_oppli[k].Close_Date__c).month() >= 10 && (lst_oppli[k].Close_Date__c).month() <= 12)
                                fiscalperiod = 'Q3-'+ (yr+1);
                            
                            lst_oppli[k].Fiscal_Period_lineitem__c = fiscalperiod;
                        }
                        //
                         * */
                        
                        updlineitems.add(lst_oppli[k]);
                    } 
                    
                }
                System.debug(updlineitems);
                if(updlineitems.size()>0) 
                    update updlineitems;
                
            }   
        }
    }
    }catch(Exception ex){
        System.debug(ex.getMessage());
    }
}