trigger SterlingQuoteProcessor on scpq__SciQuote__c (before update) 
{ 
    System.debug('++++++++++++In trigger..APAC+++++++++++++++');

    if(SystemIdUtility.skipSterlingQuoteProcessor)
        return;
    Set<Id> quoteIdsToProcess = new Set<Id>();
    Set<Id> approvedQuotes = new Set<Id>(); // This set will hold the IDs of newly approved quotes
    List<Quote_Approval_History__c> qahRecords = new List<Quote_Approval_History__c>();
    Map<Id,Set<Id>> ApproverIdsMap = new Map<Id,Set<Id>>();
    //This map holds the IDs of quotes which has to be auto-approved 
    Map<Id,boolean> AutoApprovalMap = new Map<Id,boolean>();
    //This map holds the IDs of quotes as keys and CPQ Quote Creator Ids as values 
    Map<Id,Id> SQIdAndCPQQuoteCreatorIdMap = new Map<Id,Id>();
    Map<String,Id> CPQQuoteCreatorNameAndSQIdMap = new Map<String,Id>();
    
    Static Integer MAX_APPROVERS_SIZE = 10;
    List<TAP_Rules__c> tapRulesList = new List<TAP_Rules__c>
                                    ([SELECT Id, Name, Discount_From__c, 
                                        Discount_To__c, 
                                        Solution_Sales_Leader__c, 
                                         Net_Term__c, 
                                         License_Type__c, 
                                        Is_Auto_Approved__c, 
                                        TermFrom__c, 
                                        Deal_Size__c, 
                                        Medium_Touch_Acqusition_Indirect_Medi__c, 
                                        Quote_Base_Criteria__c, 
                                        Deal_Desk_Director_as_Approvers__c, 
                                        Include_Deal_Desk_Director_as_Approvers__c,
                                        Term_To__c, 
                                        Deal_Value_per_Annum_From__c, 
                                        Deal_Value_per_Annum_To__c, 
                                        Realization_From__c, 
                                        Realization_To__c, Region__c, Commissionable_Area__c, 
                                        Opp_Owner_s_Manager__c,
                                        Education_Discount_Threshold__c,Services_Discount_Threshold__c,
                                        Deal_Desk_Approver_SaaS__c,
                                        Bus_Transaction_Type__c,//Added As part of Education QQ
                                        Is_Legal_Approval__c,
                                        Is_SR_DD_Approval__c,
                                        Is_VP_CPM_Approval__c,
                                        Net_Term_Sr_DD_Approval__c,
                                        Royalty_Product__c,
                                        Source__c,
                                        (select Id, Name, Approver__c, Type__c 
                                            from TAP_Approvers__r)
                                      FROM TAP_Rules__c ]);
                                      
         List<TAP_Approvers__c> DealDeskApprovers = [Select Id, Name,  Segment__c,
                                 Region__c, Approver__c, Area__c, Territory__c, Sub_Territory__c,//Added for Education QQ 
                                 Type__c, TAP_Rules__c FROM TAP_Approvers__c ];
                                                  
                   
                   
                   
                   
                                                

    Set<Id> SQIdSet = new Set<Id>();
    Set<Id> ProcessInstanceIdSet = new Set<Id>();
    for(scpq__SciQuote__c sQuote : Trigger.new)
    {
        System.debug('+++D+++ ' + sQuote.CA_Total_Total_Disc_Off_List__c); 
        if(sQuote.CA_Approval_Id__c!=null && (sQuote.CA_Approval_Id__c).length()==18){
            ProcessInstanceIdSet.add(sQuote.CA_Approval_Id__c);
            SQIdSet.add(sQuote.Id);
        }    
        if(trigger.newMap.get(sQuote.Id).Created_User_Email__c != null){
            CPQQuoteCreatorNameAndSQIdMap.put(trigger.newMap.get(sQuote.Id).Created_User_Email__c,sQuote.Id);
        }
    } 
    
    List<User> usersList = [select Id,UserName from user where UserName IN: CPQQuoteCreatorNameAndSQIdMap.keySet()];
    for(User u:userslist){
        if(CPQQuoteCreatorNameAndSQIdMap.containsKey(u.UserName)){
        //----Use this map to assign User Id to CPQ Quote Creator lookup field------------
            SQIdAndCPQQuoteCreatorIdMap.put(CPQQuoteCreatorNameAndSQIdMap.get(u.UserName),u.Id);
        }        
    }   
    
    Map<Id,String> SQIdAndCommentsMap = new Map<Id,String>();
   
    //----CODE TO POPULATE APPROVAL COMMENTS--------------------
    try{
        List<ProcessInstance> PIList;
        System.debug('+++++++++SQIdSet++++++++++'+SQIdSet);
        System.debug('+++++++++ProcessInstanceIdSet++++++++++'+ProcessInstanceIdSet);
        if(ProcessInstanceIdSet != null && SQIdSet != null && ProcessInstanceIdSet.size()>0 && SQIdSet.size()>0){
            PIList = [SELECT Id,TargetObjectId, (SELECT Id, StepStatus, Comments FROM Steps where Comments!=null) FROM ProcessInstance where ID IN: ProcessInstanceIdSet AND TargetObjectId IN: SQIdSet ORDER BY CreatedDate DESC];
        }
        
        System.debug('+++++++++++PIList++++++++++++'+PIList);
        if(PIList!=null && PIList.size()>0){
            for(ProcessInstance p:PIList){
                System.debug('+++++++p.Steps++++++'+p.Steps);
                for(ProcessInstanceStep s:p.Steps){
                    if(!SQIdAndCommentsMap.containsKey(p.TargetObjectId)){
                        SQIdAndCommentsMap.put(p.TargetObjectId,s.comments);
                    }else{
                        if(SQIdAndCommentsMap.get(p.TargetObjectId)!=null){
                            SQIdAndCommentsMap.put(p.TargetObjectId,SQIdAndCommentsMap.get(p.TargetObjectId)+';'+s.comments);
                        }
                    }
                }
                System.debug('+++++++SQIdAndCommentsMap++++++'+SQIdAndCommentsMap);
            }
        }
    }catch(Exception e){
    } 
    
    
    
      
    
    
    for(scpq__SciQuote__c sQuote : Trigger.new)
    {
      
        System.debug('+++ status: ' + trigger.oldMap.get(sQuote.Id).CA_CPQ_QUOTE_STATUS__C + '-----> ' + sQuote.CA_CPQ_QUOTE_STATUS__C);
        System.debug('+++ OutboundStatus: ' + trigger.oldMap.get(sQuote.Id).Oubound_Status__c + '-----> ' + sQuote.Oubound_Status__c);
        
        if(SQIdAndCommentsMap.containsKey(sQuote.Id) && SQIdAndCommentsMap.get(sQuote.Id)!=null){
                sQuote.Approval_Comments__c = SQIdAndCommentsMap.get(sQuote.Id);
        }
        
        if(sQuote.CA_CPQ_QUOTE_STATUS__C == 'Request Approval' && trigger.oldMap.get(sQuote.Id).CA_CPQ_QUOTE_STATUS__C == 'Draft'){
system.debug('TestQuoterID:'+sQuote.Id);
            quoteIdsToProcess.add(sQuote.Id);
            if(SQIdAndCPQQuoteCreatorIdMap.containsKey(sQuote.Id))
                    sQuote.CPQ_Quote_Creator_Id__c = SQIdAndCPQQuoteCreatorIdMap.get(sQuote.id);
        }            
        else if(sQuote.CA_CPQ_QUOTE_STATUS__C == 'Approved' && trigger.oldMap.get(sQuote.Id).CA_CPQ_QUOTE_STATUS__C != 'Approved')
        {   
            
            
            approvedQuotes.add(sQuote.Id);
            qahRecords.add(autoCreateDDR.createQuoteApprovalHistory(sQuote));
        }
        else if(sQuote.CA_CPQ_QUOTE_STATUS__C == 'Draft' && trigger.oldMap.get(sQuote.Id).CA_CPQ_QUOTE_STATUS__C == 'Request Approval')
        {
            System.debug('+++++ In Request Approval to Draft Method +++++++++');
            sQuote.CA_CPQ_Quote_Status__c = 'Request Approval';
        }
        else if(sQuote.CA_CPQ_QUOTE_STATUS__C == 'Draft' && trigger.oldMap.get(sQuote.Id).CA_CPQ_QUOTE_STATUS__C != 'Draft')
        {
            ApprovalByPass.updateRecallStatus(sQuote.Id);
        
            //quotesToUpdate.add(new scpq__SciQuote__c(Id=sQuote.Id, Auto_Approved__c=false));
            sQuote.Auto_Approved__c = false;
            
            //----Clearing all the approvers when status equals DRAFT-----
            sQuote.CA_Approval_Id__c = NULL;
            sQuote.Approver1__c = null;
            sQuote.Approver2__c = null;
            sQuote.Approver3__c = null;
            sQuote.Approver4__c = null;
            sQuote.Approver5__c = null;
            sQuote.Approver6__c = null;
            sQuote.Approver7__c = null;
            sQuote.Approver8__c = null;
            sQuote.Approver9__c = null;
            sQuote.Approver10__c = null;
            
            sQuote.Oubound_Status__c  = null;    
            
            sQuote.Has_Pending_Approvers__c = false;   
            sQuote.Pending_Approver1__c = null;
            sQuote.Pending_Approver2__c = null;
            sQuote.Pending_Approver3__c = null;
            sQuote.Pending_Approver4__c = null;
            sQuote.Pending_Approver5__c = null;
            sQuote.Pending_Approver6__c = null;
            sQuote.Pending_Approver7__c = null;
            sQuote.Pending_Approver8__c = null;
            sQuote.Pending_Approver9__c = null;
            sQuote.Pending_Approver10__c = null;
            
            
        }
    }
    
    
    
    
    Map<Id, scpq__SciQuote__c> idToQuoteMap = new Map<Id, scpq__SciQuote__c>
                                    ([SELECT Id,
                                             CA_Payment_Schedule__c,
                                             scpq__OpportunityId__r.Account.Segment__c,
                                             scpq__OpportunityId__r.Rpt_Area__c,
                                             scpq__OpportunityId__r.CloseDate,
                                             scpq__OpportunityId__r.StageName,
                                             scpq__OpportunityId__r.OwnerId,
                                             //scpq__OpportunityId__r.Ent_Comm_AccountId__c,
                                             scpq__OpportunityId__r.AccountId,
                                             scpq__OpportunityId__r.Opportunity_Number__c,
                                             scpq__OpportunityId__r.Amount,
                                             scpq__OpportunityId__r.CurrencyIsoCode,
                                             scpq__OpportunityId__r.Rpt_Territory_Country__c,
                                             scpq__OpportunityId__r.Type,
                                             scpq__OpportunityId__r.Rpt_Country__c,
                                             scpq__OpportunityId__r.Rpt_Region__c,
                                             scpq__OpportunityId__r.Source__c,
                                             scpq__OpportunityId__r.Deal_Approval_Status__c,
                                             (select Id,
                                                 Business_Unit__c, 
                                                 Bus_Transaction_Type__c,
                                                 CA_Pricing_Group__c,
                                                 License_Type__c,
                                                 Quick_Quote__c,
                                                 AutoCalc_Stated_Renewal__c,        
                                                 Auth_Use_Model__c,
                                                 Total_Discount_off_Volume_GSA_Price__c,
                                                 Total_Disc_off_List__c,
                                                 Royalty_Product__c,//Added for Education QQ project
                                                 Payment_Method__c,
                                                 Delivery_Method__c,  
                                                 Product_Material__r.Name,
                                                 Stated_Renewal_Fee__c,
                                                 Total_Quantity__c
                                              FROM Quote_Products_Reporting__r),
                                             (select CA_Total_Total_Disc_Off_List__c,
                                                 CA_Total_Total_Disc_Off_Vol_GSA_Price__c,
                                                 CA_Effective_Date__c,
                                                 CA_Contract_End_Date__c,
                                                 Approval_Date__c,
                                                 CA_Total_List_License_Subs_Fee__c,
                                                 CA_Total_List_Maintenance_Price__c
                                              FROM Quote_Approval_Histories__r)
                                      FROM scpq__SciQuote__c 
                                      WHERE Id IN :quoteIdsToProcess]);
                                      
    //List<scpq__SciQuote__c> quotesToUpdate = new List<scpq__SciQuote__c>();
    //List<Approval.Processsubmitrequest> submitRequests = new List<Approval.Processsubmitrequest>();
    System.debug('+++++++idToQuoteMap+++++++'+idToQuoteMap.values());
    for(scpq__SciQuote__c q : idToQuoteMap.values())
    {
        boolean autoApproveQuote = false;
        if(!q.Quote_Approval_Histories__r.isEmpty())
            autoApproveQuote = AutoCreateDDR.quoteShouldBeAutoApproved(Trigger.newMap.get(q.Id), q.Quote_Approval_Histories__r[0]);
            
        if(autoApproveQuote == true)
        {

            
            // Add the quote to the list of quotes which will have a Quote_Approval_History record generated
            qahRecords.add(autoCreateDDR.createQuoteApprovalHistory(Trigger.newMap.get(q.Id)));
            
            // Add the ID of the quote to the list of newly approved quotes.
            // All quotes in this list will have there old history purged. 
            approvedQuotes.add(q.Id);
            

            
            scpq__SciQuote__c sQuote = Trigger.newMap.get(q.ID);
            sQuote.Auto_Approved__c = true;
            sQuote.Oubound_Status__c = 'Approved';
            sQuote.Last_Updated_from_SFDC__c = true;
            //qahRecords.add(autoCreateDDR.createQuoteApprovalHistory(sQuote));
            
            /*
            Approval.Processsubmitrequest sReq = new Approval.Processsubmitrequest();
            sReq.setObjectId(q.Id);
            sReq.setComments('System Auto Approval: Submit');
            submitRequests.add(sReq);
            */
            quoteIdsToProcess.remove(q.Id);
            
        }
    }
    
    // This will need to be optimized
    Map<String, Decimal> isoCodeToConversionRate = new Map<String, Decimal>();
    for(CurrencyType ct : [SELECT IsoCode, ConversionRate FROM CurrencyType])
        isoCodeToConversionRate.put(ct.IsoCode, ct.ConversionRate);
    
    DDR_Rules__c ddrRules = [SELECT New_Product_Using_Quick_Contract_Rule__c,
                                    New_Product_Account_Segment_Rule__c, New_Product_Account_Segment__c,
                                    New_Product_CPQ_Quote_Type_Rule__c, New_Product_CPQ_Quote_Type__c,
                                    New_Product_LA_Quote_Total_Rule__c, New_Product_Max_Quote_Total_For_LA__c,
                                    New_Product_EMEA_Quote_Total_Rule__c, New_Product_Max_Quote_Total_For_EMEA__c,
                                    New_Product_NA_Quote_Total_Rule__c, New_Product_Max_Quote_Total_For_NA__c,
                                    New_Product_Pricing_Group_Term_Rule__c, New_Product_Pricing_Group__c, New_Product_Pricing_Group_Term__c,
                                    New_Product_Term_Rule__c, New_Product_Maximum_Contract_Term__c,
                                    New_Product_Net_Payment_Term_Rule__c, New_Product_Net_Payment_Terms__c,
                                    New_Product_Payment_Schedule_Rule__c, New_Product_Payment_Schedule__c,
                                    New_Product_LT_Combo_Rule_1__c, New_Product_LT1_for_LT_Combo_1__c, New_Product_LT2_for_LT_Combo_1__c, New_Product_BTT_for_LT_Combo_1__c,
                                    New_Product_LT_Combo_Rule_2__c, New_Product_LT1_for_LT_Combo_2__c, New_Product_LT2_for_LT_Combo_2__c, New_Product_BTT_for_LT_Combo_2__c,
                                    New_Product_LT_Combo_Rule_3__c, New_Product_LT1_for_LT_Combo_3__c, New_Product_LT2_for_LT_Combo_3__c, New_Product_BTT_for_LT_Combo_3__c,
                                    New_Product_BTT_for_LT_Combo_4__c,New_Product_LT1_for_LT_Combo_4__c,New_Product_LT2_for_LT_Combo_4__c,New_Product_LT_Combo_Rule_4__c,
                                    New_Product_PS_and_LT_Rule__c, New_Product_PS_for_PS_and_LT__c, New_Product_LT_for_PS_and_LT__c, New_Product_BTT_for_PS_and_LT__c,
                                    New_Product_PS_and_LT_2_Rule__c, New_Product_PS_for_PS_and_LT_2__c, New_Product_LT_for_PS_and_LT_2__c, New_Product_BTT_for_PS_and_LT_2__c,
                                    New_Product_Quick_Quote_Line_Item_Rule__c,
                                    New_Product_Auto_Calc_State_Renewal_Rule__c, New_Product_ACSR_LT_Exceptions__c, New_Product_ACSR_BTT_Exceptions__c,
                                    New_Product_Auth_Use_Model_Rule__c, New_Product_Auth_Use_Model__c,
                                    Renewal_Using_Quick_Contract_Rule__c,
                                    Renewal_LA_Quote_Total_Annum_Rule__c, Renewal_Max_Quote_Total_Annum_For_LA__c,
                                    Renewal_EMEA_Quote_Total_Annum_Rule__c, Renewal_Max_Quote_Total_Annum_For_EMEA__c,
                                    Renewal_NA_Quote_Total_Annum_Rule__c, Renewal_Max_Quote_Total_Annum_For_NA__c,
                                    Renewal_Term_Rule__c, Renewal_Maximum_Contract_Term__c,
                                    Renewal_Net_Payment_Term_Rule__c, Renewal_Net_Payment_Terms__c,
                                    Renewal_Business_Transaction_Type_Rule__c, Renewal_Business_Transaction_Type__c,
                                    Renewal2_Using_Quick_Contract_Rule__c,
                                    Renewal2_LA_Quote_Total_Annum_Rule__c, Renewal2_Max_Quote_Total_Annum_For_LA__c,
                                    Renewal2_EMEA_Quote_Total_Annum_Rule__c, Renewal2_Max_Quote_Total_Annum_For_EMEA__c,
                                    Renewal2_NA_Quote_Total_Annum_Rule__c, Renewal2_Max_Quote_Total_Annum_For_NA__c,
                                    Renewal2_Term_Rule__c, Renewal2_Maximum_Contract_Term__c,
                                    Renewal2_Net_Payment_Term_Rule__c, Renewal2_Net_Payment_Terms__c,
                                    Renewal2_Business_Transaction_Type_Rule__c, Renewal2_Business_Transaction_Type__c,
                                    Renewal3_Using_Quick_Contract_Rule__c,
                                    Renewal3_Business_Transaction_Type_Rule__c, Renewal3_Business_Transaction_Type__c,
                                    Renewal3_Net_Payment_Term_Rule__c, Renewal3_Net_Payment_Terms__c,
                                    Renewal4_Using_Quick_Contract_Rule__c,
                                    Renewal_Term_GT_36_Rule__c,//Added for Education QQ  
                                    Renewal_Term_GT_36__c,                                  
                                    Renewal_QuoteTotal_Annum_GT300K_NA_Rule__c,
                                    Renewal_Quote_Total_Annum_GT_300K_NA__c,
                                    New_Product_CA_Education_Combo_Rule__c,
                                    New_Product_CAEducation_With_PM_Rule__c,
                                    New_Product_CAEducation_PMethod_With_PM__c,
                                    CA_Education_Public_Sector_Rule__c,
                                    CA_Education_Pricing_Group__c,
                                    CA_Education_Bus_Trans_Type__c,
                                    Renewal4_Business_Transaction_Type__c,
                                    NON_CA_Education_Bus_Trans_Types__c,
                                    Renewal_APJ_Quote_Total_Annum_Rule__c, //Added for APAC
                                    Renewal2_APJ_Quote_Total_Annum_Rule__c,
                                    Renewal_Max_Quote_Total_Annum_For_APJ__c,
                                    Renewal2_Max_Quote_Total_Annum_For_APJ__c,
                                    New_Product_Morethan_1_SKUs__c,New_Product_Quote_Term__c,
                                    New_Product_Quote_Term2__c,New_Product_Quote_Type__c,
                                    New_Product_Stated_Renewal_Fee__c,New_Product_Stated_Renewal_Fee_Input__c,
                                    New_Product_Term_Input1__c,New_Product_Term_Input2__c,
                                    New_Product_Net_Term_Input__c,New_Product_Net_Payment_Term__c,
                                    New_Product_Number_of_Users__c,New_Product_UserCount_Input__c,
                                    New_Product_Payment_Schedule_Input_1__c,New_Product_Payment_Schedule_Input_2__c,
                                    New_Product_Payment_Schedule_Input_3__c,New_Product_License_Type_Input_1__c,
                                    New_Product_License_Type_Input_2__c,New_Product_License_Type_Input_3__c,
                                    New_Product_Payment_Schedule_1__c,New_Product_Payment_Schedule_2__c,
                                    New_Product_Payment_Schedule_3__c ,
                                    Renewal3_NA_Qcuote_Total_Annum_Rule__c ,
                                    Renewal3_Max_Quote_Total_Annum_For_NA__c ,
                                    Renewal3_EMEA_Rule__c ,
                                    Renewal3_LA_Rule__c ,
                                    Renewal3_APJ_Rule__c ,
                                    Renewal3_Term_Rule__c ,
                                    Renewal3_Maximum_Contract_Term__c ,
                                    Renewal4_Term_Rule__c ,
                                    Renewal4_Maximum_Contract_Term__c,
                                    New_Product_IndirectAdvantageSKUs__c                          
                             FROM DDR_Rules__c 
                             LIMIT 1];
    
    List<String> namesOfDDRsToUpdate = new List<String>();
    List<Deal_Desk_Review__c> ddrBucket = new List<Deal_Desk_Review__c>();
    Set<Id> ApproverIds;
    for(Id sQuoteId : quoteIdsToProcess)
    {
        scpq__SciQuote__c sQuote = Trigger.newMap.get(sQuoteId);
        
        boolean DDRisRequired = AutoCreateDDR.quoteRequiresDDR(sQuote, idToQuoteMap.get(sQuoteId), isoCodeToConversionRate, ddrRules);
        //DDRisRequired = false;
        if(DDRisRequired)
        {
            if(sQuote.CA_DDR_Name__c == NULL || sQuote.CA_DDR_Name__c == '')
            {
                ddrBucket.add(autoCreateDDR.createDDR(sQuote, idToQuoteMap.get(sQuoteId)));
            }
            else
            {
                namesOfDDRsToUpdate.add(sQuote.CA_DDR_Name__c);
                sQuote.Oubound_Status__c = 'Deal Desk';
                sQuote.Last_Updated_from_SFDC__c = true;
            }
        }   
        else
        {
            // Clear DDR Name
            //quotesToUpdate.add(new scpq__SciQuote__c(Id=sQuoteId, CA_DDR_Name__c=NULL));
            sQuote.CA_DDR_Name__c = NULL;
            //Clearing Approval ID field before processing TAP Rules
            
            // TAP process goes here
            System.debug('++++++++TAP Rules process started++++++++++++');
                        
            TAPRulesUtility TRU = new TAPRulesUtility();
            ApproverIds = TRU.ValidateTAPRules(sQuote,idToQuoteMap.get(sQuoteId).Quote_Products_Reporting__r,tapRulesList,DealDeskApprovers,isoCodeToConversionRate,idToQuoteMap.get(sQuoteId).scpq__OpportunityId__r);
            if(ApproverIds != null && ApproverIds.size() > 0 && !ApproverIdsMap.containsKey(sQuoteId))
            {
                ApproverIdsMap.put(sQuoteId,ApproverIds);   
                System.debug('++++++++Approval Ids Added++++++++++++' + ApproverIds);              
            }
            else
            {
                if(TapRulesUtility.AutoRunDDR == true)
                {
                        if(sQuote.CA_DDR_Name__c == NULL || sQuote.CA_DDR_Name__c == '')
                        {
                            ddrBucket.add(autoCreateDDR.createDDR(sQuote, idToQuoteMap.get(sQuoteId)));
                        }
                        else
                        {
                            namesOfDDRsToUpdate.add(sQuote.CA_DDR_Name__c);
                            sQuote.Oubound_Status__c = 'Deal Desk';
                            sQuote.Last_Updated_from_SFDC__c = true;
                        }                   
                }
                else
                {
                    AutoApprovalMap.put(sQuoteId,true);
                    System.debug('++++++++Auto Approved Quote++++++++++++' + AutoApprovalMap);
                }
            }
        }
    }
    
    if( (AutoApprovalMap != null && AutoApprovalMap.keySet().size() > 0) ||
        (ApproverIdsMap != null && ApproverIdsMap.keySet().size() > 0 ) ){
        
            Map<Id,String> ApproverIdAndNameMap = new Map<Id,String>();
            
            if(ApproverIds!=null){
                List<User> users= [select Id,Name from user where Id IN: ApproverIds];
                for(User u:users){
                    ApproverIdAndNameMap.put(u.Id,u.Name);
                }
            }
            
            System.debug('+++++++ApproverIdsMap+++++'+ApproverIdsMap);
             Set<Id> SQRecIdSet = new Set<Id>();
            if(ApproverIdsMap != null && ApproverIdsMap.keySet().size()>0){
               
                for(scpq__SciQuote__c s:Trigger.New){
                    if(ApproverIdsMap.containsKey(s.Id)){
                        
                        Integer i = 0;
                        Id anyOneApproverId;
                        s.Set_of_Approvers__c = ' ';
                        System.debug('++++++ApproverIdsMap.get(s.Id)+++++++'+ApproverIdsMap.get(s.Id));
                        for(Id ids:ApproverIdsMap.get(s.Id)){
                            System.debug('++++++++ids++++++'+ids);
                            
                            i++;
                            String str = 'Approver'+i+'__c';              
                            s.put(str,ids);            
                            anyOneApproverId = ids;
                            if(ApproverIdAndNameMap.containsKey(ids) && ApproverIdAndNameMap.get(ids)!=null){
                                if(s.Set_of_Approvers__c!=' '){
                                    s.Set_of_Approvers__c = s.Set_of_Approvers__c+' , '+ApproverIdAndNameMap.get(ids);
                                }else
                                    s.Set_of_Approvers__c = ApproverIdAndNameMap.get(ids);
                                
                            }
                            
                        }
                        
                        if(i<MAX_APPROVERS_SIZE){
                            for(Integer j=i+1;j<=MAX_APPROVERS_SIZE;j++){
                                String str = 'Approver'+j+'__c';              
                                s.put(str,anyOneApproverId);
                            }
                        }
                        SQRecIdSet.add(s.Id);
                    }
                    
                   
                }
                
            }
            
            TAPRulesUtility.updateApproverId(SQRecIdSet,AutoApprovalMap.keySet());
               
       
       
       }
    
    
   
    
    List<Deal_Desk_Review__c> ddrUpdateBucket = new List<Deal_Desk_Review__c>();
    for(Deal_Desk_Review__c ddr : [SELECT Id FROM Deal_Desk_Review__c WHERE Name IN :namesOfDDRsToUpdate])
    {
        ddr.Deal_Desk_Status__c = 'Updated – DD';
        //ddrBucket.add(ddr);
        ddrUpdateBucket.add(ddr);
    }
    update ddrUpdateBucket;
    
    //upsert ddrBucket;
    List<Id> ddrIds = new List<Id>();
    for(Database.Saveresult sr : Database.insert(ddrBucket))
    {
        ddrIds.add(sr.getId());
    }
    
    for(Deal_Desk_Review__c ddr : [SELECT Name, Sterling_Quote__c FROM Deal_Desk_Review__c WHERE Id IN :ddrIds])
    {
        scpq__SciQuote__c sQuote = Trigger.newMap.get(ddr.Sterling_Quote__c);
        sQuote.CA_DDR_Name__c = ddr.Name;
        sQuote.Oubound_Status__c = 'Deal Desk';
        sQuote.Last_Updated_from_SFDC__c = true;
    }
    
    delete [select Id From Quote_Approval_History__c WHERE Sterling_Quote__c IN :approvedQuotes];
    insert qahRecords;  
    //update quotesToUpdate;
    
    /*
    List<Approval.Processresult> results = Approval.process(submitRequests);
    List<Approval.Processworkitemrequest> approvalRequests = new List<Approval.Processworkitemrequest>();
    for(Approval.Processresult pr : results)
    {
        Approval.Processworkitemrequest iReq = new Approval.Processworkitemrequest();
        iReq.setAction('Approve');
        iReq.setComments('System Auto Approval: Approved');
        iReq.setWorkitemId(pr.getNewWorkitemIds().get(0));
        approvalRequests.add(iReq);
    }
    
    Approval.process(approvalRequests);
    */
    
}