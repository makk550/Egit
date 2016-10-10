public class BraensSubscriptionsController {
    
    public static Map<Id,BRAENS_SUBSCRIPTIONS__c> braensSubscriptionsMap=new Map<ID,BRAENS_SUBSCRIPTIONS__c>([SELECT ID,NAME,CA_Product__c,Case_Number__c,Case_Owner__c,Event_Name__c,Event_Type__c,PMFKEY__c,Reason_for_Subscription__c,Severity__c,Site_Association__c,Site_Country__c,Tops_Site_ID__c FROM BRAENS_SUBSCRIPTIONS__c]);
    public static List<BRAENS_SUBSCRIPTIONS__c> braensSubscriptionsList=[SELECT ID,NAME,CA_Product__c,Case_Number__c,Case_Owner__c,Event_Name__c,Event_Type__c,PMFKEY__c,Reason_for_Subscription__c,Severity__c,Site_Association__c,Site_Country__c,Tops_Site_ID__c FROM BRAENS_SUBSCRIPTIONS__c];
    public static Map<String, BRAENS_SUBSCRIPTIONS__c> braensSubscriptionsFinalMap=new Map<String, BRAENS_SUBSCRIPTIONS__c>();
    
    public static void processBraensSubscriptions(Case caseRec){
        set<String> tempSet=new set<String>();
        braensSubscriptionsFinalMap=getBraensSubscriptionsFinalMap();
     
        for (Integer i=0;i<braensSubscriptionsList.size();i++) {  
            
            if(braensSubscriptionsList.get(i).Tops_Site_ID__c<>null){
                if(caseRec.Tops_Support_Site_ID__c.contains(braensSubscriptionsList.get(i).Tops_Site_ID__c)){
                    tempSet.add(braensSubscriptionsList.get(i).ID);
                }
            }            
            if(braensSubscriptionsList.get(i).Site_Country__c<>null){
                if(braensSubscriptionsList.get(i).Site_Country__c.contains(caseRec.Site_Country__c.SubString(0,2))){
                    tempSet.add(braensSubscriptionsList.get(i).ID);
                } 
            }
            
            System.debug('tempMap-->'+tempSet);
           
        }
         buildMailInput(tempSet,caseRec);
    }
    
    public static Map<String, BRAENS_SUBSCRIPTIONS__c> getBraensSubscriptionsFinalMap(){
        for(BRAENS_SUBSCRIPTIONS__c obj : braensSubscriptionsList) {
            braensSubscriptionsFinalMap.put(obj.NAME, obj);
        }  
        return braensSubscriptionsFinalMap;
    }
    
    @InvocableMethod
     public static void processCaseAlerts(List<Case> caseIds){
         for(Case caseRec:caseIds){
             processBraensSubscriptions(caseRec);
         }
    }
    
    public static void buildMailInput(Set<String> subscriptionIds,Case caseRecDetails){
        List<String> emailIds=new List<String>();
        for(String s: subscriptionIds){
            emailIds.add(braensSubscriptionsMap.get(s).PMFKEY__c+'@ca.com');            
        }        
        BraensNotificationProcess.sendNotificationToAssgnUser(emailIds, caseRecDetails);
    }
       
   }