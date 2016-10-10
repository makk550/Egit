trigger EverbridgeNotifications on Case (after insert,before update,after update) {
    
    
    if(Trigger.isInsert && Trigger.isAfter){
        
        List<Case> lstTrigger = trigger.New;            
        for(Case caseRec:lstTrigger){        
            if(caseRec.Severity__c == '1'){
                String reqbody = EverbridgeRequestUtility.prepareRequestBody(caseRec);
                EverbridgeCallout.notifyUsingEverbridge(reqbody,caseRec.Id);
            }
        }           
    }
    
    //static Set<Id> sevUpdatedCasesSet = new Set<Id>();
    if(Trigger.isUpdate){
        
        if(Trigger.isBefore){
            for(Case caseRec: Trigger.New){
                if(  caseRec.Severity__c == '1' && caseRec.Severity__c != Trigger.oldMap.get(caseRec.Id).Severity__c){
                    EverbridgeRequestUtility.sevUpdatedCasesSet.add(caseRec.Id);
                }
            }
             System.debug('After before update:EverbridgeRequestUtility.sevUpdatedCasesSet:'+EverbridgeRequestUtility.sevUpdatedCasesSet);
        }
       
        
        if(Trigger.isAfter && EverbridgeRequestUtility.triggerExecutedOnce == false){
            for(Case caseRec: Trigger.New){
                System.debug('*** After Update ***');
                System.debug('caseRec.Id:'+caseRec.Id);
                System.debug('caseRec.Severity__c:'+caseRec.Severity__c);
                System.debug('EverbridgeRequestUtility.sevUpdatedCasesSet:'+EverbridgeRequestUtility.sevUpdatedCasesSet);
                System.debug('EverbridgeRequestUtility.sevUpdatedCasesSet.contains(caseRec.Id):'+EverbridgeRequestUtility.sevUpdatedCasesSet.contains(caseRec.Id));
                if(EverbridgeRequestUtility.sevUpdatedCasesSet.contains(caseRec.Id) && caseRec.Severity__c == '1'){
                    System.debug('In after update block');
                    String reqbody = EverbridgeRequestUtility.prepareRequestBody(caseRec);
                    System.debug('reqbody:'+reqbody);
                    EverbridgeCallout.notifyUsingEverbridge(reqbody,caseRec.Id);
                }
            }
            EverbridgeRequestUtility.triggerExecutedOnce = true;
        }
        
        
    }
    
    
}