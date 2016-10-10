public class ConfidentiaAttachmentCon {

@InvocableMethod
public static void sendEmailNotifications(List<Case> closedCaseList){
    try{
    System.debug('closedCaseList====='+closedCaseList);
        Map<Id,List<Id>> caseNotifyToUsersMap = UtilityFalgs.toUserList(closedCaseList);
        List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();
        String emailbody ='';
        
         for(Case caseRec: closedCaseList){
             System.debug('$$$$$$$'+caseRec.id);
             List<Id> userIdList = caseNotifyToUsersMap.get(caseRec.Id);
              if(userIdList!=null && userIdList.size()>0){
                  for(Id userId: userIdList){
                      emailbody ='Confidential Attachments is being closed for this case :+caseRec.CaseNumber';
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
          System.debug('emails.size:'+emails.size());
          Messaging.sendEmail(emails);
        }
    }
    catch(Exception e){
      System.debug('Exception e:'+e.getStackTraceString());
    }  

}
}