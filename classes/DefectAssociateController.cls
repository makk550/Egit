/*
Created By: Tarun Sharma
Created On: 10/01/2015
Purpose: B-04030: Associate an existing Defect to Case
Modified By:
*/
public class DefectAssociateController{
    
    public String defectName{get;set;}
    public String systemName{get;set;}
    public String defectType{get;set;}
    public Boolean isUpdateCallOut = false;
    public Boolean submitRecord{get;set;}
    public Boolean continueSubmitRecord{get;set;}
    public String currentRecordId;
    public List<Case> caseObj; 
    public String updateWarningMsg;
    public String updateSuccessMsg;
    public String insertUiURL;
    public String uuid ; // unique identifier of defect 
    public CaseComment caseCommentObject;
    public String responseFromGetService;
    public String responseFromUpdateService;
    
    public DefectAssociateController(){
        submitRecord = true;
        continueSubmitRecord = false;
        currentRecordId = apexpages.currentpage().getparameters().get('caseId');
        systemName = 'Rally'; //Rally is default value for R&D System
        defectType = 'Defect'; //Defect is default value for defect type
    }
    
    public pageReference cancelAssociation(){
        return new pagereference('/'+currentRecordId);
    }
    
    public pageReference submitDefectAssociate(){
        list<Defect__c> defectObj;
        
        if(defectName == '' || defectName == null){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please enter the value for Defect ID');
            ApexPages.addmessage(errMsg);
            return null;
        }else{
             //callout to check defect exist in Rally system or not
            caseObj = [Select CA_Product_Controller__r.Name, CA_Product_Component__r.Name,CA_Product_Component__r.Component_Code__c,CaseNumber, Subject, Id, Tops_Support_Site_ID__c, Site_Association__r.Name from Case where Id=:currentRecordId limit 1];
            checkDefectCallOut();
        }
        return null;
    }
    
    public pageReference continueSubmitAssocaite(){//After successfully inserted a record in defect case association object then navigate user back to case detail page

        return new pagereference('/'+currentRecordId);
    }
    
