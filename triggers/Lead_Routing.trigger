trigger Lead_Routing on Lead (after update) 
{
    //List<Lead> badleads = new List<Lead>();
    Set<ID> leadids = new Set<ID>();
    Set<ID> badids = new Set<ID>();
//    RecordType rec = [Select ID from RecordType where Name='CA Global Lead' and SObjectType='Lead' and IsActive=true];
    //changed by saba to decrease soql queries
    RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('CA Global Lead');
    id recid = rec.RecordType_Id__c;
    if(rec!=null){
        for(Lead ld : Trigger.new){
            if(ld.RecordTypeID == recID){
                System.debug(ld.RouteLeads__c); 
                //Since trigger is on update, flag should be checked to determine if Routing should take place. (For all other conditions the flag is set to false)
                if(ld.RouteLeads__c == true){
                   //CR 189522189 start 
                   leadids.add(ld.Id);
                   //CR 189522189 end
                }
            }
        }
        //Unmatched leads to go to Unassigned queue removed as a part of CR 189522189
        if(leadids!=null && leadids.size()>0){//Fetch filtered leads by their Ids and pass on to Routing class.
            List<Lead> newLeads = [select Id,Account_Class__c,RouteLeads__c,GEO__c,EAID__c,MKT_BU_Category__c,OwnerID,Country_Picklist__c,MKT_Territory__c,Sales_Territory__c,Tactic__c,LeadSource,MKT_Solution_Set__c,Sub_Tactic__c from Lead where Id in: leadids];         
            List<Lead> updatedleads = DirectLeadManagement.RouteLeads(newleads);
            //update the routing flag to false so that the routing doesn’t take place for any other updates on the lead record.
            for(Lead updlead:updatedleads){
                updlead.RouteLeads__c = false;}
            update updatedleads;
            
            
            //call asynchronous class method for sending new lead notifications
            AsnycMails.sendassignmentemail(leadids);
        }
    }
    
    //added by siddharth to call the class to grant access to the approvers on deal.
    List<Lead> listOfDeals = new List<Lead>();
    List<Lead> oldLeadIds=Trigger.old;
    List<Lead> newLeadIds=Trigger.new;   
    Lead oldDeal =new Lead();
    Lead newDeal =new Lead();
    DealReg_GrantSharingToApprovers classVar = new DealReg_GrantSharingToApprovers();
    for(Integer i=0; i<newLeadIds.size();i++)
    {
        oldDeal=Trigger.old[i];
        newDeal=Trigger.new[i];
        if(oldDeal.Deal_Registration_Approval_Status__c != 'Submitted' && newDeal.Deal_Registration_Approval_Status__c=='Submitted')
            listOfDeals.add(newDeal);
        if(oldDeal.Deal_Registration_Approval_Status__c == 'Submitted' && newDeal.Deal_Registration_Approval_Status__c=='First Approval')
            listOfDeals.add(newDeal);
        if(oldDeal.Deal_Registration_Approval_Status__c == 'First Approval' && newDeal.Deal_Registration_Approval_Status__c=='Second Approval')
            listOfDeals.add(newDeal);
       System.debug('-----------Trigegr List'+ listOfDeals);
    }
    if(listOfDeals!=null && listOfDeals.size()>0)
        classVar.giveAccessToDealApprovers(listOfDeals);   

  }