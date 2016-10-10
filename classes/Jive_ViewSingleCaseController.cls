public without sharing class Jive_ViewSingleCaseController {

        public Id caseid {get;set;}
        public Case myCase {get;set;}
        public Boolean showCaseCreatedMessage {get; set;}
        public Boolean showComment{get; set;}
        public String myCaseNumber{get; set;}
        public Boolean showButton{get; set;} {showButton = true;}
        public String insertComment{get; set;}
        public Boolean newComment{get;set;}
        public Boolean closeComment{get;set;}{closeComment = false;}
        public Boolean reOpenComment{get;set;}{reOpenComment = false;}
        
        //private Jive_ngTurkeyService turkey {
        //get { if(turkey == null) turkey = new Jive_ngTurkeyService(); return turkey; } set;
        //}
        //Jive_ngTurkeyService turkey = new Jive_ngTurkeyService();


        public cComments[] comments{
            get{
            List<cComments> comments = new List<cComments>();
            for(CaseComment comment : [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody From CaseComment c where ParentId = :myCase.Id order by c.LastModifiedDate desc])
            {
            cComments tempcComment = new cComments();
            tempcComment.cComment = comment;

            // Build String to display.
            tempcComment.commentText = '<b>Created By: <a href=\'/' + comment.CreatedBy.Id + '\'>' + comment.CreatedBy.Name + '</a> (' + comment.CreatedDate.format() + ') | ';
            tempcComment.commentText += comment.CommentBody;
            //Add to list
            comments.add(tempcComment);
            }
            return comments;
            }
            set;
        }

        public class cComments {
            public CaseComment cComment {get; set;}
            public String commentText {get; set;}
            public String PublicPrivateAction {get; set;}
        }


        public Jive_ViewSingleCaseController() {
            String tempId = ApexPages.currentPage().getParameters().get('Id');
            myCase = [SELECT Id, CaseNumber, Subject, Title__c, Severity__c, Status, CA_Product_Controller__c, Description,
                     Business_Impact__c, CreatedDate, ClosedDate, Troubleshooting_Stage__c FROM Case  WHERE id = :tempId];
            // id=50018000005JViEAAW
            // showCreatedMessage=true
            //String queryId = ApexPages.currentPage().getParameters().get('Id');
            setCaseNumber();
            String showCreateMessage = ApexPages.currentPage().getParameters().get('showCaseCreatedMessage'); // parse from query string
            if (showCreateMessage == 'true') {
              showCaseCreatedMessage = true;
            } else {
              showCaseCreatedMessage = false;
            }
        //this.comment = new CaseComment(ParentId = myCase.Id);
        }

        public void insertComment() {
           //CaseComment tempComment = new CaseComment(ParentId = myCase.Id, CommentBody = 'peanuts' + '\n' + 'butter');
           //CaseComment tempComment = new CaseComment(ParentId = '50018000003U8oFAAS', CommentBody = 'peanuts');
           CaseComment tempComment = new CaseComment();
           Case triggerCallback = new Case(Id=myCase.Id);//used to force a callback upon case commment creation 
           if (closeComment == true){
              tempComment.ParentId = myCase.Id;
              tempComment.CommentBody = 'Case Close Requested By Customer: ' + insertComment;
            }else if (reOpenComment == true){
              tempComment.ParentId = myCase.Id;
              tempComment.CommentBody = 'Case Reopen  Requested By Customer: ' + insertComment;
            }else{
              tempComment.ParentId = myCase.Id;
              tempComment.CommentBody = insertComment;
            }
              insert tempComment;
              update triggerCallback;
              insertComment = '';
              showComment = false;
              showButton = true;
              closeComment = false;
        }


        //public void insertComment() {

        //    CaseComment tempComment = new CaseComment();
        //    tempComment.CommentBody = insertComment;
        //    tempComment.ParentId = myCase.Id;
        //    insert tempComment;
        //    insertComment = '';
        //    showComment = false;
        //    showButton = true;
        //}

        public void newComment(){
            closeComment = false;
            newComment = true;
            showButton = false;
            showComment = true;
        }

        public void setCaseNumber(){
            String queryString = ApexPages.currentPage().getParameters().get('Id');
            Case tempCase = new Case();
            tempCase = [Select CaseNumber, Id
                            FROM Case
                            WHERE id = :queryString];
            myCaseNumber = tempCase.CaseNumber;
        }

        public void closeCase() {
            newComment = false;
            closeComment = true;
            showButton = false;
            showComment = true;

        }

        public void reOpenCase() {
            reOpenComment = true;
            closeComment = false;
            newComment = false;
            showButton = false;
            showComment = true;

            Integer daysSinceClose;
            Date tempDate;       
            //if(myCase.ClosedDate != null){
            //    tempDate = myCase.ClosedDate.date();
            //    daysSinceClose = tempDate.daysBetween(Date.today());
            //}
            //if(daysSinceClose < 500){
            //    Case tempCase = new Case(Id = myCase.Id, Troubleshooting_Stage__c = '1. Problem Identification');
            //    update tempCase;
            //}else{
            //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Case cannot be reopened after 14 days'));
            //}
            //myCase.Status = 'Open';
            Case tempCase = new Case(Id = myCase.Id, Troubleshooting_Stage__c = '1. Problem Identification', Reason_for_Reopen__c = 'Case Reopen Requested');
            update tempCase;

        }

      
        public void updateCase(){
            Case tempCase = new Case(Id = myCase.Id, Description = myCase.Description + 'Test this stuff');
            update tempCase;
        }



    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    //public Jive_ViewSingleCaseController(ApexPages.StandardController stdController) {
    //    this.myCase = (Case)stdController.getRecord();
    //    String tempId = ApexPages.currentPage().getParameters().get('Id');
    //    myCase = [SELECT Id, CaseNumber, Subject, Title__c, Severity__c, Status, CA_Product_Controller__c, Description,
    //             Business_Impact__c, CreatedDate FROM Case  WHERE id = :tempId];
    //    //this.comment = new CaseComment(ParentId = myCase.Id);
    //}



}