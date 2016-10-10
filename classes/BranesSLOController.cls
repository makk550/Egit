public class BranesSLOController {

      @InvocableMethod
    public static void processSLOAlerts(List<Task> taskIds){
        System.debug('taskIds-->'+taskIds);
        if(taskIds<>null && taskIds.size()>0){
        for(Task t:taskIds){
            SObject WhatIdObj = T.What;
  			if(WhatIdObj<>null && (whatIdObj.getsObjectType() == Case.sObjectType)){
                Case caseRec=new Case(Id=T.WhatId);
                  BraensSubscriptionsController.processBraensSubscriptions(caseRec);                     
			}
        }
    }
    }
}