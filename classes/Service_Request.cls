public with sharing class Service_Request {
    public  Services_Request__c sr {get; set;}
    opportunity opp;   

    public Service_Request(ApexPages.StandardController controller) {
        sr = new Services_Request__c();
        opp = (opportunity)(controller.getrecord());
    }
    
    public pagereference ApplySelection()
    {        
           if(opp!= null && opp.id != null)
           {   
            opp = [Select accountid, ownerid from opportunity where id=: opp.id]; // to retrieve the accountid   
               
            sr.Oppty_Name__c = opp.id;
            sr.Account_Name__c = opp.accountId;
            sr.ownerid = opp.ownerid;
            sr.Oppty_Owner__c =opp.ownerid ;
            insert sr;
            return new pagereference('/p/attach/NoteAttach?pid=' + sr.id + '&retURL=%2F' + sr.id);
           }
           
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select opportunity'));
           return null;
    }
    
}