public class apexJobStatus{
ApexPages.StandardController sc = null;

public TAQ_Organization__c taqRecord ;
public Integer percentComplete{get; set;} 

    public apexJobStatus(ApexPages.StandardController controller) {
         this.sc = sc;
    }

    public AsyncApexJob batchJobs;
    public Id jobId;
    public Id TaqOrgId;
    public string TaqOrgName{get; set;}
    public integer NumberOfErrors{get; set;}
    
    public PageReference RedirectPage()
    {
       //if(NumberOfErrors == null)  NumberOfErrors = 0;
       TaqOrgId  = ApexPages.currentPage().getParameters().get('Id');
       system.debug('TaqOrgId   --> ' + TaqOrgId   );
        taqRecord = [Select id,name,batch_Number__c from TAQ_Organization__c where id =: TaqOrgId];
              
        if(taqRecord != null)
           TaqOrgName = taqRecord.name;
   
           
           /*if(NumberOfErrors > 0)
          {
               taqRecord.batch_Number__c = Null;
               
               SystemIdUtility.skipTAQ_Organization = true ;        
                  update taqRecord;
               SystemIdUtility.skipTAQ_Organization = false ;
               
          }  */ 
              
       String theUrl = '/' + TaqOrgId   + '?nooverride=1';

        if(taqRecord.batch_Number__c == null || taqRecord.batch_Number__c == '')
        {        
            return new ApexPages.PageReference(theUrl).SetRedirect(true);   
        }
        else
        {          
          jobId =  Id.valueOf(taqRecord.batch_Number__c);                                   
           return null;
        }     
    }
   
    public AsyncApexJob getBatchJobs(){
        //Create new list of BatchJobs, a wrapper class that includes the job and percent complete.
        batchJobs = new AsyncApexJob();
        //if (ApexPages.currentPage().getParameters().get('Id') != NULL) {
         //  jobId = ApexPages.currentPage().getParameters().get('Id');
       // }

        if(taqRecord.batch_Number__c != null)
        {
          batchJobs=[select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name,ExtendedStatus From AsyncApexJob where Id =: jobId order by CreatedDate desc];                         
          NumberOfErrors = batchJobs.NumberOfErrors;
          if(batchJobs.TotalJobItems == 0){
                //A little check here as we don't want to divide by 0.
                percentComplete = 0;
            }else{
                percentComplete = ((batchJobs.JobItemsProcessed/ batchJobs.TotalJobItems) * 100.0).intValue();
            }          
            
          return batchJobs;
        }
        else
        {
          return null;
        }
    }
    
    public PageReference BackToTAQOrg()
    {
      batchJobs = new AsyncApexJob();
     if(taqRecord.batch_Number__c != null)
        {
          batchJobs=[select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name,ExtendedStatus From AsyncApexJob where Id =: jobId order by CreatedDate desc];                         
          NumberOfErrors = batchJobs.NumberOfErrors;
          if(NumberOfErrors > 0 || batchJobs.Status == 'Completed'){
               taqRecord.batch_Number__c = Null;
               
               SystemIdUtility.skipTAQ_Organization = true ;        
                  update taqRecord;
               SystemIdUtility.skipTAQ_Organization = false ;
               String theUrl = '/' + TaqOrgId   + '?nooverride=1';
                return new ApexPages.PageReference(theUrl).SetRedirect(true);  
           }       
            
          return null;
        }
        return null;    
    }  
}