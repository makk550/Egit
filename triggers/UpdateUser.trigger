trigger UpdateUser on User (before insert) {


 for (User u : Trigger.new){
      
  if(u.DM_Portal_User__c=='True'){   
      u.Education_Access__c= False;  
  } 
   if(u.ContactId!=null && (u.DefaultCurrencyIsoCode==Null||u.DefaultCurrencyIsoCode==''))
      u.DefaultCurrencyIsoCode='USD'; 
    
 }

}