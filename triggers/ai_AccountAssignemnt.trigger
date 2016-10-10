trigger ai_AccountAssignemnt on Trial_Request__c (after insert, after update) {

for(Trial_Request__c req:Trigger.new){

     try{

             Trial_Request__c updateReq = [select Id, Opp_Name__r.Id, account__c, originalOppoMilestone__c from Trial_Request__c where id=:req.Id];

                Trial_Request__c oldPoc = Trigger.oldMap.get(req.Id);
                
               
                if ((req.Request_Status__c != oldPoc.Request_Status__c) && (req.Request_Status__c == 'Extension Approved' || req.Request_Status__c == 'Cancelled')) {
                
                    System.debug('*** From trigger - Before calling PocUpdate for POC EcommerceOutboundClass.SendPocUpdate****');
                    EcommerceOutboundClass.SendPocUpdate(req.Id);
                    System.debug('*** From trigger - after calling PocUpdate for POC EcommerceOutboundClass.SendPocUpdate****');
                
                }
            
            if(updateReq.account__c == null){
            
             System.debug('Account is null so going to try to update');
                
             Opportunity opp =[SELECT Id, Account.Id, Sales_Milestone_Search__c FROM Opportunity WHERE Id =:updateReq.Opp_Name__r.Id limit 1];

             System.debug('Got opportunity');
             
             Account acct = [SELECT Id FROM Account WHERE Id =: opp.Account.Id limit 1];

             System.debug('Got Account');
             
            
             if(updateReq.originalOppoMilestone__c == null || updateReq.originalOppoMilestone__c == ''){
                 updateReq.originalOppoMilestone__c= opp.Sales_Milestone_Search__c;
             }
             
             updateReq.account__c = acct.Id;
             update updateReq;

             System.debug('ai_AccountAssignemnt success');

             }
             else{
                  System.debug('Account is not null so not going to try to update');
             }
                 
              //Trial_Request__c tr = new Trial_Request__c(id= req.Id);
                 //tr.account__c = acct.Id;
                 //update tr;
      
         }
         catch(Exception ex){
             System.debug('ai_AccountAssignemnt failure' + ex);
         }
}
}