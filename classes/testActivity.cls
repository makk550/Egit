@isTest
public class testActivity{

private static void CRMSFDC71_EventStarEndDateCalculation_test() {    
Event everec = new Event(subject='TSO Event',startDateTime=System.now(),endDateTime=System.now()+2,OwnerId=UserInfo.getUserId());
        insert everec;
        everec.endDateTime=System.now()+3;
        update everec;
        everec.End_Date__c=null;
        everec.Actual_Time_Spent_Hours__c =5;
        everec.Start_Date_Time__c=null;
        everec.IsAllDayEvent=true;
        update everec;
        
}
}