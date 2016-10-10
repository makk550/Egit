public class ext_LeadConvert {

public String opprName { get; set;} 
public String endUserAccountName { get; set; }
public string hdnAccountId{get;set;}
public boolean isOpportunityCreate {get;set;}
public Lead l {get; set;}
public static String splChar = '-';
public lead ldd{get;set;}
public Lead ownerLead{get;set;}
public boolean isConvertLeadBlock { get; set;}
public boolean isContactBlock {get; set;}
public Boolean bool{get;set;}
public List<SelectOption> contactPickList {get; set;}
public List<SelectOption> partnerRTMPickList {get; set;}
public List<SelectOption> partnerRTMTypePickList {get; set;}
// defect:59705-Nullifying the variable value coz of static modifier.
//public Static String selctedPartnerRTM {get; set;} // PRM 4 - Req 75.00
public String selctedPartnerRTM {get; set;} // PRM 4 - Req 75.00
public String selctedPartnerRTMType {get; set;}
public String selctedContact {get; set;}
public User loginUser {get; set;}
public Boolean ldConvertResult_Boolean=false;
public String ldConvertResult_Error=null;
public Contact contact;
public Account customerAcct;
public Static Boolean isLeadConverted=false;
public ext_LeadConvert(){
    bool = false;
}


public String selectedPartnerEngagement {get; set;}
public String selectedReason {get; set;}
public String otherFulfillmentOnlyReason {get; set;}
public List<SelectOption> partnerEngagementPicklist {get; set;}
public List<SelectOption> reasonPicklist {get; set;}
public Boolean reasonDisabled {get; set;}

public ext_LeadConvert(apexpages.standardController std)
{
    this.isConvertLeadBlock = true;
    this.isContactBlock = false;
   // isLeadConverted = false;
    l = [select id,lastname,firstname,name,email,ownerid,company,Country_Picklist__c from lead where id =:(id)std.getRecord().id];
    opprName = l.company+ext_LeadConvert.splChar;
    
    customerAcct = new Account();
    ownerlead = new Lead();
    ownerLead.ownerid = l.ownerid;
  
    getPartnerRTMList();
    
    partnerEngagementPickList =  new List<SelectOption>();
     User Usr = new User();
     Usr = [SELECT  Id,Is_Partner_User__c FROM User WHERE Id = : UserInfo.getUserId()]; 
    if(usr.Is_Partner_User__c== true){
            partnerEngagementPickList.add(new SelectOption('Incremental', 'Incremental'));
            bool = true;
    }
    else {
    partnerEngagementPickList.add(new SelectOption('--None--', '--None--'));
    Schema.DescribeFieldResult F = Opportunity.Partner_Engagement__c.getDescribe();
                  List<Schema.PicklistEntry> P = F.getPicklistValues();
                  for(Schema.PicklistEntry pEntry :p)
                  {
                        partnerEngagementPickList.add( new SelectOption(pEntry.getValue(),pEntry .getLabel()));
                  }
                  }
    reasonPickList =  new List<SelectOption>();
    reasonPickList.add(new SelectOption('--None--', '--None--'));
    Schema.DescribeFieldResult RF = Opportunity.Reason__c.getDescribe();
                  List<Schema.PicklistEntry> RP = RF.getPicklistValues();
                  for(Schema.PicklistEntry pEntry :RP)
                  {
                        reasonPickList.add( new SelectOption(pEntry.getValue(),pEntry .getLabel()));
                  }
    reasonDisabled = true;
}
 
        public void reasonValues()
        {
            
            if(selectedPartnerEngagement=='Fulfillment-Only') reasonDisabled=false;
            else reasonDisabled=true;
        }
        public pagereference checkContacts(){
            System.debug('____iiii____'+selctedPartnerRTM);
             if(hdnAccountId !=null && ownerLead.ownerid != null && selctedPartnerRTM != '--None--' && selctedPartnerRTMType != '--None--'){
                 List<Contact> contactList;
                 if( l.firstname!= null && l.firstname != '' )
                    contactList = [select id, name from contact where (name like :'%'+l.lastname+'%' OR name like :'%'+l.firstname+'%') AND Account.id = :hdnAccountId];
                 else
                      contactList = [select id, name from contact where name like :'%'+l.lastname+'%' AND Account.id = :hdnAccountId];
                if( (null != contactList && contactList.size() > 0)){
                
                    this.isConvertLeadBlock = false;
                    this.isContactBlock = true;
                    contactPickList = new List<SelectOption>();
                    contactPickList.add( new SelectOption('0', '--None--'));
                    contactPickList.add( new SelectOption('1', 'Create new contact : '+l.name));
                    for(Contact cont :contactList ){
                      
                        contactPickList.add( new SelectOption( cont.id, 'Attach to Existing : '+cont.name));
                    }
                return NULL;
                }else{
                    pageReference p= executeConvertLead();  //for AR 3504
                  
                  if(!ldConvertResult_Boolean){
                     Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.ERROR,ldConvertResult_Error));
                     return null;
                  }
                  else{
                    //pageReference p = new PageReference('/'+hdnAccountId);
                    return p; 
                  }
                     
                }
             }else{
                Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.ERROR,'Please enter all mandatory values'));
                return null;
             }
        }
        
        public PageReference executeConvertLead(){
           System.debug('____in executeConvertLead'+selctedPartnerRTM);
           OpportunityHandler.isNewConvertedFromLead = true;
           Database.LeadConvert lc = new database.LeadConvert();
             Database.LeadConvert[] leadsToConvert = new Database.LeadConvert[0];
           transient  Database.LeadConvertResult[] ldConvertResult;
            lc.setLeadId(l.id);
           if(hdnAccountId != null) 
            lc.setAccountId(hdnAccountId);
            
           if( !isContactBlock ){
               lc.setContactId(createContact());
           }
           else{
           
               if( selctedContact.contains('1')){
                   lc.setContactId(createContact());
               }else{
                   lc.setContactId( selctedContact);
               }
           }
           
           lc.setOwnerId(ownerLead.ownerid); 
           lc.setOpportunityname(opprName);
           LeadStatus convertStatus;
           convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true
                            and  MasterLabel like 'C%'];     
           lc.setConvertedStatus(convertStatus.MasterLabel);
           System.debug('*************B4 convert***********');
           leadsToConvert.add(lc);
         //  try{
               ldConvertResult = Database.ConvertLead(leadsToConvert,false);
         //  }catch(Exception e){
         //    ApexPages.addMessage(new ApexPages.Message(APEXPAGES.SEVERITY.ERROR,e.getMessage()));
          // }
          
          System.debug('*************After convert***********');
           Opportunity opp;
           System.debug('_____ lead convert result_____'+ldConvertResult[0]);
           if(ldConvertResult[0].isSuccess()){
            isLeadConverted = true;
              opp = [select id,Type,AccountId,Service_Provider_Client__c,
                            partner_1__c,
                            reseller__c,
                            partner__c 
                            from opportunity where id =: ldConvertResult[0].getOpportunityId()];
               
               customerAcct = [SELECT Id,Name,OwnerId,RecordType.Name,Solution_Provider_CAM_PMFKey__c from Account where Id =:hdnAccountId];
               
               /*COMMENTED AS PART OF REQ#72.00 IN PRM-3 - TADKR01.
                if(selctedPartnerRTM== 'Alliance')
                    opp.partner_1__c = loginUser.contact.accountid;
              */
              User Usr = new User();
              Usr = [SELECT  Id,Is_Partner_User__c FROM User WHERE Id = : UserInfo.getUserId()]; 
              if(usr.Is_Partner_User__c== true){
             opp.partner_engagement__c = 'Incremental';
             }
             else{
              opp.partner_engagement__c = selectedPartnerEngagement;
              }
              opp.reason__c = selectedReason;
              opp.Other_Fulfillment_Only_Reason__c = otherFulfillmentOnlyReason;
              System.debug('_____outside first if'+selctedPartnerRTM);
            if(selctedPartnerRTM== 'Solution Provider'){
                System.debug('___in SOL PROVIDER');               
                if(customerAcct.Id != null&&customerAcct.RecordType.Name.contains('Account Team Covered')){
                              //opp.OwnerId = customerAcct.OwnerId;
                              ext_LeadConvert.setOppOwnerToAccOwner(opp.id, customerAcct.OwnerId);
                 }

                if(selctedPartnerRTMType == 'Reseller' || selctedPartnerRTMType == 'Mainframe'){
                 opp.type='1 Tier';              
                 opp.AccountId = hdnAccountId ;
                 System.debug('____!111_____'+loginUser.contact.accountid);
                 opp.Reseller__c=loginUser.contact.accountid;
                
                }
                else if(selctedPartnerRTMType == 'Distributor'){
                 opp.type='2 Tier';
                 opp.AccountId = hdnAccountId ;
                 opp.Distributor_6__c=loginUser.contact.accountid;
                }
              }
              else if(selctedPartnerRTM== 'Service Provider'){
                System.debug('___in Serv PROVIDER');               
                opp.Type = 'xSP';
                opp.AccountId = loginUser.contact.accountid;
                opp.Service_Provider_Client__c = hdnAccountId;
              } 
             
             
              else if(selctedPartnerRTM == 'Data Management'){
                System.debug('___in DM');
                    opp.Type='ERWIN';
                    if(selctedPartnerRTMType == 'Reseller' || selctedPartnerRTMType == 'Distributor' || selctedPartnerRTMType == 'Solution provider'){
                        System.debug('_if__in DM'+opp.AccountId);
                        opp.AccountId = hdnAccountId;
                        opp.Reseller__c=loginUser.contact.accountid;
                        System.debug('_if__LoginUser'+opp.Reseller__c);
                    }
                    else if(selctedPartnerRTMType == 'SAAS Aggregators' || selctedPartnerRTMType == 'OEM' || selctedPartnerRTMType == 'MSP'){
                        System.debug('_else1__in DM'+opp.AccountId);
                        opp.AccountId = loginUser.contact.accountid;
                        System.debug('_else2__in DM'+opp.AccountId);
                    }
              }
                 
                
                
                  OpportunityGateway.classexecuted=0;  
                System.debug('*************b4 update***********');
             update opp;
             
             System.debug('*************After update***********');
           }
           if(ldConvertResult[0].isSuccess()){
            ldConvertResult_Boolean = true;
            ldConvertResult_Error='';
               pageReference p = new PageReference('/'+opp.Id);   //for AR 3504
                return p; 
           }
           else{
            if(contact.id!=null){
                    delete contact;
            }
            ldConvertResult_Boolean = false;
            ldConvertResult_Error = ldConvertResult[0].getErrors()[0].getMessage();
             ApexPages.addMessage(new ApexPages.Message(APEXPAGES.SEVERITY.ERROR,ldConvertResult[0].getErrors()[0].getMessage()));
           
              RETURN NULL;
           }
         
        }

    public pageReference cancelMeth(){
        pageReference p = new PageReference('/'+l.id);
    
     return p;  
    }
    
    public void switchBlock(){
        isConvertLeadBlock = true;
        isContactBlock = false;
    }

    public id createContact(){
         contact = new Contact();
        contact.lastName = l.lastname;
        contact.firstname = l.firstname;
        contact.accountid = hdnAccountId;
        contact.email = l.email;
        contact.country_picklist__c = l.country_picklist__c;
        insert contact;
        return contact.id;
    }

    public void getPartnerRTMList(){
    
        partnerRTMPickList =  new List<SelectOption>();
        partnerRTMTypePickList =  new List<SelectOption>();
        loginUser = [select contactid, 
                            contact.accountId,
                            contact.account.Alliance__c ,
                            contact.account.Service_Provider__c,
                            contact.account.Solution_Provider__c,
                            contact.account.Velocity_Seller__c,
                            contact.account.Solution_Provider_CAM_PMFKey__c
                            from user where id =: userinfo.getUserId()];
        System.debug('___login user details___'+loginUser.contact.AccountId);
        partnerRTMPickList.add(new SelectOption('--None--', '--None--'));
        partnerRTMTypePickList.add(new SelectOption('--None--', '--None--'));
       /*COMMENTED AS PART OF REQ#72.00 IN PRM-3 - TADKR01.
        if(loginUser.contact.account.Alliance__c){
            partnerRTMPickList.add(new SelectOption('Alliance','Alliance'));
        }
        */
        if( loginUser.contact.account.Service_Provider__c)
            partnerRTMPickList.add(new SelectOption('Service Provider','Service Provider'));
        if( loginUser.contact.account.Solution_Provider__c)
            partnerRTMPickList.add(new SelectOption('Solution Provider','Solution Provider'));
        if( loginUser.contact.account.Velocity_Seller__c)
            partnerRTMPickList.add(new SelectOption('Data Management','Data Management'));
        
    }

    // RETURNS LIST OF RTMTYPES BASED ON THE SELCTED PARTNERRTM - TADKR01.
      public void getPartnerRTMTypeList(){
      System.debug('____meth call007___'+selctedPartnerRTM);
         partnerRTMTypePicklist = new List<SelectOption>();
         partnerRTMTypePickList.add(new SelectOption('--None--', '--None--'));
         if(selctedPartnerRTM != '--None--'){
             if(selctedPartnerRTM == 'Service Provider'){
                   Schema.DescribeFieldResult F = Account.Service_Provider_Type__c.getDescribe();
                  List<Schema.PicklistEntry> P = F.getPicklistValues();
                  for(Schema.PicklistEntry pEntry :p)
                  {
                        partnerRTMTypePickList.add( new SelectOption(pEntry.getValue(),pEntry .getLabel()));
                  }
             }else if(selctedPartnerRTM == 'Solution Provider'){
                   Schema.DescribeFieldResult F = Account.Solution_Provider_Type__c.getDescribe();
                  List<Schema.PicklistEntry> P = F.getPicklistValues();
                  for(Schema.PicklistEntry pEntry :p)
                  {
                        partnerRTMTypePickList.add( new SelectOption(pEntry.getValue(),pEntry .getLabel()));
                  }
             }else if(selctedPartnerRTM == 'Data Management'){
                  Schema.DescribeFieldResult F = Account.Velocity_Seller_Type__c.getDescribe();
                  List<Schema.PicklistEntry> P = F.getPicklistValues();
                  for(Schema.PicklistEntry pEntry :p)
                  {
                        partnerRTMTypePickList.add( new SelectOption(pEntry.getValue(),pEntry .getLabel()));
                  }
             }
          }
      }
      @future
      public static void setOppOwnerToAccOwner(Id oppid, Id id)
      {          
          Opportunity opp = [select ownerid from Opportunity where id=:oppid];
          opp.OwnerId = id;
          update opp;
      }
}