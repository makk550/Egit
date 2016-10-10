global class DefectMigrationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
global List<DefectMigrationObject__c> datatoupload{get;set;} 
global Database.QueryLocator start(Database.BatchableContext BC)
{
    datatoupload=new List<DefectMigrationObject__c>();
    String query = 'Select Blocked__c,	Blocked_Reason__c,	Defect_Number__c,	Defect_Object_ID__c,	Defect_Owner__c,	Defect_Submitted_By__c,	Defect_System__c,	Description__c,	Migrated__c,	Priority__c,	Project_object__c,	Resolution__c,	Severity__c,	Status__c,	Subject__c,	Targeted_Release_Number__c,	Target_Release_date__c,	Type__c from DefectMigrationObject__c where Migrated__c!=TRUE';
    return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<DefectMigrationObject__c> scope)
{
   
    for (DefectMigrationObject__c value : scope){
        try{
            
    Map<String, Object> mapOfJSONData = null;
    Http binding = new Http(); 
    HttpRequest req = new HttpRequest(); 
    req.setMethod('GET');
    req.setHeader('Username','sgunda@rallydev.com');
    req.setHeader('password','Boulder2016!!!');
    req.setHeader('authorization','Basic c2d1bmRhQHJhbGx5ZGV2LmNvbTpCb3VsZGVyMjAxNiEhIQ==');
    req.setEndpoint('https://rally1.rallydev.com/slm/webservice/v2.0/defect/'+value.Defect_Number__c); 
    HttpResponse res = binding.send(req);
    system.debug('RESPONSE====='+res.getBody());

    mapOfJSONData=(Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    if(mapOfJSONData.get('Defect')!=NULL){
    Map<String, Object>  defectMap=(Map<String, Object>)mapOfJSONData.get('Defect');
    Map<String, Object>  submittedByValueMap=(Map<String, Object>)defectMap.get('SubmittedBy');
    Map<String, Object>  projectValueMap=(Map<String, Object>)defectMap.get('Project');
    if(defectMap.get('Owner')!=null){
    Map<String,Object>   ownerValueMap=(Map<string,Object>)defectMap.get('Owner');
    value.Defect_Owner__c=(string)ownerValueMap.get('_refObjectName');
    system.debug('In IF');
    }
    else{
    value.Defect_Owner__c=(string)defectMap.get('Owner');
    system.debug('In ELSE');
    }                 
        value.Blocked__c=(boolean)defectMap.get('Blocked');
        value.Blocked_Reason__c=(string)defectMap.get('BlockedReason');
        value.Defect_Object_ID__c=(string)defectMap.get('_ref');
	    value.Project_object_number__c=(string)projectValueMap.get('_ref');
        value.Defect_Submitted_By__c=(string)submittedByValueMap.get('_refObjectName');
        value.Description__c=(string)defectMap.get('Description');
        value.Priority__c=(string)defectMap.get('Priority');
        value.Project_object__c=(string)projectValueMap.get('_refObjectName');
        value.Resolution__c=(string)defectMap.get('Resolution');
        value.Severity__c=(string)defectMap.get('Severity');
        value.Status__c=(string)defectMap.get('State');
        value.Subject__c=(string)defectMap.get('Name');
        value.Targeted_Release_Number__c=(string)defectMap.get('TargetBuild');
        value.Target_Release_date__c=(string)defectMap.get('TargetDate');
        value.Migrated__c=true;        
        datatoupload.add(value); 
system.debug('Ref'+defectMap.get('_ref')); 
system.debug('Description'+  defectMap.get('Description'));
system.debug('Name'+defectMap.get('Name'));
system.debug('Blocked'+defectMap.get('Blocked'));
system.debug('BlockedReason'+defectMap.get('BlockedReason'));
system.debug('Priority'+defectMap.get('Priority'));
system.debug('Resolution'+defectMap.get('Resolution'));
system.debug('Owner'+defectMap.get('Owner'));
system.debug('Severity'+defectMap.get('Severity'));
system.debug('TargetBuild'+defectMap.get('TargetBuild'));
system.debug('TargetDate'+defectMap.get('TargetDate'));
system.debug('State'+defectMap.get('State'));
system.debug('SubmittedName'+submittedByValueMap.get('_refObjectName'));
system.debug('ProjectName'+projectValueMap.get('_refObjectName'));
            }
    }catch(Exception e){}
    }
  }
global void finish(Database.BatchableContext BC)
{
    system.debug('LIST size'+datatoupload.size());
    
Database.SaveResult[] srList = Database.update(datatoupload,false);
// Iterate through each returned result

for (Database.SaveResult sr : srList) {

    if (sr.isSuccess()) {

        // Operation was successful, so get the ID of the record that was processed

        System.debug('Successfully updated DefectMigrated data = ' + sr.getId());

    }

    else {

        // Operation failed, so get all errors               

        for(Database.Error err : sr.getErrors()) {

            System.debug('The following error has occurred.');                   

            System.debug(err.getStatusCode() + ': ' + err.getMessage());

            System.debug('DefectMigrated fields that affected this error: ' + err.getFields());

        }

    }

}


}
}