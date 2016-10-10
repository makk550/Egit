trigger CaseCommentTrigger on CaseComment (Before insert, Before update,After update,After insert,Before delete){
  //log.startTrigger('CaseCommentTrigger');

  //Commented the bypass code as we dont have initial case load - velud01 - dec 2,2014
//    if(Label.Integration_UserProfileIds.contains(userinfo.getProfileId().substring(0,15)))
  //     return;
    Profile p = [select name from Profile where id =:UserInfo.getProfileId()];
    String pname=p.name;
                 
    Set<Id> caseSet=new Set<Id>();
    List<Case> caseList = new List<Case>();  
    set<Id>privateCommentCaseSet = new set<Id>();
    if(Trigger.isDelete){          
          for(CaseComment cc:Trigger.old){
              if(!(pname.contains('Integration') || pname.contains('Admin'))) {
                cc.addError('You are not allowed to delete the record. Please contact System Administrator.');
              }
              if(cc.isPublished){
                 caseSet.add(cc.parentId);    
             }
             else{
             	privateCommentCaseSet.add(cc.parentId);
             }
          }
    }
    else if((Trigger.isBefore && (trigger.isupdate || trigger.isinsert))){
          System.debug('recCasComm :'+Trigger.new);
            for(CaseComment recCasComm: Trigger.new){
                if(trigger.isupdate  && !(pname.contains('Integration') || pname.contains('Admin'))
                  && ((Trigger.oldMap.get(recCasComm.id).CommentBody)!=(recCasComm.CommentBody)))
                   {
                   recCasComm.addError('You are not allowed to Edit the comment body. Please contact your System Administrator.');
                }
                System.debug('ispublished:'+recCasComm.ispublished);
                if(recCasComm.ispublished){            
                    caseSet.add(recCasComm.parentId);
                }
                else{
             	    privateCommentCaseSet.add(recCasComm.parentId);
                }
                
                System.debug('userinfo.getProfileId().substring(0,15)-->'+userinfo.getProfileId().substring(0,15));
                System.debug('label.Service_cloud_external_user_profile-->'+label.Service_cloud_external_user_profile);
                
                //if(userinfo.getProfileId().substring(0,15)==label.Service_cloud_external_user_profile){
                  if (CaseGateway.isExternalUser()) {
                    if(recCasComm.CommentBody.contains(label.Email2Case_subject)){
                        recCasComm.CommentBody = recCasComm.CommentBody.replace(label.Email2Case_subject,'');
                        recCasComm.CommentBody += '<sent via email>' ;
                        UtilityFalgs.callbackSubject='Email';
                        UtilityFalgs.callbackSource='Email';
                     }   
                    else{ 
                        UtilityFalgs.callbackSubject='Case Update';
                        UtilityFalgs.callbackSource='CSO';
                    }
                }
                
             }
        }else if(Trigger.isAfter && Trigger.isInsert){
            for(CaseComment recCasComm: Trigger.new){
                Task taskRec = new Task(RecordTypeId=label.Service_cloud_Task_Record_Type,Subject=UtilityFalgs.callbackSubject,Source__c=UtilityFalgs.callbackSource,Status='Open',Priority='Low',WhatId=recCasComm.ParentId,Type='Callback');  
            }          
        }
      
      System.debug('1caseSet:'+caseSet);
      if(caseSet!=null || privateCommentCaseSet!=null){
      	 caseSet.addAll(privateCommentCaseSet);  
         System.debug('2caseSet:'+caseSet);
         caseList=[select id,Subject from case where id in :caseSet];        
      }    
      if(caseList!=null && caseList.size()>0)
      {
            System.debug('userinfo.getProfileId().substring(0,15)-->'+userinfo.getProfileId().substring(0,15));
            System.debug('label.EAI_Integration_NON_SSO_Profile-->'+label.EAI_Integration_NON_SSO_Profile);
          
            if((userinfo.getProfileId().substring(0,15)!=label.EAI_Integration_NON_SSO_Profile)&& (!UtilityFalgs.sentAlert))
            {
              //commented as part of SPIKE US118509	  
             //UtilityFalgs.sendMail(caseList);
             //UtilityFalgs.sentAlert=true;
             //UtilityFalgs.sendMailCaseComments(caseList);

            }
              for(Integer i = 0 ;i<caseList.Size() ;i++){
              	  if(privateCommentCaseSet.contains(caseList[i].Id)){
              	  	caseList.remove(i);
              	  }
              }
              Database.SaveResult[] results = Database.Update(caseList, false);
              for(Integer i=0;i<results.size();i++){
                 if (!results.get(i).isSuccess()){
                     String errorMsg = results.get(i).getErrors().get(0).getMessage();
                     if(!Trigger.isDelete)
                       Trigger.new[0].addError(errorMsg);
                    else
                       Trigger.old[0].addError(errorMsg);                    
                 }
              
              }
              
      }        
    

}