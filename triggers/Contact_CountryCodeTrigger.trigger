trigger Contact_CountryCodeTrigger on Contact (before insert, before update) {

     List<Accreditation__c> lstAccreditation = [Select Id,Email__c,Partner__c,Contact_Name__c  from Accreditation__c where Partner__c = null and Contact_Name__c = null  Limit:(Limits.getLimitQueryRows() - Limits.getQueryRows())];
     List<Contact> cnt = Trigger.new;
     Map<string,Id> mapEmail = new Map<string,Id>();
     Map<Id,Accreditation__c> mapAccr = new Map<Id,Accreditation__c>();    
     Accreditation__c AccrTemp = new Accreditation__c();
     Id  idAccr;

     for(Accreditation__c accr : lstAccreditation)    
     {
           mapEmail.put(accr.Email__c,accr.id);
           mapAccr.put(accr.Id,accr);
     }

    for (Contact con : Trigger.new) {
        if (con.Country_Picklist__c != null)
        {         
            con.MailingCountry = con .Country_Picklist__c.substring(0,2);
        }
        //For PRM5
        if(mapEmail.size() > 0)
         {

            idAccr = mapEmail.get(con.Email);
            if(idAccr != null)
            {
               AccrTemp = mapAccr.get(idAccr);
               if(AccrTemp != null)
               {
                AccrTemp.Id = idAccr;
                AccrTemp.Partner__c = con.Account.Id;
                AccrTemp.Contact_Name__c = con.Id;
                system.debug('hi --> ' + idAccr);
               }
            }
           if(AccrTemp != null && idAccr != null)
            update(AccrTemp);
         }        
    }
}