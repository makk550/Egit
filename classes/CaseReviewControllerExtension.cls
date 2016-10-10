public class CaseReviewControllerExtension
{
    private final Case_Review__c caseReview;
    private final Case_Review__c myCaseReview;
    private final Id caseId;
    public List<Case_Review_Admin__c> caseReviewAdmin {set; get;}
    public List<Case_Review_Type__c> caseQuestionsList {set; get;}
    public List<Case_Review_Type__c> caseQuestionsViewList {set; get;}
    public List<List<SelectOption>> scoreOptionsList {set; get;}
    public String myScoreOptionsNew {set; get;}
    private Apexpages.StandardController controller;
    public List<boolean> scoreOption1 {set; get;}
    public List<boolean> scoreOption2 {set; get;}
    public List<boolean> scoreOption3 {set; get;}
    public List<boolean> scoreOption4 {set; get;}
    
    public CaseReviewControllerExtension() {}
    
    public CaseReviewControllerExtension(ApexPages.StandardController stdController)
    {
        controller = stdController;
        this.myCaseReview = (Case_Review__c)stdController.getRecord(); 
        system.debug('**mycaseReview'+myCaseReview);
        System.debug('**** 1 *****');  
        if(myCaseReview.Id != null)
            caseReview = [Select id, Engineer_Name__c, Reviewer_Name__c, Today_Date__c, case__c from Case_Review__c where id =: myCaseReview.Id];
        else
            caseReview = (Case_Review__c)stdController.getRecord(); 
        
        Case myCase; //= caseReview.Case__r;    
        System.debug('**** 2 *****');        
        
        if(caseReview.case__c!=null)
            myCase = [Select id, casenumber, ownerid from Case where id = :caseReview.case__c][0];
        
        else
        {     caseId = ApexPages.currentPage().getParameters().get('caseId');
         CaseReview.Case__c = caseId;
         myCase = [Select id, casenumber, ownerid from Case where id = :caseId][0];
         
        }
        
        System.debug('**** 3 *****');        
        if(caseReview.Id == null)
        {
            this.caseReview.Engineer_Name__c = myCase.ownerid;
            this.caseReview.Reviewer_Name__c = UserInfo.getUserId();
            this.caseReview.Today_Date__c = Date.today();
            this.caseReview.Case_Number__c = myCase.casenumber;
            if(caseQuestionsList == null)
            {
                caseQuestionsList = new List<Case_Review_Type__c>();
            }
            
            if(scoreOption1 == null)
            {
                scoreOption1 = new List<boolean>();
            }            
            
            if(scoreOption2 == null)
            {
                scoreOption2 = new List<boolean>();
            } 
            
            if(scoreOption3 == null)
            {
                scoreOption3 = new List<boolean>();
            } 
            
            if(scoreOption4 == null)
            {
                scoreOption4 = new List<boolean>();
            }                                     
            
            System.debug('**** 4 *****');        
            if(caseReviewAdmin == null)
            {
                caseReviewAdmin = new List<Case_Review_Admin__c>();
                caseReviewAdmin = [Select Description__c, Score_Options_New__c, Explanation_of_Scores__c, Sort_Order__c, Title__c from Case_Review_Admin__c order by Sort_Order__c ASC];
                scoreOptionsList = new List<List<SelectOption>>();
                
                for(Case_Review_Admin__c myAdmin : caseReviewAdmin)
                {
                    Case_Review_Type__c tmp = new Case_Review_Type__c(Score_Options__c=myAdmin.Score_Options_New__c, Description__c=myAdmin.Description__c, Explanation__c=myAdmin.Explanation_of_Scores__c, Type__c=myAdmin.Title__c, Sort_Order__c=myAdmin.Sort_Order__c);
                    
                    if(myAdmin.Score_Options_New__c == '1-5')
                    {
                        tmp.render_3__c = true;
                    }
                    
                    if(myAdmin.Score_Options_New__c == '1-5 NR')
                    {
                        tmp.render_4__c = true;
                    }
                    
                    if(myAdmin.Score_Options_New__c == 'Yes-No')
                    {
                        tmp.render_1__c = true;
                    }
                    
                    if(myAdmin.Score_Options_New__c == 'Yes-No NR')
                    {
                        tmp.render_2__c = true;
                    }
                    caseQuestionsList.add(tmp);                                                       
                    //scoreOptionsList.add(getScoreOptions(myAdmin.Score_Options__c));
                }            
            }
            System.debug('**** 5 *****');
            
        }
        System.debug('**** 6 *****');        
        if(caseReview.Id != null)
        {   caseQuestionsList = new List<Case_Review_Type__c>();
         caseQuestionsViewList = [Select Comment__c, Description__c, Explanation__c, Score__c, Score_New__c, Type__c,render_1__c
                                  ,render_2__c,render_3__c,render_4__c
                                  ,Score_Picklist_1__c,Score_Picklist_2__c,Score_Picklist_3__c
                                  ,Score_Picklist_4__c,Case_Review__c from Case_Review_Type__c where case_review__c = :caseReview.Id order by Sort_Order__c ASC];
         caseQuestionsList.addAll(caseQuestionsViewList);
        }
        
        
        System.debug('**** 7 *****');        
    }
    
    public PageReference Save()
    {
        System.debug('**** Calling Save ****');
        
        if(this.caseReview.id == null)
        {     try{
            insert caseReview;}
         
         catch(DMLException e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failed'));     
             return null;
         }
         
        }
        
        
        
        for(Case_Review_Type__c Q : caseQuestionsList)
        {
            System.debug('**** Q Score 1 ****' + Q.Score_Picklist_1__c);
            System.debug('**** Q Score 2 ****' + Q.Score_Picklist_2__c);
            System.debug('**** Q Score 3 ****' + Q.Score_Picklist_3__c);
            System.debug('**** Q Score 4 ****' + Q.Score_Picklist_4__c);
            
            //Begin of Changes for CR:200-157898
            if(Q.Score_Picklist_3__c== null){
                Q.Total_Score__c = 0;
                Q.Score_New__c = Q.Score_Picklist_3__c;
            }
            
            //End of changes for CR:200-157898
            
            if(Q.Score_Picklist_1__c != null && Q.Score_Picklist_1__c != '')
            {
                Q.Score_New__c = Q.Score_Picklist_1__c;
            }
            if(Q.Score_Picklist_2__c != null && Q.Score_Picklist_2__c != '')
            {
                Q.Score_New__c = Q.Score_Picklist_2__c;
            }
            if(Q.Score_Picklist_3__c != null && Q.Score_Picklist_3__c != '')
            {  
                Q.Total_Score__c = Integer.valueOf(Q.Score_Picklist_3__c);
                Q.Score_New__c = Q.Score_Picklist_3__c;
            }
            if(Q.Score_Picklist_4__c != null && Q.Score_Picklist_4__c != '')
            {
                Q.Score_New__c = Q.Score_Picklist_4__c;
            }     
            
            
            if(Q.Case_Review__c==null)
            {
                Q.Case_Review__c = caseReview.id;
            }
        }
        try{
            upsert caseQuestionsList;
        }
        
        catch(DMLException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Upsert Failed'));     
            return null;
        }
        
        PageReference pageRef;
        if(caseId==null)
            pageRef = controller.save(); 
        else
            
            pageRef = new PageReference('/'+caseId); 
        return pageRef;              
    }   
    
    
    
    Public PageReference Cancel(){
        
        PageReference pageRef;
        if(caseId==null)
            pageRef = controller.cancel(); 
        else
            
            pageRef = new PageReference('/'+caseId); 
        return pageRef;   
    } 
    
}