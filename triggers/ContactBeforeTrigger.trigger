trigger ContactBeforeTrigger on Contact (before update,before delete) 
{
    if(Label.Marketo_ProfileIds.contains(userinfo.getProfileId().substring(0,15)) && Trigger.isbefore && Trigger.isUpdate)
     {
         for (Contact c : Trigger.new)
         {
             Contact oldContact = (Contact)Trigger.OldMap.get(c.id);  
             String oldLDAPId = oldContact.SC_CONTACT_LDAPID__c;
             if(oldLDAPId != null && oldLDAPId.trim() != '')
             {
                 c.email = oldContact.email;
                 c.FirstName = oldContact.FirstName;
                 c.LastName = oldContact.LastName;
                 c.Phone = oldContact.Phone;
             }
         } 
     }
    
    
    if(trigger.isBefore && trigger.isDelete){
        
        for(Contact c: Trigger.old){
            if(Label.Email_to_case_missing_contact.contains(String.valueOf(c.id).subString(0,15)) 
               && !Label.Admin_Profile_Label.contains(userinfo.getProfileId().subString(0,15))){
                   c.addError('You are not authorized to delete this contact. Please contact your system administrator.');
               }
            
        }
        
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        
        for(Contact c: Trigger.new){
            if(Label.Email_to_case_missing_contact.contains(String.valueOf(c.id).subString(0,15)) 
               && !Label.Admin_Profile_Label.contains(userinfo.getProfileId().subString(0,15))){
                   c.addError('You are not authorized to update this contact. Please contact your system administrator.');
               }
        }
    }
    
    
}