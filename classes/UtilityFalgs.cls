public class UtilityFalgs
{
    
     public static boolean bCaseAssignedFlag=true;
    public static boolean bCaseClosedFlag=true;
    public static boolean bCaseTransferredFlag=true;
    public static boolean bCaseReOpenedFlag=true;
    public static boolean bCaseSLOFlag=true;
    public static boolean callbackCreated=false;
    Public static boolean relatedcaseFlag=true;
    public static string  callbackSubject='Call';
    public static string  callbackSource='Phone';
    public static boolean createGSS=false;
    public static boolean sentAlert=false;
    public static boolean updateTask = false;
    public static boolean updateExternalRequest = false;
    public static boolean isDefectUpdate = false;
    public static boolean createWRTasks = false; // flag to track creation of workaround and resolution tasks
    public static boolean isCaseReopend = false; // flag to check if reopen scenario is executed  US133511
    //US134926
    public static boolean isInitialCallBackTaskCreated;
    //US138062
    public static boolean isQueueJumpingEnabled=false;
    //***US108116 - Lifecycle: Troubleshooting Stage Reporting
    public static boolean createStageGSSTransactions=false; 
    public static boolean isSEActionTaskCreated = false; //Timeboxing
    public static boolean clearManagerActionValues = false; //Timeboxing
    public static boolean xmatteralert = false; //xmatter by suresh
    public static Map<String,String> stageGSSTransCode = new Map<String,String>{'1. Problem Identification'=>'LC1',
                                                                  '2. Knowledge Search'=>'LC2',
                                                                  '3. Cause Determination'=>'LC3',
                                                                  '4. Solution Identification'=>'LC4',
                                                                  '5. Solution Provided'=>'LC5',
                                                                  '6. Solution Deferred'=>'LC6',
                                                                  '7. Closed'=>'LC7'};

    
    public static void sendMail(LIST<Case> caseId)
    {
       List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();
       String user_info=UserInfo.getUserid();
       Map<Id,User> toUser;
       List<Id> emailId=new List<Id>();
       List<Case> casedet=new List<Case>([select id,OwnerId,caseNumber,site_id__c,site_name__c,Severity__c,Subject from Case where id in :caseId]);
        if(casedet!=null && casedet.size()>0)
        {
         for(Case caseRec:casedet)
         {   
           String body='A case for which you are an owner or Case Team Member has been updated.<br/><br/>';
           body += 'Case : '+caseRec.CaseNumber  +'<br/>' ;
           body += 'Tops Site ID : '+caseRec.Site_Id__c  +'<br/>';
           body += 'Site Association : '+caseRec.site_name__c+'<br/>';
           body += 'Severity : '+caseRec.Severity__c  +'<br/>';
           body += 'Subject : '+caseRec.Subject +'<br/>';
           body += 'Last Updated By : '+UserInfo.getName() +'<br/><br/><br/>';
           body += 'Thanks & Regards,<br/>' +
          'CA Support.';

      String owner=caseRec.OwnerId;
            List<CaseTeamMember> team=new List<CaseTeamMember>();
             if(!Test.isRunningTest())
             {  if( caseRec.OwnerId!=user_info && (!owner.startsWith('00G')))  
                    emailId.add(caseRec.OwnerId);
       
                team = [select Id,parentid,memberid from CaseTeamMember where ParentId =: caseRec.Id and  MemberId !=: user_info ];
             }
             else
             {
                  emailId.add(caseRec.OwnerId);
                 team = [select Id,parentid,memberid from CaseTeamMember ];
             }
              System.debug('size of team'+team.size()); 
            if(team!=null && team.size()>0)
            {
               
                for(CaseTeamMember memRec:team )
                {
                    if(memRec.MemberId!=user_info)
                        emailId.add(memRec.MemberId);
                }
            }
            if(emailId!=null)
             toUser=new Map<Id,User>([select id,email from User where id in :emailId]);
              
              for(User userRec : toUser.values())
              {
                Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                email.setSubject('SC Case :'+caseRec.caseNumber+' Updated');
                email.setHTMLBody(body);
                email.setSaveAsActivity(false);
                email.setTargetObjectId(UserRec.id);
                emails.add(email);
              }  
             
         }
         
        if(emails!=null)
        {
            Messaging.sendEmail(emails);
        } 
      }
    }
    
    public static void sendNotificationToAssgnUser(LIST<Case> caseList)
    {
       List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();
       String user_info=UserInfo.getUserid();
       Map<Id,User> toUser;
       List<Id> emailId=new List<Id>();

        if(caseList!=null && caseList.size()>0)
        {
         for(Case caseRec:caseList)
         {   
           String body='Case ' + caseRec.caseNumber + ' has been assigned to you. Please click on the link below to view the record.<br/><br/>';
           String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
           body = body + '<a href="' + urlCode + '/'+caseRec.Id + '">'+urlCode+ '/'+caseRec.Id +'</a>';

            String owner=caseRec.OwnerId;
            List<CaseTeamMember> team=new List<CaseTeamMember>();
             if(!Test.isRunningTest())
             {
                 if( caseRec.OwnerId!=user_info && (!owner.startsWith('00G')))  
                 {
                     emailId.add(caseRec.OwnerId);
                 }
             }
             else
             {
                emailId.add(caseRec.OwnerId);
             }

            if(emailId!=null)
            {
                toUser=new Map<Id,User>([select id,email from User where id in :emailId]);
            }
              
            for(User userRec : toUser.values())
            {
                Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                email.setSubject('Case : '+caseRec.caseNumber+' assigned to you.');
                email.setHTMLBody(body);
                email.setSaveAsActivity(false);
                email.setTargetObjectId(UserRec.id);
                emails.add(email);
            }  
             
         }
         
        if(emails!=null)
        {
            Messaging.sendEmail(emails);
        } 
      }
    }  
    
    //US78177 - Usability: In email notifications, include the Case Comment that was added to the case
    @InvocableMethod
    public static void sendEmailNotifications(List<CaseComment> caseCommentList){

      List<Id> caseIdList = new List<Id>();
      Map<Id,String> caseIdCommentTextMap = new Map<Id,String>();

      for(CaseComment caseCommentRec:caseCommentList){
          caseIdList.add(caseCommentRec.parentId);
          caseIdCommentTextMap.put(caseCommentRec.parentId,caseCommentRec.CommentBody); //TODO: check if multiple comments are added at a time.
      }

      if(caseIdList!= null && caseIdList.size()>0){
                      sendNotificationToCaseOwnerandTeamMemebers(caseIdList,caseIdCommentTextMap);
        }
      }
    
    public static void sendNotificationToCaseOwnerandTeamMemebers(List<Id> caseIdList,Map<Id,String> idTextMap){
              try{
                    List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();
                    List<Case> caseList = [select id,caseNumber,Site_Id__c,site_name__c,Severity__c,OwnerId,Subject,Confidential_Attachments__c from case where id = : caseIdList]; 
                    Map<Id,List<Id>> caseNotifyToUsersMap = UtilityFalgs.toUserList(caseList);
                    System.debug('caseNotifyToUsersMap:'+caseNotifyToUsersMap); 
                    String emailbody ='';
                     for(Case caseRec: caseList){
                                List<Id> userIdList = caseNotifyToUsersMap.get(caseRec.Id);
                                //DE199235 user story change
                                if(caseRec.Confidential_Attachments__c){
                                   userIdList.add(userInfo.getUserId()); 
                                }
                                system.debug('@@@@@@@'+userIdList);
                                if(userIdList!=null && userIdList.size()>0){
                                        for(Id userId: userIdList){
                                              emailbody = UtilityFalgs.emailBody(caseRec, idTextMap.get(caseRec.Id)); 
                                              System.debug('userId:'+userId+'\n Email body:'+emailbody);
                                              Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                                              email.setSubject(System.label.SCCase+' :'+caseRec.caseNumber+' '+System.label.Updated);
                                              //email.setPlainTextBody(emailbody);
                                              email.setHtmlBody(emailbody);
                                              email.setSaveAsActivity(false);
                                              email.setTargetObjectId(userId);
                                              emails.add(email);
                                        }
                                }
                      }
                      if(emails!=null)
                      {
                          system.debug('@@@$$$$'+emails);
                          System.debug('emails.size:'+emails.size());
                          Messaging.sendEmail(emails);
                      }   
              }
              catch(Exception e){
                  System.debug('Exception e:'+e.getStackTraceString());
              }

      }
    
    public static String emailbody(Case caseRec,String commentBody){
            System.debug('====='+commentBody);
            String body = System.label.CaseUpdated+' <br/><br/>';
         // body += '\n' +System.label.Case+' : '+caseRec.CaseNumber ;
            body += '\n' +System.label.Case+' : '+'<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseRec.id+'">'+caseRec.CaseNumber+'</a> <br/>' ;
            body += '\n' +System.label.TopsSiteID+' : '+String.valueOf(caseRec.Site_Id__c)+'<br/>' ; 
            body += '\n' +System.label.SiteAssociation+' : '+String.valueOf(caseRec.site_name__c) + '\t\n <br/>';
            body += System.label.Severity+' : '+String.valueOf(caseRec.Severity__c) + '\t\n <br/>'; 
            body += System.label.Subject+' : '+String.valueOf(caseRec.Subject )+ '\t\n <br/>'; 
            body += System.label.LastUpdatedBy+' : '+String.valueOf(UserInfo.getName())+ '\t\n <br/>' ; 
            body += System.label.DetailsoftheUpdate+': <br/>'; 
            //body += '\n' +commentBody+'\n';
            body += '\n' +commentBody.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>')+'\n'; 
            return body;
    }
    
    public static Map<Id,List<Id>> toUserList(List<Case> caseList){
      Map<Id,List<Id>> caseIdToUserMap = new Map<Id,List<Id>>();      
      List<Id> caseIdList = new List<Id>();
      for(Case caseRec : caseList){
        caseIdList.add(caseRec.Id);
      }

      List<CaseTeamMember> caseTeamMemberList =  new List<CaseTeamMember>();
      caseTeamMemberList = [select id,parentid,memberid from CaseTeamMember where parentid= :caseIdList
                                                    and memberid!= :UserInfo.getUserid()];
      System.debug('caseTeamMemberList:'+caseTeamMemberList);
       List<Id> teamMemberIDList;
       for(CaseTeamMember ctm : caseTeamMemberList){
               teamMemberIDList = new List<Id>();
                if(caseIdToUserMap.containsKey(ctm.parentid)){
                       teamMemberIDList =  caseIdToUserMap.get(ctm.parentid);
                       teamMemberIDList.add(ctm.memberId);
                       caseIdToUserMap.put(ctm.parentid,teamMemberIDList);
                }
                else{
                        teamMemberIDList.add(ctm.memberId);
                        caseIdToUserMap.put(ctm.parentId,teamMemberIDList);
                }
       }
        
       //For adding case owner
       for(Case c : caseList){
          teamMemberIDList = new List<Id>();
          if( !String.valueOf(c.OwnerId).startsWith('00G') && c.OwnerId != UserInfo.getUserid()){
                    System.debug('c.OwnerId:'+c.OwnerId+'-String.valueOf(c.OwnerId).startsWith(00G):'+String.valueOf(c.OwnerId).startsWith('00G'));
                    if(caseIdToUserMap.containsKey(c.Id)){
                          teamMemberIDList = caseIdToUserMap.get(c.Id);
                          teamMemberIDList.add(c.OwnerId);
                          caseIdToUserMap.put(c.Id,teamMemberIDList);
                    }
                    else{
                          teamMemberIDList.add(c.OwnerId);
                          caseIdToUserMap.put(c.Id,teamMemberIDList);
                    }
          }
       }
      System.debug('###################caseIdToUserMap:'+caseIdToUserMap);      
      return caseIdToUserMap;
    } 
    
}