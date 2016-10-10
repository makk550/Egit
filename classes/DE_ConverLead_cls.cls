public with sharing class DE_ConverLead_cls {

    public Lead leadrec {get; set;}
    public List<Account> leadCAAccountIDExists {get; set;}
    public boolean IsSendEmailChecked {get; set; }
    public String endUserAccountName { get; set; }
    public string hdnAccountId{get;set;}
    public boolean isOpportunityCreate {get;set;}
    public boolean setSendNotificationEmail {get; set; }
    public String opprName { get; set; } 
    public String selctedConvertedStatus { get; set; }
    public Task taskrec { get; set; }
    public ID OppId { get; set; }
    
    public static String splChar = '-';
    public boolean isLeadOwnerActive;
    public boolean isConvertLeadBlock { get; set;}
    public boolean isContactBlock {get; set;}
    public List<SelectOption> contactPickList {get; set;}    
    public String selectedContact {get; set;}
    public Contact contact;
       
    public DE_ConverLead_CLS(ApexPages.StandardController controller) {

     isConvertLeadBlock = true;
     isContactBlock = false;
    
        isLeadOwnerActive = false;
        IsSendEmailChecked = false;
        //hdnAccountId = '001f000000ZhX3E';
        List<Lead> leadreclist = [select id, lastname, firstname, name, email, ownerid, company, Country_Picklist__c, EAID__c, Commercial_Account__c, Commercial_Account__r.Name, IsConverted from lead where id =:(id)controller.getRecord().id LIMIT 1];
        if(leadreclist.size() > 0) {
            leadrec = leadreclist[0];
            opprName = leadrec.company + DE_ConverLead_cls.splChar;
            System.debug('leadrec^^^^^'+leadrec.Commercial_Account__c);
            if(leadrec.Commercial_Account__c <> null) { //&& leadrec.Commercial_Account__c <> '')
                leadCAAccountIDExists = [Select id, name from Account where id =: leadrec.Commercial_Account__c LIMIT 1];
                if(leadCAAccountIDExists.size() > 0) {
                    endUserAccountName = leadrec.Commercial_Account__r.Name;
                    hdnAccountId = leadrec.Commercial_Account__c;
                }    
            }
        }
            
        taskrec = new Task();
    }
    
    public pagereference CheckIsConverted() {
        PageReference pageref;
        if(leadrec.IsConverted)
            pageref = new PageReference('/p/lead/ViewConvertedLead/d?id='+leadrec.id);
        else {
            pageref = null;
        }
        return pageref;
    }
    
    public List<SelectOption> getConvertedStatusList() { 
        List<SelectOption> sellist = new List<SelectOption>();
        sellist.add(new SelectOption('Converted','Converted'));
        return sellist;
    }
    
    public pageReference cancelMeth(){
        pageReference p = new PageReference('/'+leadrec.id);
        return p;  
    }
    
    public id createContact(){
         contact = new Contact();
        contact.lastName = leadrec.lastname;
        contact.firstname = leadrec.firstname;
        contact.accountid = hdnAccountId;
        contact.email = leadrec.email;
        contact.country_picklist__c = leadrec.country_picklist__c;
        insert contact;
        return contact.id;
    }
    
    public pagereference checkContacts(){
             if(hdnAccountId !=null && leadrec.ownerid != null){
                 List<Contact> contactList;
                 if( leadrec.firstname!= null && leadrec.firstname != '' )
                    contactList = [select id, name from contact where (name like :'%'+leadrec.lastname+'%' OR name like :'%'+leadrec.firstname+'%') AND Account.id = :hdnAccountId];
                 else
                      contactList = [select id, name from contact where name like :'%'+leadrec.lastname+'%' AND Account.id = :hdnAccountId];
                if( (null != contactList && contactList.size() > 0)){
                
                    isConvertLeadBlock = false;
                    isContactBlock = true;
                    contactPickList = new List<SelectOption>();
                    contactPickList.add( new SelectOption('0', '--None--'));
                    contactPickList.add( new SelectOption('1', 'Create new contact : '+leadrec.name));
                    for(Contact cont :contactList ){
                      
                        contactPickList.add( new SelectOption( cont.id, 'Attach to Existing : '+cont.name));
                    }
                return NULL;
                }else{
                //return null;
                     return ConvertLeadRecord_1();
                  
                  /*if(!ldConvertResult_Boolean){
                     Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.ERROR,ldConvertResult_Error));
                     return null;
                  }
                  else{
                    pageReference p = new PageReference('/'+hdnAccountId);
                    return p; 
                  }*/
                     
                }
             }else{
                Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.ERROR,'Please enter all mandatory values'));
                return null;
             }
        }

    public pagereference ConvertLeadRecord_1(){
        pageReference p;
        string leadownerid = leadrec.ownerid;

        if(leadownerid.substring(0,3) == '00G') 
            isLeadOwnerActive = true;
        else {
            //Is Lead Owner Active
            List<User> LeadOwner = [select id, name, IsActive from User where id =: leadrec.ownerid LIMIT 1];
            if(LeadOwner.size() > 0) 
                isLeadOwnerActive = LeadOwner[0].IsActive;
        }
        
        if(isLeadOwnerActive) {
            Database.LeadConvert lc = new database.LeadConvert();
            Database.LeadConvert[] leadsToConvert = new Database.LeadConvert[0];
            transient  Database.LeadConvertResult[] ldConvertResult;
    
            lc.setLeadId(leadrec.id);
            lc.setSendNotificationEmail(setSendNotificationEmail);
            lc.setDoNotCreateOpportunity(isOpportunityCreate);
    
            if(isOpportunityCreate) opprName = '';
            if(hdnAccountId != null && hdnAccountId != '') 
                lc.setAccountId(hdnAccountId);
    
            if( !isContactBlock ){
               lc.setContactId(createContact());
            }
            else{
           
               if( selectedContact.contains('1')){
                   lc.setContactId(createContact());
               }else{
                   lc.setContactId(selectedContact);
               }
            }

                lc.setOwnerId(Userinfo.getUserId());
                lc.isSendNotificationEmail();
                if(opprName != '') 
                    lc.setOpportunityname(opprName);
                LeadStatus convertStatus;
                convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true and  MasterLabel like 'C%'];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                System.debug('*************B4 convert***********');
                leadsToConvert.add(lc);
                ldConvertResult = Database.ConvertLead(leadsToConvert,false);
                System.debug('*************After convert***********'+ldConvertResult);
                if(ldConvertResult[0].isSuccess()){
                    OppId = ldConvertResult[0].getOpportunityId();
                    System.debug('________Oppty'+OppId);
                    
                    //Insert Task
                    taskrec.OwnerId =  Userinfo.getUserId();
                    taskrec.WhatId = OppId;
                    insert taskrec;
                
                    //Navigate to Account Detail Page
                    p = new PageReference('/'+hdnAccountId);
                    return p;
                }     
                else {
                    //Apexpages.Message error = new Apexpages.Message(ApexPages.Severity.Error, ldConvertResult[0].getErrors()[0].getMessage());
                    Apexpages.Message error = new Apexpages.Message(ApexPages.Severity.Error, 'You do not have the required permission.  To continue, please contact Operations to grant \"Edit\" permissions on the selected Account.');
                    Apexpages.addMessage(error);
                    return null;
                }
        }
        else { //Add Pagemessage Lead Owner Inactive change Leadowner Active before convert.
            Apexpages.Message error = new Apexpages.Message(ApexPages.Severity.Error, 'Lead Owner is inactive change Leadowner before convert');
            Apexpages.addMessage(error);
            return null;
        }    
    }
    public void switchBlock(){
        System.debug('________I am here');
        isConvertLeadBlock = true;
        isContactBlock = false;
    }
}