trigger EmailRecipientStatus on dsfs__DocuSign_Recipient_Status__c (before update ) {
     Boolean sendEmailFlag = false ;
     String Message1 ='<p style="font-family:calibri">The following DocuSign Recipient Status records are tried to be updated by User:<b> '+UserInfo.getName()+' </b><br/>';
     String Message ='';
     Map<Id,String> recMap = new Map<Id,String>();
     Map<Id,SA_Booking__c> SAbookingMap =new Map<Id,SA_Booking__c>();
     SAbookingMap.putAll([Select Id,Name from SA_Booking__C]);
     Map<Id,dsfs__DocuSign_Status__c> StatusMap =new Map<Id,dsfs__DocuSign_Status__c>();
     StatusMap.putAll([Select Id,Name from dsfs__DocuSign_Status__c]);
     Boolean skip = false ; 
     List<String> escapeList = Label.DocuSignEscapeUsers.split(',');
    for(string es :escapeList)
    {
        if(es==UserInfo.getUserName())
        {
          skip=true;
           System.debug('Escaping User'+UserInfo.getUserName());
        }
        
    }
    
    if(!skip)
    {
     
   for (dsfs__DocuSign_Recipient_Status__c doc : trigger.new){
       if(trigger.oldmap.get(doc.id).SA_Booking__c != null && trigger.oldmap.get(doc.id).dsfs__Parent_Status_Record__c != null)
       {
          sendEmailFlag = false ;
          
          Message ='<br/><b>-->&nbsp SA Booking number : </b>'+SAbookingMap.get(trigger.oldmap.get(doc.id).SA_Booking__c).name+'<br/><b>&nbsp Docusign Status Record number : </b>'+StatusMap.get(trigger.oldmap.get(doc.id).dsfs__Parent_Status_Record__c).name+'<br/>&nbsp Changes are : ';
          
          //Message ='--> SA Booking number : '+trigger.oldmap.get(doc.id).SA_Booking__r.name+' Docusign Status Record number : '+trigger.oldmap.get(doc.id).dsfs__Parent_Status_Record__r.name+'&nbsp Changes are :<br/> ';
        if( trigger.oldmap.get(doc.id).dsfs__Date_Declined__c!=null && trigger.oldmap.get(doc.id).dsfs__Date_Declined__c != doc.dsfs__Date_Declined__c){
              sendEmailFlag = true;
              Message+=' <br/><b>&nbsp Date Declined </b>field from: '+trigger.oldmap.get(doc.id).dsfs__Date_Declined__c+' to: '+doc.dsfs__Date_Declined__c+', ';
              
              doc.dsfs__Date_Declined__c=trigger.oldmap.get(doc.id).dsfs__Date_Declined__c;
    
        }
        if( trigger.oldmap.get(doc.id).dsfs__Date_Delivered__c !=null && trigger.oldmap.get(doc.id).dsfs__Date_Delivered__c != doc.dsfs__Date_Delivered__c){
              sendEmailFlag = true;
              Message+='<br/><b>&nbsp Date Delivered </b>from: '+trigger.oldmap.get(doc.id).dsfs__Date_Delivered__c+' to: '+doc.dsfs__Date_Delivered__c+', ';
              
              doc.dsfs__Date_Delivered__c=trigger.oldmap.get(doc.id).dsfs__Date_Delivered__c;
        }
        if( trigger.oldmap.get(doc.id).dsfs__Date_Sent__c !=null && trigger.oldmap.get(doc.id).dsfs__Date_Sent__c != doc.dsfs__Date_Sent__c){
              sendEmailFlag = true;
              Message+='<br/><b>&nbsp Date Sent </b> from: '+trigger.oldmap.get(doc.id).dsfs__Date_Sent__c+' to: '+doc.dsfs__Date_Sent__c+', ';
              
              doc.dsfs__Date_Sent__c=trigger.oldmap.get(doc.id).dsfs__Date_Sent__c;
    
        }
        if( trigger.oldmap.get(doc.id).dsfs__Date_Signed__c !=null && trigger.oldmap.get(doc.id).dsfs__Date_Signed__c != doc.dsfs__Date_Signed__c){
              sendEmailFlag = true;
              Message+='<br/><b>&nbsp Date Signed </b> from: '+trigger.oldmap.get(doc.id).dsfs__Date_Signed__c+' to: '+doc.dsfs__Date_Signed__c+' <br/>';
             
              doc.dsfs__Date_Signed__c=trigger.oldmap.get(doc.id).dsfs__Date_Signed__c;
        }
        
         if(sendEmailFlag){
            recMap.put(doc.id,Message);  
         }
   
       }
   }
      
      if(recMap.size()>0){
        // call email service
         String body = message1+'';
        for(dsfs__DocuSign_Recipient_Status__c doc1 : trigger.new){
        
                if(recMap!=null && recMap.get(doc1.id)!=null)
                     body+=recMap.get(doc1.id)+'<br/>';
        
        } 
      
         DocusignEmailAlert alert = new DocusignEmailAlert();
         alert.sendAlert(body);
      }
}
}