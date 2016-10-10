/************************************************************************** \ 
@ Author : D.S Sandeep Reddy
@ Date : 16/04/14 
@ Test File :Initial Version 
@ Description : Trigger Handler for the Case SObject. This class implements the ITrigger. interface to help
ensure the trigger code is bulkified and all in one place.


@ Audit Trial : Repeating block for each change to the code
@ Last Modified By   : Vamshi    
@ Last Modified On   :  22/06/14 
@ Last Modified Reason     :  Updated Business hours calculation rules.

@Last Modified on **** 2nd July 2015 by Pankaj  *** condition "&& (caseRec.Origin != 'chat')" added by Pankaj for by pass case record created by Live Agent, find line by #liveAgent
@Last Modified on **** by *** to ******
****************************************************************************/

public class CaseGateway {
    public static Map<id, String> siteCntryMap = new Map<id, String>();
    public static Map<id, String> siteAccMap = new Map<id, String>();
    public static Map<ID, Site_Association__c> siteAssMap;
    public static Map<ID,CA_Product_Component__c> prodCompMap;
    public static Map<ID, Contact> contactsMap;
    public static Set<ID> contactIDs = new Set<ID>();
    public static Map<ID, Contact> contactsMapInsert;
    public static Set<ID> contactIDInsert = new Set<ID>();
    public static Map<ID, User> userMapInsert;
    public static Set<ID> userIDInsert = new Set<ID>();
    public static Map<id, User> usrPMFkeyMap = new Map<id, User>();
    public static Map<id, List<Task>> taskMap = new Map<id, List<Task>>();
    public static Map<id, GSS_Transactions__c> caseGSSMap = new Map<id, GSS_Transactions__c>();
    public static Set<ID> csmSiteIds = new Set<ID>();
    public static Map<Id, List<Task>> otherSupportTypeTaskMap = new Map<Id, List<Task>>();
    public static Set<ID> initialCB;
    public static Set<ID> openCB;
    public static Set<ID> seAction;
    public static Set<ID> expSLO;
    public static Map<String, GSS_Transactions__c> caseStageGSSMap = new Map<String, GSS_Transactions__c>(); //US108116
    public static List<Case_Portal_View__c> casePortalViewList = new List<Case_Portal_View__c>();
    
    
    //Added as part of LifeCycle:US47726 by Aditya  
    public static Map<String,String> stageStatusMap=new Map<String,String>{'1. Problem Identification'=>'Open',
        '2. Knowledge Search'=>'Open',
        '3. Cause Determination'=>'Open',
        '4. Solution Identification'=>'Open',
        '5. Solution Provided'=>'Verify',
        '6. Solution Deferred'=>'Verify',
        '7. Closed'=>'Closed'};
            
            
            public static Map<String,id> loadCaseBulkBefore(){
                List<Case> lstTrigger;
                set<id> siteIds = new set<id>();
                set<id> closedCaseIds = new set<id>();
                set<id> openCaseIds = new set<id>();
                set<id> productComponentIds = new set<id>();
                initialCB = new Set<ID>();
                openCB = new Set<ID>();
                seAction = new Set<ID>(); 
                expSLO = new Set<ID>();
                
                List<Businesshours> busHrsList = new List<Businesshours>();
                Map<String,id> busHrsIdMap = new Map<String,id>();      
                lstTrigger = trigger.New;   
               //US145728 : Abuse field to default 
                for(Case rec: lstTrigger){
                    if(rec.Abuse_reason__c != null )
            {
                if(rec.Abuse_Created_By__c == null){
                            rec.Abuse_Created_By__c = UserInfo.getUserId();
                }
                if(rec.Abuse_date__c == null){
                            rec.Abuse_date__c = Date.today();
                }
            }

                    Case oldcase;            
                    if(Trigger.isUpdate)
                        oldcase = (Case)Trigger.OldMap.get(rec.id);                                                     
                    
                    if(Trigger.isUpdate && rec.Status!='Closed')
                        openCaseIds.add(rec.Id);
                    
                    if(rec.Site_Association__c!=null)
                        siteIds.add(rec.Site_Association__c); 
                    
                    if(rec.Internal_Contact__c!=null)
                        userIDInsert.add(rec.Internal_Contact__c); 
                    
                    if(rec.contactid != null)
                    {
                        contactIDs.add(rec.contactID);
                        contactIDInsert.add(rec.contactID);
                    }
                    
                    
                    if(rec.CA_Product_Component__c!=null)
                        productComponentIds.add(rec.CA_Product_Component__c);
                    
                    
                    
                    if(Trigger.isInsert && Trigger.isBefore){
                        //Added as part of LifeCycle:US47726 by Aditya  
                        if(rec.Troubleshooting_Stage__c=='7. Closed'){
                            rec.addError('You cannot select Troubleshooting Staged as '+rec.Troubleshooting_Stage__c);
                        }
                        rec.Status=stageStatusMap.get(rec.Troubleshooting_Stage__c);
                        //End of Aditya   
                    }
                    
                    //US133508 , US133511 - Starts
                       
                    
                    if(rec.Next_Action__c==null && rec.Next_Action_Due_Date__c<>null){
                        rec.addError('Next Action Owner Must not Be Blank ');
                    }
                    
                    
                    boolean cReopen = Trigger.isUpdate && (oldcase.Troubleshooting_Stage__c == '7. Closed'  && rec.Troubleshooting_Stage__c!='7. Closed' );
                    System.debug('cReopen:'+cReopen);
                    if(cReopen){
                        UtilityFalgs.isCaseReopend = true;
                    }
                    if(Trigger.isInsert || cReopen ){
                        if(rec.Next_Action__c==null || rec.Next_Action__c==''){
                            if(rec.Troubleshooting_Stage__c != '5. Solution Provided'){
                                rec.Next_Action__c = 'Pending CA Support'; //TODO:Replace with custom label
                            } 
                            else{
                                rec.Next_Action__c = 'Pending Customer';
                            }
                            rec.isNextActionOwnerDefault__c=true;
                        }
                    }
                    //US133508 , US133511 - Ends
                    
                  
                    
                    
                    if(Trigger.isUpdate && Trigger.isBefore){
                        //Added for Lifecycle:US47726 by Aditya status shoudl be set before the any status logic is checked.
                        if(rec.Status!='Closed' && oldcase.Status!='Closed' && rec.Troubleshooting_Stage__c=='7. Closed'){                      
                            rec.addError('Invalid Data.Troubleshooting Stage field cannot be set to Closed for Updating Case');
                        }
                        if(rec.Status=='Closed' && oldcase.Status!='Closed' && rec.Troubleshooting_Stage__c!='7. Closed'){                      
                            rec.addError('Invalid Data.Troubleshooting Stage field must be set to Closed');
                        }
                        if(rec.Troubleshooting_Stage__c != null && rec.Troubleshooting_Stage__c!='')
                            rec.Status=stageStatusMap.get(rec.Troubleshooting_Stage__c);                
                        //End of Aditya           

                    }
                    
                    if (Trigger.isUpdate && oldcase.Status!=rec.Status) {       
                        
                        if (rec.Status=='Closed' ){
                            rec.Next_Action__c = 'Issue Closed';    
                            rec.Next_Action_Due_Date__c=null;
                            
                            if(rec.Reopen_Count__c>0)  
                                rec.Date_Time_ReClosed__c =System.now();  
                        }
                        
                        else if (oldcase.Status == 'Closed'){
                            if(rec.Next_Action__c == 'Issue Closed') 
                                rec.Next_Action__c =null;
                            If(rec.Status=='Open')
                                rec.Date_Time_ReOpened__c =System.now();                   
                        } 
                        
                        //When case is owner is changed capture the case id to re-assigned initial callbacks to a real user(case owner) from a Queue. 
                        //when case is closed capture the case id to close all callbacks.                  
                        
                        //  if ( oldcase.ownerid!=rec.ownerid || rec.Status=='Closed')
                        //    closedCaseIds.add(rec.Id);                                                                                                       
                    }   
                    
                    
                    if ( Trigger.isUpdate && (oldcase.ownerid!=rec.ownerid || rec.Status=='Closed'))
                        closedCaseIds.add(rec.Id);
                    
                }
                if(!productComponentIds.isEmpty())
                    prodCompMap = new Map<Id,CA_Product_Component__c> ([select id , Component_Code__c from CA_Product_Component__c where Id IN :productComponentIds]);
                
                if(!siteIds.isEmpty())
                    siteAssMap = new Map<ID,Site_Association__c>([Select id,Enterprise_ID__c,Country_picklist__c,SC_CA_Internal_Site__c,SC_SITE_CSM__c,SC_TOPS_ID__c  from Site_Association__c where id in:siteIds]);
                
                if(!userIDInsert.isEmpty())
                    userMapInsert=new Map<ID, User>([Select id,FirstName,LastName,Phone,Email,Preferred_Contact_Method__c from User where id in:userIDInsert]);
                
                if(!contactIDInsert.isEmpty())
                    contactsMapInsert=new Map<ID, Contact>([Select id,FirstName,LastName,phone,SC_CONTACT_Language_Preference2__c,Email,SC_CONTACT_Preferred_Contact_Method__c,Language_Preference__c from Contact where id in:contactIDInsert]);
                
                if(Trigger.isUpdate && !contactIDs.isEmpty())
                    contactsMap = new Map<ID,Contact>([select email from contact where id=:contactIDs]);
                
                if(siteAssMap != null && siteAssMap.size()>0){
                    for(Site_Association__c siteRec :siteAssMap.values()){                                   
                        if(siteRec.Country_picklist__c!=null)
                            siteCntryMap.put(siteRec.id,siteRec.Country_picklist__c);
                        if(siteRec.Enterprise_ID__c!=null)
                            siteAccMap.put(siteRec.id,siteRec.Enterprise_ID__c);   
                        if(siteRec.SC_SITE_CSM__c!=null)
                            csmSiteIds.add(siteRec.id);     
                    }
                }
                if(siteCntryMap.size()>0)
                    busHrsList = [select id,Name from Businesshours where name in: siteCntryMap.values()];
                
                for(BusinessHours bhRec:busHrsList)
                    busHrsIdMap.put(bhRec.Name,bhRec.id);
                if(!closedCaseIds.isEmpty()){     
                    List<Task> taskLst = [select id,Ownerid,whatid,Type,RecordTypeId from task where whatid in:closedCaseIds and status NOT IN ('Closed', 'Completed')]; 
                    system.debug('casegateway ======'+taskLst);  
                    if(!taskLst.isEmpty()){        
                        for(Task taskRec:taskLst){          
                            List<Task>  taskList =  taskMap.get(taskRec.Whatid);            
                            if(taskMap.containsKey(taskRec.Whatid)){
                                List<Task> rec = new List<Task>();
                                rec = taskMap.get(taskRec.Whatid) ; 
                                rec.add(taskRec);
                                Set<Task> taskSet = new Set<Task>(); //code added to remove duplicate records
                                taskSet.addAll(rec);
                                rec = new List<Task>();
                                rec.AddAll(taskSet);
                                taskMap.put(taskRec.Whatid,rec);
                            }    
                            else{              
                                List<Task> rec = new List<Task>();
                                rec.add(taskRec);
                                taskMap.put(taskRec.Whatid,rec);
                            }
                        }   
                    } 
                    // start of fix for case close error issue in fsb1
                    else{
                        taskMap = new Map<id, List<Task>>();
                    }
                    // end of fix for case close error issue in fsb1
                }
                
                if(openCaseIds!=null && openCaseIds.size()>0){
                    List<Task> openTaskList = [select id,Type,Status,WhatId,Due_Date_SLO__c from Task where whatid in:openCaseIds and ( Type='SE Action' or Type like '%Callback' ) and Status<>'Closed'];
                    
                    for(Task tsk:openTaskList){                       
                        if(tsk.Type=='SE Action')
                            seAction.add(tsk.WhatId);
                        else{
                            if(tsk.Due_Date_SLO__c < System.now())
                                expSLO.add(tsk.WhatId);
                            if(tsk.Type=='Initial Callback')
                                initialCB.add(tsk.WhatId);
                            else if(tsk.Type=='Callback')
                                openCB.add(tsk.WhatId);                          
                        }   
                    }
                }

                
                //Timeboxing - Starts
                String managerAction;
                String managerActionComment;
                for(Case caseRec:lstTrigger){
                    if(caseRec.ThresholdCalc_Enabled_on_Product__c){
                        if(Trigger.isInsert){
                            caseRec=SupportThresholdCalculator.performThresholdCalculations(caseRec, null,busHrsIdMap);
                        }
                        else if(Trigger.isUpdate){                            
                            Case oldcase =(Case) Trigger.oldMap.get(caseRec.Id);
                            if(caseRec.CA_Product_Controller__c!= oldcase.CA_Product_Controller__c){
                                caseRec = SupportThresholdCalculator.performThresholdCalculations(caseRec, null,busHrsIdMap);//TODO: Should we check seacion??
                            }
                            if(caseRec.Troubleshooting_Stage__c!= oldcase.Troubleshooting_Stage__c ){
                                if(caseRec.Troubleshooting_Stage__c.equalsIgnoreCase(system.label.SolutionIdentification) && seAction!=null && seAction.size()>0){
                                    caseRec = SupportThresholdCalculator.performThresholdCalculations(caseRec, seAction,busHrsIdMap);
                                }else{
                                    caseRec = SupportThresholdCalculator.performThresholdCalculations(caseRec, null,busHrsIdMap);
                                }
                            }
                            else{
                                    if(UtilityFalgs.isSEActionTaskCreated && caseRec.Troubleshooting_Stage__c.equalsIgnoreCase(system.label.SolutionIdentification) && seAction!=null && seAction.size()>0) {
                                             caseRec = SupportThresholdCalculator.performThresholdCalculations(caseRec, seAction,busHrsIdMap);
                                    }
                            }                              
                            if(caseRec.Severity__c!= oldCase.Severity__c){
                                if(caseRec.Troubleshooting_Stage__c== oldCase.Troubleshooting_Stage__c){
                                    if(caseRec.Troubleshooting_Stage__c.equalsIgnoreCase(system.label.SolutionIdentification) && seAction!=null && seAction.size()>0){
                                        caseRec=SupportThresholdCalculator.performThresholdCalculationsonSevChange(caseRec,seAction,busHrsIdMap);
                                    }else{
                                        caseRec=SupportThresholdCalculator.performThresholdCalculationsonSevChange(caseRec,null,busHrsIdMap);
                                    }
                                }
                            }
                        }//end of Trigger.isUpdate
                    }
                    else{
                        managerAction = caseRec.Manager_Action__c;
                        managerActionComment = caseRec.Manager_Action_Comment__c;
                        caseRec = SupportThresholdCalculator.clearThresholdValues(caseRec);
                    }
                    
                    //-----
                    if(Trigger.isUpdate && Trigger.isBefore){
                        Case oldcase =(Case) Trigger.oldMap.get(caseRec.Id);

                        if(caseRec.ThresholdCalc_Enabled_on_Product__c){
                            if(caseRec.Manager_Action__c!= oldCase.Manager_Action__c){
                                if(!UtilityFalgs.clearManagerActionValues){
                                    if(caseRec.Manager_Action__c== null || caseRec.Manager_Action__c==''){
                                        caseRec.addError(system.label.Manager_Action_cannot_be_made_blank);
                                    }
                                    
                                }
                            }
                        }else{
                            if(UtilityFalgs.clearManagerActionValues){
                                if(managerAction!=null || managerActionComment!=null){
                                        caseRec.addError(System.label.Cannot_Set_Manager_Action);//('Cannot set \'Manager Action\' or \'Manager Action Comment\' when Thresholds are not calculated');
                                }
                            }
                        }
                        
                        if(caseRec.Threshold_Start_Date_Time__c == null){
                            if(caseRec.Manager_Action__c!= null ||caseRec.Manager_Action_Comment__c!=null ){
                                caseRec.addError(System.label.Cannot_Set_Manager_Action);//('Cannot set \'Manager Action\' or \'Manager Action Comment\' when Thresholds are not calculated');
                            }
                        }else{
                            if(caseRec.Manager_Action_Comment__c != oldcase.Manager_Action_Comment__c && caseRec.Manager_Action_Comment__c!=null){
                                caseRec.Manager_Action_Comment_By__c = UserInfo.getUserId();
                                caseRec.Manager_Action_Comment_Update_Date_Time__c = System.now();
                            }
                            if(caseRec.Manager_Action__c != oldcase.Manager_Action__c && caseRec.Manager_Action__c!=null){
                                caseRec.Manager_Action_Update_By__c = UserInfo.getUserId();
                                caseRec.Manager_Action_Update_Date_Time__c = System.now();
                            }
                        }
                                              
                        
                    }
                } //Timeboxing - Ends  
                
                
                
                return busHrsIdMap;       
            }
    
