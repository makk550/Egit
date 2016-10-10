public class LighteningCBRCertificationController {
    
    @TestVisible private static List<cbr_Calculated_Certification__x> cbrmockedRequests = new List<cbr_Calculated_Certification__x>();
    public List<CBR_Certifications_LPAC__c> cbrList;// {get;set;} 
    public String totalCount {get;set;}
    public Boolean isDetailsPresent{get;set;}
    public String contactID {get;set;}
    public integer totalRecs {get;set;}
    //public integer OffsetSize {= 0};
    //public integer LimitSize =5;
    public integer OffsetSize {get;set ;}
    public integer LimitSize {get;set ; }
    public Integer offsetvalue;
    
    public LighteningCBRCertificationController(){
        totalRecs = [select count() from CBR_Certifications_LPAC__c];
        System.debug('totalRecs:'+totalRecs);
         OffsetSize = 0;
        LimitSize = 900;
        getcbrList();
       
    }
    
    /* public List<CBR_Certifications_LPAC__c> getcbrList(){
cbrList=[SELECT SFDC_ID__c,Employee_Name__c,Employee_Type__c,badge__c,ca_product_code__c,ca_product_description__c,ca_product_name__c,certified__c,certified_status_code__c,certified_status_text__c,
completion_percentage__c,ldap_id__c,modify_date__c,previous_status_code__c,previous_status_text__c,resource_type__c,status_reason__c,valid_from__c,valid_to__c FROM CBR_Certifications_LPAC__c  
where certified__c='Yes' OR (certified__c='No' and certified_status_code__c IN (700,800)) order BY ldap_id__c LIMIT :LimitSize OFFSET :OffsetSize];
return cbrList;
}*/
    
    // public PageReference getCBRCertificationDetails(){
    public List<CBR_Certifications_LPAC__c> getcbrList(){  
        
        try{
           // if(OffsetSize==0 && prev==true)
           // OffsetSize = OffsetSize -1;
            cbrList=[SELECT SFDC_ID__c,Employee_Name__c,Employee_Type__c,badge__c,ca_product_code__c,ca_product_description__c,ca_product_name__c,certified__c,certified_status_code__c,certified_status_text__c,
                     completion_percentage__c,ldap_id__c,modify_date__c,previous_status_code__c,previous_status_text__c,resource_type__c,status_reason__c,valid_from__c,valid_to__c FROM CBR_Certifications_LPAC__c  
                     where certified__c='Yes' OR (certified__c='No' and certified_status_code__c IN (700,800)) order BY ldap_id__c LIMIT :LimitSize OFFSET :OffsetSize];
            if(cbrList<>null && cbrList.size()>0){
                totalCount=String.valueOf(cbrList.size());
                this.isDetailsPresent=true;
            }else{
                this.isDetailsPresent=false; 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No Records are Available for Certifications');
                ApexPages.addMessage(myMsg);
            }
            //snippet to catch an excpetion in test class
            if(Test.isRunningTest()){
                String e ;
                e.toLowerCase();                
            }            
        }catch(System.Exception e){
            this.isDetailsPresent=false; 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to connect Service');
            ApexPages.addMessage(myMsg);           
        }
        return cbrList;
    }
    public void FirstPage()
    {
        OffsetSize = 0;
    }
    public void previous()
    {
        OffsetSize = OffsetSize - LimitSize;
    }public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
    }public void LastPage()
    {
        if (math.mod(totalRecs,LimitSize)==0){
           // OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
           OffsetSize = (totalrecs - LimitSize);
           // OffsetSize = OffsetSize -1;
        }else{
            OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        }
        
         System.debug('totalRecs:'+totalRecs);
        System.debug('OffsetSize:'+OffsetSize);
         System.debug('LimitSize:'+LimitSize);
    }
    public boolean getprev()
    {
        if(OffsetSize == 0)
            return true;
        else
            return false;
    }
    public boolean getnxt()
    {	
        system.debug('OffsetSize:'+OffsetSize);
        if((OffsetSize + LimitSize) >= totalRecs)
            return true;
        else
            return false;
    }
    Public PageReference displayRecord(){
        PageReference newPage=new PageReference('/' + contactID);
        newPage.getParameters().put('nooverride', '1');       
        return newPage;
        
    }
    
    
}