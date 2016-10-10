global class GSSTransactionsWrapper implements Comparable {

    public GSS_Transactions__c gssTransObj;
    
    // Constructor
    public GSSTransactionsWrapper(GSS_Transactions__C gssObj) {
        gssTransObj = gssObj;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        GSSTransactionsWrapper compareToGssTranObj = (GSSTransactionsWrapper)compareTo;
        
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (gssTransObj.LastModifiedDate > compareToGssTranObj.gssTransObj.LastModifiedDate) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (gssTransObj.LastModifiedDate < compareToGssTranObj.gssTransObj.LastModifiedDate) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;      
        //return null;//****remove this line
    }
}