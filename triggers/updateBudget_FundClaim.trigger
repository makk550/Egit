trigger updateBudget_FundClaim on SFDC_MDF_Claim__c (after insert, after update, after delete, after undelete) {

    /*
     * Recalculates The FundClaim Amount on the Budget on insert, update, delete of a fund claim.
     * Only those FundClaims are considered which are approved (approved__c = true)
     *
     */ 
    List<SFDC_Budget__c> budgetList = new List<SFDC_Budget__c>();
    Set<Id> budgetSet = new Set<Id>();
    
    //list of fund Claim - code added by Siddharth
    List<SFDC_MDF_Claim__c> listOfMDFClaims = new List<SFDC_MDF_Claim__c>();
    MDF_GrantAccessToApprovers classVar = new MDF_GrantAccessToApprovers();

    if (Trigger.isDelete) {
        //for delete
        for (SFDC_MDF_Claim__c changedMDFClaim : Trigger.old) {
            if (changedMDFClaim.Budget__c != null)
                budgetSet.add(changedMDFClaim.Budget__c);
        }
        
    } else {
        if (Trigger.isUpdate) {
            for (Integer i = 0; i < Trigger.size; i++) {
                SFDC_MDF_Claim__c oldMDFClaim = Trigger.old[i];
                SFDC_MDF_Claim__c newMDFClaim = Trigger.new[i];
                Id oldBudgetId = oldMDFClaim.Budget__c;
                Id newBudgetId = newMDFClaim.Budget__c;
                if (oldBudgetId != null) {
                    if (newBudgetId == null || oldBudgetId != newBudgetId) {
                        //budget removed - need to update old budget
                        budgetSet.add(oldBudgetId);
                    }
                } 
                
                //code added by Siddharth in R2 for giving access to approvers of Fund Claim.
                if(oldMDFClaim.MDF_Claim_Approval_Status__c!= 'Submitted' && newMDFClaim.MDF_Claim_Approval_Status__c=='Submitted')
                    listOfMDFClaims.add(newMDFClaim );
                if(oldMDFClaim.MDF_Claim_Approval_Status__c== 'Submitted' && newMDFClaim.MDF_Claim_Approval_Status__c=='First Approval')
                    listOfMDFClaims.add(newMDFClaim );
                if(oldMDFClaim.MDF_Claim_Approval_Status__c== 'First Approval' && newMDFClaim.MDF_Claim_Approval_Status__c=='Second Approval')
                    listOfMDFClaims.add(newMDFClaim );
                System.debug('------- delegated approver'+newMDFClaim.Approver_1__r.DelegatedApproverId);
                //end of if conditions added by Siddharth
                  
            }
            
            //code added by Siddharth in R2- calling the class to give access to the approvers
            if(listOfMDFClaims!=null && listOfMDFClaims.size()>0)
                classVar.giveAccessToMDFClaimApprovers(listOfMDFClaims);
           
        }
        
        for (SFDC_MDF_Claim__c changedMDFClaim : Trigger.new) {
            if (changedMDFClaim.Budget__c != null)
                budgetSet.add(changedMDFClaim.Budget__c);
        }
    }
    budgetList = BudgetUtil.getBudgetList(budgetSet);

    //update the budget objects
    if (budgetList.size() > 0) {
        try {
           BudgetUtil.updateList(budgetList);
        } catch (DmlException e) {
            String message = 'An error occured while Updating Budget: ';
            message += '\nMessage: ' + e.getMessage();
            message += '\nCause: ' + e.getCause();
            System.debug(message);
            budgetList.get(0).addError(message);
        }
    }
}