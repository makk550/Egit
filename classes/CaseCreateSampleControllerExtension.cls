public  class CaseCreateSampleControllerExtension {

    public Case caseRec {get;set;}
    public boolean isEditing {get;set;}
  
    public CaseCreateSampleControllerExtension(ApexPages.StandardController stdController) {
        this.caseRec = (Case)stdController.getRecord();
        String caseId = ApexPages.currentPage().getParameters().get('Id');
                
        if(caseId != NULL)
            isEditing = true;        
    }

   
}