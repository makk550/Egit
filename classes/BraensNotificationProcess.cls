public class BraensNotificationProcess {
    
    
    
    public static void sendNotificationToAssgnUser(List<String> emailsIDs,Case caseRecDetails)
    {
        List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();      
        
        String emailIdValue=String.join(emailsIDs, ';');
        
        String body='A case for which you are an owner or Case Team Member has been updated.<br/><br/>';
           body += 'Case : '+caseRecDetails.CaseNumber  +'<br/>' ;
           body += 'Tops Site ID : '+caseRecDetails.Tops_Support_Site_ID__c  +'<br/>';
           body += 'Site Association : '+caseRecDetails.site_name__c+'<br/>';
           body += 'Severity : '+caseRecDetails.Severity__c  +'<br/>';
           body += 'Subject : '+caseRecDetails.Subject +'<br/>';
           body += 'Thanks & Regards,<br/>' +'CA Support.';
        String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
           body = body + '<a href="' + urlCode + '/'+caseRecDetails.Id + '">'+urlCode+ '/'+caseRecDetails.Id +'</a>';
        
        
        Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
        email.setSubject('Case : '+caseRecDetails.caseNumber+' assigned to you.');
        email.setHTMLBody(body);
        email.setSaveAsActivity(false);
        email.setToAddresses(emailsIDs);
        emails.add(email);
        if(emails!=null){
          //Messaging.sendEmail(emails);  
        }        

    }
}