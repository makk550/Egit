trigger aiau_UpdateTrialRequests on Opportunity (after update) {
    //Code by Afzal .. 
    /*boolean wasClosed = false;
    if(Trigger.old!=null)
        wasClosed = Trigger.old[0].IsClosed;

    for(Opportunity opp:Trigger.new){
        List<Trial_Request__c> reqList = [select Request_Status__c,Opp_Name__r.RecordType.Name from Trial_Request__c where Opp_Name__c=:opp.Id];
        if(!reqList.isEmpty()){
            for(Trial_Request__c req:reqList){
                if(!wasClosed && opp.IsClosed)
                    req.Request_Status__c = 'Closed';

                if(opp.RecordTypeId!=null){
                    req.Record_Type__c = req.Opp_Name__r.RecordType.Name;
                }
                
            }
        }
        update reqList;
    }*/
    
    // Corrected code added by Nomita on 22 March 2010.
    // Correction made because earlier code was updating the trial request list , even though there were no changes to it.
    // Also, since query and DMLs are inside 'FOR' loop, it would hit governor limits for bulk operations. 
    Set<Id> oppids = new Set<Id>();
    for(Integer i=0;i<Trigger.new.size();i++)
    {
        if(Trigger.new[i].IsClosed && (Trigger.new[i].IsClosed != Trigger.old[i].IsClosed))
            oppids.add(Trigger.new[i].Id);
    }
    if(oppids.size()>0)
    {
        List<Trial_Request__c> reqList = new List<Trial_Request__c>();
        reqList = [select Request_Status__c,Opp_Name__r.RecordType.Name from Trial_Request__c where Opp_Name__c in:oppids];
        if(reqList.size()>0)
        {
            for(Trial_Request__c req:reqList)
            {
                req.Request_Status__c = 'Closed';
            }
            try{
            update reqList;
            }catch(DMLException ex){
                System.debug(ex.getMessage());
            }
        }       
    }
}