    // fetch pmf key of respective user for populating previous modied user on
    // GSS transaction record.
    // fetch latest GSS transaction record for case and store theese details in
    // previous values of a new Gss transaction record.
    
    public static Map<id,User> loadCaseBulkAfter(){
        
        List<Case> lstTrigger = trigger.New;      
        Set<id> lastModUsrIdSet= new set<id>();
        Set<id> gssCaseIds= new set<id>();
        Set<Id> updatedStatusCaseIdSet = new Set<Id>();
        Set<Id> portalViewCaseIdSet = new Set<Id>(); // Set to store Case Id for which Case Portal View  will be updated
        List<Case> caseAlert=new List<Case>();  
        List<CaseComment> closeCCList = new List<CaseComment>();
        for(Case rec: lstTrigger){
            lastModUsrIdSet.add(rec.LastmodifiedbyID); 
            if(Trigger.isUpdate){
                gssCaseIds.add(rec.Id);  
                Case oldcase = (Case)Trigger.OldMap.get(rec.id); 
                //updated condition to look for next action due date also - VELUD01 - 30-01-2015 - 300-208365
                if(rec.Status!=oldcase.status  ||oldcase.Next_Action__c!=rec.Next_Action__c || oldCase.Next_Action_Due_Date__c!=rec.Next_Action_Due_Date__c ){
                    updatedStatusCaseIdSet.add(rec.Id);
                }    
                if(rec.Status!=oldcase.status || rec.Severity__c != oldcase.Severity__c){
                    System.Debug('case stat'+rec.Status+oldcase.status +' case sev '+rec.Severity__c+' '+oldcase.Severity__c);
                    caseAlert.add(rec);
                }
                //DE133448 : Identify cases where Action Code and Next Action fields are changed  
                if((rec.Issue_Action_c__c!=oldcase.Issue_Action_c__c)|| (rec.Next_Action__c!=oldcase.Next_Action__c)||(rec.Next_Action_Date__c!=oldcase.Next_Action_Date__c)) {
                    portalViewCaseIdSet.add(rec.Id);
                }
                //US184023 : Creating case comment to case has confidential attachment
                if(rec.Status=='Closed' && oldcase.status!='Closed')
                {
                    if(rec.Confidential_Attachments__c){
                        CaseComment CloseCC = new CaseComment();
                        CloseCC.ParentId = rec.Id;
                        CloseCC.IsPublished = false;
                        String str = label.ClousreCommentBody_ConfidentialAttachment;
                        String target = '00xxxxxx';
                        String replacement = rec.CaseNumber;
                        String finalComment = str.replace(target ,replacement);
                        CloseCC.CommentBody = finalComment;
                        //CloseCC.CommentBody = 'It is a requirement to delete all file attachments related to Case '+rec.CaseNumber+'.  Please make sure you have deleted all related file attachments.';
                        CloseCCList.add(CloseCC);
                    }
                }
            }      
        }
        if(CloseCCList!=null && CloseCCList.size()>0){
                insert CloseCCList;}
        if(!UtilityFalgs.sentAlert && caseAlert.size()>0 && caseAlert!=null)
        {
            //Commented to test as part of SPIKE:US118509
            //  System.Debug('Case UtilityFalgs.sentAlert ' +UtilityFalgs.sentAlert);
            // UtilityFalgs.sendMail(caseAlert);
            // UtilityFalgs.sentAlert=true;
        } 
        
        String caseStage;//US108116
        
        if(!gssCaseIds.isEmpty()){
            
            /* List<GSS_Transactions__c> gssLst = [select id,Case__c,Current_Next_Action__c,Current_Status__c,Current_Status_Added_By__c,Curr_Next_Action_By__c,Current_Next_Action_Date__c,
Current_Status_Date__c,Current_GSS_TR__c,Current_Next_Action_Due_Date__c,Current_GSS_TR_Date__c from GSS_Transactions__c where Case__c in: gssCaseIds order by LastModifieddate desc ];
*/ 
            List<GSS_Transactions__c> gssLst = [select id,Case__c,Case__r.Troubleshooting_Stage__c,Current_Next_Action__c,Current_Status__c,Current_Status_Added_By__c,Curr_Next_Action_By__c,Current_Next_Action_Date__c,
                                                Current_Status_Date__c,Current_GSS_TR__c,Current_Next_Action_Due_Date__c,Current_GSS_TR_Date__c,Current_Stage_End_Date__c,Stage_Count__c,CA_product__c,offering_name__c,case_origin__c 
                                                from GSS_Transactions__c where Case__c in: gssCaseIds
                                                and Stage_Count__c = null  order by createdDate  desc ];                                                
            //US131502 - commented   ---> , and added createdDate  desc, and removed LastModifieddate desc,
            System.debug('***gssLst:'+gssLst);     
            if(gssLst!=null && !gssLst.isEmpty()){
                for(GSS_Transactions__c  gssRec: gssLst){
                    if(!caseGssMap.keySet().contains(gssRec.Case__c))
                        caseGssMap.put(gssRec.Case__c,gssRec); 
                } 
            } //CLOSED the loop of if for gss transantion to be independent of task 
            System.debug('caseGssMap:'+caseGssMap);
            
            //US108116 - starts
            List<GSS_Transactions__c> gssLst2 = [select id,Case__c,Case__r.Troubleshooting_Stage__c,Current_Next_Action__c,Current_Status__c,Current_Status_Added_By__c,
                                                 Curr_Next_Action_By__c,Current_Next_Action_Date__c,Current_Status_Date__c,Current_GSS_TR__c,Current_Next_Action_Due_Date__c,Current_GSS_TR_Date__c,
                                                 Current_Stage_End_Date__c,Stage_Count__c,Current_Troubleshooting_Stage__c,CA_product__c,offering_name__c,case_origin__c
                                                 from GSS_Transactions__c where Case__c in: gssCaseIds 
                                                 order by LastModifieddate desc,  createdDate  desc]; 
            System.debug('***gssLst2:'+gssLst2);
            for(GSS_Transactions__c gssRec : gssLst2){
                //caseStage = gssRec.Case__c+'-'+((Case)Trigger.OldMap.get(gssRec.Case__c)).Troubleshooting_Stage__c;  
                caseStage = gssRec.Case__c+'-'+gssRec.Current_Troubleshooting_Stage__c;   //US131502  - commented this - caseStage = gssRec.Case__c+'-'+gssRec.Current_Status__c;           
                //System.debug('caseStage:'+caseStage);         
                //System.debug('gssRec.Stage_Count__c :'+gssRec.Stage_Count__c );
                if(!caseStageGSSMap.keySet().contains(caseStage) && gssRec.Stage_Count__c != null){
                    //System.debug('caseStage--gssRec:'+caseStage + '--'+gssRec);
                    caseStageGSSMap.put(caseStage,gssRec);
                }                    
            }
            
            //US108116 - ends
            
            //   } //CLOSED the loop of if for gss transantion to be independent of task  //**** MANAR08 -- US131502
            //querying other support record type Tasks with type SE Action to set Calculated status on GSS trasanction record
            List<Task> otherSupportTaskList = [select Id,Status,WhatId from Task where RecordTypeId =: Label.Other_Support_Task_Record_Type  AND  Type = 'SE Action'
                                               AND (WhatId IN :updatedStatusCaseIdSet )];  
            if(otherSupportTaskList!=null && otherSupportTaskList.Size()>0){
                for(Task taskRec : otherSupportTaskList ){
                    if(otherSupportTypeTaskMap!=null && otherSupportTypeTaskMap.containsKey(taskRec.WhatId)){
                        List<Task> taskList = otherSupportTypeTaskMap.get(taskRec.WhatId);
                        taskList.add(taskRec);
                        otherSupportTypeTaskMap.put(taskRec.WhatId,taskList);
                    }
                    else{
                        otherSupportTypeTaskMap.put(taskRec.WhatId,new List<Task>{taskRec});
                    }
                }
            }
            //US131502 - starts -- Added below logic to populate the nextxa ction duedate to GSS Transaction record created initially, with TR code 'N'        
            System.debug('&&&&&&&&&&&&&&&&&&&&&&');
            if(Trigger.isUpdate ){
                for(Case caseRec : lstTrigger){
                    if(UtilityFalgs.isInitialCallBackTaskCreated == true){
                        System.debug('In after update,caseGSSMap:'+caseGSSMap);
                        GSS_Transactions__c gssRecN = caseGSSMap.get(caseRec.id);
                        System.debug('gssRecN:'+gssRecN);
                        gssRecN.Current_Next_Action_Due_Date__c = caseRec.Next_Action_Due_Date__c;
                        gssLst.add(gssRecN);
                    }             
                }
            }
            //US131502 - ends                         
            
        }
        //DE133448 : Query Portal View Records for identified cases
        if(!portalViewCaseIdSet.isEmpty()){
            casePortalViewList = [select Id , Case__c , Portal_View_Date__c from Case_Portal_View__c where Case__c IN :portalViewCaseIdSet ];
        }
        // End DE133448


        usrPMFkeyMap = new Map<id,User>([select id,PMFKey__c from User where id in:lastModUsrIdSet]);      
        return usrPMFkeyMap;
    }
    
