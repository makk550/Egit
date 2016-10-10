global class BatchCBRCalculatedCertifications implements Database.Batchable<sObject> {
	
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT ExternalId,badge__c,ca_product_code__c,ca_product_description__c,ca_product_name__c,certified__c,certified_status_code__c,certified_status_text__c,completion_percentage__c,ldap_id__c,modify_date__c,previous_status_code__c,previous_status_text__c,resource_type__c,status_reason__c,valid_from__c,valid_to__c FROM cbr_Calculated_Certification__x where certified__c=\'Yes\' OR (certified__c=\'No\' and certified_status_code__c IN (700,800))';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<cbr_Calculated_Certification__x> certifications) 
    {
        SupportOfferingsFlowController spf = new SupportOfferingsFlowController();
        List<String> ldapIDList=new List<String>();
        List<CBR_Certifications_LPAC__c> cbrCertificationsLPACList = new List<CBR_Certifications_LPAC__c>();
        Map<String,Map<String,String>> ldapIdsfIdNameEmpTypeMap = new Map<String,Map<String,String>>();
        if(certifications != null && certifications.size() > 0)
        {
          for(cbr_Calculated_Certification__x cbrData:certifications){
                ldapIDList.add(cbrData.ldap_id__c);
          }
          ldapIdsfIdNameEmpTypeMap=spf.searchUserOrContact(ldapIdlist);
        }
        
        for(cbr_Calculated_Certification__x data:certifications){
            CBR_Certifications_LPAC__c cbrData=new CBR_Certifications_LPAC__c(badge__c=data.badge__c,ca_product_code__c=data.ca_product_code__c,ca_product_description__c=data.ca_product_description__c,ca_product_name__c=data.ca_product_name__c,certified__c=data.certified__c,certified_status_code__c=data.certified_status_code__c,certified_status_text__c=data.certified_status_text__c,completion_percentage__c=data.completion_percentage__c,ldap_id__c=data.ldap_id__c.toUpperCase(),modify_date__c=data.modify_date__c,previous_status_code__c=data.previous_status_code__c,previous_status_text__c=data.previous_status_text__c,resource_type__c=data.resource_type__c,status_reason__c=data.status_reason__c,valid_from__c=data.valid_from__c,valid_to__c=data.valid_to__c,UniqueCBRIdentifier__c=data.ExternalId);
                                                                    cbrData.SFDC_ID__c=ldapIdsfIdNameEmpTypeMap.get('salesforceID').get(cbrData.ldap_id__c);
                                                                    cbrData.Employee_Name__c = ldapIdsfIdNameEmpTypeMap.get('Name').get(cbrData.ldap_id__c);
                                                                    cbrData.Employee_Type__c = ldapIdsfIdNameEmpTypeMap.get('EmpType').get(cbrData.ldap_id__c);
                                                                    cbrCertificationsLPACList.add(cbrData);
        }
        upsert cbrCertificationsLPACList UniqueCBRIdentifier__c;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}