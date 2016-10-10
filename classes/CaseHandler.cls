/*************************************************************************\
       @ Author      : D.S Sandeep Reddy
       @ Date        : 16/04/14
       @ Test File   : Initial Version
       @ Description : Trigger Handler for the Case SObject. This class implements the ITrigger.
                       interface to help ensure the trigger code is bulkified and all in one place.

@ Audit Trial : Repeating block for each change to the code
       @ Last Modified By   : Vamshi    
       @ Last Modified On   :  22/06/14 
       @ Last Modified Reason     :  Updated Business hours calculation rules.

 @Last Modified on **** by *** to ******

 ****************************************************************************/
 

public without sharing class CaseHandler implements ITrigger{

    // Member variable to hold the site details of the case.
    private Map<Id,Case> siteDtls = new Map<Id,Case>();

    // Member variable to hold the Business hour name and corresponding Id related to Case.
    Map<String,id> busHrsIdMap = new Map<String,id>();
    Map<id,User> usrPMFkeyMap = new Map<id,User>(); 
    Map<id,GSS_Transactions__c> caseGSSMap;
    String conMilli='60000';
    List<GSS_Transactions__c> gssLst = new List <GSS_Transactions__c>();
    //List<GSS_Transactions__c> gssLstToUpdate = new List <GSS_Transactions__c>(); //US131502

    List<Task> taskLst = new List<Task>();
    Set<Id> closedCaseSet = new Set<Id>();
    Map<Id,List<Task>> otherSupportTypeTaskMap = new Map<Id,List<Task>>(); // Map to hold case ID as key and values as list of other support tasks

    Map<String, GSS_Transactions__c> caseStageGSSMap; //US108116  
    List<Case_Portal_View__c> portalViewList = new List<Case_Portal_View__c>();
                                                                          
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore()
    {        
        if (Trigger.isInsert || Trigger.isUpdate)
            busHrsIdMap = CaseGateway.loadCaseBulkBefore();       
    }

    public void bulkAfter()
    {
        if (Trigger.isInsert || Trigger.isUpdate)
            usrPMFkeyMap = CaseGateway.loadCaseBulkAfter();

    } 
    public void beforeInsert(SObject so)
    {
        Case caseRec = (Case)so;     
        caseRec.BusinessHoursid =  busHrsIdMap.get(CaseGateway.siteCntryMap.get(caseRec.Site_Association__c));
        caseRec.Accountid=CaseGateway.siteAccMap.get(caseRec.Site_Association__c);
      //  CaseGateway.updateContactFieldsOnCase(caseRec); CR:400-1600
      
        if(caseRec.Next_Action__c!=null)
           caseRec.Next_Action_Date__c =System.Now(); 
        
       
     
      
       //Common Code for Support Offerings Flow
        if(!caseRec.Case_Created_without_Entitlement__c && caseRec.Origin!='Chat'){
             SupportOfferingsFlowController supportOfferingsFlowController=new SupportOfferingsFlowController();               
            SupportOfferingsFlowController.FinalOfferingData finalOfferingData=supportOfferingsFlowController.getAdvantageousOfferingCodeDetails(caseRec.Tops_Support_Site_ID__c, caseRec.CA_Product_Controller__c, caseRec.ContactId, caseRec.Severity__c);
             if(finalOfferingData<>null){
                caseRec.Offering_Code_Ref__c=finalOfferingData.offeringCode;
                caseRec.Offering_Name__c=finalOfferingData.offeringBusinessRulesID;
                caseRec.Offering_Source__c=finalOfferingData.offeringSource;
                caseRec.Offering_Support_Engineer__c=finalOfferingData.offeringDSE;
                caseRec.Certified_Bypass_Routing_Qualified__c=finalOfferingData.isCBRQualified;
                caseRec.Offering_Code_Configuration_Issue__c=finalOfferingData.isOfferingCodeConfIssue;
                 //US130725 -- Start
                caseRec.Queue_Jumping__c = finalOfferingData.isQueueJumpingField;
                //US130725 -- End
                caseRec.Guaranteed_Restoration__c = finalOfferingData.isRestorationFeatureAvailable; //US202426
            }
        }  
        //US138062-Set utility flags value to true when case is queue jumping enabled-start
        if(caseRec.Queue_Jumping__c && caseRec.Queue_Jumping__c!=null)
        UtilityFalgs.isQueueJumpingEnabled=true;
        //US138062-end 
        CaseGateway.updInternalPriority(caseRec);   
        UtilityFalgs.callbackCreated=true;   
        UtilityFalgs.isInitialCallBackTaskCreated = true;

    }


    public void beforeUpdate(SObject oldSo, SObject so)
    {
        Case caseRecNew = (Case)so;
        Case caseRecOld = (Case)oldSo;
        boolean caseWithSpCond = false;
        
        
        
        //CR:400-1270
        //CR:400-1600
        /*
        if((caseRecNew.ContactId!=caseRecOld.ContactId)||(caseRecNew.Internal_Contact__c!=caseRecOld.Internal_Contact__c)){
           CaseGateway.updateContactFieldsOnCase(caseRecNew); 
        }*/
        CaseGateway.updInternalPriority(caseRecNew);

        caseRecNew.BusinessHoursid =  busHrsIdMap.get(CaseGateway.siteCntryMap.get(caseRecNew.Site_Association__c));
        caseRecNew.Accountid=CaseGateway.siteAccMap.get(caseRecNew.Site_Association__c);
        if(caseRecNew.Status!=caseRecOld.Status && (caseRecNew.Status =='Closed'))     
        caseRecNew.Eligible_for_Survey__c = CaseGateway.checkSurveyEligibility(caseRecNew);
       //code to enable search on tops site --commented below
      // String site_id=caseRecNew.Tops_Support_Site_ID__c;
      // caseRecNew.SiteId__c=(site_id.leftpad(6)).replace(' ','0');
       
         if(caseRecNew.Next_Action__c != null){
            if(caseRecNew.Next_Action__c!=caseRecOld.Next_Action__c || caseRecNew.Next_Action_due_date__c!=caseRecOld.Next_Action_Due_Date__c)
             caseRecNew.Next_Action_Date__c =System.Now();
         }      
        else
            caseRecNew.Next_Action_Date__c = null;
                          
         if((caseRecNew.Status!=caseRecOld.Status) && (caseRecNew.Status =='Verify')){
                if(caseRecNew.Close_Count__c!=null)   
                   caseRecNew.Verify_Count__c = caseRecNew.Verify_Count__c+1;
                else
                   caseRecNew.Verify_Count__c =1;                
         }
         if((caseRecNew.Status!=caseRecOld.Status) && (caseRecNew.Status =='Closed')){                 
                 caseRecNew.Open_CB__c='N';
                if(caseRecNew.Close_Count__c!=null)
                   caseRecNew.Close_Count__c = caseRecNew.Close_Count__c+1;
                else
                   caseRecNew.Close_Count__c =1;                               
         }
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {  
      
    }
    public void afterInsert(SObject so)
    {
        Case caseRec = (Case)so;   
        String pmfKey;
        //updated dueDate field from Date to Datetime - VELUD01 - 30-01-2015 - 300-208365
        DateTime dueDate=null;

        if(caseRec.Next_Action_Due_Date__c!=null)
            dueDate = caseRec.Next_Action_Due_Date__c; 
        //end of changes for 300-208365

        if(usrPMFkeyMap.get(caseRec.LastmodifiedbyID) != null && usrPMFkeyMap.get(caseRec.LastmodifiedbyID).PMFKey__c!= null)
            pmfKey = usrPMFkeyMap.get(caseRec.LastmodifiedbyID).PMFKey__c;

        if(pmfkey==null)
            pmfKey = Userinfo.getName();

        gssLst.add(new GSS_Transactions__c(Case__c=caseRec.id,Current_GSS_TR__c='N',Current_Next_Action__c=caseRec.Next_Action__c,
        Current_Status__c=caseRec.Status,Current_Status_Added_By__c=pmfKey, Current_Next_Action_Date__c=caseRec.Next_Action_Date__c,
        Current_Status_Date__c=DateTime.now(),Curr_Next_Action_By__c=pmfKey,Current_GSS_TR_Date__c=DateTime.now(),
        Current_Next_Action_Due_Date__c=dueDate,ReOpen_Date__c = caseRec.CreatedDate,Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
        CA_product__c = caseRec.Product__c, offering_name__c =caseRec.Offering_Name__r.Name,case_origin__c =caserec.Origin));

        //Commented below for US131502
            /*
        //US108116 
        gssLst.add(new GSS_Transactions__c(Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
            Current_Status_Date__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
            Current_Status_Added_By__c = pmfKey,Current_Status__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c =1));
          //US108116 */

            //US131502        
         gssLst.add(new GSS_Transactions__c(Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
            Date_Current_Troubleshooting_Stage_set__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
            Current_Status_Added_By__c = pmfKey,Current_Troubleshooting_Stage__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c =1,
            Current_Status__c = caseRec.Status,Current_Next_Action__c=caseRec.Next_Action__c,Current_Next_Action_Date__c=caseRec.Next_Action_Date__c,Curr_Next_Action_By__c=pmfKey,
            Current_Next_Action_Due_Date__c=dueDate,ReOpen_Date__c = caseRec.CreatedDate,CA_product__c = caseRec.Product__c, offering_name__c =caseRec.Offering_Name__r.Name,case_origin__c =caserec.Origin));
        //US131502


        /*
       If the owner of the case is a queue 
          Then unassigned user would be the owner of the Task/Call back

         **/                         

        String caseOwner = caseRec.Ownerid;
        
        Map<id,String> BhrsMap = new Map<id,String>();
        for(BusinessHours bhRec:[select id,TimeZoneSidKey from BusinessHours])
        {
            BhrsMap.put(bhRec.id,bhRec.TimeZoneSidKey );
        }
              
        UtilityFalgs.callbackCreated=true;     
        
         //Added as part of Case Activity Flag Issue start
        try{
        Case_Portal_View__c portal_view = new Case_Portal_View__c();
        portal_view.Case__c=caseRec.Id;
        portal_view.Portal_View_Date__c=System.Now();
        database.insert(portal_view ,false);
        }catch(Exception e){
        system.debug('Exception is ----->'+e);
        }
        
        //Added as part of Case Activity Flag Issue end 
        
        //Added as Part of Support Offerings to populate topsproduct code on Case comment.
        if(caseRec.Offering_Tops_Product_Code_Selected__c<>null){
            CaseComment case_comment = new CaseComment();
            case_comment.CommentBody = 'Originally selected Entitled Product = '+caseRec.Offering_Tops_Product_Code_Selected__c;
            case_comment.ParentId = caseRec.Id;
            insert case_comment;           
        }
        
        if(caseRec.Offering_Code_Configuration_Issue__c && caseRec.Offering_Code_Ref__c<>null && caseRec.Offering_Name__c==null){
            String supportEngineer=caseRec.Offering_Support_Engineer__c;
            String dseMessage=''; 
            if(supportEngineer==null){
                supportEngineer='';
                dseMessage='';
            }
            else if(supportEngineer<>null){
                dseMessage='Please assign this Case to '+ supportEngineer;
            }
            CaseComment case_comment = new CaseComment();
            case_comment.CommentBody = 'The Site/Product for this Case is configured to have a Services Offering, but the definition for this offering is missing from Service Cloud. Please contact the System Administrator.Offering Code: '+ caseRec.Offering_Code_Ref__c+'\n'+dseMessage; 
            case_comment.ParentId = caseRec.Id;
            insert case_comment; 
            Case newC=new Case(Id=caseRec.Id);
            newC.Offering_Code_Ref__c='';
            newC.Offering_Support_Engineer__c='';  
            update newC;
        }   
        //End of Aditya-Support Offering Code

        //Changes related to ESS PLUS
        if(caseRec.Offering_Name__c!= null){
              UtilityFalgs.createWRTasks = true;
        }
    }
    public void afterUpdate(SObject oldSo, SObject so)
    {
        System.debug('In CaseHandler,afterUpdate()');
        Case caseRec = (Case)so;
        Case oldCaseRec = (Case)oldSo;
        String pmfKey;   
        String NextAction=caseRec.Next_Action__c;

        if(usrPMFkeyMap.get(caseRec.LastmodifiedbyID) != null && usrPMFkeyMap.get(caseRec.LastmodifiedbyID).PMFKey__c!= null)
            pmfKey = usrPMFkeyMap.get(caseRec.LastmodifiedbyID).PMFKey__c;
        else
            pmfKey = Userinfo.getName();

        DateTime dueDate=null;
        DateTime prevDueDate=null;  
        if(caseRec.Next_Action_Due_Date__c!=null)
            dueDate = caseRec.Next_Action_Due_Date__c;     

        if(oldCaseRec.Next_Action_Due_Date__c!=null)
            prevDueDate = oldCaseRec.Next_Action_Due_Date__c;     

        caseGSSMap = CaseGateway.caseGSSMap;
        caseStageGSSMap = CaseGateway.caseStageGSSMap; //US108116
        System.debug('In after Updated, initial caseStageGSSMap:'+caseStageGSSMap);
        System.debug('In after Updated, initial caseGSSMap:'+caseGSSMap);

        String lastModId = caseRec.LastModifiedById;

           //if(!UtilityFalgs.callbackCreated && ((oldCaseRec.Status!=caseRec.Status && oldCaseRec.Status=='Closed')|| (caseRec.Status!='Closed' && 
           // userinfo.getProfileId().substring(0,15)==label.Service_cloud_external_user_profile))){ 
         if(!UtilityFalgs.callbackCreated && !UtilityFalgs.isDefectUpdate && ((oldCaseRec.Status!=caseRec.Status && oldCaseRec.Status=='Closed')|| (caseRec.Status!='Closed' && CaseGateway.isExternalUser() == true))){ 
              UtilityFalgs.bCaseSLOFlag=false;
               
             Task taskRec = new Task(RecordTypeId=label.Service_cloud_Task_Record_Type,Subject=UtilityFalgs.callbackSubject,Source__c=UtilityFalgs.callbackSource,Status='Open',Priority='Low',WhatId=caseRec.id,Type='Callback');            
             
            // if owner is queue assign task to unassigned user.           
            String caseOwner = caseRec.Ownerid; 
            if(caseOwner.substring(0, 3)!='005')
                taskRec.OwnerId=label.Service_cloud_Task_assignee;
            else
                taskRec.OwnerId=caseRec.Ownerid;                                      

            taskLst.add(taskRec); 
            UtilityFalgs.callbackCreated=True;             

        }



        //US108116 - Starts
            System.debug('***oldCaseRec.Troubleshooting_Stage__c:'+oldCaseRec.Troubleshooting_Stage__c);
            System.debug('***caseRec.Troubleshooting_Stage__c:'+caseRec.Troubleshooting_Stage__c);
            GSS_Transactions__c gssRecToInsert ;
            GSS_Transactions__c gssRecToUpdate;
            if(oldCaseRec.Troubleshooting_Stage__c != caseRec.Troubleshooting_Stage__c){
                     
                     System.debug('***caseStageGSSMap.size():'+caseStageGSSMap.size());
                     System.debug('***caseStageGSSMap:'+caseStageGSSMap);
                     
                     Decimal prevStageCount ;
                     Decimal stageCount;
                    //if(caseStageGSSMap != null && caseStageGSSMap.size()>0){
                        //calculate the stage count value for new record to be inserted.

                        //update the existing gss record.
                            System.debug('***get--:'+caseStageGSSMap.get(caseRec.id +'-'+oldCaseRec.Troubleshooting_Stage__c));
                            gssRecToUpdate = caseStageGSSMap.get(caseRec.id +'-'+oldCaseRec.Troubleshooting_Stage__c);
                            if(gssRecToUpdate!=null){
                                gssRecToUpdate.Current_Stage_End_Date__c = DateTime.now();
                                //gssRecToUpdate.Status_From__c = caseRec.Troubleshooting_Stage__c;
                                //Added below fields for Timeboxing
                                gssRecToUpdate.Threshold_Start_time__c = oldCaseRec.Threshold_Start_Date_Time__c;
                                gssRecToUpdate.Threshold_Target_Date_time__c = oldCaseRec.Threshold_Target_Date_time__c;
                                gssRecToUpdate.Threshold_Time_Exceeded_Flag__c = oldCaseRec.Threshold_Exceeded_Flag__c;
                                gssRecToUpdate.Threshold_Notification_Start_Date_Time__c = oldCaseRec.Notification_Start_Date_Time__c; 
                                gssRecToUpdate.Threshold_Notification_End_Date_Time__c = oldCaseRec.Notification_Target_Date_Time__c;
                                gssRecToUpdate.Threshold_Notification_Flag__c = oldCaseRec.Notification_Exceeded_Flag__c;
                                gssRecToUpdate.Threshold_End_Time__c = DateTime.now();  //Update the stage end time
                                gssRecToUpdate.Manager_Action__c = oldCaseRec.Manager_Action__c;
                                gssRecToUpdate.Manager_Action_Comment__c=oldCaseRec.Manager_Action_Comment__c;
                                gssRecToUpdate.Manager_Action_Comment_Update_Date_Time__c = oldCaseRec.Manager_Action_Comment_Update_Date_Time__c;
                                gssRecToUpdate.Manager_Action_Update_By__c = oldCaseRec.Manager_Action_Update_By__c;
                                gssRecToUpdate.Manager_Action_Update_Date_Time__c=oldCaseRec.Manager_Action_Update_Date_Time__c;
                                gssRecToUpdate.Manager_Action_Comment_By__c= oldCaseRec.Manager_Action_Comment_By__c;                                
                            }
                            
                            //fecth the stage count of previous GSS TRansaction for the same case with new Stage value
                            GSS_Transactions__c gssTrObj = caseStageGSSMap.get(caseRec.id +'-'+caseRec.Troubleshooting_Stage__c);
                            //System.debug('***gssTrObj:'+gssTrObj);
                            if(gssTrObj!=null){                                
                                stageCount = gssTrObj.Stage_Count__c +1;
                            }
                            else{
                                stageCount =1;
                            }
                        //insert a new GSS record
                        if(gssRecToUpdate!=null){
                            
                           /* gssRecToInsert =  new GSS_Transactions__c (Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
                                                                       Current_Status_Date__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
                                                                       Current_Status_Added_By__c = pmfKey,Current_Status__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c = stageCount ,
                                                                       Status_From__c = oldCaseRec.Troubleshooting_Stage__c,Previous_GSS_TR__c = gssRecToUpdate.Current_GSS_TR__c ,
                                                                       Previous_GSS_TR_Date__c = gssRecToUpdate.Current_GSS_TR_Date__c);*/
                            //Commented above and added below for US131502
                             gssRecToInsert =  new GSS_Transactions__c (Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
                                                                       Date_Current_Troubleshooting_Stage_set__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
                                                                       Current_Status_Added_By__c = pmfKey,Current_Troubleshooting_Stage__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c = stageCount ,
                                                                       Previous_Troubleshooting_Stage__c = oldCaseRec.Troubleshooting_Stage__c,Previous_GSS_TR__c = gssRecToUpdate.Current_GSS_TR__c ,
                                                                       Previous_GSS_TR_Date__c = gssRecToUpdate.Current_GSS_TR_Date__c,Current_Status__c = caseRec.Status,Status_From__c=oldCaseRec.Status,
                                                                       CA_product__c = caseRec.Product__c, offering_name__c =caseRec.Offering_Name__r.Name,case_origin__c =caserec.Origin);
                                                                        

                        }else {
                           /* gssRecToInsert =  new GSS_Transactions__c (Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
                                                                       Current_Status_Date__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
                                                                       Current_Status_Added_By__c = pmfKey,Current_Status__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c = stageCount ,
                                                                       Status_From__c = oldCaseRec.Troubleshooting_Stage__c,Previous_GSS_TR__c = UtilityFalgs.stageGSSTransCode.get(oldCaseRec.Troubleshooting_Stage__c )
                                                                      );*/
                            //Commented above and added below for US131502
                             gssRecToInsert =  new GSS_Transactions__c (Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
                                                                       Date_Current_Troubleshooting_Stage_set__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
                                                                       Current_Status_Added_By__c = pmfKey,Current_Troubleshooting_Stage__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c = stageCount ,
                                                                       Previous_Troubleshooting_Stage__c = oldCaseRec.Troubleshooting_Stage__c,
                                                                       Previous_GSS_TR__c = UtilityFalgs.stageGSSTransCode.get(oldCaseRec.Troubleshooting_Stage__c),Current_Status__c = caseRec.Status,
                                                                       Status_From__c=oldCaseRec.Status,CA_product__c = caseRec.Product__c, offering_name__c =caseRec.Offering_Name__r.Name,case_origin__c =caserec.Origin
                                                                      );
                        }
                        //US131502
                        if((caseRec.Status=='Open' || caseRec.Status=='Verify') && (caseRec.Calculated_Status_Transfer_In_Count__c > 0 && caseRec.Is_Task_Closed__c == false ))
                            gssRecToInsert.Current_Status__c = 'Transferred';

                       //}
                    /*   //****MANAR08
                    else{
                        gssRecToInsert = new GSS_Transactions__c (Case__c=caseRec.id,Current_GSS_TR__c=UtilityFalgs.stageGSSTransCode.get(caseRec.Troubleshooting_Stage__c),
                                                                       Current_Status_Date__c=DateTime.now(),Current_GSS_TR_Date__c=DateTime.now(),Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,
                                                                       Current_Status_Added_By__c = pmfKey,Current_Status__c = caseRec.Troubleshooting_Stage__c,Stage_Count__c = 1 ,
                                                                       Status_From__c = oldCaseRec.Troubleshooting_Stage__c,Previous_GSS_TR__c = UtilityFalgs.stageGSSTransCode.get(oldCaseRec.Troubleshooting_Stage__c                                                                                                                                                                                )
                                                                      );
                    }                        
                    //****MANAR08*/


                        if(!UtilityFalgs.createStageGSSTransactions)
                         {
                            if(gssRecToInsert!= null){         
                                System.debug('gssRecToInsert:'+gssRecToInsert);       
                                gssLst.add(gssRecToInsert);
                            }
                             if(gssRecToUpdate!= null){
                                System.debug('gssRecToUpdate:'+gssRecToUpdate);
                                gssLst.add(gssRecToUpdate);
                               // gssLstToUpdate.add(gssRecToUpdate); //US131502
                             }
                           UtilityFalgs.createStageGSSTransactions=true;
                         }    

            }
        //US108116 - ends



        /**
        When the case is re-assigned to a real user(case owner) from a Queue, All Initial Callbacks and Subsequent Callbacks will be re-assigned from “Unassigned” to the case owner.
        When case is reassigned to new owner, only initial callback will be transferred(transfer happens only when initial call back is open), but secondary callbacks still stay with previous owner which he has to close them out. 
         **/
           
        system.debug('caseTaks======'+CaseGateway.taskMap.get(caseRec.Id));
        if(oldCaseRec.ownerid!=caseRec.ownerid || (caseRec.Status=='Closed' && oldCaseRec.Status!=caseRec.Status) ){
            List<Task> caseTaks = CaseGateway.taskMap.get(caseRec.Id);
            String caseOwner = caseRec.Ownerid; 
            if(caseTaks!=null && !caseTaks.isEmpty()){            
                for(Task rec:caseTaks){
                    
                    if(caseRec.Status=='Closed' && oldCaseRec.Status!=caseRec.Status) 
                        taskLst.add(new Task(id= rec.Id,Status='Closed'));                       
                    else if(oldCaseRec.ownerid!=caseRec.ownerid && rec.OwnerId==label.Service_cloud_Task_assignee && rec.RecordTypeId==label.Service_Cloud_Task_Record_Type){
                        if(caseOwner.substring(0, 3)!='005')
                            taskLst.add(new Task(id= rec.Id,Ownerid=label.Service_cloud_Task_assignee));
                        else if(rec.ownerId==label.Service_cloud_Task_assignee)
                            taskLst.add(new Task(id= rec.Id,Ownerid=caseRec.Ownerid));
                        else if(rec.Type=='Initial Callback' || rec.Type=='Workaround' || rec.Type=='Resolution' ) 
                            taskLst.add(new Task(id= rec.Id,Ownerid=caseRec.Ownerid));
                    }                         
                }
            }
        }
        
         //updated condition to look for next action due date also - VELUD01 - 30-01-2015 - 300-208365
            if(oldCaseRec.status!=caseRec.Status ||oldCaseRec.Next_Action__c!=caseRec.Next_Action__c||oldCaseRec.Next_Action_Due_Date__c!=caseRec.Next_Action_Due_Date__c){
                GSS_Transactions__c gssRec =null ;
                System.debug('*******offering_name__c:'+caseRec.Offering_Name__r.Name);
                System.debug('*******offering_name__c Id:'+caseRec.Offering_Name__c);
                 if(caseGSSMap!=null && caseGSSMap.size()>0 ){        
                     gssRec = new GSS_Transactions__c(Case__c=caseRec.id,Previous_GSS_TR__c=caseGssMap.get(caseRec.id).Current_GSS_TR__c,Current_Next_Action__c=caseRec.Next_Action__c,Current_Status__c=caseRec.Status,
                                                      Current_Status_Added_By__c=pmfKey,Current_Next_Action_Date__c=caseRec.Next_Action_Date__c,Current_Status_Date__c=DateTime.now(),Prev_Next_Action_Date__c=oldCaseRec.Next_Action_Date__c,
                                                      Status_From_Date__c=caseGssMap.get(caseRec.id).Current_Status_Date__c,Prev_Next_Action_By__c=caseGssMap.get(caseRec.id).Curr_Next_Action_By__c,Curr_Next_Action_By__c=pmfKey,
                                                      Previous_Status_Added_By__c=caseGssMap.get(caseRec.id).Current_Status_Added_By__c,Previous_Next_Action__c=oldCaseRec.Next_Action__c,Status_From__c=oldCaseRec.Status,
                                                      Current_Next_Action_Due_Date__c=dueDate,Prev_Next_Action_Due_Date__c=prevDueDate,Current_GSS_TR_Date__c=DateTime.now(),Previous_GSS_TR_Date__c=caseGssMap.get(caseRec.id).Current_GSS_TR_Date__c, 
                                                      ReOpen_Date__c = caseRec.Date_Time_ReOpened__c!=null ? caseRec.Date_Time_ReOpened__c :caseRec.CreatedDate,Current_Troubleshooting_Stage__c = caseRec.Troubleshooting_Stage__c,
                                                      Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,CA_product__c = caseRec.Product__c, offering_name__c =caseRec.Offering_Name__r.Name,case_origin__c =caserec.Origin);
                 }
                  else{                                       
                     gssRec = new GSS_Transactions__c(Case__c=caseRec.id,Previous_GSS_TR__c= '',Current_Next_Action__c=caseRec.Next_Action__c,Current_Status__c=caseRec.Status,Current_Status_Added_By__c=pmfKey,Current_Next_Action_Date__c=caseRec.Next_Action_Date__c,
                                                      Current_Status_Date__c=system.now(),Prev_Next_Action_Date__c=oldCaseRec.Next_Action_Date__c,Status_From_Date__c= null ,Prev_Next_Action_By__c= '' ,Curr_Next_Action_By__c=pmfKey,Previous_Status_Added_By__c= '',
                                                      Previous_Next_Action__c=oldCaseRec.Next_Action__c,Status_From__c=oldCaseRec.Status,Current_Next_Action_Due_Date__c=dueDate,Prev_Next_Action_Due_Date__c=prevDueDate,Current_GSS_TR_Date__c=system.now(),
                                                      Previous_GSS_TR_Date__c= null,ReOpen_Date__c = caseRec.Date_Time_ReOpened__c!=null ? caseRec.Date_Time_ReOpened__c :caseRec.CreatedDate,Current_Troubleshooting_Stage__c = caseRec.Troubleshooting_Stage__c,
                                                      Case_Owner__c=caseRec.OwnerID,Case_Severity__c=caseRec.Severity__c,CA_product__c = caseRec.Product__c, offering_name__c =caseRec.Offering_Name__r.Name,case_origin__c =caserec.Origin);                                    
                 }

                otherSupportTypeTaskMap = CaseGateway.otherSupportTypeTaskMap;
                List<Task> otherSupportTaskList = new List<Task>();     
                Boolean taskOpen = false;
                Boolean caseHasTask = false;
                if(otherSupportTypeTaskMap!=null && otherSupportTypeTaskMap.containskey(caseRec.Id)){
                    caseHasTask = true;
                    otherSupportTaskList = otherSupportTypeTaskMap.get(caseRec.Id);
                    if(otherSupportTaskList!=null && otherSupportTaskList.Size()>0){
                        for(Task recTask :otherSupportTaskList){
                            if(recTask.Status !='Closed'){
                                taskOpen = true;
                                break;
                            }
                        }
                    }
                }
                //adding logic to set calculated status on GSS Current_Status__c field
                if((caseRec.Status=='Open' || caseRec.Status=='Verify') && caseHasTask && taskOpen){
                    gssRec.Current_Status__c = 'Transferred';               
                }
                else if(caseRec.Status=='Verify' && caseHasTask && !taskOpen){
                    gssRec.Current_Status__c = 'Pending'; 
                }
                else if(caseRec.Status=='Open' && caseHasTask && !taskOpen){
                    gssRec.Current_Status__c = 'Open'; 
                }
                else if(caseRec.Status=='Open' && !caseHasTask){
                    gssRec.Current_Status__c = 'Open'; 
                }
                else if(caseRec.Status=='Verify' && !caseHasTask){
                    gssRec.Current_Status__c = 'Verify'; 
                }
                else if(caseRec.Status=='Closed'){
                    gssRec.Current_Status__c = 'Closed'; 
                   
                }
                if(oldCaseRec.status!=caseRec.Status){
                     if(caseRec.Status=='Open'){
                        if(oldCaseRec.status == 'Closed' && (caseRec.Reopen_Count__c-oldcaseRec.Reopen_Count__c==0) ){
                            gssRec.Current_GSS_TR__c='R';  // when case status changes from closed to open for any number of times 
                        }
                        else if(oldCaseRec.status=='Verify'){
                            if(caseRec.Reopen_count_from_verify__c==0){
                                gssRec.Current_GSS_TR__c='R3'; //when case status changed from verify to open for first time 
                            }
                            else if(caseRec.Reopen_count_from_verify__c>=1 &&(caseRec.Reopen_count_from_verify__c-oldcaseRec.Reopen_count_from_verify__c==0 )){
                                gssRec.Current_GSS_TR__c='R4'; //when case status changed from verify to open for more than once
                            }

                        }
                    }
                    else if( caseRec.Status=='Closed' ){
                        if( caseRec.Close_Count__c==1){
                            gssRec.Current_GSS_TR__c='S1'; //when case was closed for first time 
                        }

                        else if( caseRec.Close_Count__c>1){
                            gssRec.Current_GSS_TR__c='S2'; //when case was closed for more than once
                        }
                    }

                    else if(caseRec.Status=='Verify'){
                        if(caseRec.Verify_Count__c==1){
                            gssRec.Current_GSS_TR__c='S3'; //when case status changed to verify for first time
                        }
                        else if(caseRec.Verify_Count__c>1){
                            gssRec.Current_GSS_TR__c='S4'; //when case status changed to verify more than once
                        }
                    }
                 
                }
                else if(oldCaseRec.Next_Action__c!=caseRec.Next_Action__c || oldCaseRec.Next_Action_Due_Date__c!=caseRec.Next_Action_Due_Date__c){
                    gssRec.Current_GSS_TR__c = gssRec.Previous_GSS_TR__c ; // For Next Action and Next Action Due Date change previous TR code is copied over --due date change added for 300-308265 
                }

                //Updated code to restrict the GSS transactions created to only 1 by adding createGSS flag. - VELUD01 - CR#400-1275
                if(!UtilityFalgs.createGSS && gssRec.Current_GSS_TR__c!=null)
                 {
                   gssLst.add(gssRec);
                   UtilityFalgs.createGSS=true;
                 }  
            }
         //this block is to do a fake update on parent case to get the latest modification details
         if(caserec.parentid!=null && UtilityFalgs.relatedcaseFlag)
       {
           UtilityFalgs.relatedcaseFlag=false;
        system.debug('No of SOQL' +limits.getQueries() );
        Case parentrec=[select id from Case where id = :caserec.parentid];
          if(parentrec!=null)
          {
            try
            {
                update parentrec;
            }
            catch(Exception ex)
            {
                String msg=ex.getMessage();
                if(ex.getMessage().contains('VALIDATION_EXCEPTION'))
                    msg=msg.substring(10+msg.indexof('EXCEPTION,'),msg.indexof(': ['));
                if(!Trigger.isDelete)
                    Trigger.new[0].addError(msg+' on Parent Case');
                else
                    Trigger.old[0].addError(msg+' on Parent Case');
            }
          }    

       }
        
    }
    public void afterDelete(SObject so)
    {

    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        /*if(gssLst.size()>0)
            database.insert(gssLst,false);*/
        //US108116  - commented above lines and added below. - made insert to upsert
         if(gssLst.size()>0){
            System.debug('*** In finally , gssLst:'+gssLst);
            database.upsert(gssLst,false);
         }             // -- commented for //US131502

        //US131502
      /*  if(gssLstToUpdate.size()>0)
                database.update(gssLstToUpdate,false);*/
/*         if(gssLst.size()>0)
            database.insert(gssLst,false);*/

        if(taskLst.size()>0)
        {
            system.debug('taskLst=========='+taskLst);
             upsert taskLst;
        }
        portalViewList = CaseGateway.casePortalViewList ;
        if(portalViewList!=null && portalViewList.Size()>0){
            database.insert(portalViewList,false);
        }         

    }
}