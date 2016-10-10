/**
 * Class OpportunityHandler
 * Trigger Handler for the Opportunity SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class OpportunityHandler
    implements ITrigger
{   
    // Member variable to hold the Id's of Opportunitys 'in use'
    private static List<Account> lstUpdateSiteRequestforAccount = new List<Account>();
    private static List<FeedItem> posts = new List<FeedItem>(); 
    // Member variables
    private List<OpportunityLineItem> s_oli = new List<OpportunityLineItem>();
    public static List<Trial_Request__c> lst_req = new List<Trial_Request__c>();
    //used to control the block of code for Closed-Lost Notification
    private static boolean competitorNotification = false;
    private static boolean NotificationCheck = false;
        
    // Constructor
    public OpportunityHandler()
    {
        
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public static boolean isNewConvertedFromLead {get;set;} 
     //= (Trigger.isInsert &&  ((Opportunity) Trigger.new[0]).LeadSource  <> null);
    
    public void bulkBefore()
    {
        if(isNewConvertedFromLead == null)
            isNewConvertedFromLead= (Trigger.isInsert &&  ((Opportunity) Trigger.new[0]).LeadSource  <> null);
            
        if( !isNewConvertedFromLead)
            OpportunityGateway.loadOpportunityBulkValues();
    }
    
    
    public void bulkAfter()
    {
        if(isNewConvertedFromLead == null)
            isNewConvertedFromLead= (Trigger.isInsert &&  ((Opportunity) Trigger.new[0]).LeadSource  <> null);
            
        if(isNewConvertedFromLead)
            OpportunityGateway.loadOpportunityBulkValues();
    }
        
    public void beforeInsert(SObject so)
    {
        Opportunity opp = (Opportunity)so;
        if(opp.IsClosed) //bibu_DefaultCloseDate
            opp.CloseDate = Date.today();
        if(opp.CPM_Owner__c == null && opp.Business_Type__c!=null) //OppUpdateAggregateInfo        
               opp.CPM_Owner__c = opp.OwnerId;   
               
         if(opp.Volume_Account__c <> null && OpportunityGateway.m_volumeCustomers.keySet().contains(opp.volume_account__c))
         {
            copyVCValuesToOpp(OpportunityGateway.m_volumeCustomers.get(opp.volume_account__c), opp);
         }       
        
        //Update Dated Conversion Rates on Opp 
        for(DatedConversionRate cr: OpportunityGateway.conversionRates)
                {
                    if(opp.CloseDate >= cr.StartDate && opp.CloseDate<cr.NextStartDate && opp.CurrencyIsoCode==cr.IsoCode)
                    {
                        opp.USD_Exchange_Rate__c=cr.ConversionRate;
                        break;
                    }
                }
        
    }
    
    public void copyVCValuesToOpp(Volume_Customer__c vc, Opportunity opp)
    {
            opp.Aggregate_Account__c=vc.Account__c;
            //opp.Agg_Acct_Area__c=vc.Agg_Acct_Area__c;
            //opp.Agg_Acct_Region__c=vc.Agg_Acct_Region__c;
            //opp.Agg_Acct_Territory_Country__c=vc.Agg_Acct_Territory_Country__c;
    } 
    
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        Opportunity opp = (Opportunity)so;
        Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.id);
        if((opp.IsClosed && !oldOpp.IsClosed )&&((math.abs(opp.CloseDate.daysBetween(Date.today())) <= 14 )&& opp.CloseDate==oldOpp.CloseDate)) //bibu_DefaultCloseDate
            opp.CloseDate = Date.today();
            System.debug('Date.today().daysBetween(opp.CloseDate)'+Date.today().daysBetween(opp.CloseDate)+Date.today()+opp.CloseDate);
        if(opp.Volume_Account__c <> null && OpportunityGateway.m_volumeCustomers.keySet().contains(opp.volume_account__c))
         {
            copyVCValuesToOpp(OpportunityGateway.m_volumeCustomers.get(opp.volume_account__c), opp);
         }
         
        //ResetLeadToOpportunityFlag
        if(opp.Lead_to_Oppty__c)
        {
            Decimal timeDiffierence=CPMSIntegartionUtility.getDateTimeDiffInHours(DateTime.now(),opp.CreatedDate);
            if(timeDiffierence>.2)
            {
                opp.Lead_to_Oppty__c=false;
            }
        }
        
        //Update Conversion Rates
        if(opp.CloseDate<>oldOpp.CloseDate || opp.CurrencyIsoCode<>oldOpp.CurrencyIsoCode)
         {
            for(DatedConversionRate cr: OpportunityGateway.conversionRates)
                {
                    if(opp.CloseDate >= cr.StartDate && opp.CloseDate<cr.NextStartDate && opp.CurrencyIsoCode==cr.IsoCode)
                    {
                        opp.USD_Exchange_Rate__c=cr.ConversionRate;
                        break;
                    }
                }
         }
         
         
         
    }
    
    /**
     * beforeDelete
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {   
        //Cast the SObject to an Opportunity
        Opportunity opp = (Opportunity)so;
        
    }
    
    public void afterInsert(SObject so)
    {
        Opportunity opp = (Opportunity)so;
        if(OpportunityGateway.s_IdsForAccountUpdates.contains(opp.Id) &&  opp.AccountId <> null && OpportunityGateway.m_AccountUpdateSiteRequest.keySet().contains(opp.AccountId))
        {
            Account acc = OpportunityGateway.m_AccountUpdateSiteRequest.get(opp.AccountId);
            if((acc.GEO__c == 'LA'&& opp.probability >= 90) || acc.GEO__c <>  'LA')
            {
                if(!setAddedIds.contains(acc.id))    
                     lstUpdateSiteRequestforAccount.add(acc);
                setAddedIds.add(acc.id);     
            }        
        } 
        
       afterInsertandUpdate(null, opp);
        
    }
    
  private static  Set<id> setAddedIds = new Set<id>();
    
    
    public void afterUpdate(SObject oldSo, SObject so)
    {
        Opportunity opp = (Opportunity)so;
        Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.id);
        
        if(OpportunityGateway.s_IdsForAccountUpdates.contains(opp.Id) &&  opp.AccountId <> null && OpportunityGateway.m_AccountUpdateSiteRequest.keySet().contains(opp.AccountId))
            {
                Account acc = OpportunityGateway.m_AccountUpdateSiteRequest.get(opp.AccountId);
                if((acc.GEO__c == 'LA'&& opp.probability >= 90) || acc.GEO__c <>  'LA')
                  {  
                       if(!setAddedIds.contains(acc.id))     //To avoid dupes   
                            lstUpdateSiteRequestforAccount.add(acc);
                       setAddedIds.add(acc.id);
                  }
            }    
        
        if(opp.RPD_Status_Formula__c != oldOpp.RPD_Status_Formula__c)
            {
                posts = OpportunityGateway.addFeedToList(posts, opp.id, ' changed the RPD Status from ' +oldOpp.RPD_Status_Formula__c+ ' to ' +opp.RPD_Status_Formula__c+' .');
            }
                
       if(opp.Finance_Valuation_Status__c != oldOpp.Finance_Valuation_Status__c)
           {
                posts = OpportunityGateway.addFeedToList(posts, opp.id, ' changed the Finance Valuation Status from ' +oldOpp.Finance_Valuation_Status__c+ ' to ' +opp.Finance_Valuation_Status__c+'.');
           }
           
           
           
        System.debug('Near Competitor Notification');
        if((opp.competitor__c != oldOpp.competitor__c) && competitorNotification == false)
        {
            competitorNotification(opp);
            competitorNotification = true;
        }
        
       //System.debug('Old Opp SCBU:'+oldOpp.Driving_Sales_Coverage_Business_Unit__c );  
       //System.debug('Opp SCBU:'+opp.Driving_Sales_Coverage_Business_Unit__c );    
       //System.debug('Old Opp products:'+oldOpp.Total_Product_Line_Count__c);
       //System.debug('Opp products:'+opp.Total_Product_Line_Count__c);
       System.debug('Near Driving SCBU field');
       if((opp.Driving_Sales_Coverage_Business_Unit__c!=null && oldOpp.Driving_Sales_Coverage_Business_Unit__c == null) && NotificationCheck ==false )
       {
            competitorNotification(opp);
            NotificationCheck = true;
       }
           
           
        afterInsertandUpdate(oldOpp, opp);
            
    }
        
    public void afterInsertandUpdate(Opportunity oldOpp, Opportunity opp)
    {
        
        //LOGIC FOR ADDING THE USER IN REQUESTOR INFO TO THE OPP SALES TEAM - auai_SalesTeamForEA  trigger  
        if(opp.Requestor_Information__c <> null && (oldOpp == null || opp.Requestor_Information__c <> oldOpp.Requestor_Information__c) && (OpportunityGateway.m_entcommaccount.get(opp.Requestor_Information__c) <> null))
        {
             OpportunityGateway.addOppTeamMember(opp.Requestor_Information__c, opp.id, 'IND-Reseller');
        }
        
        if(opp.Ent_Comm_Account__c <> null && ( oldOpp == null || opp.Ent_Comm_Account__c <> oldOpp.Ent_Comm_Account__c ) && OpportunityGateway.m_entcommaccount.keySet().contains(opp.Ent_Comm_Account__c) )
        {
            OpportunityGateway.addOppTeamMember(OpportunityGateway.m_entcommaccount.get(opp.Ent_Comm_Account__c).ownerid, opp.id, 'IND-Reseller');
        }   
        
        //end 
        
        //sales team from TAQ - start
        System.debug('In Opportunity Handler - AccountId is:'+opp.AccountId);
     if(opp.AccountId != null && (oldOpp == null || oldOpp.AccountId == null) )                         
       {    
            OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.AccountId,'');
       }
     if(opp.Service_Provider_Client__c != null && (oldOpp == null || oldOpp.Service_Provider_Client__c == null) )                         
       {    
            OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Service_Provider_Client__c,'');
       }
    if(opp.Reseller__c != null && (oldOpp == null || oldOpp.Reseller__c == null))                      
       {
            
            OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Reseller__c,'TAQ-PARTN SOLPROV');
       } 
       if(opp.Partner_1__c != null && (oldOpp == null || oldOpp.Partner_1__c == null))                         
        {   OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Partner_1__c,'TAQ-PARTN ALLIANCE');
        }
        
       if(opp.Distributor_6__c != null && (oldOpp == null || oldOpp.Distributor_6__c == null))                         
        {   OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Distributor_6__c, 'TAQ-PARTN SOLPROV');
        } 
            
       if(opp.partner__c != null && (oldOpp == null || oldOpp.partner__c == null))                        
         {  OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Partner__c, 'TAQ-PARTN SERVPROV');
         }
         
       if(opp.Alliance_Partner_2__c !=null && ((oldOpp == null || oldOpp.Alliance_Partner_2__c == null)))
       {
           OpportunityGateway.addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Alliance_Partner_2__c , 'TAQ-PARTN ALLIANCE');
       }
       
       if(opp.OwnerId!=null && ((oldOpp == null || oldOpp.OwnerId == null)))
       {
          /* User currentUser=new user();
           for(user u:[Select Id,UserType,ContactId, IsPortalEnabled, AccountId , contact.Account.Solution_Provider_CAM_PMFKey__c,PMFKey__c From User WHERE Id = :opp.Ownerid LIMIT 1])
            currentUser = u;
           if(currentUser.id!=null){
           if(currentUser.UserType == 'PowerPartner' && currentUser.IsPortalEnabled)
           OpportunityGateway.addOppTeamMember(opp.Ownerid, opp.Id, 'Partner');
            else*/
           OpportunityGateway.addOppTeamMember(opp.Ownerid, opp.Id, 'Owner');
          // }
          
       }
       
        //sales team from TAQ - end
          
    }
    
    public void competitorNotification(Opportunity opp)
    {
        if((opp.competitor__c != 'No Competitor' && opp.Competitor__c!='Other' && opp.competitor__c !=null )
            &&(opp.Opportunity_Type__c!=null && opp.Opportunity_Type__c.contains('PNCV'))
            && opp.recordTypeId != Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Deal Registration').RecordTypeId
            && !(opp.Source__c =='Partner')
            && !(opp.Source__c == 'Deal Registration') 
            && !(opp.Source__c == 'Lead' && opp.Partner_Engagement__c == 'Incremental' )             
                )
                
                {
                    System.debug('Entered the logic for Competitor Notification');
                    List<Opportunity> opportunityList = new List<Opportunity>();
                    DateTime temp = opp.LastModifiedDate;
                    Date lastmodified = Date.newinstance(temp.year(), temp.month(),temp.day());
                    Date d = lastmodified.addMonths(-3);
                    System.debug('Last Modified date: '+lastmodified+'---'+d);
                    List<Opportunity> tempList = [select Name,CurrencyIsoCode,Owner.Name,Account.Name,Id,Segment__c,Rpt_Country__c,ReasonField__c,closedate,Competitor__c,Amount,Driving_Sales_Coverage_Business_Unit__c,Source__c,Pulldown__c,Type  
                                                  from Opportunity 
                                                  where closedate< :lastmodified and closedate > :d 
                                                  and Competitor__c =:opp.Competitor__c 
                                                  and Opportunity_Type__c like 'PNCV%'
                                                  and (Sales_Milestone_Search__c='100% - Contract Signed' or Sales_Milestone_Search__c='100% - Closed')
                                                  order by Amount Desc];
                                             
                    System.debug(tempList);                  
                    if(tempList != null && tempList.size() > 0){
                        for(Opportunity o:tempList)
                        {
                            if(opportunityList.size()<3)
                                if(o.Driving_Sales_Coverage_Business_Unit__c == opp.Driving_Sales_Coverage_Business_Unit__c && o.AccountId != opp.AccountId && o.Type!= '1 Tier' && o.Type!= '2 Tier' && o.Type!='ERWIN' && (o.Source__c == 'CA Internal' || o.Source__c == 'Lead') && o.Pulldown__c == FALSE)
                                    opportunityList.add(o);
                        }
                        System.debug('----Opp list: '+opportunityList);
                        if(opportunityList!=null && opportunityList.size() > 0){
                            System.debug('OpportunityList Contents:'+opportunityList);
                            sendEmail(opp,opportunityList);
                    }
                   }
                  }
        }
    
    public void sendEmail(Opportunity opp,List<Opportunity> opportunityList)
    {
    
    // Text email generation is commented and replaced with the email template below.
    /*
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        String message = 'Your Opportunity: '+opp.Name+'<br><br>Need some ideas to help you crush the competition?<br><br>Collaborate with the winning teams of these opportunities that share your competitor and learn about CA\'s competitive advantage!<br><br>';
        String hyperlink = '<a href = \'https://one.ca.com/solutions/Pages/Competitive_FY15.aspx\'>here</a>' ;
        message +='<ul>';
        for(Opportunity o : opportunityList)
        { 
             String closedate = String.valueOf(o.closedate);
             message += '<li>'+o.Name+' | '+o.Account.Name+' | '+o.Segment__c+' | '+closedate+' | '+o.CurrencyIsoCode+' '+o.Amount+' | '+o.ReasonField__c+' | '+o.Owner.Name+' | '+o.Territory.Name+'</li>';
        }
        message +='</ul>';
        message += 'Look for more information on your Competitors '+hyperlink+'!<br><br><br>';
        message += '<i>For Additional resources, search our <a href = \'https://one.ca.com/sales/Pages/default.aspx\'>Sales Site</a> and <a href =\'https://one.ca.com/sales/Compass Enablement/Navigate Sales - Enablement Library Overview.pdf\'>Enablement Library</a></i>.';                
        msg.sethtmlbody('<font size="2">'+message+'</font>');
        msg.setSubject('Getting Ahead of the Competition');
        msg.setTargetObjectId(opp.ownerId);
        msg.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
        */
        String message = '';
        List<Document> l = [select Id,Name from Document where Name = 'Header' or Name = 'Competitive Insight Image' or Name='PM Contacts Image' or Name='Sales Site Image'];
        System.debug(l);
        String baseurl = URL.getSalesforceBaseUrl().toExternalForm();
        Map<String,String> m = new Map<String,String>();
        for(integer i = 0; i< l.size();i++)
        {
            string url = baseurl+'/servlet/servlet.ImageServer?id='+l[i].Id+'&oid='+UserInfo.getOrganizationId();
            m.put(l[i].Name,url);
        }
        System.debug(m);
        String Opplink = baseurl+'/'+opp.id;
        String OpportunityName = '<a href="'+Opplink+'" style="color:#47BFDD; text-decoration:none"><i>'+opp.Name+'</i></a>';
        for(Opportunity o : opportunityList)
        { 
             String closedate = String.valueOf(o.closedate);
             message += '<tr><td align="center">'+o.Name+' </td><td align="center"> '+o.Account.Name+' </td><td align="center"> '+o.Segment__c+'</td><td align="center">'+closedate+' </td><td align="center"> '+o.CurrencyIsoCode+' '+o.Amount+' </td><td align="center"> '+o.ReasonField__c+' </td><td align="center"> '+o.Owner.Name+' </td><td align="center"> '+o.Rpt_Country__c+'</td></tr>';
        }
        message +='';
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.sethtmlbody('<html> <body style="margin: 0; padding: 0;"> <table cellpadding="10" cellspacing="10" width="100%" bgcolor="#C6C6C6"> <tr> <td> <table align="center" cellpadding="10" cellspacing="10" width="600" bgcolor="white"> <tr> <td> <img src="'+m.get('Header')+'" alt="Header"/> </td> </tr> <tr> <td style="margin-top: 5px;font-family:Calibri,Verdana;font-size:14;"> <br/> <p style="font-size:18;color:#47BFDD">Your Opportunity: '+OpportunityName+' </p> <p>Need some ideas to help you crush the competition?</p> <p>Collaborate with the winning teams of these opportunities that share your competitor and learn about CA\'s competitive advantage!</p> </td> </tr> <tr> <td> <br/> <table width = "100%" border="1" style="font-weight:bold;background-color:#47BFDD;font-family:Calibri,Verdana;border:2px solid black;border-bottom:.5px;border-collapse:collapse;font-size:18;"> <tr> <td rowspan="7" style="color:white;font-size:14">&nbsp;Top Wins Against Your Competitor</td> </tr> </table> <table width = "100%" border="1" style="border-collapse:collapse; font-family:Calibri,Verdana;border:1.5px;display: inline-block;font-size:12;color:#1A1A1A"> <tr style="background-color:#CAD4D4" align="center"> <th width="75px">Opp Name</th> <th width="75px">Account Name</th> <th width="75px">Segment</th> <th width="75px">Close Date</th> <th width="75px">Amount</th> <th width="75px">W/L Reason</th> <th width="75px">Opp Owner</th> <th width="75px">Territory</th> </tr> <!-- Data rows will be here-->'+message+' </table> <p style= "font-family:Calibri,Verdana;font-size:15;font-weight:bold;font-size:14;margin-top:25px;">Additional Resources:</p> </td> </tr> <tr> <td> <table cellpadding="0" cellspacing="0" width="100%" border="0; style="margin-top:30px;"> <tr> <td width="33%" style="float:left;font-size:14;position:relative;font-family:Calibri,Verdana;font-weight:bold" align="center"> <a href="https://one.ca.com/solutions/Pages/Competitive_FY15.aspx" style="color:#0066CC"> <img src="'+m.get('Competitive Insight Image')+'" align="center"/> <p>Competitive Insight</p> </a> </td> <td width="33%" style="float:left;position:relative;font-size:14;font-family:Calibri,Verdana;font-weight:bold" align="center"> <a href="https://one.ca.com/sales/Compass%20Enablement/Navigate%20Sales%20-%20Enablement%20Library%20Overview.pdf" style="color:#0066CC"> <img src="'+m.get('Sales Site Image')+'"/> <p>Sales Site</p> </a> </td> <td width="33%" style="float:left;position:relative;font-size:14;font-family:Calibri,Verdana;font-weight:bold" align="center"> <a href="https://one.ca.com/solutions/Documents/Product%20Marketing%20Org.pdf" style="color:#0066CC"> <img src="'+m.get('PM Contacts Image')+'"/> <p>PM Contacts</p> </a> </td> </tr> </table> </td> </tr> <tr> <td style="font-size:9;color:#808080;font-family:Calibri,Verdana;padding-top:35px;">Copyright &copy; 2015 CA. All rights reserved. <br/>CA Confidential and proprietary information for CA internal use only. <br/>No unauthorized copying or distribution permitted. <br/> </td> </tr> </table> </td> </tr> </table> </body></html>');
        msg.setSubject('Getting Ahead of the Competition');
        msg.setSaveAsActivity(false);
        msg.setTargetObjectId(opp.ownerId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }
    
    public void afterDelete(SObject so)
    {
        
    }
    
    /**
     * andFinally
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
    
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.IsUpdate))
        {
            //update the site request info
            if(lstUpdateSiteRequestforAccount.size() > 0 )
            {
                Database.update(lstUpdateSiteRequestforAccount, false);
                lstUpdateSiteRequestforAccount = new List<Account>();
            }
            if(posts.size() > 0)
            {    
                database.insert(posts, false);
                posts = new List<FeedItem>();
            
            }
            if(Trigger.IsUpdate)
            {
                /*
                 Boolean gotoTrialMethod = false;
                 for(SObject so : trigger.new)
                {
                    Opportunity opp = (Opportunity)so;                   
                    if(opp.tr__c != null && opp.tr__c != 0 )
                    gotoTrialMethod = true;
                }
                if(gotoTrialMethod )
                {
                    lst_req = OpportunityGateway.getUpdateTrials();//aiau_UpdateTrialRequests
                    if(lst_req <> null && lst_req.size() > 0)
                    {
                            Database.update(lst_req,false);
                    }
                }
               Boolean gotoRFPMethod = false;
                for(SObject so : trigger.new)
                {
                    Opportunity opp = (Opportunity)so;                   
                    if(opp.rfx__c != null && opp.rfx__c != 0 )
                    gotoRFPMethod = true;
                }
                if(gotoRFPMethod )
                {
                    List<RFP__c> lstRFP = OpportunityGateway.getUpdateRFPs(); //UpdateLineitems
                    if(lstRFP <> null && lstRFP.size() > 0 ) 
                    {
                        Database.update(lstRFP, false);
                           
                    } 
                } 
                 List<OpportunityLineItem> lstOLI = OpportunityGateway.getUpdatedOpportunityLineItems(); //UpdateLineitems
                if(lstOLI <> null && lstOLI.size() > 0)
                   { 
                    Database.update(lstOLI,false);
                   }
                   
                Boolean gotoSRMethod = false;
                for(SObject so : trigger.new)
                {
                    Opportunity opp = (Opportunity)so; 
                    if(opp.rfx__c != null && opp.sr__c != 0)
                    gotoSRMethod = true;
                }
                if(gotoSRMethod )
                { 
                    List<Services_Request__c> lstSR = OpportunityGateway.getUpdatedSRs(); //UpdateLineitems
                    if(lstSR <> null && lstSR.size() > 0)
                       { 
                        Database.update(lstSR,false);
                       }  
                } 
               */
                if(OpportunityGateway.lst_dealDesk.size() > 0) //OppUpdateDealDeskTrigger
                    {    Database.update(OpportunityGateway.lst_dealDesk,false);
                         OpportunityGateway.lst_dealDesk = new List<Deal_Desk_Review__c>();
                    }
                if(OpportunityGateway.lst_QuoteRequest.size() > 0) //OppUpdateDealDeskTrigger
                    {    Database.update(OpportunityGateway.lst_QuoteRequest,false);
                         OpportunityGateway.lst_QuoteRequest = new List<Quote_Request__c>();
                    }
            }
                 
             if(OpportunityGateway.lstOTM.size() > 0) //Common for All Opp Team additions
            {
                      
                     List<Database.upsertResult> uResults = Database.upsert(OpportunityGateway.lstOTM,false);                     
                     
                     for(Database.upsertResult result:uResults) {
                       
                       System.debug('is scucess:' + result.isSuccess()+ 'Is insert:'+ result.isCreated());
                       if(result.isSuccess()){
                       
                       System.debug('ID:*******'+result.getId());
                       }
                     }
                     OpportunityGateway.lstOTM = new List<OpportunityTeamMember>();
                      
            }
            
                       if(OpportunityGateway.lstOS.size() > 0) //Common for All Opp Team additions
            {       
                     
               System.debug('opp lstos:'+OpportunityGateway.lstOS);
                     List<Database.upsertResult> uResults = Database.upsert(OpportunityGateway.lstOS,false);
                     
                      for(Database.upsertResult result:uResults) {
                       
                       System.debug('is scucess lstOS:' + result.isSuccess()+ 'Is insert:'+ result.isCreated());
                       if(result.isSuccess()){                       
                           System.debug('ID:***lstOS****'+result.getId());
                       }                     
                     }
                    
                      OpportunityGateway.lstOS = new List<OpportunityShare>();
            }            

        
        }
    
    }
}