    private void checkDefectCallout(){
        try{
            String productName;
            if(caseObj[0].CA_Product_Component__r.Name.contains(' ')){
              productName  = caseObj[0].CA_Product_Component__r.Name.replaceAll(' ','+');
            }else{
              productName = caseObj[0].CA_Product_Component__r.Name;
            }
            Http httpObj = new Http();
            HttpRequest httpRequestObj = new HttpRequest();
            httpRequestObj.setMethod('GET');
            httpRequestObj.setEndpoint(prepareEndPoint()+'&defectNumber='+defectName+'&product='+productName);
            httpRequestObj.setHeader('Content-Type', 'application/json');
            httpRequestObj.setTimeout(Integer.valueof(Label.RallyTimeout));
            HTTPResponse httpResponseObj;
            String jsonResponse;
            if(!Test.isRunningTest()){
                Layer7UtilCallout Layer7UtilCalloutObj = new Layer7UtilCallout();
                responseFromGetService = Layer7UtilCalloutObj.processLayer7Services(httpRequestObj);
                system.debug('--responseFromGetService -->'+responseFromGetService);
            }else{
                responseFromGetService = httpObj.send(httpRequestObj).getBody();
                system.debug('--responseFromGetService----response -->'+httpObj.send(httpRequestObj).getBody());
            }
            
            if(responseFromGetService== null || responseFromGetService==''){
               DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
               defectErrorLogObj.defectErrorLogMethod(caseObj[0].CaseNumber,defectName,httpRequestObj.getBody(),responseFromGetService,httpRequestObj.getMethod(),0,httpRequestObj.getEndpoint());
               ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'There has been an error. Please try again or contact your system administrator');
               ApexPages.addmessage(errMsg);
            }else{
                prepareResponse(responseFromGetService,httpRequestObj);
            }
        }Catch(Exception serviceException){
            DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
            defectErrorLogObj.defectErrorLogMethod(caseObj[0].CaseNumber,defectName,'',serviceException.getMessage(),'',0,'');   
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'The defect you submitted timed out.  Thus, the defect has not been linked to the ServiceCloud case and might not have even been created in Rally.  If the Rally defect was created then it would contain the ServiceCloud case number in the Salesforce Case Number field in the defect and you can associate the defect to your ServiceCloud case.  If the defect was not created in Rally then you need to resubmit it');
            ApexPages.addmessage(errMsg); 
        }
    }
    
    private String prepareEndPoint(){
        String retreiveEndPoint;
        Organization orgObj = [select Id, IsSandbox from Organization limit 1 ];
        if(orgObj.IsSandbox){
            retreiveEndPoint = Label.RallyGetEndpointQA;
        }
        else {
             retreiveEndPoint = Label.RallyProductionGetEndpoint;
        }
        return retreiveEndPoint;
   }
   
     private void prepareResponse(String response, HttpRequest httpRequestObj){
         system.debug('service response------------>'+response);
         response = response.replace('\\"','\\\"');
         response = response.removeStart('[');
         response = response.removeEnd(']');
         system.debug('JSON------->'+response);
        
         AssociateDefectResponse associateDefectObject = (AssociateDefectResponse)JSON.deserialize(response, AssociateDefectResponse.class);
         uuid = associateDefectObject.defect.uiURL.substringAfterLast('/'); // extract the UUID of defect    
         system.debug('associateDefectObject----->'+associateDefectObject);
         
         if(associateDefectObject<>null){
             if((!associateDefectObject.successful)){
                 ApexPages.Message errMsg;
                 DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
                 defectErrorLogObj.defectErrorLogMethod(caseObj[0].CaseNumber,defectName,httpRequestObj.getBody(),responseFromGetService,httpRequestObj.getMethod(),0,httpRequestObj.getEndpoint());
                 if(associateDefectObject.errors <> null && associateDefectObject.errors.size()>0){ 
                     errMsg = new ApexPages.Message(ApexPages.Severity.FATAL,associateDefectObject.errors[0].detail);
                 }else if(associateDefectObject.warnings<>null && associateDefectObject.warnings.size()>0){
                     errMsg = new ApexPages.Message(ApexPages.Severity.WARNING,associateDefectObject.warnings[0].detail);
                 }
                 ApexPages.addmessage(errMsg);
             }else{
                   List<Defect__c> defObj;
                   if(associateDefectObject.defect<>null && associateDefectObject.defect.defectNumber<>null){
                      defObj = [Select Id, Defect_Object_ID__c, Name from Defect__c where Name=:associateDefectObject.defect.defectNumber and Defect_UUID__c  =: uuid limit 1];
                   }         
                   if(defObj<>null && defObj.size()>0){
                       list<Defect_Case_Association__c> existingRecord = [select Case__c from Defect_Case_Association__c where Case__c=:currentRecordId AND Defect__c=:defObj[0].Id limit 1]; // to check same record already exist in defect case association object
                
                    if(existingRecord<> null  && existingRecord.size()==0){
                        if(defObj[0].Defect_Object_ID__c <> null){
                            updateDefectCaseAssociation(defObj[0].Defect_Object_ID__c,caseObj);
                        }
                        if(isUpdateCallOut){
                            submitRecord = false;
                            continueSubmitRecord = true;
                            Defect_Case_Association__c defectCaseAssociateObj = new Defect_Case_Association__c();
                            defectCaseAssociateObj.Case__c = currentRecordId;
                            defectCaseAssociateObj.Defect__c = defObj[0].Id;
                            insert defectCaseAssociateObj;
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Confirm, 'Association successful');
                            ApexPages.addmessage(errMsg);
                            caseCommentObject = new CaseComment();
                            caseCommentObject.CommentBody = 'Defect '+associateDefectObject.defect.defectNumber+' successfully associated';
                            caseCommentObject.ParentId = currentRecordId;
                            UtilityFalgs.isDefectUpdate = true; 
                            insert caseCommentObject;
                            if(defObj[0].Defect_Object_ID__c <> null){
                                ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.Confirm, updateSuccessMsg);
                                ApexPages.addmessage(successMsg);
                                if(updateWarningMsg<>null){
                                    ApexPages.Message updateWarnMsg = new ApexPages.Message(ApexPages.Severity.WARNING,updateWarningMsg);
                                    ApexPages.addmessage(updateWarnMsg);
                                }
                            }
                        }
                    }else{
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, defObj[0].Name + ' already associate with the same case number');
                        ApexPages.addmessage(errMsg);
                    }
                }else{
                    
                    if(associateDefectObject.defect<>null && associateDefectObject.defect.defectId<>null){
                        updateDefectCaseAssociation(associateDefectObject.defect.defectId,caseObj);
                    }
                                    
                    if(isUpdateCallOut && associateDefectObject.defect<>null){
                        
                        Defect__c defectObject = new Defect__c();
                        if(associateDefectObject.defect.defectNumber<>null){
                            defectObject.Name = associateDefectObject.defect.defectNumber;
                        }
                        //defectObject.Defect_Id__c = associateDefectObject.uiId;
                        if(associateDefectObject.defect.defectOwner<>null){
                            defectObject.Defect_Owner__c = associateDefectObject.defect.defectOwner;
                        }
                        if(String.isNotBlank(insertUiURL)<>null){
                            defectObject.Defect_URL__c = insertUiURL;//associateDefectObject.defect.uiURL;
                            defectObject.Defect_UUID__c = insertUiURL.substringAfterLast('/'); // extract the UUID of defect    
                        }
                        if(associateDefectObject.defect.defectId<>null){
                            defectObject.Defect_Object_ID__c = associateDefectObject.defect.defectId;
                        }
                        if(associateDefectObject.defect.status<>null){
                         defectObject.Status__c = associateDefectObject.defect.status;
                        }
                        if(associateDefectObject.defect.defectPripority<>null){
                            defectObject.Priority__c = associateDefectObject.defect.defectPripority;
                        }
                        if(associateDefectObject.defect.subject<>null){
                            defectObject.Subject__c = associateDefectObject.defect.subject;
                        }
                        if(associateDefectObject.defect.defectSeverity<>null){
                            defectObject.Severity__c = associateDefectObject.defect.defectSeverity;
                        }
                        if(associateDefectObject.defect.description<>null){
                            defectObject.Description__c = associateDefectObject.defect.description;
                        }
                        //if(){
                            //defectObject.Defect_Submitted_By__c =  Userinfo.getName();
                        //}
                        if(associateDefectObject.defect.targetedReleaseNumber<>null){
                            defectObject.Targeted_Release_Number__c = associateDefectObject.defect.targetedReleaseNumber;
                        }
                        if(associateDefectObject.defect.targetReleaseDate<>null){
                           defectObject.Target_Release_date__c =  Date.valueOf(associateDefectObject.defect.targetReleaseDate);
                        }
                        if(associateDefectObject.defect.resolution<>null){
                            defectObject.Resolution__c =  associateDefectObject.defect.resolution;
                        }
                        insert defectObject;
                                        
                        Defect_Case_Association__c defectCaseAssociateObj = new Defect_Case_Association__c();
                        defectCaseAssociateObj.Case__c = currentRecordId;
                        defectCaseAssociateObj.Defect__c = defectObject.Id;
                        insert defectCaseAssociateObj;
                        submitRecord = false;
                        continueSubmitRecord = true;
                        
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Confirm, 'Association Successful');
                        ApexPages.addmessage(errMsg);
                        ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.Confirm, updateSuccessMsg);
                        ApexPages.addmessage(successMsg);
                        caseCommentObject = new CaseComment();
                        caseCommentObject.CommentBody = 'Defect '+associateDefectObject.defect.defectNumber+' successfully associated';
                        caseCommentObject.ParentId = currentRecordId;
                        UtilityFalgs.isDefectUpdate = true; 
                        insert caseCommentObject;
                        if(associateDefectObject.warnings<>null && associateDefectObject.warnings.size()>0){
                            ApexPages.Message warningMsg = new ApexPages.Message(ApexPages.Severity.WARNING,associateDefectObject.warnings[0].detail);
                            ApexPages.addmessage(warningMsg);
                        }
                        if(updateWarningMsg<>null){
                            ApexPages.Message updateWarnMsg = new ApexPages.Message(ApexPages.Severity.WARNING,updateWarningMsg);
                            ApexPages.addmessage(updateWarnMsg);
                        }
                    }
                }
            }
        }else{
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Response returned by service is null');
             ApexPages.addmessage(errorMsg);
    }
}
    
    private void updateDefectCaseAssociation(String defectURL,List<Case> caseObject){
        try{
            Http httpObj = new Http();
            HttpRequest httpRequestObj = new HttpRequest();
            httpRequestObj.setMethod('PUT');
            httpRequestObj.setEndpoint(prepareUpdateEndPoint());
            httpRequestObj.setHeader('Content-Type', 'application/json');
            httpRequestObj.setBody(prepareUpdateBody(defectURL,caseObject));
            httpRequestObj.setTimeout(Integer.valueof(Label.RallyTimeout));
            HTTPResponse httpResponseObj;
            String jsonResponse;
            if(!Test.isRunningTest()){
                Layer7UtilCallout Layer7UtilCalloutObj = new Layer7UtilCallout();
                responseFromUpdateService = Layer7UtilCalloutObj.processLayer7Services(httpRequestObj);
                system.debug('--responseFromUpdateService -->'+responseFromUpdateService);
            }else{
                responseFromUpdateService = httpObj.send(httpRequestObj).getBody();
                system.debug('--responseFromUpdateService----response -->'+httpObj.send(httpRequestObj).getBody());
            }
            
            if(responseFromUpdateService == null || responseFromUpdateService ==''){
              DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
              defectErrorLogObj.defectErrorLogMethod(caseObj[0].CaseNumber,defectName,httpRequestObj.getBody(),responseFromUpdateService,httpRequestObj.getMethod(),0,httpRequestObj.getEndpoint());
              ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'There has been an error. Please try again or contact your system administrator');
              ApexPages.addmessage(errMsg); 
            }else{
              prepareUpdateResponse(responseFromUpdateService,httpRequestObj); 
            }
        }Catch(Exception serviceException){
            DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
            defectErrorLogObj.defectErrorLogMethod(caseObj[0].CaseNumber,defectName,'',serviceException.getMessage(),'',0,'');   
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'The defect you submitted timed out.  Thus, the defect has not been linked to the ServiceCloud case and might not have even been created in Rally.  If the Rally defect was created then it would contain the ServiceCloud case number in the Salesforce Case Number field in the defect and you can associate the defect to your ServiceCloud case.  If the defect was not created in Rally then you need to resubmit it');
            ApexPages.addmessage(errMsg); 
        }
    }
    
    private String prepareUpdateEndPoint(){
        String retreiveEndPoint;
        Organization orgObj = [select Id, IsSandbox from Organization limit 1 ];
        if(orgObj.IsSandbox){
            retreiveEndPoint = Label.RallyEndpointQA;
        }
        else {
             retreiveEndPoint = Label.RallyProductionEndpoint;
        }
        return retreiveEndPoint;
   }
    
    private string prepareUpdateBody(String defectURL, List<Case> caseObject){        
        JSONGenerator jsonGeneratorObj = JSON.createGenerator(true);
        jsonGeneratorObj.writeStartObject();
        jsonGeneratorObj.writeStringField('objectId',defectURL);
        jsonGeneratorObj.writeStringField('product',caseObject[0].CA_Product_Component__r.Name);
        jsonGeneratorObj.writeStringField('externalSystemNumber',caseObject[0].CaseNumber);
        jsonGeneratorObj.writeStringField('externalSystemID',caseObject[0].Id);
        jsonGeneratorObj.writeStringField('customer',caseObject[0].Site_Association__r.Name+' ('+caseObject[0].Tops_Support_Site_ID__c+')');
        jsonGeneratorObj.writeEndObject();
        String jsonRequest = jsonGeneratorObj.getAsString();
        system.debug('jsonRequestqqqq----->'+jsonRequest);
        return jsonRequest;
    }  
    
    private void prepareUpdateResponse(String response, HttpRequest httpRequestObj){
         system.debug('service responseqqq------------>'+response);
         response = response.replace('\\"','\\\"');
         response = response.removeStart('[');
         response = response.removeEnd(']');
         system.debug('JSONqqq------->'+response);
        
         DefectResponse defectResponseObject = (DefectResponse)JSON.deserialize(response, DefectResponse.class);
        if(defectResponseObject.successful){
            isUpdateCallOut = true;
            insertUiURL = defectResponseObject.uiUrl;
            updateSuccessMsg = 'Defect '+ defectResponseObject.uiId+' successfully updated in Rally System';
               
            if(defectResponseObject.warnings<>null && defectResponseObject.warnings.size()>0){
                updateWarningMsg = defectResponseObject.warnings[0].detail;
            }
        }else{
            DefectErrorLogHelper defectErrorLogObj = new DefectErrorLogHelper();
            defectErrorLogObj.defectErrorLogMethod(caseObj[0].CaseNumber,defectName,httpRequestObj.getBody(),responseFromUpdateService,httpRequestObj.getMethod(),0,httpRequestObj.getEndpoint());
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.FATAL,defectResponseObject.errors[0].detail);
            ApexPages.addmessage(errMsg);
        }
        
   }
}