    public static void updInternalPriority(Case caseRec){
          System.debug('UtilityFalgs.isInitialCallBackTaskCreated:'+UtilityFalgs.isInitialCallBackTaskCreated);
      String nextAct=caseRec.Next_Action__c;     
      //updated dueDate field from Date to Datetime - VELUD01 - 30-01-2015 - 300-208365       
      DateTime nextActDueDate =null;
            
      if(caseRec.Next_Action_Due_Date__c!=null)
         nextActDueDate = caseRec.Next_Action_Due_Date__c; 
      
      //end of changes for 300-208365              
      
      if(caseRec.Status=='Closed')
         caseRec.Internal_Priority__c='99';
      else if(caseRec.Status=='Verify')
         caseRec.Internal_Priority__c='12';   
      else{ 
          if(nextActDueDate<system.Today()){
          caseRec.Internal_Priority__c='1';    
          }            
         else if(caseRec.Next_Action__c==null ){
          caseRec.Internal_Priority__c='2'; 
         }           
         else if(Trigger.isInsert){         
               caseRec.Internal_Priority__c='3';
          }
          else if(Trigger.isUpdate && initialCB!=null && initialCB.contains(caseRec.Id)){
            caseRec.Internal_Priority__c='3'; 
          }
          //US134926
           else if(Trigger.isUpdate && (UtilityFalgs.isInitialCallBackTaskCreated!=null && UtilityFalgs.isInitialCallBackTaskCreated == true)){
            caseRec.Internal_Priority__c='3'; 
              // UtilityFalgs.isInitialCallBackTaskCreated=false;
          }  
         else if(caseRec.Internal_Priority_4__c=='Y' || expSLO!=null && expSLO.contains(caseRec.Id)){
            caseRec.Internal_Priority__c='4';  
          }
          else if(caseRec.Site_Association__c!=null && csmSiteIds!=null && csmSiteIds.contains(caseRec.Site_Association__c)){   
            caseRec.Internal_Priority__c='5';  
          }
          else if(openCB!=null && openCB.contains(caseRec.Id)){
            caseRec.Internal_Priority__c='6';
          }    
          //US134926
          else if(nextActDueDate<>null && nextActDueDate.date()==system.Today() && NextAct!=null && (NextAct.contains('Pending CA') ||  NextAct.contains('Pending Partner') || NextAct.contains('Pending 3rd Party Vendor'))){
             caseRec.Internal_Priority__c='7';  
          }             
          else if(nextActDueDate<>null && nextActDueDate.date()==system.Today() && NextAct!=null && NextAct.contains('Pending Customer') ){
                 caseRec.Internal_Priority__c='8';
          }         
          else if(nextActDueDate<>null && nextActDueDate > system.Today() && NextAct!=null && (NextAct.contains('Pending CA') ||  NextAct.contains('Pending Partner') || NextAct.contains('Pending 3rd Party Vendor'))){
            caseRec.Internal_Priority__c='9';
          }
          else if(nextActDueDate<>null && nextActDueDate > system.Today() && NextAct!=null && NextAct.contains('Pending Customer')){
            caseRec.Internal_Priority__c='10';
          }
          //US134926
          else if(seAction!=null && seAction.contains(caseRec.Id)){
            caseRec.Internal_Priority__c='11';  
          }
          else{
             caserec.Internal_Priority__c='0'; 
          }
      }
        
    }
    /* CR:400-1600
public static void updateContactFieldsOnCase(Case caseRec)
{

if(!Label.Service_cloud_external_user_profile.contains(userinfo.getProfileId().substring(0,15))){
if(caseRec.Internal_Contact__c==null && caseRec.contactid != null)
{
Contact contactInsert=CaseGateway.contactsMapInsert.get(caseRec.ContactID);
caseRec.Alt_Contact_First_Name__c = contactInsert.FirstName;
caseRec.Alt_Contact_Last_Name__c = contactInsert.LastName;
caseRec.Alternate_Phone__c = contactInsert.phone;
caseRec.Alt_Contact_Alternate_Language__c = contactInsert.SC_CONTACT_Language_Preference2__c;
caseRec.Alternate_email__c = contactInsert.Email;
caseRec.Alt_Contact_Preferred_Contact_Method__c = contactInsert.SC_CONTACT_Preferred_Contact_Method__c;
caseRec.Alt_Contact_Preferred_Language__c = contactInsert.Language_Preference__c;
}
if(caseRec.Internal_Contact__c!=null && caseRec.contactid == null)
{
User userInsert=CaseGateway.userMapInsert.get(caseRec.Internal_Contact__c);
caseRec.Alt_Contact_First_Name__c = userInsert.FirstName;
caseRec.Alt_Contact_Last_Name__c = userInsert.LastName;
caseRec.Alternate_Phone__c = userInsert.phone;
caseRec.Alternate_email__c = userInsert.Email;
caseRec.Alt_Contact_Preferred_Contact_Method__c = userInsert.Preferred_Contact_Method__c;
}
} 
}
*/
    
