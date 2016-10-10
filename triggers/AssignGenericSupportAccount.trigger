Trigger AssignGenericSupportAccount on Site_Association__c(before insert,after insert,before update, after update,after delete){
   
     if('YES'.equals(Label.TriggerByPass)){
            return ;
       }
    
    if( (!Label.Informatica_userid.contains(userinfo.getUserId().substring(0,15)))&& Label.Integration_UserProfileIds.contains(userinfo.getProfileId().substring(0,15)))
       return;
       
        Set<Id> setAccIds=new Set<Id>();
        if(trigger.isinsert || trigger.isupdate)
        { 
            Map<String, String> countryAndRegion = new Map<String, String>(); 
            if(trigger.isBefore)
            {
                List<Country_Support_Region__c> suppRegionList = Country_Support_Region__c.getAll().Values(); 
                    
                for(Country_Support_Region__c csr : suppRegionList)
                {
                    countryAndRegion.put(csr.Country__c, csr.Region__c);
                } 
            }
            
            for(Site_Association__c  recSite:trigger.new)
            {    
                if(!countryAndRegion.isEmpty() && countryAndRegion.keySet().size()>0 && countryAndRegion.keySet()!=null && countryAndRegion!=null)
                {
                    if( trigger.isBefore && countryAndRegion.containsKey(recSite.Country_picklist__c.trim()))
                    {
                        recSite.Support_Region__c = countryAndRegion.get(recSite.Country_picklist__c.trim());
                    }
                }
                if(trigger.isinsert &&(recSite.SC_SITE_Source__c == 'Support' ||recSite.SC_SITE_Source__c == 'GPOC'))
                    setAccIds.add(recSite.Enterprise_ID__c);
                
                if(trigger.isUpdate && (recSite.SC_SITE_Source__c == 'Support' ||recSite.SC_SITE_Source__c == 'GPOC'))
                {
                    if(trigger.oldmap.get(recSite.Id).Enterprise_ID__c!= recSite.Enterprise_ID__c)
                    {
                        setAccIds.add(recSite.Enterprise_ID__c);
                        setAccIds.add(trigger.oldmap.get(recSite.Id).Enterprise_ID__c);
                    }
                }             
            }
        }
               if(trigger.isdelete)
                {
                    for(Site_Association__c  recSite:trigger.old)
                    {
                        If(recSite.SC_SITE_Source__c == 'Support' ||recSite.SC_SITE_Source__c == 'GPOC')                
                        setAccIds.add(recSite.Enterprise_ID__c);
                    }    
                }
                
   if(!Label.Informatica_userid.contains(userinfo.getUserId().substring(0,15)))
       {    
                  
        system.debug('enetred in to debugg ---------------'+setAccIds.size());
         List<Account> lisUpdateAcc=new List<Account>();
         List<Account> lisAcc=[select id, (select id from Site_Association__r) from Account where id in:setAccIds];
         try{
            if(lisAcc!=null && lisAcc.size()>0)
            {
                for(Account recAcc:lisAcc)
                {
                    if(recAcc.Site_Association__r!=null)
                    {
                        List< Site_Association__c > listSite=recAcc.Site_Association__r;
                        recAcc.Count_of_Sites__c= listSite.size();
                    
                    }
                    else
                        recAcc.Count_of_Sites__c=0;
                    lisUpdateAcc.add(recAcc);
                }
            }
            }
            catch(Exception e)
            {
                system.debug('too many queries exception------------');
            }
            system.debug('list size --------------------'+lisUpdateAcc.size());
            if(lisUpdateAcc!=null && lisUpdateAcc.size()>0)
                update lisUpdateAcc;
      }
   else{
        
      if(Trigger.isInsert && trigger.isBefore){
        
          system.debug('enetred in to debugg ---------------'+setAccIds.size());
         List<Account> lisUpdateAcc=new List<Account>();
         List<Account> lisAcc=[select id, (select id from Site_Association__r) from Account where id in:setAccIds];
         
            if(lisAcc!=null && lisAcc.size()>0)
            {
                
                for(Account recAcc:lisAcc)
                {
                    if(recAcc.Site_Association__r!=null)
                    {
                        List< Site_Association__c > listSite=recAcc.Site_Association__r;
                        recAcc.Count_of_Sites__c= listSite.size();
                    
                    }
                    else
                        recAcc.Count_of_Sites__c=0;
                    lisUpdateAcc.add(recAcc);
                }
            }
                     
            system.debug('list size --------------------'+lisUpdateAcc.size());
            if(lisUpdateAcc!=null && lisUpdateAcc.size()>0)
                update lisUpdateAcc;
      } 
    } 
    if(Trigger.isInsert && trigger.isBefore){
        //Execute the below logic only if Site_Source_System__c == “Support”
        //Query on Account object whose name contains ”Generic Support Account” to retrieve the Account Id
        Account acc;
        Site_Association__c provSite ;
        
  
          
            //Assign this Id to CA Account ID(Lookup)[Enterprise_ID__c] field
        boolean executeQueryOnAccount = false;
        
        for(Site_Association__c s:trigger.New){
            if(s.SC_SITE_Source__c == 'Support' ||s.SC_SITE_Source__c =='GPOC'){
                executeQueryOnAccount = true;
                           }      
        }
        if(executeQueryOnAccount){
            //try{
                System.debug('+++++++++acc++++++'+acc);
                acc = [select Id from Account where Name LIKE 'Generic Support Account%' and (Count_of_Sites__c<9950 or Count_of_Sites__c = null) ORDER BY CREATEDDATE DESC LIMIT 1 ];
            //}
            //catch(Exception e){
           // }
        }
        for(Site_Association__c s:trigger.New){
            if(s.SC_SITE_Source__c == 'Support' ||s.SC_SITE_Source__c == 'GPOC' ){
               // s.GU_DUNS_NUMBER__c  =  'SUPPORT';
                if(s.System__c ==null || s.System__c == '')
                    s.System__c='SC';
                if(acc!=null)
                    s.Enterprise_ID__c = acc.Id;  
                //else
                  //  s.addError('No Generic Support Account existing in the system to associate this Site');
                    
                                           
            }   
            
            
                 }
    }
     //}
       //else{
        //system.debug('enetrd in ot els e-------------');
       //}
    
    if(Trigger.isAfter && Trigger.isInsert){
        
        
         Integer provisionalSite = 0;
       
         Set<Id>  siteIds = new Set<Id> ();
         //custom setting that stores prov site of last record created
         Provisional_Site_Number__c provSiteNumber = Provisional_Site_Number__c.getInstance('Last Site No');  
         List<Site_Association__c> provSite = [SELECT ProviSite__c  FROM Site_Association__c  WHERE ProviSite__c != null ORDER BY ProviSite__c  DESC LIMIT 1 ]; 
        
         if((provSiteNumber==null) && (provSite!=null)){
                provSiteNumber = new Provisional_Site_Number__c();
                provSiteNumber.Name = 'Last Site No' ;
                provSiteNumber.Prov_Site_Number__c = Integer.valueof(provSite[0].ProviSite__c)+1;
         }
         else{
                provSiteNumber.Prov_Site_Number__c = Integer.valueof(provSiteNumber.Prov_Site_Number__c)+1;
         }
         upsert provSiteNumber;
             
         if((Trigger.new.size()==1 && Trigger.new[0].SC_SITE_Sanctioned_Party__c=='NOT VALIDATED')||Label.Informatica_userid.contains(userinfo.getUserId().substring(0,15))){
              for(Integer i=0; i<trigger.new.size(); i++){
                  SiteAssociationHandler.doSanctionedPartyCheck(trigger.new[i].Id);
              }
         }
            
             Map<Id,Site_Association__c> tempMap =new  Map<Id,Site_Association__c>();
             Map<Id,Site_Association__c> mapSiteAssociation=New Map<Id,Site_Association__c>([Select Id,SAP_Site_ID__c,SC_TOPS_ID__c from Site_Association__c where id in:trigger.newmap.keyset()]); 
             for(Id recID:mapSiteAssociation.keySet())
            {

                    Site_Association__c siteId = mapSiteAssociation.get(recID);
                    siteId.Id =recID ;
                
                    if(StringUtils.isEmpty(siteId.SAP_Site_ID__c)){
                        if(provisionalSite == 0 ){      
                                    
                          if(provSite != null && provSite.size() >0 && provSite[0].ProviSite__c !=null){
                           
                                 if(provSiteNumber.Prov_Site_Number__c  <= 6999999)
                                        provisionalSite= Integer.valueOf(provSiteNumber.Prov_Site_Number__c )  ;
                                 else 
                                     siteId.addError('Provisional Site Range has  exceeded .Please contact System Adminstrator ');
                        
                            }
                            else 
                                provisionalSite = 6500000 ;
                                
                            }
                          
                        siteId.SAP_Site_ID__c = String.valueOf(provisionalSite) ;
                        siteId.SC_TOPS_ID__c = String.valueOf(provisionalSite) ;
                        siteId.ProviSite__c = provisionalSite ;
                       
                       tempMap.put(recID,siteId);
                        
                    }
                 
                    
            }
          
            if(!tempMap.isEmpty())
               update tempMap.values() ;
            
    }
    
    //This code is added to allow specific list of users to modify only  the sanctioned party field .
    
        List<User> currentUser = [Select Alias From User WHERE Id = :UserInfo.getUserId() LIMIT 1];  
        String alias ;
        for(User currUserr:currentUser)
            alias = currUserr.Alias;   
       
       
        if(!Label.Informatica_userid.contains(userinfo.getUserId().substring(0,15)))
       {   
        if(Trigger.isUpdate && Trigger.isBefore){
    system.debug('is update -=================================================');
            List<SancPartyUserList__c> sanctList= new List<SancPartyUserList__c>();
            Set<String> SancSet = new Set<String>();    
            sanctList=SancPartyUserList__c.getAll().Values();
            boolean allowUsertoModify = false ;
              for(SancPartyUserList__c sl:sanctList){
                          SancSet.add(sl.userPMF__c);
                  }
                 if(SancSet.Contains(alias))
                    {
                        allowUsertoModify =true ;
                                      
                    }   
            
              Map<id,Profile> profileMap = new Map<id,Profile>([Select Id,Name from Profile 
                                                          Where Name LIKE 'System Adm%'
                                                             OR Name LIKE '1.0 CA Sys Admin%'
                                                              OR Name = 'Global Service Center'
                                                              OR Name = 'Global GSC User'
                                                               OR Name = 'Global GSC PRM Support'
                                                             OR Name = 'Service Cloud Bus Admin' Limit : Limits.getLimitQueryRows()-Limits.getQueryRows()
                                                         ]);   
            for(Site_Association__c siteAssociation : Trigger.New){
          
                   if((Trigger.oldMap.get(siteAssociation.Id).SC_SITE_Sanctioned_Party__c!=null && Trigger.oldMap.get(siteAssociation.Id).SC_SITE_Sanctioned_Party__c.equalsIgnoreCase('Yes'))&& ((!(profileMap.containsKey(UserInfo.getProfileId())) && !allowUsertoModify) ||(allowUsertoModify && Trigger.oldMap.get(siteAssociation.Id).SC_SITE_Sanctioned_Party__c==(Trigger.newMap.get(siteAssociation.Id).SC_SITE_Sanctioned_Party__c))) ){     
                        siteAssociation.addError('Site Record with Sanctioned Party cannot be edited');
                  }
                
             }
             //end of modified code  
                                                         
    }
       }
       else{
        system.debug('no sanctioned aprty------------------------');
       }
    
    //code for updating account information of site to cases
    if(Trigger.isUpdate && Trigger.isAfter){
   
    Map<id,id> siteMap=new  Map<id,id>();
        
     for (Site_Association__c site : Trigger.new){
     if(trigger.oldmap.get(site.Id).Enterprise_ID__c!= site.Enterprise_ID__c){
       
        siteMap.put(site.id,site.Enterprise_ID__c);
        }
        }
        //Map<account,String> accountmap=new Map<account,String>([select id,])
        system.debug('site map ------------------------------------'+siteMap.isEmpty());
    if(!siteMap.isEmpty())
    FutureMethod_Assign_support_Generic.updateaccountoncase(siteMap);
    }
    
    
}