public class DefectExtensionController{
    public Defect__c defect;
    public Defect_Comment__c comment {get;set;}
    private Id caseId ; 
    public Case caseRec {get;set;}
    private String requestor=''; 
    public Boolean showSave {get;set;}
    public Boolean showContinue {get;set;} 
    public String responseFromService;
    public DefectExtensionController(ApexPages.StandardController stdController) {
            showSave = true ; 
            showContinue = false;
            this.defect= (Defect__c)stdController.getRecord();
            caseId = apexpages.currentpage().getparameters().get('caseid');
            comment = new Defect_Comment__c();
            caseRec = [select Id , casenumber ,Priority , Severity__c , CA_Product_Controller__r.Name,
                              CA_Product_Component__r.Component_Code__c,CA_Product_Component__r.Name,Site_Name__c, Tops_Support_Site_ID__c,
                              Customer_Environment__c,owner.type , ownerId ,CreatedDate ,Product_Release__c
                       from Case 
                       where Id =:caseId limit 1
                      ];
            requestor = [select pmfkey__c from user where Id = :Userinfo.getuserid() limit 1].pmfkey__c;
                     
    }
    public class comment{
        public string comment ;
        public string cdate ;
        public string author ;
    }
    
    public pageReference save(){
        showSave = false ; 
        defect.Priority__c = caseRec.Priority;
        defect.Severity__c = caseRec.Severity__c;
        createDefectCallout();
        return null;
        
    }
    public pageReference cancel(){
        return new pagereference('/'+caseId);
    }
    public  pageReference continueSave(){
        insert defect; 
        Defect_Case_Association__c defectCaseAssociation = new Defect_Case_Association__c();
        defectCaseAssociation.Defect__c = defect.Id ; 
        defectCaseAssociation.case__c = caseId;
        insert defectCaseAssociation;
        comment.Defect__c = defect.Id;
        system.debug('comment.Comments__c======='+comment.Comments__c);
        if(comment.Comments__c!=null && comment.Comments__c!=''){
            insert comment;
            CaseComment caseCommentObject = new CaseComment();
            caseCommentObject.CommentBody = 'Defect # '+defect.Name+' Updated from ServiceCloud Case # '+caseRec.CaseNumber+'\nDiscussion: '+comment.Comments__c;
            caseCommentObject.ParentId = caseId;
            insert caseCommentObject;
        }
        system.debug('Id==========='+comment.Id);
        
        return new pagereference('/'+caseId);
    }
    private void createDefectCallout(){
       try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(buildEndpoint());
            req.setMethod('POST');
            req.setTimeout(Integer.valueof(Label.RallyTimeout));
            req.setHeader('Content-Type', 'application/json');
            req.setBody(createBody());
            HTTPResponse res;   
            String response ;
            if(!Test.isRunningTest()){
               Layer7UtilCallout Layer7UtilCalloutObj = new Layer7UtilCallout();
               responseFromService = Layer7UtilCalloutObj.processLayer7Services(req);
               system.debug('responseFromService---->'+responseFromService);
            }
            else{
                responseFromService = http.send(req).getBody();
                //res = http.send(req);
            }
            
            if(responseFromService == null || responseFromService ==''){
                 DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
                 defectErrorLogObj.defectErrorLogMethod(caseRec.casenumber,'',req.getBody(),responseFromService,req.getMethod(),0,req.getEndpoint());
                 CaseComment caseCommentObject = new CaseComment();
                 ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'There has been an error. Please try again or contact your system administrator');
                 ApexPages.addmessage(errMsg); 
                 caseCommentObject.CommentBody = 'Error- '+errMsg.getSummary();
                 caseCommentObject.ParentId = caseId;
                 UtilityFalgs.isDefectUpdate = true;
                 insert caseCommentObject;
            }else{
                parseResponse(responseFromService,req);
            }
        }Catch(Exception serviceException){
            DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
            defectErrorLogObj.defectErrorLogMethod(caseRec.casenumber,'','',serviceException.getMessage(),'',0,'');   
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'The defect you submitted timed out.  Thus, the defect has not been linked to the ServiceCloud case and might not have even been created in Rally.  If the Rally defect was created then it would contain the ServiceCloud case number in the Salesforce Case Number field in the defect and you can associate the defect to your ServiceCloud case.  If the defect was not created in Rally then you need to resubmit it');
            ApexPages.addmessage(errMsg); 
        }
       
    }
    private string createBody(){
        comment commentReq = new comment();
        commentReq.comment = comment.Comments__c;
        commentReq.author = requestor.toLowerCase();
        commentReq.cDate =  String.valueof(DateTime.Now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
        List<comment> commentreqList = new List<comment>();
        if(commentReq.comment!=null && commentReq.comment!=''){
            commentreqList.add(commentReq);
        }
        JSONGenerator jGenerator = JSON.createGenerator(true);
        jGenerator.writeStartObject();
        jGenerator.writeStringField('subject',defect.subject__c);
        jGenerator.writeStringField('description',defect.Description__c);
        jGenerator.writeStringField('product',caseRec.CA_Product_Component__r.Name);
        jGenerator.writeStringField('component',caseRec.CA_Product_Component__r.Component_Code__c);
        jGenerator.writeStringField('externalSystemNumber',caseRec.casenumber);
        jGenerator.writeStringField('externalSystemID',caseRec.Id);
        jGenerator.writeStringField('severity',caseRec.Severity__c); 
        jGenerator.writeStringField('priority',caseRec.Priority);
        jGenerator.writeStringField('environment',caseRec.Customer_Environment__c);
        jGenerator.writeStringField('requestor',requestor.toLowerCase());
        jGenerator.writeStringField('customer',caseRec.Site_Name__c+' ('+caseRec.Tops_Support_Site_ID__c+')');
        jGenerator.writeStringField('createdDate',caseRec.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
        if(caseRec.Product_Release__c!=null && caseRec.Product_Release__c!=''){
            jGenerator.writeStringField('productRelease',caseRec.Product_Release__c);
        }
        if(commentReq.comment !=null && commentReq.comment!='' && commentreqList!=null){
            jGenerator.writeObjectField('comments', commentreqList);  
        }         
        jGenerator.writeEndObject();
        String jsonReq = jGenerator.getAsString();
        jsonReq = jsonReq.replace('cdate','date');
        system.debug('jsonReq===='+jsonReq);
        return jsonReq;
    }
    private void parseResponse(String res,HttpRequest req){
         system.debug('response'+res);
         res = res.replace('\\"','\\\"');
         res = res.removeStart('[');
         res = res.removeEnd(']');
         
         DefectResponse defectRes = (DefectResponse)JSON.deserialize(res, DefectResponse.class);
         CaseComment CaseCommentObject = new CaseComment();
         if(defectRes.successful){
             showContinue = true;
             defect.name = defectRes.uiId;
             defect.Defect_URL__c = defectRes.uiURL;
             defect.Defect_UUID__c = defectRes.uiURL.substringAfterLast('/'); // extract the UUID of defect             
             defect.Defect_Submitted_By__c = UserInfo.getName();
             defect.Defect_Object_ID__c = defectRes.objectId;
             defect.Priority__c = defectRes.defectPriority;
             defect.Severity__c = defectRes.defectSeverity;
             defect.R_D_System__c = defectRes.workspaceName;
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Defect Creation Successful <br/> Defect Id : '+defectRes.uiId+' <br/> Click on Continue');
             ApexPages.addmessage(msg);
             caseCommentObject.CommentBody = 'Defect '+ defectRes.uiId +' successfully created';
             if(defectRes.warnings!=null && defectRes.warnings.size()>0){
                ApexPages.Message warningMsg = new ApexPages.Message(ApexPages.Severity.WARNING, defectRes.warnings[0].detail);
                ApexPages.addmessage(warningMsg);
                caseCommentObject.CommentBody = caseCommentObject.CommentBody + '\r\n Warning-'+warningMsg.getSummary();
                continueSave(); 
                 
             }
         }else{
             DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
             defectErrorLogObj.defectErrorLogMethod(caseRec.casenumber,'',req.getBody(),responseFromService,req.getMethod(),0,req.getEndpoint());
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL, defectRes.errors[0].detail);
             ApexPages.addmessage(errMsg);
             caseCommentObject.CommentBody = 'Error- '+errMsg.getSummary();
         }
         caseCommentObject.ParentId = caseId;
         UtilityFalgs.isDefectUpdate = true;
         insert caseCommentObject;
    }
   /*
    * Method used to determine if org instance is sandbox or production and use endpoint respectively 
    */
    private string buildEndpoint(){
        String endpoint ;
        Organization org = [select Id, IsSandbox from Organization limit 1 ];
        if(org.IsSandbox){
             endpoint = Label.RallyEndpointQA;
        }
        else {
             endpoint = Label.RallyProductionEndpoint;
        }
        return endpoint;
    }
}