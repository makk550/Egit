public with sharing class  CST_Timesheet {
 
 //To Display the Timeentry grid
    public List<wrapTasks> lstWrap{get;set;}
    public List<string>  lstCategory{get;set;}
    id recid;  
    public Map<string,integer> mIndex {get;set;}
    
    public Date getDisplayDate()
    {
        if(lstWrap.size() > 0 && lstWrap[0].lstTask.size() > 0)
            return lstWrap[0].lstTask[0].week_end_Date__c;
        else
            return    Date.Today();
    }     
    
  //Wrapper Class to display the grid
    public class wrapTasks
   {
        public account acc{get;set;}
        public string accname_short {get;set;}
        public List<Task> lstTask{get;set;}
        public decimal gettotalhours(){
             decimal totalhours  = 0;
             if(lstTask<> null && lstTask.size()> 2)
                 for(integer i=0;i< lstTask.size()-2; i++)
                   {
                            if(lstTask[i].Actual_Time_Spent_Hours__c <> null)
                                totalhours += lstTask[i].Actual_Time_Spent_Hours__c;
                   }                
                                    
                return totalhours;                    
        }
        public decimal gettotalcount(){
             decimal totalcount= 0;
             if(lstTask<> null && lstTask.size()> 2)
                 for(integer i=lstTask.size() -2;i< lstTask.size(); i++)
                   {
                        
                            if(lstTask[i].Interaction_Count__c <> null)
                                totalcount += lstTask[i].Interaction_Count__c;
                       
                   }                
                                    
                return totalcount;                    
        }
      

       public wrapTasks(Account a,List<Task> lst)
       {
         //  totalhours = 0;
         //  totalcount = 0;
           acc= a;
           if(acc.name <> null && acc.name.length() > 25)
               accname_short = acc.name.substring(0,25) + '...';
           else
               accname_short = acc.name;
           lstTask = lst;
          

       }

   }

    private List<Account> lstAccount;
    
    //Constructor for Initiating Values
    public CST_Timesheet() 
    {
        RecordType[] rt = [Select id from RecordType where name ='Customer Success Activity'];  
         if(rt <> null && rt.size() > 0)
                recId = rt[0].id; 
        if(task_temp == null)
            task_temp = new Task(recordtypeid=recId, Week_End_Date__c = getFriday(Date.Today())); 
        if(lstCategory==null)
        {   lstCategory = new List<string>();
            Schema.DescribeFieldResult F = Task.Category__C.getDescribe();
            List<Schema.PicklistEntry> P = F.getPicklistValues();
            integer i=0;
            mIndex = new Map<string,integer>();
            for(Schema.PicklistEntry pe:P)
            {       
                lstCategory.add(pe.getLabel());
                mIndex.put(pe.getLabel(),i);
                i++;
            }
            
        }       
        if(lstAccount == null)
             {
                setAccIds = new Set<id>();
                lstAccount = new List<Account>();
                for(AccountTeamMember atm: [Select Account.id, Account.Name, Account.Enterprise_Id__c, Account.Commercial_ID__c from AccountTeamMember Where Userid =: UserInfo.getUserId() ORDER BY Account.Name Limit 10000])    
                {
                    if( !setAccIds.contains(atm.Account.id))
                    {
                        lstAccount.add(atm.account);
                        setAccIds.add(atm.Account.id);
                    }
                }
                RefreshTasks();
            } 
    }
   
    //Containg the Ids of the Accounts Available
    private set<id> setAccIds;
    
    //Temporary Task for retrieveing the Weekend Date
    public Task task_temp {get;set;}
    
    //List of Tasks to Update/Insert in the DataBase
    private List<Task> lstTaskUpdate{get;set;}     
    
     public void SaveTasks()
     {
         List<Task> lstUpsert = new List<Task>();
         List<Task> lstDelete = new List<Task>();
         
         for(wrapTasks wr:lstWrap)
         {
             for(Task t: wr.lstTask)
                 if( t.task_account_name__c <> 'Totals' && ((t.Interaction_Count__c <> null && t.Interaction_Count__c <> 0.0 ) || (t.Actual_Time_Spent_Hours__c <> null && t.Actual_Time_Spent_Hours__c <> 0.0)))
                    {  

                        lstUpsert.add(t); 
                    }
                 else if( t.id != null)   
                     lstDelete.add(t); 

         }
    
         if(lstUpsert.size() > 0)   
             database.upsert(lstUpsert, false);
    
         if(lstDelete .size() > 0)   
             database.Delete(lstDelete ,false);
             
         RefreshTasks();
     }

    //To Refresh the task List
    public void RefreshTasks()
    {
         if(! task_temp.Week_End_Date__c.isSameDay(getFriday(task_temp.Week_End_Date__c)))
           {      
                  ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Week Ending Date must be a Friday'));   
                  return; 
           }
           
         MAP<string,List<Task>> mTaskAcc = gettask(); //Get All The Tasks associated to the selected accounts
         List<Task> lst_temp;
         List<Task> lst_actual;
         integer lstIndex;
         List<Task> lst_Totals = initListForCategory(new account(name='Totals'));
     

         lstWrap = new List<wrapTasks>(); 
         //Empty row at the Top  
         lst_temp = initListForCategory(new account());
          if(lstAccount.size()==0)   
                lstAccount.add(new account());
          else if(lstAccount[0].id <> null)
                lstAccount.add(0,new account());      
        
        //Rows in the Grid -start
         for(account ac:lstAccount)
           {
             lst_temp = initListForCategory(ac);
             if(ac.id != null)  
                 lst_actual = mTaskAcc.get(ac.id); //Actual records of Task in DB
             else   
                 lst_actual = mTaskAcc.get('--');    //records without account
             
             if(lst_actual <> null)
             {
                for(task t: lst_actual) 
                {
                    lstIndex = mIndex.get(t.Category__c);
                    if(lstIndex <> null)
                      lst_temp[lstIndex] = t;
                     
                    //Totals Calculation - Start
                    if(lst_Totals[lstIndex].Interaction_Count__c == null)
                        {lst_Totals[lstIndex].Interaction_Count__c=0.0;}
                    if(lst_Totals[lstIndex].Actual_Time_Spent_Hours__c == null)
                        {lst_Totals[lstIndex].Actual_Time_Spent_Hours__c=0.0;}
                    
                    if(lst_temp[lstIndex].Interaction_Count__c != null)
                        {lst_Totals[lstIndex].Interaction_Count__c += lst_temp[lstIndex].Interaction_Count__c;}
                    if(lst_temp[lstIndex].Actual_Time_Spent_Hours__c != null)
                        {lst_Totals[lstIndex].Actual_Time_Spent_Hours__c += lst_temp[lstIndex].Actual_Time_Spent_Hours__c;}
                     
                     //Totals Calculation - End
                }
             }
             lstWrap.add(new wrapTasks(ac,lst_temp));
            
            }
          //Rows in the Grid -end
          //Empty row at the End
          lstWrap.add(new wrapTasks(new account(name='Totals'),lst_Totals)); //Empty row at the Top  

    }
          
    public List<Task>  initListForCategory(Account ac)
    {
           List<task> lst = new  List<task>(); 
           for(integer i=0;i< lstCategory.size(); i++)
           {
               lst.add(new Task(recordtypeid=recid, Task_Account_Name__c = ac.name, Task_Account_Enterprise_Id__C=ac.Enterprise_Id__c,Task_Account_Site_Id__C=ac.Commercial_ID__c,Task_Account_Id__c=ac.id, Actual_Time_Spent_Hours__c=0.0, 
               Week_End_Date__c=task_temp.Week_End_Date__c,ownerid=UserInfo.getUserId(),Subject='Customer Success Team',Type='Time Tracking',
               Status='Completed',Priority='Normal', ActivityDate =task_temp.Week_End_Date__c, Category__c=lstCategory[i],Interaction_Count__c=0.0));
           }
           return lst;
    }

    public MAP<string,List<Task>> gettask()
      {
        List<Task> lstTask = new List<Task>(); 
        MAP<string,List<Task>> m = new MAP<string,List<Task>>();
        for(Task t: [Select Status, Subject, Category__c,  Interaction_Count__c,  Task_Account_Id__c, Task_Account_Name__c,
        Actual_Time_Spent_Hours__c, Week_End_Date__c from Task Where 
        (Task_Account_Id__c in : setAccIds OR Task_Account_Id__c = NULL OR Task_Account_Id__c = '')  And Week_End_Date__c = : task_temp.Week_End_Date__c 
        AND OwnerId =: UserInfo.getUserId() AND RecordTypeId = : recId and Category__c in : lstCategory
        order by CreatedDate desc limit 1000])
        {
                 if(t.Task_Account_Id__c == null || t.Task_Account_Id__c == '')
                    lstTask = m.get('--');
                else    
                    lstTask = m.get(t.Task_Account_Id__c);
               
                if(lstTask == null) {lstTask = new List<Task>(); }
                lstTask.add(t);
                if(t.Task_Account_Id__c == null || t.Task_Account_Id__c == '')
                    m.put('--', lstTask);
                else    
                    m.put(t.Task_Account_Id__c, lstTask);
        }

        return m ;
      }
      
      @isTest(SeeAllData=true)
      public static void TestMethod_For_CST_Timesheet (){

          RecordType rt = [Select r.SobjectType, r.Name, r.Id From RecordType r WHERE SobjectType = 'Account' AND Name='Account Team Covered Account'  Limit 1];
          
          Account ac = new Account(RecordTypeId=rt.id, name = 'Test Account for large name test', enterprise_id__c= 'NA1234567', geo__c='NA');
          insert ac;
          
          AccountTeamMember atm = new AccountTeamMember(accountid=ac.id,TeamMemberRole='CST', UserId=UserInfo.getUserId());
          insert atm;

         RecordType[] rts = [Select id from RecordType where name ='General Task'];  
         id recid;
         if(rts <> null && rts.size() > 0)
                recId = rts[0].id; 
          List<Task> lstTask = new List<Task>();

          lstTask.add(new Task(recordtypeid=recid, Task_Account_Name__c = ac.name, Task_Account_Enterprise_Id__C=ac.Enterprise_Id__c,Task_Account_Id__c=ac.id, Actual_Time_Spent_Hours__c=11.0, 
               ownerid=UserInfo.getUserId(),Subject='Customer Success Team',Type='Time Tracking',
               Status='Completed',Priority='Normal', ActivityDate =getFriday(Date.Today()), Category__c='CVP',Week_End_Date__c = getFriday(Date.Today())));
 
          lstTask.add(new Task(recordtypeid=recid, Task_Account_Name__c = ac.name, Task_Account_Enterprise_Id__C=ac.Enterprise_Id__c,Task_Account_Id__c=ac.id, Actual_Time_Spent_Hours__c=0.0, 
               ownerid=UserInfo.getUserId(),Subject='Customer Success Team',Type='Time Tracking',
               Status='Completed',Priority='Normal', ActivityDate =getFriday(Date.Today()), Category__c='Face to Face',Interaction_Count__c=5.0,Week_End_Date__c = getFriday(Date.Today())));
 
          lstTask.add(new Task(recordtypeid=recid, WhatId=ac.id,  
               ownerid=UserInfo.getUserId(),Subject='Customer Success Team',Type='Time Tracking',
               Status='Completed',Priority='Normal', ActivityDate =getFriday(Date.Today()), Category__c='Call',Interaction_Count__c=5.0,Week_End_Date__c = getFriday(Date.Today())));
 
          insert lstTask;

          CST_Timesheet  cls = new CST_Timesheet();
          cls.getDisplayDate();
          cls.SaveTasks();
          cls.RefreshTasks();
          cls.lstWrap[0].gettotalhours();
          cls.lstWrap[0].gettotalcount();
          
      
      }
     
     public static date getFriday(date dy)
     {
         if(dy== null)
             dy = Date.Today();
        
         datetime dt = DateTime.newInstance(dy.year(),dy.month(),dy.day());
         
         string daystring = dt.format('EEEE');
         integer adddays = 0;
         if(daystring == 'Saturday')
              adddays =6;
         else if(daystring == 'Sunday')
              adddays =5;      
         else if(daystring == 'Monday')
              adddays =4;      
         else if(daystring == 'Tuesday')
              adddays =3;      
         else if(daystring == 'Wednesday')
              adddays =2;      
         else if(daystring == 'Thursday')
              adddays =1;      
                 
             
         SYSTEM.DEBUG('Saba Test Date Today' + dy);
         SYSTEM.DEBUG('Saba Test DateTime Today' + dt);
         SYSTEM.DEBUG('Saba Test Day Today' + daystring );
         SYSTEM.DEBUG('Saba Test ADD DAYS' + adddays);
         SYSTEM.DEBUG('Saba Test End Date' + dy.addDays(adddays));
         
        // return dy;
         
         return dy.addDays(adddays );
         
     }
   
    
}