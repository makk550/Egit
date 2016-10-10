public class SamplePaginationExtension {
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public String contactID {get;set;}
  
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                //size = 900;
                size = integer.valueof(system.label.Cert_PageLimit);
             
                string mymainquery ='SELECT SFDC_ID__c,Employee_Name__c,Employee_Type__c,badge__c,ca_product_code__c,ca_product_description__c,ca_product_name__c,certified__c,certified_status_code__c,certified_status_text__c,completion_percentage__c,ldap_id__c,modify_date__c,previous_status_code__c,previous_status_text__c,resource_type__c,status_reason__c,valid_from__c,valid_to__c FROM CBR_Certifications_LPAC__c';  
                string varquery ='where  certified__c= \'Yes\' OR (certified__c=\'No\' and certified_status_code__c IN (700,800)) order BY ldap_id__c';
                 mymainquery  =  mymainquery + ' '+ varquery;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(mymainquery));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    
    Public List<CBR_Certifications_LPAC__c> getcbrcertlist(){
        List<CBR_Certifications_LPAC__c> cbrList = new List<CBR_Certifications_LPAC__c>();
        for(CBR_Certifications_LPAC__c cbr : (List<CBR_Certifications_LPAC__c>)setCon.getRecords())
            cbrList.add(cbr);
        return cbrList;
    }
    
    public pageReference refresh() {
        setCon = null;
        getcbrcertlist();
        setCon.setPageNumber(1);
        return null;
    }
    Public PageReference displayRecord(){
        PageReference newPage=new PageReference('/' + contactID);
        newPage.getParameters().put('nooverride', '1');       
        return newPage;
        
    }

}