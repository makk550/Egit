trigger AutoAssign on Case (after insert,before update,after update,before Insert) {
  //log.startTrigger('AutoAssign');
   
 if(Label.Integration_UserProfileIds.contains(userinfo.getProfileId().substring(0,15)))
       return;
    
    if(Trigger.isbefore &&(Trigger.isInsert || Trigger.isUpdate))
      {       
              
               boolean isDefaultExpired = false;
              Set<id> CAControllerid = new Set<id>();
              Map<id, id> compCtrlMap = new Map<id,id>();
              DateTime dT = System.now();
              Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
              List<CA_Product_Component__c> ProComplist=new List<CA_Product_Component__c>();
                    for (case c : Trigger.new) 
                    {
                        
                    if(c.CA_Product_Component__c==null)
                    {
                    
                    CAControllerid.add(c.CA_Product_Controller__c);
                    }
                    }
         
                     if(!CAControllerid.isempty())
                     {
                     
                     ProComplist= [select id,CA_Product_Controller__c,component_expiration_date__c,Internal_Presentation_Only__c from CA_Product_Component__c  where CA_Product_Controller__c in:CAControllerid and Default_Component_for_this_CA_Product__c = true ORDER BY CREATEDDATE DESC
                    limit 1];
                    
                    }
                     if(ProComplist!=null && ProComplist.size()>0)
                     {
                     
                     for(CA_Product_Component__c  prodComo :ProComplist){
                     if(!(prodComo.component_expiration_date__c<myDate  && prodComo.Internal_Presentation_Only__c==false)||string.valueof(prodComo.component_expiration_date__c)==''){
                     compCtrlMap.put(prodComo.CA_Product_Controller__c,prodComo.id);
                     system.debug('^^^^^^^^^^^^^^^^in if'+compCtrlMap+System.now()+prodComo.component_expiration_date__c);
                     }
                     else{
                     isDefaultExpired =true;
                     
                     }
                     
                     }}
         
                     if(compCtrlMap!=null && !compCtrlMap.isempty())
                     {
                     
                     for (case c : Trigger.new) 
                     {
                         if(c.CA_Product_Component__c == null)
                         {
                             c.CA_Product_Component__c=compCtrlMap.get(c.CA_Product_Controller__c);
                         }
                     }
                     }
                      if(isDefaultExpired)
                        {   
                        
                      for (case c : Trigger.new) 
                                c.addError('Default Component for the product is expired.Please select the component for this case and change the default component');
                                return;   
                         }
                         
                         
                     if(compCtrlMap.isempty()){
                     
                    if(!CAControllerid.isempty())
                        {
                        
                            for (case c : Trigger.new) 
                                c.addError('Component cannot be blank for this product.');
                                return; 
                        }
                              
                     }
                     isDefaultExpired=false;
               
      }
      
      //By Sachin Kadian for TPC Team Logic
      
       Set<case> casesNotAssignedToTPC = new Set<Case>();              
       Set<String> componentValues = new Set<String>();     
       Map<Id,Id> caseToSiteIdMap = new Map<Id,Id>();  
       System.debug('@@@ Before my code');      
       if(Trigger.isBefore && Trigger.isInsert){   
           System.debug('@@@ Inside before Insert');     
           for(Case record : Trigger.New){      
               System.debug('##Case Before Insert'+ record);        
               caseToSiteIdMap.put(record.Site_Association__c,record.Id);       
               componentValues.add(record.CA_Product_Component__c);    
               System.debug('1'); 
           }        
           Map<String,Id> queueList = new Map<String,Id>();     
           for(Group queue : [select Id,name from group where Type = 'Queue']){     
               queueList.put(queue.name,queue.Id);      
           }        
           Map<Id,String> caseToSitemap = new Map<Id,String>();     
           if(!caseToSiteIdMap.isEmpty()){      
               for(Site_Association__c  site:  [select id,SC_TOPS_ID__c  from Site_Association__c where id IN : caseToSiteIdMap.keySet()]){     
                   caseToSitemap.put(caseToSiteIdMap.get(site.Id),site.SC_TOPS_ID__c );     
               }        
           }        
           Map<Id,TPC_Team__c> TPCTeams = new Map<Id,TPC_Team__c>([select id,Location__c,Tops_Site_Id__c,name from TPC_Team__c]);       
           Map<Id,List<Id>> TeamCompMap = new Map<Id,List<Id>>();       
           for(TPCTeamProductCodeAssociation__c TeamComp : [select id,CA_Product_Component__c,Component_Code__c,TPC_Team__c  from TPCTeamProductCodeAssociation__c where TPC_Team__c IN: TPCTeams.keySet() AND CA_Product_Component__c IN : componentValues]){      
               List<Id> TCPTeamIds = TeamCompMap.get(TeamComp.CA_Product_Component__c);     
               if(TCPTeamIds == NULL){      
                   TCPTeamIds = new List<Id>();     
                   TeamCompMap.put(TeamComp.CA_Product_Component__c,TCPTeamIds);        
               }        
               TCPTeamIds.add(TeamComp.TPC_Team__c);        
           }        
           for(Case newCase: Trigger.New){      
           System.debug('###2');
               Boolean isAllocatedToTeam = false;       
               if(TeamCompMap.containskey(newCase.CA_Product_Component__c)){        
                    for(Id TeamId : TeamCompMap.get(newCase.CA_Product_Component__c)){   
                        System.debug('###3');   
                        TPC_Team__c TPCTeam = TPCTeams.get(TeamId);    
                        System.debug('###Tpc Team '+TPCTeam.Id+'-'+newCase.Site_Country__c); 
                        System.debug('###Tpc site '+TPCTeam.Tops_Site_Id__c+'-'+caseToSitemap.get(newCase.Id)); 
                        if(TPCTeam.Location__c.contains(newCase.Site_Country__c) && TPCTeam.Tops_Site_Id__c.contains(caseToSitemap.get(newCase.Id))){    
                            System.debug('###4');   
                            newCase.TPC_Team__c = TPCTeam.Id;       
                            if(queueList.containsKey(TPCTeam.name))     
                            newCase.ownerId = queueList.get(TPCTeam.name);      
                            isAllocatedToTeam = true;       
                        }       
                    }       
               }        
               if(!isAllocatedToTeam)       
                   casesNotAssignedToTPC.add(newCase);      
               System.debug('##Case1 Before Insert'+ newCase);      
           }        
       }        
       
      
      
  if(Trigger.isBefore && Trigger.isUpdate){
            Set<ID> ids = Trigger.newMap.keySet();
			List<LiveChatTranscript> lCT = [SELECT Id,closure_reason__c,caseId FROM LiveChatTranscript WHERE CaseId in:ids];          
            for(case chatCase : Trigger.new) {
                 if(chatCase.origin=='Chat'){
                   chatCase.ownerId = chatCase.createdById;
                      for(LiveChatTranscript cLCT: lCT){
                         if(cLCT.caseId == chatCase.Id && cLCT.closure_reason__c == null && chatCase.status == 'Closed')
                         {
                             string link ='https://ca--fsb1--c.cs42.visual.force.com/apex/TranscriptClosure?id='+chatCase.Id; 
                             chatCase.addError('Case can not be closed without closure reason field on live chat transcript record.<a href='+link+' target="_blank">Click on this link to update live chat transcript record</a>',false);
                         }
                     } 
                 }
                 
            }
           
      }
 
       
      if(Trigger.isInsert && Trigger.isAfter)
      {
           List<case> ls = new List<case>();
			
            for (case c : Trigger.new) {
               System.debug('##Case After Insert'+ c);
                if(c.TPC_Team__c == NULL) {
                    ls.add(new case(id = c.id));
                }
            }

                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                try{
                Database.update(ls, dmo);
                }catch(Exception e){}
                
            List<String> xmlStrings = new List<String>();                
            for(case c : Trigger.new)
            {
                String xmlString = '<createCaseFolderRequest><caseId>'+c.Id+'</caseId><caseNumber>'+c.CaseNumber+'</caseNumber><siteId>'+c.Site_Id__c+'</siteId></createCaseFolderRequest>';  
                xmlStrings.add(xmlString);          
            }
            if(!(Test.isRunningTest()))
            {
                CaseDirectoryCreate.callEAIforDirectoryCreate(xmlStrings);                 
            }
                
      }
      
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        List<case> ls = new List<case>();
        List<id> tpcAssignedCaseList=new List<id>();
        for (case c : Trigger.new) {
            case oldCase = (case)Trigger.OldMap.get(c.id);
            if(c.Check_to_Auto_Re_Assign_this_case__c && (c.Component_Code__c != null && (c.Component_Code__c!=oldCase.Component_Code__c)))
            {
                ls.add(new case(id = c.id));
            }
            //Check if updated with tpc assignment. 
            if(c.TPC_TEAM__c != null && oldCase.TPC_Team__c == null) {
                tpcAssignedCaseList.add(c.Id);
            }
        }
        //Iterate all task for the tpc case and update with visible in portal flag true.
        if(!tpcAssignedCaseList.isEmpty()) {
            List<Task> tpcTaskList=[SELECT id FROM Task WHERE whatid in :tpcAssignedCaseList and IsVisibleInSelfService=false];
            System.debug('tpctask list.' + tpcTaskList.size() );
            for(Task tpcTask:tpcTaskList) {
                tpcTask.IsVisibleInSelfService=true;      
            }
            if(!tpcTaskList.isEmpty()) {
                update tpcTaskList;    
            }
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        try{
            Database.update(ls, dmo);
        }catch(Exception e){}
    }      
     
    if(trigger.isbefore && Trigger.isUpdate)
    {   
       
        //Added for support Offering flow 
       // SiteUtilOfferingCaseSupportEngineer.executeOfferingCaseOwner(Trigger.New); commented for B-05262
        //End of Aditya   
        //FOr SPIKE STORY TEST US118509	
       // SiteUtilOfferingCaseSupportEngineer.testcasecomments(Trigger.New);     
        
        Set<String> QueSet = new Set<String>();
        List<User_Skills__c> listUS= new List<User_Skills__c>();
        List<User_Skills__c> listUS1= new List<User_Skills__c>();
        set<string> setCou = new set<String>();
        set<String> setCom = new set<String>();
        set<id> setId= new set<id>();
        List<User_Skills__c> finalusskillList = new List<User_Skills__c>();
        List<Auto_Assign_Queues__c> AssList = new List<Auto_Assign_Queues__c>();
        AssList=Auto_Assign_Queues__c.getAll().Values();
        for(Auto_Assign_Queues__c Aq:AssList)
        QueSet.add(Aq.Queue_Id__c);

        for(case recCase :Trigger.new)
        {
            if((recCase.Status !='Closed') && QueSet.Contains((String.ValueOf(recCase.OwnerId)).subString(0,15)))
            {
                recCase.OAE_Case_close_and_transfer__c=true;
                recCase.Assignment_rule_fire__c=false;
                setCou.add(recCase.Site_Country__c);
                setCom.add(recCase.CA_Product_Component__c);
            }   
        }
        Map<String,List<User_Skills__c>> mapUS=new Map<String,List<User_Skills__c>>();
        Map<String,List<User_Skills__c>> mapSevWOUS=new Map<String,List<User_Skills__c>>();
        Map<String,List<User_Skills__c>> mapUSTopSiteNull=new Map<String,List<User_Skills__c>>();
        Map<String,List<User_Skills__c>> mapUSTopSiteNullSevWOUS=new Map<String,List<User_Skills__c>>();
        if(setCou.size()>0 && setCom.size()>0)
        {
            listUS=[select id,Cases_Assigned__c,Cases_assigned_perday__c,Case_Severity__c,Component_Code__c,Maximum_Cases_Per_Day__c,Start_Time1__c,Start_Time2__c,Start_Time3__c,Start_Time4__c,Start_Time5__c,Start_Time6__c,Start_Time7__c,Start_Time10__c,Start_Time20__c,Start_Time30__c,Start_Time40__c,Start_Time50__c,Start_Time60__c,Start_Time70__c,
            End_Time1__c,End_Time2__c,End_Time3__c,End_Time4__c,End_Time5__c,End_Time6__c,End_Time7__c,End_Time10__c,End_Time20__c,End_Time30__c,End_Time40__c,End_Time50__c,End_Time60__c,End_Time70__c,
             Maximum_Severity1_Cases__c,Maximum_Total_Cases__c,Severity_1_cases_assigned__c,Severity_1_Utilisation__c,User__c,Business_Hours__c,Business_Hours__r.TimeZoneSidKey,Utilization__c,Utilsation_per_day__c,Location__c,Tops_Site_ID__c from User_Skills__c  where User__c!=null and (Auto_Assignment__c = TRUE) and (Utilsation_per_day__c<100 and Utilization__c<100) and((Vacation_Start_Date__c=:null and Vacation_End_Date__c=:null) or (Vacation_Start_Date__c>:System.today())  or (Vacation_End_Date__c<:System.today()))  Order By Utilsation_per_day__c,Utilization__c,Severity_1_Utilisation__c];

             Set<ID> ids = New Set<ID>();             
            For (User_Skills__c  c : listUS )
            {
                boolean flag = true;
              if(c.Business_Hours__c!=null && (BusinessHours.isWithin(c.Business_Hours__c,system.now())))
              {
                   string str1 = (System.now().format('yyyy-MM-dd',c.Business_Hours__r.TimeZoneSidKey));
                  DateTime tDate =Date.valueOf(str1);
                  if((tDate.format('EEEE')) == 'Sunday'){
                      if(c.Start_Time1__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time1__c, c.End_Time1__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time10__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time10__c, c.End_Time10__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      }
                  else if((System.now().format('EEEE')) == 'Monday'){
                      if(c.Start_Time3__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time2__c, c.End_Time2__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time30__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time20__c, c.End_Time20__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                  }
                  else if((System.now().format('EEEE')) == 'Tuesday'){
                      if(c.Start_Time3__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time3__c, c.End_Time3__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time30__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time30__c, c.End_Time30__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                  }
                  else if((System.now().format('EEEE')) == 'Wednesday'){
                      if(c.Start_Time4__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time4__c, c.End_Time4__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time40__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time40__c, c.End_Time40__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                  }
                  else if((System.now().format('EEEE')) == 'Thursday'){
                      if(c.Start_Time5__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time5__c, c.End_Time5__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time50__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time50__c, c.End_Time50__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                  }
                  else if((System.now().format('EEEE')) == 'Friday'){
                      if(c.Start_Time6__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time6__c, c.End_Time6__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time60__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time60__c, c.End_Time60__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                  }
                  else if((System.now().format('EEEE')) == 'Saturday'){
                      if(c.Start_Time7__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time7__c, c.End_Time7__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                      if(c.Start_Time70__c != null){if(BreakPeriodCalculator.validateAutoassign(c.Start_Time70__c, c.End_Time70__c,c.Business_Hours__r.TimeZoneSidKey)){ flag = false;}}
                  }
			if(flag != false){
    				ids.Add(c.ID );}
              }
            }
            
            System.debug('Eligible US - ' + ids.size());
            System.debug('Eligible US - ' + setCom);
            
        //    System.debug ('Ramacount: ' + [SELECT count() FROM UserSkillProductCodeAssociation__c Where User_Skills__c IN : ids]);
            
            Map<ID,List<UserSkillProductCodeAssociation__c>> mapRecs = New Map <ID,List<UserSkillProductCodeAssociation__c>>();
            
            For ( UserSkillProductCodeAssociation__c u :  [ SELECT Id, User_Skills__c, CA_Product_Component__c FROM UserSkillProductCodeAssociation__c Where User_Skills__c IN : ids and CA_Product_Component__c IN : setCom] )
            
            {
                If ( mapRecs.containsKey(u.User_Skills__c) == False )
               {
                   List<UserSkillProductCodeAssociation__c> li = New List<UserSkillProductCodeAssociation__c>();
                   li.Add(u);
                   mapRecs.Put(u.User_Skills__c , li);
                }
                Else If (mapRecs.containsKey(u.User_Skills__c))
                {
                   List<UserSkillProductCodeAssociation__c> li = New List<UserSkillProductCodeAssociation__c>();
                   li = mapRecs.Get(u.User_Skills__c);
                   li.Add(u);
                   mapRecs.Put(u.User_Skills__c, li);
                }
            
            }
            
             if(listUS!=null &&listUS.size()>0)
           
            for(User_Skills__c recUS :listUS)
            {    
                
            
            if(recUS.Business_Hours__c!=null && (BusinessHours.isWithin(recUS.Business_Hours__c,system.now())))
               //if(recUS.Component_Code__c!=null)
                If ( mapRecs.ContainsKey(recUS.ID) )
                {  
                for(UserSkillProductCodeAssociation__c sCC: mapRecs.Get(recUS.ID))
                {
                
                  if(recUS.Tops_Site_ID__c=='*')
                  {
                  
                      if(recUS.Location__c!=null)
                        for(String sLoc: (recUS.Location__c.split(';')))
                        {
                        
                            
                            if(recUS.Case_Severity__c!=null)
                            {
                                for(String sCaseSev: (recUS.Case_Severity__c.split(';')))
                                {
                                    List<User_Skills__c> listTempUSTopNull=mapUSTopSiteNull.get(sCC.CA_Product_Component__c+sLoc+sCaseSev);
                                    if(null==listTempUSTopNull)
                                    {
                                        listTempUSTopNull=new List<User_Skills__c>();
                                        mapUSTopSiteNull.put(sCC.CA_Product_Component__c+sLoc+sCaseSev,listTempUSTopNull);
                                    }
                                    listTempUSTopNull.add(recUS);
                                }
                            }
                            else
                            {
                                List<User_Skills__c> listTempUSTopNullSevWOUS=mapUSTopSiteNullSevWOUS.get(sCC+sLoc);
                                if(null==listTempUSTopNullSevWOUS)
                                {
                                    listTempUSTopNullSevWOUS=new List<User_Skills__c>();
                                    mapUSTopSiteNullSevWOUS.put(sCC.CA_Product_Component__c+sLoc,listTempUSTopNullSevWOUS);
                                }
                                listTempUSTopNullSevWOUS.add(recUS);
                            }
                        }
                  }
                  else
                  {
                      if(recUS.Tops_Site_ID__c!=null)
                      for(String sTS: (recUS.Tops_Site_ID__c.split(';')))
                      {
                          if(recUS.Location__c!=null)
                        for(String sLoc: (recUS.Location__c.split(';')))
                        {
                            if(recUS.Case_Severity__c!=null)
                            for(String sCaseSev: (recUS.Case_Severity__c.split(';')))
                            {
                                List<User_Skills__c> listTempUS=mapUS.get(sCC.CA_Product_Component__c+sLoc+sCaseSev+sTS);
                                if(null==listTempUS)
                                {
                                    listTempUS=new List<User_Skills__c>();
                                    mapUS.put(sCC.CA_Product_Component__c+sLoc+sCaseSev+sTS,listTempUS);
                                }
                                listTempUS.add(recUS);
                            }
                            List<User_Skills__c> listTempWOUS=mapSevWOUS.get(sCC.CA_Product_Component__c+sLoc+sTS);
                            if(null==listTempWOUS)
                            {
                                listTempWOUS=new List<User_Skills__c>();
                                mapSevWOUS.put(sCC.CA_Product_Component__c+sLoc+sTS,listTempWOUS);
                            }
                            listTempWOUS.add(recUS);
                        }
                    }
                }
              }
              }
            }
        }   
        //Map<Id,Case> mapCase=New Map<Id,Case>([Select Id,Site_Association__r.Name from Case where id in:trigger.newmap.keyset()]); 
        
        Map<Id, integer> severity1USUpdates = new Map<Id, integer>();
        Map<Id, integer> otherUSUpdates = new Map<Id, integer>();
        Set<Id> ownerSet = new Set<Id>();
        
        List<User_Skills__c> listExistUSSkills=new List<User_Skills__c>();
        List<Case> CaseEmailAlertList = new List<Case>();
        for(case recCase :trigger.new)
        {
            if((recCase.Status !='Closed') && QueSet.Contains((String.ValueOf(recCase.OwnerId)).subString(0,15))&& UtilityFalgs.bCaseAssignedFlag)
            {
            
                UtilityFalgs.bCaseAssignedFlag=false;
                listExistUSSkills=new List<User_Skills__c>();
                if(recCase.Severity__c!=null)
                {
                    if(mapUS.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Severity__c+recCase.Tops_Support_Site_ID__c)!=null)
                    {
                        listExistUSSkills=mapUS.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Severity__c+recCase.Tops_Support_Site_ID__c);
                    }
                    else if(mapUSTopSiteNull.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Severity__c)!=null)
                    {
                        listExistUSSkills.addAll(mapUSTopSiteNull.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Severity__c));
                    }
                     //system.debug('#####'+listExistUSSkills[0]+listExistUSSkills.size());
                }
                else
                {
                    if(mapSevWOUS.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Tops_Support_Site_ID__c)!=null)
                    listExistUSSkills=mapSevWOUS.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Tops_Support_Site_ID__c);
                    if(mapUSTopSiteNullSevWOUS.get(recCase.CA_Product_Component__c+recCase.Site_Country__c)!=null)
                     {
                         listExistUSSkills.addAll(mapUSTopSiteNullSevWOUS.get(recCase.CA_Product_Component__c+recCase.Site_Country__c+recCase.Severity__c));
                     }
                   // system.debug('#####'+listExistUSSkills[0]+listExistUSSkills.size());
                }
                if(recCase.Severity__c=='1')
                {
                    if(listExistUSSkills!=null && listExistUSSkills.size()>0)
                    {
                        if(listExistUSSkills[0].Severity_1_Utilisation__c<100 && listExistUSSkills[0].Utilsation_per_day__c<100 &&listExistUSSkills[0].Utilization__c<100)
                        recCase.OwnerId=listExistUSSkills[0].User__c;
                        Id IdUS=listExistUSSkills[0].Id;
                        Integer iMin=0;
                        for(Integer iCnt=0;iCnt<listExistUSSkills.size()-1;iCnt++)
                        {
                            if(listExistUSSkills[iCnt].Utilization__c >= listExistUSSkills[iCnt+1].Utilization__c)
                            {
                                iMin=iCnt+1;
                            }
                        }
                        if(listExistUSSkills[iMin].Severity_1_Utilisation__c<100 && listExistUSSkills[iMin].Utilsation_per_day__c<100 &&listExistUSSkills[iMin].Utilization__c<100)
                        {
                            recCase.OwnerId=listExistUSSkills[iMin].User__c;
                            //recCase.BusinessHoursId=listExistUSSkills[iMin].Business_Hours__c;
                            ownerSet.add(listExistUSSkills[iMin].User__c);
                            if(severity1USUpdates.containsKey(listExistUSSkills[iMin].User__c))
                            {
                                integer count = severity1USUpdates.get(listExistUSSkills[iMin].User__c);
                                severity1USUpdates.put(listExistUSSkills[iMin].User__c, count+1);
                            }
                            else
                            {
                                severity1USUpdates.put(listExistUSSkills[iMin].User__c, 1);
                            }
                            
                            /*if(listExistUSSkills[iMin].Severity_1_cases_assigned__c!=null)
                                listExistUSSkills[iMin].Severity_1_cases_assigned__c=listExistUSSkills[iMin].Severity_1_cases_assigned__c+1;
                            else
                                listExistUSSkills[iMin].Severity_1_cases_assigned__c=1;
                                
                                if(listExistUSSkills[iMin].Cases_assigned_perday__c!=null)
                                listExistUSSkills[iMin].Cases_assigned_perday__c=listExistUSSkills[iMin].Cases_assigned_perday__c+1;
                            else
                                listExistUSSkills[iMin].Cases_assigned_perday__c=1;
                                
                            if(listExistUSSkills[iMin].Cases_Assigned__c!=null)
                                listExistUSSkills[iMin].Cases_Assigned__c=listExistUSSkills[iMin].Cases_Assigned__c+1;
                            else
                                listExistUSSkills[iMin].Cases_Assigned__c=1;*/
                        }
        
                    }
                }
                
                else
                {
                    if(listExistUSSkills!=null && listExistUSSkills.size()>0)
                    {
                        
                        if(listExistUSSkills[0].Utilsation_per_day__c<100 &&listExistUSSkills[0].Utilization__c<100)
                        recCase.OwnerId=listExistUSSkills[0].User__c;
                        Id IdUS=listExistUSSkills[0].Id;
                        Integer iMin=0;
                        for(Integer iCnt=0;iCnt<listExistUSSkills.size()-1;iCnt++)
                        {
                            if(listExistUSSkills[iCnt].Utilsation_per_day__c>listExistUSSkills[iCnt+1].Utilsation_per_day__c)
                            {
                                iMin=iCnt+1;
                            }
                        }
                        if(listExistUSSkills[iMin].Utilsation_per_day__c<100 && listExistUSSkills[iMin].Utilization__c<100)
                        {
                            recCase.OwnerId=listExistUSSkills[iMin].User__c;
                            //recCase.BusinessHoursId=listExistUSSkills[iMin].Business_Hours__c;

                            ownerSet.add(listExistUSSkills[iMin].User__c);
                            
                            if(otherUSUpdates.containsKey(listExistUSSkills[iMin].User__c))
                            {
                                integer count = otherUSUpdates.get(listExistUSSkills[iMin].User__c);
                                otherUSUpdates.put(listExistUSSkills[iMin].User__c, count+1);
                            }
                            else
                            {
                                otherUSUpdates.put(listExistUSSkills[iMin].User__c, 1);
                            }                            
                            
                            
                            /*if(listExistUSSkills[iMin].Cases_assigned_perday__c!=null)
                                listExistUSSkills[iMin].Cases_assigned_perday__c=listExistUSSkills[iMin].Cases_assigned_perday__c+1;
                            else
                                listExistUSSkills[iMin].Cases_assigned_perday__c=1;
                             if(listExistUSSkills[iMin].Cases_Assigned__c!=null)
                                listExistUSSkills[iMin].Cases_Assigned__c=listExistUSSkills[iMin].Cases_Assigned__c+1;
                            else
                                listExistUSSkills[iMin].Cases_Assigned__c=1;   */
                                
                        }
                        
                        else 
                        recCase.OwnerId=label.Auto_Assign_Queue;
                    }
                }
                String testOwner = recCase.OwnerId;
                if(!(testOwner.startsWith('00G')))
                {
                    CaseEmailAlertList.add(recCase);
                }
            }  
        }
        if(CaseEmailAlertList.size() > 0)
        {
            UtilityFalgs.sendNotificationToAssgnUser(CaseEmailAlertList);
            UtilityFalgs.sentAlert=true;
        }
        
        if(ownerSet.size() > 0)
        {
            List<User_Skills__c> ownerUserSkillList=[select id,Cases_Assigned__c,Cases_assigned_perday__c,Severity_1_cases_assigned__c,User__c from User_Skills__c  where User__c IN:ownerSet]; 
            if(severity1USUpdates.size() > 0)
            {
            //UtilityFalgs.bCaseAssignedFlag=false;
                for(Id myId : severity1USUpdates.keySet())
                {
                    for(User_Skills__c myUS : ownerUserSkillList)
                    {
                        if(myUS.User__c == myId)
                        {
                            integer myCount = severity1USUpdates.get(myId);
                        
                            if(myUS.Severity_1_cases_assigned__c!=null)
                                myUS.Severity_1_cases_assigned__c=myUS.Severity_1_cases_assigned__c+myCount;
                            else
                                myUS.Severity_1_cases_assigned__c=myCount;
                                
                            if(myUS.Cases_assigned_perday__c!=null)
                                myUS.Cases_assigned_perday__c=myUS.Cases_assigned_perday__c+myCount;
                            else
                                myUS.Cases_assigned_perday__c=myCount;
                                
                            if(myUS.Cases_Assigned__c!=null)
                                myUS.Cases_Assigned__c=myUS.Cases_Assigned__c+myCount;
                            else
                                myUS.Cases_Assigned__c=myCount;                            
                        }
                    }
                }
              }
                

            if(otherUSUpdates.size() > 0)
            {
            //UtilityFalgs.bCaseAssignedFlag=false;
                for(Id myId : otherUSUpdates.keySet())
                {
                    for(User_Skills__c myUS : ownerUserSkillList)
                    {
                        if(myUS.User__c == myId)
                        {
                            integer myCount = otherUSUpdates.get(myId);
                        
                            if(myUS.Cases_assigned_perday__c!=null)
                                myUS.Cases_assigned_perday__c=myUS.Cases_assigned_perday__c+myCount;
                            else
                                myUS.Cases_assigned_perday__c=myCount;
                                
                            if(myUS.Cases_Assigned__c!=null)
                                myUS.Cases_Assigned__c=myUS.Cases_Assigned__c+myCount;
                            else
                                myUS.Cases_Assigned__c=myCount;                            
                        }
                    }
                }
            }  
            
            if(ownerUserSkillList!=null && ownerUserSkillList.size()>0)
            {
                try
                {
                    Update ownerUserSkillList;
                }
                catch(Exception e){}
            }            
        }
    }
    
    
    if(trigger.isafter && trigger.isupdate)
    {
        if(UtilityFalgs.bCaseAssignedFlag)
        {
            Map<Id,List<Case>> mapClosedCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapTransOldCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapTransferredCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapSev1ClosedCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapSev1TransferredCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapSev1OldTransferredCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapTodayClosedCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapReOpenedCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapSev1ReOpenedCases=new Map<Id,List<Case>>();
            Map<Id,List<Case>> mapSev1PromotionCases = new Map<Id, List<Case>>();
            Map<Id,List<Case>> mapSev1DemotionCases = new Map<Id, List<Case>>();
            
            Set<Id> setOwnerIds=new Set<Id>();
            
            for(Case recCase:trigger.new)
            {
                system.debug('******'+recCase);
                
                if(recCase.Severity__c=='1' && (Trigger.oldmap.get(recCase.id).Severity__c!= null && (Trigger.oldmap.get(recCase.id).Severity__c=='2' || Trigger.oldmap.get(recCase.id).Severity__c=='3' || Trigger.oldmap.get(recCase.id).Severity__c=='4')))
                {
                    setOwnerIds.add(recCase.OwnerId);
                    List<Case> listTempCases=mapSev1PromotionCases.get(recCase.OwnerId);
                    if(listTempCases==null)
                    {
                        listTempCases=new list<Case>();
                        mapSev1PromotionCases.put(recCase.OwnerId,listTempCases);
                    }
                    listTempCases.add(recCase);                    
                }
                
                if((recCase.Severity__c=='2' || recCase.Severity__c=='3' || recCase.Severity__c=='4') && (Trigger.oldmap.get(recCase.id).Severity__c!= null && (Trigger.oldmap.get(recCase.id).Severity__c=='1')))
                {
                    setOwnerIds.add(recCase.OwnerId);
                    List<Case> listTempCases=mapSev1DemotionCases.get(recCase.OwnerId);
                    if(listTempCases==null)
                    {
                        listTempCases=new list<Case>();
                        mapSev1DemotionCases.put(recCase.OwnerId,listTempCases);
                    }
                    listTempCases.add(recCase);                    
                }                
                
                if(recCase.Status=='Closed' && Trigger.oldmap.get(recCase.id).status!='Closed')
                {
                    if(UtilityFalgs.bCaseClosedFlag)
                    {
                        UtilityFalgs.bCaseClosedFlag=false;
                        setOwnerIds.add(recCase.OwnerId);
                        List<Case> listTempCases=mapClosedCases.get(recCase.OwnerId);
                        if(listTempCases==null)
                        {
                            listTempCases=new list<Case>();
                            mapClosedCases.put(recCase.OwnerId,listTempCases);
                        }
                        listTempCases.add(recCase);
                        if(recCase.Severity__c=='1')
                        {
                            List<Case> listTempSev1Cases=mapSev1ClosedCases.get(recCase.OwnerId);
                            if(listTempSev1Cases==null)
                            {
                                listTempSev1Cases=new list<Case>();
                                mapSev1ClosedCases.put(recCase.OwnerId,listTempSev1Cases);
                                
                            }
                            listTempSev1Cases.add(recCase);
                        }
                        
                        
                        if(recCase.CreatedDate.Date()==recCase.Closeddate.Date() && recCase.CreatedDate.Date()==System.Today())
                        {
                        
                            List<Case> listTempTodayCases=mapTodayClosedCases.get(recCase.OwnerId);
                            if(listTempTodayCases==null)
                            {
                                listTempTodayCases=new list<Case>();
                                mapTodayClosedCases.put(recCase.OwnerId,listTempTodayCases);
                                
                            }
                            listTempTodayCases.add(recCase);
                           
                        }
                    }
                	
                }
                if(Trigger.OldMap.get(recCase.Id).Status!=recCase.Status && Trigger.OldMap.get(recCase.Id).Status=='Closed')
                {
                    if(UtilityFalgs.bCaseReOpenedFlag)
                    {
                        UtilityFalgs.bCaseReOpenedFlag=false;
                        setOwnerIds.add(recCase.OwnerId);
                        List<Case> listTempCases=mapReOpenedCases.get(recCase.OwnerId);
                        if(listTempCases==null)
                        {
                            listTempCases=new list<Case>();
                            mapReOpenedCases.put(recCase.OwnerId,listTempCases);
                        }
                        listTempCases.add(recCase);
                        if(recCase.Severity__c=='1')
                        {
                            List<Case> listTempSev1Cases=mapSev1ReOpenedCases.get(recCase.OwnerId);
                            if(listTempSev1Cases==null)
                            {
                                listTempSev1Cases=new list<Case>();
                                mapSev1ReOpenedCases.put(recCase.OwnerId,listTempSev1Cases);
                                
                            }
                            listTempSev1Cases.add(recCase);
                        }
                    }
                }
                //system.debug('******'+Trigger.oldmap.get(recCase.id));
                
                //system.debug('******'+Trigger.oldmap.get(recCase.id).ownerid);
                String caseOwner=recCase.ownerid;
                String caseOwnerold=Trigger.oldmap.get(recCase.id).ownerid;

                if((recCase.ownerid!=Trigger.oldmap.get(recCase.id).ownerid) && (caseOwner.substring(0, 3)!='00G' || caseOwnerold.substring(0, 3)!='00G'))
                {
                    if(UtilityFalgs.bCaseTransferredFlag)
                    {
                        UtilityFalgs.bCaseTransferredFlag=false;
                        
                        setOwnerIds.add(recCase.OwnerId);
                        setOwnerIds.add(Trigger.oldmap.get(recCase.id).ownerid);
                        List<Case> listTempCases=mapTransferredCases.get(recCase.OwnerId);
                        if(listTempCases==null)
                        {
                            listTempCases=new list<Case>();
                            if(caseOwner.substring(0, 3)!='00G')
                            {
                            mapTransferredCases.put(recCase.OwnerId,listTempCases);
                            }
                        }
                        listTempCases.add(recCase);
                        List<Case> listTempOldCases=mapTransOldCases.get(Trigger.oldmap.get(recCase.id).ownerid);
                        if(listTempOldCases==null)
                        {
                            listTempOldCases=new list<Case>();
                            if(caseOwnerold.substring(0, 3)!='00G')
                            {
                            mapTransOldCases.put(Trigger.oldmap.get(recCase.id).ownerid,listTempOldCases);
                            }
                        }
                        listTempOldCases.add(recCase);
                        if(recCase.Severity__c=='1')
                        {
                            List<Case> listTempSev1Cases=mapSev1TransferredCases.get(recCase.OwnerId);
                            if(listTempSev1Cases==null)
                            {
                                listTempSev1Cases=new list<Case>();
                                mapSev1TransferredCases.put(recCase.OwnerId,listTempSev1Cases);
                                
                            }
                            listTempSev1Cases.add(recCase);
                            List<Case> listTempSev1OldCases=mapSev1OldTransferredCases.get(Trigger.oldmap.get(recCase.id).ownerid);
                            if(listTempSev1OldCases==null)
                            {
                                listTempSev1OldCases=new list<Case>();
                                mapSev1OldTransferredCases.put(Trigger.oldmap.get(recCase.id).ownerid,listTempSev1OldCases);
                            }
                            listTempSev1OldCases.add(recCase);
                            
                        }
                        /*
                        
                        if(recCase.CreatedDate.Date()==recCase.Closeddate.Date() && recCase.CreatedDate.Date()==System.Today())
                        {
                        
                            List<Case> listTempTodayCases=mapTodayClosedCases.get(recCase.OwnerId);
                            if(listTempTodayCases==null)
                            {
                                listTempTodayCases=new list<Case>();
                                mapTodayClosedCases.put(recCase.OwnerId,listTempTodayCases);
                                
                            }
                            listTempTodayCases.add(recCase);
                           
                        }
                        */
                    }
                }
            }
            
            List<User_Skills__c> listUpdateUS=new List<User_Skills__c>();
            List<User_Skills__c> listUS=[SELECT Id,component_code__c, User__c, Maximum_Total_Cases__c, Maximum_Cases_Per_Day__c, Maximum_Severity1_Cases__c, Cases_Assigned__c,Severity_1_cases_assigned__c, Cases_assigned_perday__c FROM User_Skills__c where User__c in:setOwnerIds];
            if(listUS!=null && listUS.size()>0)
            {
                for(User_Skills__c recUS:listUS)
                {
                    if(mapSev1PromotionCases.get(recUS.User__c)!=null )
                    {
                        recUS.Severity_1_cases_assigned__c=recUS.Severity_1_cases_assigned__c+mapSev1PromotionCases.get(recUS.User__c).size();
                    }
                    
                    if(mapSev1DemotionCases.get(recUS.User__c)!=null )
                    {
                        recUS.Severity_1_cases_assigned__c=recUS.Severity_1_cases_assigned__c-mapSev1DemotionCases.get(recUS.User__c).size();
                    }                    
                
                    List<Case> listClosedCases=mapClosedCases.get(recUS.User__c);
                    if(listClosedCases!=null && listClosedCases.size()>0)
                    {
                             if(recUS.Cases_Assigned__c!=0)
                                 recUS.Cases_Assigned__c=recUS.Cases_Assigned__c-listClosedCases.size();
                             //if(recUS.Cases_assigned_perday__c !=0 && mapTodayClosedCases.get(recUS.User__c)!=null)
                                 //recUS.Cases_assigned_perday__c =recUS.Cases_assigned_perday__c-mapTodayClosedCases.get(recUS.User__c).size();
                             if(recUS.Severity_1_cases_assigned__c!=0 && mapSev1ClosedCases.get(recUS.User__c)!=null)
                                 recUS.Severity_1_cases_assigned__c=recUS.Severity_1_cases_assigned__c-mapSev1ClosedCases.get(recUS.User__c).size();

                    }
                    if(mapTransferredCases.get(recUS.User__c)!=null )
                    {
                        
                         recUS.Cases_Assigned__c=recUS.Cases_Assigned__c+mapTransferredCases.get(recUS.User__c).size();
                         recUS.Cases_assigned_perday__c =recUS.Cases_assigned_perday__c+mapTransferredCases.get(recUS.User__c).size();
                         if(mapSev1TransferredCases.get(recUS.User__c)!=null)
                             recUS.Severity_1_cases_assigned__c=recUS.Severity_1_cases_assigned__c+mapSev1TransferredCases.get(recUS.User__c).size();
                     }
                     if(mapReOpenedCases.get(recUS.User__c)!=null)
                     {
                         
                         recUS.Cases_Assigned__c=recUS.Cases_Assigned__c+mapReOpenedCases.get(recUS.User__c).size();
                         recUS.Cases_assigned_perday__c =recUS.Cases_assigned_perday__c+mapReOpenedCases.get(recUS.User__c).size();
                         if(mapSev1ReOpenedCases.get(recUS.User__c)!=null)
                             recUS.Severity_1_cases_assigned__c=recUS.Severity_1_cases_assigned__c+mapSev1ReOpenedCases.get(recUS.User__c).size();
                     }
                     
                     if(mapTransOldCases.get(recUS.User__c)!=null &&  mapSev1OldTransferredCases.get(recUS.User__c)!=null)
                     {
                         if(recUS.Cases_Assigned__c!=0)
                         recUS.Cases_Assigned__c=recUS.Cases_Assigned__c-mapTransOldCases.get(recUS.User__c).size();
                         if(recUS.Cases_assigned_perday__c !=0)
                         recUS.Cases_assigned_perday__c =recUS.Cases_assigned_perday__c-mapTransOldCases.get(recUS.User__c).size();
                         if(recUS.Severity_1_cases_assigned__c!=0 )
                         recUS.Severity_1_cases_assigned__c=recUS.Severity_1_cases_assigned__c-mapSev1OldTransferredCases.get(recUS.User__c).size();
                     }
                     else if(mapTransOldCases.get(recUS.User__c)!=null )
                     {
                         if(recUS.Cases_Assigned__c!=0)
                        recUS.Cases_Assigned__c=recUS.Cases_Assigned__c-mapTransOldCases.get(recUS.User__c).size();
                        if(recUS.Cases_assigned_perday__c !=0)
                        recUS.Cases_assigned_perday__c =recUS.Cases_assigned_perday__c-mapTransOldCases.get(recUS.User__c).size();
                     }
                     listUpdateUS.add(recUS);
                }
                try{
                if(listUpdateUS!=null && listUpdateUS.size()>0)
                    update listUpdateUS;
                }catch(Exception e){}
            }
        }    
    }
}