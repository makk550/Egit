global class ThresholdTimerExtension {
    
	public Double dueDateMS{get; set;}
    public String caseRefId{get;set;}
    Case caseRec;
    public ThresholdTimerExtension(ApexPages.StandardController controller) {
        caseRec = (Case)controller.getRecord();
        caseRefId = caseRec.Id;
        if(caseRec.Threshold_Target_Date_Time__c != null ){
           dueDateMS = (caseRec.Threshold_Target_Date_Time__c.getTime() - System.now().getTime())/1000; 
        }        
    }  
    
    @RemoteAction
    global static void updateFields(String caseRefId){
        Case c = new Case(Id = caseRefId);
        c.Manager_Action__c = 'Threshold Exceeded';
        update c;
    }
    
}