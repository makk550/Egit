public class PartnerEngagementRequest_Controller {
 
public Opportunity Opp;
public Id oppId{get;set;}
public  Id  OppReg{get;set;}    
public boolean showReadOnly{get;set;}
public boolean showEdit{get;set;}
public boolean showeditbutton{set;get;}
public boolean isapprovededit{set;get;}
public string selectedstatus{get;set;}
public Partner_Engagement_Program__c per{set;get;}
      public PartnerEngagementRequest_Controller(ApexPages.StandardController stdController) 
     {
        OppReg =  ApexPages.currentPage().getParameters().get('oppReg');
        oppId= ApexPages.currentPage().getParameters().get('oppId');
       Id PEId= ApexPages.currentPage().getParameters().get('Id');
       String returl=ApexPages.currentPage().getParameters().get('retURL');
       showeditbutton=false;
        per = (Partner_Engagement_Program__c)stdController.getrecord();
         showReadOnly =true;
         showEdit =true;
         isapprovededit=false;
         if(PEId!=null){
         if(PEId!=null&&returl!=null)
         {              
            per=[select id,Name,Parent_Opportunity__c,Distributor__c,License_Implementation__c,Customer_Procurement__c,Contract_Administration__c,Support_and_Maintenance__c,Customer_Training__c,Proposal__c,Presentation__c,Distributor_Contact__c,Partner_Engagement_Type__c,Partner__c,Partner_Contact__c,Comments__c,Engagement_Approver__c,POC__c,Demo__c,Status__c,Lunch_and_Learn__c,On_Customer_s_Approved_Vendor_List_for__c,Relationship_with_Customer__c  from Partner_Engagement_Program__c where id=:PEId limit 1 ];
             if(per.Status__c=='Approved')
             {
                 showReadOnly = true;
                showEdit =false;
                isapprovededit=true;
             }
             else
             {
                 showReadOnly = false;
                showEdit =true;
             }
         }
         if(PEId!=null&&(returl==null))
         {
              showReadOnly = true;
              showeditbutton=true;
            showEdit =false;
             per=[select id,Name,Parent_Opportunity__c,Distributor__c,License_Implementation__c,Customer_Procurement__c,Contract_Administration__c,Support_and_Maintenance__c,Customer_Training__c,Proposal__c,Presentation__c,Distributor_Contact__c,Partner_Engagement_Type__c,Partner__c,Partner_Contact__c,Comments__c,Engagement_Approver__c,POC__c,Demo__c,Status__c,Lunch_and_Learn__c,On_Customer_s_Approved_Vendor_List_for__c,Relationship_with_Customer__c  from Partner_Engagement_Program__c where id=:PEId limit 1 ];
         }
         }
         else
         {
          if(per.Status__c == 'Pending' && per.Engagement_Approver__c == UserInfo.getUserId())
        {
            showReadOnly = false;
            showEdit =true;
        } 
         else if(per.Status__c == 'Approved' && per.Engagement_Approver__c == UserInfo.getUserId())
        {
            showReadOnly = true;
            showEdit =false;
        } 
          else
        {
             showEdit =true;    
             showReadOnly = false;
        }
          if(oppId == null)
        {
           oppId = per.Parent_Opportunity__c;
        }
        opp = [select stagename,Probability,recordtypeId,Account.Alliance__c,Type,closedate,Accountid,Account.RecordtypeId,Account.Service_Provider__c,Partner_Engagement__c,(SELECT Id, Status__c FROM Partner_Engagement_Requests__r where (Status__c != null AND Status__c != '' AND (Status__c =: 'Approved' OR Status__c =: 'Pending Approval' OR Status__c =: 'New'))),(select id,OpportunityId from OpportunityContactRoles where isprimary=:true)  from Opportunity where Id= :oppId ] ;  
		Integer fyMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Integer fyYear = System.today().year();
		Integer closemonth = opp.closedate.month();
        Integer closeyear = opp.closedate.year();
        if(opp != null)
        {
            if(opp.type=='xSP'||opp.type=='OEM'||opp.type=='ERWIN')
            {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner Engagement Request is for 1 Tier and 2 Tier transactions only');            
                ApexPages.addMessage(msg);
                showReadOnly = true;
                showEdit =false; 
            }
            if('100% - Contract Signed' == opp.StageName || '100% - Closed' == opp.StageName || 'Closed - Lost' == opp.StageName || opp.CloseDate <  Date.today()) 
            { 
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Partner Engagement Request cannot be created if the Opportunity Sales Milestone = "Closed - Lost" OR "100% - Contract Signed" and the "Close Date" of the Opportunity cannot be in the past.');            
                ApexPages.addMessage(msg);
                showReadOnly = true;
                showEdit =false; 

            } 
            if(opp.OpportunityContactRoles.size()<=0 && ((opp.Probability >= 20  && opp.Probability!= 100) || (opp.Probability == 100 && ((closemonth >= fymonth && closeyear == fyyear) || (closemonth < fymonth && closeyear == fyyear + 1))))&&('10% - Identification & Qualification' != opp.StageName && '10% - Discovery & Assessment' != opp.StageName))
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity should have primary contact role');            
                ApexPages.addMessage(msg);
                showReadOnly = true;
                showEdit =false; 
            }
            user u=[select id,Opportunity_Validation_Bypass__c  from user where id=:userinfo.getUserId()];
            if(u.Opportunity_Validation_Bypass__c=true&&(opp.recordtypeId==RecordTypes_Setting__c.getValues('New Opportunity').RecordType_Id__c||opp.recordtypeId==RecordTypes_Setting__c.getValues('Acquisition').RecordType_Id__c)&&opp.Account.Service_Provider__c==true)
            {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '"Sell To" account cannot be a Service Provider account.');            
                ApexPages.addMessage(msg);
                showReadOnly = true;
                showEdit =false; 
            }
            if(u.Opportunity_Validation_Bypass__c=true&&(opp.recordtypeId==RecordTypes_Setting__c.getValues('New Opportunity').RecordType_Id__c||opp.recordtypeId==RecordTypes_Setting__c.getValues('Acquisition').RecordType_Id__c)&&opp.Account.Recordtypeid!=RecordTypes_Setting__c.getValues('Account Team Covered Account').RecordType_Id__c&&opp.Account.Recordtypeid!=RecordTypes_Setting__c.getValues('SMB').RecordType_Id__c&&opp.Account.Recordtypeid!=RecordTypes_Setting__c.getValues('Territory Covered Account').RecordType_Id__c&&(opp.Account.Recordtypeid!=RecordTypes_Setting__c.getValues('Reseller/Distributor Account').RecordType_Id__c&&!(opp.Account.Service_Provider__c||opp.Account.Alliance__c)))
            {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '"New Opportunity" and Acquistions, can be created only for Account Team , Territory Covered, SMB or Service Provider accounts.');            
                ApexPages.addMessage(msg);
                showReadOnly = true;
                showEdit =false; 
            }
            //if('Collaborative' == opp.Partner_Engagement__c || 'Fulfillment-Only' == opp.Partner_Engagement__c || 'Pending' == opp.Partner_Engagement__c) 
            if(opp.Partner_Engagement_Requests__r.size() != 0)
            { 
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Only 1 Partner Engagement Request per Opportunity.');            
                ApexPages.addMessage(msg);
                showReadOnly = true;
                showEdit =false; 

            } 
            
        }
        }
         if(oppId == null)
        {
           oppId = per.Parent_Opportunity__c;
        }
        else
        per.Parent_Opportunity__c=oppId;
     }
     public PageReference save()
     {   
         PageReference pref;
         System.debug(per.Demo__c+'@@'+per.Lunch_and_Learn__c);
         try{
             if(per.partner__c != null && per.partner_Contact__c == null ){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A Partner Contact is required.');            
                ApexPages.addMessage(msg);
                pref=null;
            }
            else if(per.Distributor__c!= null && per.Distributor_Contact__c== null ){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A Distributor Contact is required.');            
                ApexPages.addMessage(msg);
                pref=null;
            }
            else
            {
             if(per.On_Customer_s_Approved_Vendor_List_for__c || per.Relationship_with_Customer__c || per.POC__c || per.Demo__c ||per.Lunch_and_Learn__c||per.Proposal__c||per.Presentation__c||per.Customer_Training__c||per.License_Implementation__c||per.Contract_Administration__c||per.Support_and_Maintenance__c||per.Customer_Procurement__c) {
             if(selectedstatus!=''&&selectedstatus!=null)
             per.status__c=selectedstatus;
             if(per.Relationship_with_Customer__c || per.POC__c ||per.Demo__c || per.Lunch_and_Learn__c||per.Proposal__c||per.Presentation__c||per.Customer_Training__c) 
                per.Partner_Engagement_Type__c = 'Collaborative';
              else per.Partner_Engagement_Type__c = 'Fulfillment';
             upsert per;
             pref = new PageReference('/apex/PartnerEngagementRequest_VFP?id='+per.id);
                pref.setRedirect(true); 
             }
             else
             {
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select atleast one value from Collaborative or Fulfillment.');            
                 ApexPages.addMessage(msg);
               pref=null;
             }
             }
             
         }
          catch(Exception e)
         {
            if(ApexPages.getMessages().size()<=0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());            
           ApexPages.addMessage(msg);
           }
            pref=null;
         }
          //Opp = [select Id,Name,Partner_Engagement__c from Opportunity where Id =:oppId ] ;
          //if(per.Status__c == 'Pending Approval') opp.Partner_Engagement__c = 'Pending';
          //if(per.Partner_Engagement_Type__c == 'Collaborative' && per.Status__c == 'Approved') opp.Partner_Engagement__c = 'Collaborative';
          //if(per.Partner_Engagement_Type__c == 'Fulfillment' && per.Status__c == 'Approved') opp.Partner_Engagement__c = 'Fulfillment-Only';
        /* try{
             //upsert Opp;
         }
          catch(Exception e)
         {
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());            
           ApexPages.addMessage(msg);
           pref=null;
         }*/
      
        
        return pref;
     }
     public PageReference saveNsubmit()
     { 
          PageReference pref;
         try{
             if(per.partner__c != null && per.partner_Contact__c == null ){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A Partner Contact is required.');            
                ApexPages.addMessage(msg);
                pref=null;
            }
            else if(per.Distributor__c!= null && per.Distributor_Contact__c== null ){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A Distributor Contact is required.');            
                ApexPages.addMessage(msg);
                pref=null;
            }
            else
            {
               if(per.On_Customer_s_Approved_Vendor_List_for__c || per.Relationship_with_Customer__c || per.POC__c || per.Demo__c ||per.Lunch_and_Learn__c||per.Proposal__c||per.Presentation__c||per.Customer_Training__c||per.License_Implementation__c||per.Contract_Administration__c||per.Support_and_Maintenance__c||per.Customer_Procurement__c) {
             if(selectedstatus!=''&&selectedstatus!=null)
             per.status__c=selectedstatus;
             if(per.Relationship_with_Customer__c  || per.POC__c ||per.Demo__c || per.Lunch_and_Learn__c||per.Proposal__c||per.Presentation__c||per.Customer_Training__c) 
                per.Partner_Engagement_Type__c = 'Collaborative';
              else per.Partner_Engagement_Type__c = 'Fulfillment';
             upsert per;
             pref = new PageReference('/apex/PartnerEngagementRequest_VFP?id='+per.id);
                pref.setRedirect(true); 
             }
             else
             {
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select atleast one value from Collaborative or Fulfillment.');            
                   ApexPages.addMessage(msg);
               pref=null;
             }
             }
         }
          catch(Exception e)
         {
           if(ApexPages.getMessages().size()<=0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());            
           ApexPages.addMessage(msg);
           }
            pref=null;
         }
         if(oppid==null)
         oppId=per.parent_opportunity__c;
          Opp = [select Id,Name,Partner_Engagement__c from Opportunity where Id =:oppId ] ;
          //if(per.Status__c == 'Pending Approval') opp.Partner_Engagement__c = 'Pending';
          //if(per.Partner_Engagement_Type__c == 'Collaborative' && per.Status__c == 'Approved') opp.Partner_Engagement__c = 'Collaborative';
          //if(per.Partner_Engagement_Type__c == 'Fulfillment' && per.Status__c == 'Approved') opp.Partner_Engagement__c = 'Fulfillment-Only';
         try{
             //upsert Opp;
             Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
             req.setObjectId(per.Id);
             Approval.ProcessResult result = Approval.process(req);
         }
          catch(Exception e)
         {
           if(ApexPages.getMessages().size()<=0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());            
           ApexPages.addMessage(msg);
           }
            pref=null;
         }
        /*PageReference pref = new PageReference('/'+ oppId);
        pref.setRedirect(true); 
        return pref;*/
        // showReadOnly =true;
        // showEdit =false;
         return pref;
     }
     public PageReference cancel()
     {
        PageReference pref = new PageReference('/'+ oppId);
        pref.setRedirect(true); 
        return pref;
     }
     public pagereference editPER()
     {
         PageReference pref = new PageReference('/apex/PartnerEngagementRequest_VFP?id='+per.id+'&retURL='+ oppId);
        pref.setRedirect(true); 
        return pref;
     }
}