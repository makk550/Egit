trigger bu_ValidateTrialRequest on Trial_Request__c (before update) {
         //User usr= [select Id from user where Id='005f00000019tb9'];
    for(Trial_Request__c req:Trigger.new){
        if(Trigger.old!=null){
            string strStatus = req.Request_Status__c;
            string strOldStatus = Trigger.old[0].Request_Status__c;
            if(strOldStatus!='New' && strStatus=='New' && strStatus == 'On Hold' ){
                req.Request_Status__c.addError('Cannot reset status to New, after the requested status has been changed.');
            }
        }
        if(req.Request_Status__c == 'Extension Approved' || req.Request_Status__c == 'Request Approved' || req.Request_Status__c == 'DDR Request Approved' || req.Request_Status__c == 'On Hold' )
        {
            req.ownerID = req.CreatedById;
        }
       
 /*      //Esclation Manager. need to optimize
        if(req.Request_Status__c == 'Request for Approval')
        {
          List<POC_Escalation_Matrix__c> lstEscMatrix = [select POC_Escalation_Manager__c from POC_Escalation_Matrix__c where Area1__c = :req.Acc_Area__c  and Business_Unit__c =:req.Business_Unit__c  and  Region__c =:req.Acc_Region__c];          
          if(lstEscMatrix != null && lstEscMatrix.size() > 0)
             if(lstEscMatrix[0].POC_Escalation_Manager__c != null)
                req.POC_Escalation_Manager__c = lstEscMatrix[0].POC_Escalation_Manager__c;                   
        }           
   */
           //Esclation Manager. need to optimize
           //(Trigger.old[0].Request_Status__c != Trigger.new[0].Request_Status__c) 
           // 
        if((Trigger.old[0].OwnerId != Trigger.new[0].OwnerId) && (req.Request_Status__c == 'Request for Approval' || req.Request_Status__c == 'Extension for Approval'))
        {           
           List<POC_Escalation_Matrix__c> lstEscMatrix = [select POC_Escalation_Manager__c,POC_Approver_Email__c from POC_Escalation_Matrix__c where Area1__c = :req.Acc_Area__c  and Business_Unit__c =:req.Business_Unit__c  and  Region__c =:req.Acc_Region__c];     
   
           if(lstEscMatrix != null && lstEscMatrix.size() > 0)
           {    
             if(lstEscMatrix[0].POC_Escalation_Manager__c != null)                
                 req.POC_Escalation_Manager__c = lstEscMatrix[0].POC_Escalation_Manager__c;                                                
              
             if(lstEscMatrix[0].POC_Approver_Email__c != null)
             {      

                    String strRecipients = lstEscMatrix[0].POC_Approver_Email__c;          
                    String[] ArrstrRecipients = strRecipients.split(',');                        
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setWhatId(req.Id);
                    if(req.Request_Status__c == 'Request for Approval' && req.StdLicAgr__c == true)
                       email.setTemplateId(Label.POC_Approval_Email_Template);
                    else if(req.Request_Status__c == 'Request for Approval' && req.StdLicAgr__c == false)
                        email.setTemplateId(Label.POC_Approval_Email_Template);
                    else
                       email.setTemplateId(Label.POC_Extension_Email_Template);
                    email.setToAddresses(ArrstrRecipients);
                    //email.setCCAddresses(new String[]{'GlobalPOCTeam@ca.com'});
                    
                    email.setTargetObjectId(Label.POC_GlobalPOCTeam);
                    system.debug('***');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
             }
             else
             {
                req.addError('ERROR MESSAGE:The GPOC Request for Approval email could not be triggered. Please contact GlobalPOCTeam@ca.com to identify the correct  Business Unit Presales Management contact for the GEO and Operating Area.');
             }
        }   
        }
    
    }
}