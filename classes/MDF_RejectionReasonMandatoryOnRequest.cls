/* class to validate the rejection reason during MDF Request approval process
Created by - Jon Holato
# of SOQL/DML - 0
*/
public with sharing class MDF_RejectionReasonMandatoryOnRequest {
    SFDC_MDF__c OldRequest=new SFDC_MDF__c();
    SFDC_MDF__c NewRequest=new SFDC_MDF__c();
    public void validateRejectionReason(List<SFDC_MDF__c> OldRequestList,List<SFDC_MDF__c> NewRequestList){
        for(Integer i=0;i<NewRequestList.size();i++){
            OldRequest = OldRequestList[i];
            NewRequest = NewRequestList[i];
            
            //If Status is rejected, the Rejection Reason should be mandatory
            if(NewRequest.Status__c=='Rejected' && (NewRequest.Rejection_Reason__c=='' || NewRequest.Rejection_Reason__c == null))
                NewRequest.Rejection_Reason__c.addError('Rejection Reason can not be blank, when Approval Status is Rejected'); 
        }
    }
}