/**
* Description :This global class contains a web service method
*              to handle user record updates based on the process steps of the
*              Approved Org records. This class can be invoked through trigger a
*              Or with a button on a page layout.
*               
* Author       : Sayeed Faruqi
* Company      : Accenture
* Client       : Computer Associates
* Last Updated  : March 2012
Changes for FY13 : Updated the Batch Job to accomodate upto 1000 records
**/
global class TAQOrgAdmin_Error implements schedulable{
    // added a static variable check for keeping count of future method calls in same transaction - Heena sept-29
    public static boolean inFutureContext = false;
  
    // this interface is requirement to be able to used by apex scheduler
    // We will simply kick start the web service
    global void execute (SchedulableContext sc){
        TAQOrgAdmin.updateUser();
    }
    
    webservice static void updateUser()
    {
        system.debug ('begin code ');
        
        // Step 1 - Select candidate records from Approved Account Org
        // where process steps include
        //     - Term/Transfer (exclude transfer-within) 
        //     - New Hire
        //     - Employee Change
        // but exclude: IF Plantype = 'None' or 'LOA', OR Organization = 'SERVICES', OR Position ID = 'None'.
        //added AND Organization__c not in('SUPPORT', 'SERVICES', 'MARKETING','GBO' )  by rao 
        // We are limiting the batch size to 10 because the number @Future calls/job limit is 10 
        Set<string> NewHireIds = new Set<string>();
        
        
        TAQ_Organization_Approved__c[] ta = 
                [SELECT id,PMFKey__c,position_id__c, process_status__c, process_message__c,
                 process_step__c, createdDate
                   FROM TAQ_Organization_Approved__c
                    WHERE (process_step__c = 'Term / Transfer' OR 
                           process_step__c = 'Employee Change' OR
                           process_step__c = 'New Hire') 
                           AND process_status__c = 'ERROR' 
                           AND employee_status__c <> 'Transfer-within'
                           AND Plan_Type__c <> 'None'
                           AND Plan_Type__c <> 'LOA'
                           AND Organization__c <> 'SERVICES' 
                           AND Position_Id__c <> 'None'
                           AND Employee_Status__c <> 'Open'
                           AND PMFKey__c like '_______'
                           AND Organization__c not in('SUPPORT', 'SERVICES', 'FIELD MARKETING','GBO','EDUCATION' ) 
                           order by createddate desc
                           LIMIT 1000];  

        set<string> pmfkeys = new set<string>();
        set<string> setPositions = new set<string>();
        for(TAQ_Organization_Approved__c t : ta)
        {
            if(t.PMFKey__c <> null)
                pmfkeys.add(t.PMFKey__c.toUpperCase());
            if(t.position_id__c <> null)
                setPositions.add(t.position_id__c.toUpperCase());
        }

        Map<string,user>  pmfUser = new Map<string,user>(); 
        Map<id,user>  mapIdUser = new Map<id,user>(); 
        

        for(User u :[select id,isActive,PMFKey__c, Username  from user where PMFKey__c IN:pmfkeys])
        {
            if(u.PMFKey__c <> null)
                pmfUser.put(u.PMFKey__c.toUpperCase(),u);
                
             mapIdUser.put(u.id, u);   
        }

        // get matching position Id record from the position reference table
        Map<string,TAQ_REF_Position__c> mapPositionRef = new Map<string,TAQ_REF_Position__c>();
        for(TAQ_REF_Position__c rp : [SELECT name, profile_id__c, role_id__c,
                                                     profile_name__c, role_name__c 
                                                FROM TAQ_REF_Position__c
                                                 WHERE name IN: setPositions])
        {
                if(rp.profile_id__c <> null)
                    mapPositionRef.put(rp.name.toUpperCase(),rp);
        
        
        }



        //changes by Heena begin to avoid too many future updates added on 1/11/2011        
        List<user> updateTT = new List<user>();
        List<user> updateNHEC= new List<user>();
        Map<id,id> mapUserTAQId = new Map<id,id>();
        Map<id,id> UserRole= new Map<id,id>();
        //changes by Heena End
        
        
        for (Integer i = 0; i < ta.size();i++)
        {
             Boolean doNotProcess = false;
             
             //Examine records completenss
             if (ta[i].PMFKey__c == NULL || ta[i].position_id__c == NULL) {
                 // Call status update method
                 string message = 'PMF key or Position Id is null for this record';
                 string status  = 'Error';
                 
              //   system.debug ('DBG: ' + status + ' - ' + message);
                 
                 updateStatus( ta[i].id, status, message);
                 doNotProcess = true;
             }
             
             // Let's handle the term/Transfer first by deactivating the user
             if (doNotProcess == false && ta[i].process_step__c == 'Term / Transfer'){
                 system.debug (' Handling term/transfer out condition');
                 // Let's locate the user based on the PMF key
                 //User[] u=[select id,isActive,PMFKey__c  from user where PMFKey__c= :ta[i].PMFKey__c LIMIT 1];
                 user u;
                 if(ta[i].PMFKey__c <> null)
                    u= pmfUser.get(ta[i].PMFKey__c.toUpperCase());

                 if (u <> null) {
                     try {
                         mapUserTAQId.put(u.id,ta[i].id);
                         system.debug ('Found a corresponding position Id record in POS REF Table');
                         u.isActive = false; // only 1 record is in the array
                         u.TAQ_Position_ID__c = '';  // by rao 
                         updateTT.add(u); //changes by Heena to avoid too many future updates added on 1/11/2011
                         
                         //update u;
                         string status = 'Success';
                         string message = 'Deactivated user with PMF Key ' + u.PMFKey__c;
                         
                         system.debug ('DBG: ' + status + ' - ' + message);
         
                         updateStatus( ta[i].id, status, message);
                     } catch (Exception e) 
                     {
                         
                         string status = 'Error';
                         string message;
                         //Following code modified by Jagan. checking the length of exception and updating accordingly.
                         string excep=''+e;
                         if(excep.length()>200)
                             message = 'Exception Caught with PMF Key ' + u.PMFKey__c + ' - ' + excep.substring(0,200);
                         else
                             message = 'Exception Caught with PMF Key ' + u.PMFKey__c + ' - ' + e;
                         
                         system.debug ('DBG: ' + status + ' - ' + message);
                         
                         updateStatus( ta[i].id, status, message);
                         //TAQ_SendTestEmails.SendMail('TAQOrgAdmin', e); 
                     }

                 } else { // write status - no user forund
                     string message = 'No corresponding user record found for PMF key '+ ta[i].PMFKey__c ;
                     string status = 'Error';
                     
                 //    system.debug ('DBG: ' + status + ' - ' + message);
                     
                     updateStatus( ta[i].id, status, message);
                 }
              }
              // Let's handle the new hire and employee change process
              if (doNotProcess == false && (ta[i].process_step__c == 'New Hire' 
                       || ta[i].process_step__c == 'Employee Change') ) {
                   system.debug ('Handling the employee change');
                   // get matching position Id record from the position reference table
                   /*TAQ_REF_Position__c[] rp =[SELECT name, profile_id__c, role_id__c,
                                                     profile_name__c, role_name__c 
                                                FROM TAQ_REF_Position__c
                                                 WHERE name = :ta[i].position_id__c LIMIT 1 ];   
                    */
                  TAQ_ref_Position__c rp;
                  if(ta[i].position_id__c <> null)
                   rp = mapPositionRef.get(ta[i].position_id__c.toUpperCase());
                   if (rp <> null){
                   
                       // get user record from the user object based on the PMF key //Saba 10/9/2010: SFDC 7.1 Added AE_SE_PMFKey__c for AE SE Shadowing on Employee New Hire
                       /*User u=[SELECT id,isActive,PMFKey__c,Username 
                              FROM user 
                               WHERE PMFKey__c= :ta[i].PMFKey__c LIMIT 1];
                        */
                        User u;
                        if(ta[i].PMFKey__c <> null)
                            u= pmfUser.get(ta[i].PMFKey__c.toUpperCase());

                       if (u  <> null){
                           // update following fields in the user object
                           u.profileId = rp.profile_id__c;
                           u.TAQ_position_Id__c = rp.name;
                           UserRole.put(u.Id,rp.Role_Id__c);  //User Role update should be done separately     
                           string message = 'Updated the user profile to '+ rp.profile_name__c +
                             ' based on position ref # '+ rp.name;
                           string status = 'Success';
                           
                           // Activate user if new hire or not yet activated
                           if(ta[i].process_step__c == 'New Hire' || u.isActive == false) {
                      // FY13--         u.AE_SE_PMFKey__c=ta[i].AE_SE_PMFKey__c; //Saba 10/9/2010: SFDC 7.1 Change for AE SE Shadowing on Employee New Hire                   
                               u.isActive = true; // only 1 record is in the array
                               
                               NewHireIds.add(u.id);
                               
                               message += '; Activated user ' + u.Username;
                               
                           }
                           
                           system.debug ('DBG: ' + status + ' - ' + message);
                           updateNHEC.add(u); //changes by Heena to avoid too many future updates added on 1/11/2011
                           
                           //update u;
                           
                           updateStatus( ta[i].id, status, message);
                       } else { // write error message for no user record found for the given PMF Key
                           string message = 'No corresponding user record found for PMF key '+ ta[i].PMFKey__c ;
                           string status = 'Error';
                           
                           system.debug ('DBG: ' + status + ' - ' + message);
                           
                           updateStatus( ta[i].id, status, message);
                        }
                    } else { // write error message for no position Id record found for the given position Id
                           string message = 'No corresponding record found for Position Id '+ ta[i].position_id__c ;
                           string status  =  'Error';
                           
                           system.debug ('DBG: ' + status + ' - ' + message);
                           
                           updateStatus( ta[i].id, status, message);
                       }
        }
     }
     //changes by Heena begin to avoid too many future updates added on 1/11/2011     
     //update updateTT;
     //update updateNHEC;
     Set<user> lstUpdateSet = new Set<User>();
     lstUpdateSet.addAll(updateTT);
     lstUpdateSet.addAll(updateNHEC);
     
     List<user> lstUpdate = new List<User>();
      lstUpdate.addAll(lstUpdateSet);
        
     Database.SaveResult[] lsr = Database.update(lstUpdate, false); //Update the Users real Time
    
    // Iterate through the Save Results 
        
        
    integer i = 0;   
        
    for(Database.SaveResult sr:lsr)
    {
       if(!sr.isSuccess())
       {
        
       
        
          Database.Error err = sr.getErrors()[0];
          
          if(NewHireIds.contains(lstUpdate[i].id))
                NewHireIds.remove(lstUpdate[i].id);
            
          
          string status = 'Error';
           string message;
      
           string excep= err.getMessage();
           
           if(excep.length()>200)
              message = 'Exception Caught with PMF Key ' + lstUpdate[i].PMFKey__c + ' - ' + excep.substring(0,200);
           else
              message = 'Exception Caught with PMF Key ' + lstUpdate[i].PMFKey__c + ' - ' + excep;
                         
           system.debug ('DBG: ' + status + ' - ' + message);
           
           updateStatus( mapUserTAQId.get(lstUpdate[i].id), status, message);
         }
         
        i++;
    }
    
    //Updates the status and message fields for TAQ Org Approved
    //TBD ... Fetch the TAQ Accounts with Account Team Members having the PMF/Position for message = 'Success' 
     updateStatusAll(TAQOrgApprovedMessage,TAQOrgApprovedStatus, NewHireIds); //Update the TAQ Org Approved in Future

    List<User> UserforRole = new List<user>();
     for(User u:[select id,UserRoleId from user where id IN:UserRole.Keyset()])
        {
            u.UserRoleId = UserRole.get(u.Id);
                
               UserforRole.add(u);
        }
     Update UserforRole;

  }
   /** At future Web Service to handle the Approved Org status updates. 
       @future is needed because Salesforce.com will not allow us to update
       the setup object (user) and non setup object (TAQ Org Approved) in a same
       context (i.e. same for loop or method). @Future is a way to fool Salesforce.com
       that context is different
   **/
//    @future
    
     global static Map<string,string> TAQOrgApprovedMessage = new Map<string,string>();
     global static Map<string,string> TAQOrgApprovedStatus = new Map<string,string>();

     global static void updateStatus( id tasId, string status, string message)
     {
          
            TAQOrgApprovedStatus.put(tasId,status);
            TAQOrgApprovedMessage.put(tasId,message);
    
     }
    
    @future
    global static void updateStatusAll(Map<string,string> mTAQOrgApprovedMessage, Map<string,string> mTAQOrgApprovedStatus, Set<string> NewHireIds)
    {
        
        TAQOrgAdmin.inFutureContext =true;
        List<TAQ_Organization_Approved__c> lstUpdateOrgStatus = new  List<TAQ_Organization_Approved__c>();
       
       //TBD ... Fetch the TAQ Accounts with Account Team Members having the PMF/Position for message = 'Success' 
     
        if(mTAQOrgApprovedStatus.keyset().size() > 0)
            for(string taqOrgAppId: mTAQOrgApprovedStatus.keyset())
                {
                    TAQ_Organization_Approved__c t = new TAQ_Organization_Approved__c(id= taqOrgAppId);
                    t.process_message__c = mTAQOrgApprovedMessage.get(taqOrgAppId);
                    t.process_status__c = mTAQOrgApprovedStatus.get(taqOrgAppId);
                    lstUpdateOrgStatus.add(t);
                    
                     }

                
        if(lstUpdateOrgStatus.size() > 0)
            Database.update(lstUpdateOrgStatus, false);    
       
       
       //TAQ
       
       Map<id,Account> mapAccount = new map<id,Account>();
       
       List<TAQ_Account_Team__c> taqActTeams_owners = [SELECT Id,TAQ_Account__c, TAQ_Account__r.view_acc_record__c, User__c, isActive__c from TAQ_Account_Team__c
                                                        where User__c in: NewHireIds and Is_Account_Owner__c = true and TAQ_Account__r.view_acc_record__c <> null];
       for(TAQ_Account_Team__c t: taqActTeams_owners)
       {
      
                mapAccount.put(t.TAQ_Account__r.view_acc_record__c,  new Account(id=t.TAQ_Account__r.view_acc_record__c, ownerid = t.User__c));
       }                                                        
       
       if(mapAccount.size() > 0)
            update mapAccount.values();
       
       
    } 
     
     
     
     
    /** Method to retrieve Role Id based on Position REF roleId field 
    global id getRoleId( string strId){
        USerRole [] usr = [SELECT id, name
                            FROM UserRole
                             WHERE id = :strId limit 1]; 
        if (usr.size() > 0) { //found a matching role record
            return usr[0].id;
        }
        return usr[0].id;
    }
    **/
    /** Test Methods **/
    @isTest
    private static void AutoProvTest1() {
        
        User[] u=[select id,PMFKey__c,profile.name, profileId, UserRole.name, userRoleId  from User where isActive=true and PMFKey__c like '_______' limit 2];
        
        system.debug('User:'+u);
        
        //------
        TAQ_Organization__c taqOrg =new TAQ_Organization__c();
        taqOrg.Employee_Name__c='test,user';
        taqOrg.Process_Step__c='Open Headcount';
        taqOrg.Manager_Name__c='test,mgr';
        taqOrg.Manager_PMF_Key__c=u[1].PMFKey__c;
        taqOrg.PMFKey__c=u[0].PMFKey__c;
        taqOrg.Position_Id__c='testpos1';
        taqOrg.Role__c='AD/AM';
        taqOrg.Organization__c='DIRECT';
        taqOrg.Region__c='EMEA';
        taqOrg.Area__c='testa';
        taqOrg.Territory__c='nordics';
        taqOrg.Country__c='United States';
        taqOrg.Plan_Type__c='test';
        taqOrg.Distribute_Plan__c='NO';
        taqOrg.Plan_Type__c='LOA';
        taqOrg.ownerid=userinfo.getuserid();
        
        taqOrg.Cost_Center_Desc_For_Data_Load__c='test cost';
        taqOrg.Job_Title_For_Data_Load__c='test job';
        taqOrg.IC_Currency_For_Data_Load__c='test currency';
        
        taqOrg.Organization_for_Data_Load__c='DIRECT';
        taqOrg.Area_for_Data_Load__c='testa';
        taqOrg.Territory_For_Data_Load__c='nordics';
        taqOrg.Country_for_Data_Load__c='United States';
        taqOrg.Approval_Process_Status__c='Migrated';
        taqOrg.Employee_Status__c='Active';
        taqOrg.Position_ID_Status__c='Active';
        taqOrg.PlanType_Effective_Date__c = Date.newInstance(2012, 12, 01);
        insert taqOrg;
         
        //---------
        //Create Dummy Records for TAQ Org Approved and TAQ Ref position
        
        TAQ_REF_Position__c testRp =new TAQ_REF_Position__c();
        testRp.name='TEST POS';
        //testRp.profile_id__c=u[0].profileId;
        //testRp.role_id__c=u[0].userRoleId;
        testRp.profile_name__c=u[0].Profile.name;
        testRp.role_name__c=u[0].UserRole.name;
        insert testRp; 
                                                 
        TAQ_Organization_Approved__c testApp=new TAQ_Organization_Approved__c();
        testApp.PMFKey__c=null;
        testApp.position_id__c='TEST POS';
        testApp.process_status__c = 'New';
        testApp.process_message__c='';
        testApp.process_step__c= 'Employee Change';
        testApp.employee_status__c = 'Transfer';
        testApp.Plan_Type__c='TEST PLAN';
        testApp.Organization__c='DIRECT';
        insert testApp;
    
        TAQ_Organization_Approved__c testApp2=new TAQ_Organization_Approved__c();
        testApp2.PMFKey__c=u[0].PMFKey__c;
        testApp2.position_id__c='TEST POS';
        testApp2.process_status__c = 'New';
        testApp2.process_message__c='';
        testApp2.process_step__c= 'Employee Change';
        testApp2.employee_status__c = 'Transfer';
        testApp2.Plan_Type__c='TEST PLAN';
        testApp2.Organization__c='DIRECT';
        insert testApp2;
    
        TAQ_Organization_Approved__c testApp3=new TAQ_Organization_Approved__c();
        testApp3.PMFKey__c='testpmf';
        testApp3.position_id__c='TEST POS';
        testApp3.process_status__c = 'New';
        testApp3.process_message__c='';
        testApp3.process_step__c= 'Employee Change';
        testApp3.employee_status__c = 'Transfer';
        testApp3.Plan_Type__c='TEST PLAN';
        testApp3.Organization__c='DIRECT';
        insert testApp3;
        
        TAQ_Organization_Approved__c testApp4=new TAQ_Organization_Approved__c();
        testApp4.PMFKey__c=u[0].PMFKey__c;
        testApp4.position_id__c='TEST POS';
        testApp4.process_status__c = 'New';
        testApp4.process_message__c='';
        testApp4.process_step__c= 'Term / Transfer';
        testApp4.employee_status__c = 'Transfer';
        testApp4.Plan_Type__c='TEST PLAN';
        testApp4.Organization__c='DIRECT';
        insert testApp4;
        
        TAQ_Organization_Approved__c testApp5=new TAQ_Organization_Approved__c();
        testApp5.PMFKey__c='Invalid PMF KEY';
        testApp5.position_id__c='TEST POS';
        testApp5.process_status__c = 'New';
        testApp5.process_message__c='';
        testApp5.process_step__c= 'Term / Transfer';
        testApp5.employee_status__c = 'Transfer';
        testApp5.Plan_Type__c='TEST PLAN';
        testApp5.Organization__c='DIRECT';
        insert testApp5;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            try{
                 TAQOrgAdmin.updateUser();
                    } catch(Exception e)
            {
                System.Debug('ERROR'+e);
            }
        }
    }
    
    /** Test Methods **/
    @isTest
    private static void AutoProvTest2() {
        
        User[] u=[select id,PMFKey__c,profile.name, profileId, UserRole.name, userRoleId  from User where isActive=true and PMFKey__c like '_______' limit 2];
        
        system.debug('User:'+u);
        
        //------
        TAQ_Organization__c taqOrg =new TAQ_Organization__c();
        taqOrg.Employee_Name__c='test,user';
        taqOrg.Process_Step__c='Open Headcount';
        taqOrg.Manager_Name__c='test,mgr';
        taqOrg.Manager_PMF_Key__c=u[1].PMFKey__c;
        taqOrg.PMFKey__c=u[0].PMFKey__c;
        taqOrg.Position_Id__c='testpos1';
        taqOrg.Role__c='AD/AM';
        taqOrg.Organization__c='DIRECT';
        taqOrg.Region__c='EMEA';
        taqOrg.Area__c='testa';
        taqOrg.Territory__c='nordics';
        taqOrg.Country__c='United States';
        taqOrg.Plan_Type__c='test';
        taqOrg.Distribute_Plan__c='NO';
        taqOrg.Plan_Type__c='LOA';
        taqOrg.ownerid=userinfo.getuserid();
        
        taqOrg.Cost_Center_Desc_For_Data_Load__c='test cost';
        taqOrg.Job_Title_For_Data_Load__c='test job';
        taqOrg.IC_Currency_For_Data_Load__c='test currency';
        
        taqOrg.Organization_for_Data_Load__c='DIRECT';
        taqOrg.Area_for_Data_Load__c='testa';
        taqOrg.Territory_For_Data_Load__c='nordics';
        taqOrg.Country_for_Data_Load__c='United States';
        taqOrg.Approval_Process_Status__c='Migrated';
        taqOrg.Employee_Status__c='Active';
        taqOrg.Position_ID_Status__c='Active';
        taqOrg.PlanType_Effective_Date__c = Date.newInstance(2012, 12, 01);
        insert taqOrg;
         
        //---------
        
        //Create Dummy Records for TAQ Org Approved and TAQ Ref position
        
        TAQ_REF_Position__c testRp =new TAQ_REF_Position__c();
        testRp.name='TEST POS';
        //testRp.profile_id__c=u[0].profileId;
        //testRp.role_id__c=u[0].userRoleId;
        testRp.profile_name__c=u[0].Profile.name;
        testRp.role_name__c=u[0].UserRole.name;
        insert testRp; 
                                                 
        TAQ_Organization_Approved__c testApp=new TAQ_Organization_Approved__c();
        testApp.PMFKey__c=u[0].PMFKey__c;
        testApp.position_id__c='TEST POS';
        testApp.process_status__c = 'Error';
        testApp.process_message__c='';
        testApp.process_step__c= 'New Hire';
        testApp.employee_status__c = 'Transfer';
        testApp.Plan_Type__c='TEST PLAN';
        testApp.Organization__c='DIRECT';
        insert testApp;

        try{
        TaqOrgAdmin_Error.updateUser();
        }Catch (Exception e)
        {
            System.Debug ('ERROR..'+e);
        }

    }
}