    public static boolean checkSurveyEligibility(Case caseRec){
        boolean eligibleForSurvey = false;
        if(caseRec.Do_No_Survey__c)
        {
            eligibleForSurvey = false;
        }
        else if(
            (caseRec.status=='Closed')
            && (caseRec.Reopen_Count__c==0)   
            && (!(caseRec.Internal_Contact__c != null))  
            && (!caseRec.Internal_CA__c) 
            && (caseRec.contactid!=null) && (caseRec.Case_Type__c != 'Chat' ) //#liveAgent 
            && ( contactsMap.get(caseRec.contactid).email != null)
            && (!(contactsMap.get(caseRec.contactid).email.endsWith('@ca.com')))
            && (!(contactsMap.get(caseRec.contactid).email.endsWith('@CA.COM')))
            && (!(contactsMap.get(caseRec.contactid).email.endsWith('@contractor.ca.com')))
            && (!(contactsMap.get(caseRec.contactid).email.endsWith('@arcserve.com')))
            && (!(contactsMap.get(caseRec.contactid).email.endsWith('@cai.com')))
            && (!(contactsMap.get(caseRec.contactid).email.endsWith('@CAI.COM')))) {
                
                if(siteAssMap.get(caseRec.Site_Association__c).SC_CA_Internal_Site__c != true){
                    
                    eligibleForSurvey = true;
                    for(Emails_List__c emailsList : Emails_List__c.getAll().values()){
                        if((contactsMap!=null )&&(contactsMap.get(caseRec.contactid).email == emailsList.name)) eligibleForSurvey  = false;
                    }
                    for(Products_List__c productsList : Products_List__c.getAll().values()){
                        if((prodCompMap!=null )&&(prodCompMap.get(caseRec.CA_Product_Component__c).Component_Code__c == productsList.name)) eligibleForSurvey  = false;
                    }
                    for(Sites_List__c sitesList: Sites_List__c.getAll().values()){
                        if((siteAssMap!=null) && (siteAssMap.get(caseRec.Site_Association__c).SC_TOPS_ID__c   == sitesList.name)) eligibleForSurvey  = false;
                    }
                }
            }
        return eligibleForSurvey;
    }
    
    public static Boolean isExternalUser() {
        return (Label.Service_cloud_external_user_profile.contains(userinfo.getProfileId().substring(0,15)) 
          || userinfo.getProfileId() == CC_Settings.communityUserDefaultAccountId);
    }
}