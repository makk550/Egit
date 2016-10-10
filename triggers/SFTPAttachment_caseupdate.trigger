trigger SFTPAttachment_caseupdate on SFTP_File_Attachments__c (Before insert, Before update,after insert, after update, before delete) {

    set<String> CaNumSet=new set<String>();
    List<Case> CaseList=new List<Case>(); 
    Map<String,id> caseNumMap = new Map<String,id>();
    

    if(Trigger.isBefore&&(trigger.isupdate || trigger.isinsert))
       {
            for(SFTP_File_Attachments__c recSFTP: Trigger.new)
            {
              
                if(recSFTP.Case_Number__c!=null && recSFTP.Case__c==null)
                {
                    CaNumSet.add(recSFTP.Case_Number__c);
                    
                }
            }
            
            
                caseList=[select id,CaseNumber from case where CaseNumber in :CaNumSet];
                   if(caseList!=null && caseList.size()>0)
                    {
                        for(Case caseRec:caseList)
                        caseNumMap.put(caseRec.CaseNumber,caseRec.id);
                    }
            
            if(caseNumMap!=null)
            {
                for(SFTP_File_Attachments__c recSFTP: Trigger.new)
                  {
                  
                    if(recSFTP.Case_Number__c!=null && recSFTP.Case__c==null)
                      recSFTP.Case__c=caseNumMap.get(recSFTP.Case_Number__c);
                
                    }
            }
    }

    if((Trigger.isAfter && (trigger.isupdate || trigger.isinsert))||(trigger.isbefore && trigger.isDelete))
    {
       
             UtilityFalgs.callbackSubject='File'; 
             UtilityFalgs.callbackSource='File Attachment';
          if(Trigger.isdelete&&trigger.isbefore)
          {
                 for(SFTP_File_Attachments__c recSFTP: Trigger.old)
              {
                
                CaNumSet.add(recSFTP.Case__c);
             }
            
          }
          else
          {
                for(SFTP_File_Attachments__c recSFTP: Trigger.new)
                    {
                      CaNumSet.add(recSFTP.Case__c);
                    }
          }
            if(CaNumSet.size()>0&&CaNumSet!=null)
            caseList=[select id from case where id in :CaNumSet];
            Set<id>caseIdSet = new Set<id>();
            for(Case caseRec: caseList){
            	caseIdSet.add(caseRec.Id);
            }
            List<task> callbackList = [select Id , whatId from Task where subject ='File' and whatId IN :caseList ];
            Integer i = 0;
            for(Task callbackFile :callbackList ){
            	
            	if(caseList!=null && caseIdSet.contains(callbackFile.whatId)){
            		caseIdSet.remove(callbackFile.whatId);
            	}
            	i++;
            }
           List<case>updateCaseList = new List<Case>();
            for(Case caseRec: caseList){
            	if(caseIdSet.contains(caseRec.Id)){
            		updateCaseList.add(caseRec);
            	}
            }
            
           if(updateCaseList!=null && updateCaseList.size()>0)
           {
             if((userinfo.getProfileId().substring(0,15)!=label.EAI_Integration_NON_SSO_Profile)&& (!UtilityFalgs.sentAlert))
            { //Commented to test as part of SPIKE:US118509
             //UtilityFalgs.sendMail(caseList);
             //UtilityFalgs.sentAlert=true;
            } 
            try
            {
                update updateCaseList;
            }
            catch(Exception ex)
            {
                String msg=ex.getMessage();
                if(ex.getMessage().contains('VALIDATION_EXCEPTION'))
                    msg=msg.substring(10+msg.indexof('EXCEPTION,'),msg.indexof(': ['));
                if(!Trigger.isDelete)
                    Trigger.new[0].addError(msg+' on Case');
                else
                    Trigger.old[0].addError(msg+' on Case');
            }
           }
            
    }
 
}