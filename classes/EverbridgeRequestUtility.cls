public class EverbridgeRequestUtility {
    
	public static Set<Id> sevUpdatedCasesSet = new Set<Id>();
    public static boolean triggerExecutedOnce = false;
    
    public static String prepareRequestBody(Case caseRec){
        
        EverBridgeRequestFromJSON.cls_phaseDefinitions phaseDefObj = new EverBridgeRequestFromJSON.cls_phaseDefinitions();
        phaseDefObj.id = 1001;
        phaseDefObj.status = 'A';
        phaseDefObj.isDefault = false;
        phaseDefObj.name = 'New';
        phaseDefObj.seq = 0;
        
        List<EverBridgeRequestFromJSON.cls_phaseDefinitions> phaseDefinitionsList = new List<EverBridgeRequestFromJSON.cls_phaseDefinitions>();
        phaseDefinitionsList.add(phaseDefObj);
        
        
        EverBridgeRequestFromJSON.cls_val asgnGroup1 = new EverBridgeRequestFromJSON.cls_val();
        asgnGroup1.variableValue = caseRec.Product__c; //'Test Group'; //TODO - caseRec.CA_Product_Controller__r.Name;
        
        EverBridgeRequestFromJSON.cls_val asgnGroup2 = new EverBridgeRequestFromJSON.cls_val();
        asgnGroup2.variableValue = 'None';
        
        EverBridgeRequestFromJSON.cls_val notifDetails = new EverBridgeRequestFromJSON.cls_val();
        notifDetails.variableValue = 'Case Subject: ' + caseRec.Subject;//'This is a test of the incident template';  //TODO
        
        EverBridgeRequestFromJSON.cls_val severity = new EverBridgeRequestFromJSON.cls_val();
        severity.variableValue = caseRec.Severity__c;//'1'; //TODO caseRec.Severity__c
        
        EverBridgeRequestFromJSON.cls_val caseNum = new EverBridgeRequestFromJSON.cls_val();
        caseNum.variableValue = caseRec.CaseNumber; //'023456'; //TODO caseRec.caseNumber
        
        EverBridgeRequestFromJSON.cls_val customer = new EverBridgeRequestFromJSON.cls_val();
        customer.variableValue = caseRec.Site_Name__c; //'Test Customer'; //TODO - Site Name  caseRec.Site_Association__r.Name
        
        EverBridgeRequestFromJSON.cls_val product = new EverBridgeRequestFromJSON.cls_val();
        product.variableValue = caseRec.CA_Product_Controller__r.Name; //'Test Product'; //TODO  caseRec.CA_Product_Controller__r.Name;
        
        List<EverBridgeRequestFromJSON.cls_formVariableItems> formVariableItemsList = new List<EverBridgeRequestFromJSON.cls_formVariableItems>();
        
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_asgnGrp1 = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_asgnGrp1.variableName = 'Assignment Group 1';
        formVariablesObj_asgnGrp1.isRequired = false;
        formVariablesObj_asgnGrp1.seq =1;
        formVariablesObj_asgnGrp1.variableId = '3083034899257342';
        formVariablesObj_asgnGrp1.prefixName = '1';
        formVariablesObj_asgnGrp1.val = new List<String>{caseRec.Product__c};//new List<EverBridgeRequestFromJSON.cls_val>{asgnGroup1};
        formVariableItemsList.add(formVariablesObj_asgnGrp1);
            
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_asgnGrp2 = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_asgnGrp2.variableName = 'Assignment Group 2';
        formVariablesObj_asgnGrp2.isRequired = false;
        formVariablesObj_asgnGrp2.seq = 2;
        formVariablesObj_asgnGrp2.variableId = '3083034899257343';
        formVariablesObj_asgnGrp2.prefixName = '1';
        formVariablesObj_asgnGrp2.val = new List<String>{'None'};//new List<EverBridgeRequestFromJSON.cls_val>{asgnGroup2};
        formVariableItemsList.add(formVariablesObj_asgnGrp2);
        
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_notifDetails = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_notifDetails.variableName = 'Notification Details';
        formVariablesObj_notifDetails.isRequired = false;
        formVariablesObj_notifDetails.seq = 3;
        formVariablesObj_notifDetails.variableId = '3083034899257344';
        formVariablesObj_notifDetails.prefixName = '1';
        formVariablesObj_notifDetails.val = new List<String>{'Case Subject: ' + caseRec.Subject};//new List<EverBridgeRequestFromJSON.cls_val>{notifDetails};
        formVariableItemsList.add(formVariablesObj_notifDetails);
        
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_caseSev = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_caseSev.variableName = 'Severity';
        formVariablesObj_caseSev.isRequired = false;
        formVariablesObj_caseSev.seq = 4;
        formVariablesObj_caseSev.variableId = '3083034899257345';
        formVariablesObj_caseSev.prefixName = '1';
        formVariablesObj_caseSev.val = new List<String>{caseRec.Severity__c};//new List<EverBridgeRequestFromJSON.cls_val>{severity};        
        formVariableItemsList.add(formVariablesObj_caseSev);
        
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_caseNum = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_caseNum.variableName = 'Case';
        formVariablesObj_caseNum.isRequired = false;
        formVariablesObj_caseNum.seq = 5;
        formVariablesObj_caseNum.variableId = '2203425597033939';
        formVariablesObj_caseNum.prefixName = '1';
        formVariablesObj_caseNum.val = new List<String>{caseRec.CaseNumber};//new List<EverBridgeRequestFromJSON.cls_val>{caseNum};  
		formVariableItemsList.add(formVariablesObj_caseNum);
        
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_customer = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_customer.variableName = 'Customer';
        formVariablesObj_customer.isRequired = false;
        formVariablesObj_customer.seq = 6;
        formVariablesObj_customer.variableId = '2203425597033941';
        formVariablesObj_customer.prefixName = '1';
        formVariablesObj_customer.val = new List<String>{caseRec.Site_Name__c};//new List<EverBridgeRequestFromJSON.cls_val>{customer};  
        formVariableItemsList.add(formVariablesObj_customer);
        
        EverBridgeRequestFromJSON.cls_formVariableItems formVariablesObj_product = new EverBridgeRequestFromJSON.cls_formVariableItems();
        formVariablesObj_product.variableName = 'Product';
        formVariablesObj_product.isRequired = false;
        formVariablesObj_product.seq = 7;
        formVariablesObj_product.variableId = '2203425597033940';
        formVariablesObj_product.prefixName = '1';
        formVariablesObj_product.val = new List<String>{caseRec.Product__c};//new List<EverBridgeRequestFromJSON.cls_val>{product};  
		formVariableItemsList.add(formVariablesObj_product);            
        
        
        EverBridgeRequestFromJSON.cls_formTemplate formTemplatesObj = new EverBridgeRequestFromJSON.cls_formTemplate();
        formTemplatesObj.subject = 'New: Severity One - CaseNumber:'+caseRec.CaseNumber;
        formTemplatesObj.formVariableItems = formVariableItemsList;
        
           
        //List<EverBridgeRequestFromJSON.cls_phaseTemplate> phaseTemplatesList = new List<EverBridgeRequestFromJSON.cls_phaseTemplate>();
        
        EverBridgeRequestFromJSON.cls_phaseTemplate phaseTemplateObj= new EverBridgeRequestFromJSON.cls_phaseTemplate();
        phaseTemplateObj.templateId = '1323816294814762';
        phaseTemplateObj.templateName = 'Severity One';
        phaseTemplateObj.name = 'New';
        phaseTemplateObj.messageFlag = 3;
        phaseTemplateObj.contactsFlag = 3;
        phaseTemplateObj.settingsFlag = 3;
        phaseTemplateObj.phaseDefinitions = phaseDefinitionsList;
        phaseTemplateObj.formTemplate = formTemplatesObj;
        //phaseTemplatesList.add(phaseTemplateObj);        
        
        List<EverBridgeRequestFromJSON.cls_incidentPhases> incidentPhasesList = new List<EverBridgeRequestFromJSON.cls_incidentPhases>();
        EverBridgeRequestFromJSON.cls_incidentPhases incidentPhasesObj = new EverBridgeRequestFromJSON.cls_incidentPhases();
        incidentPhasesObj.createdName = 'Manaswi Arja';
        incidentPhasesObj.id = 10011;
        incidentPhasesObj.phaseTemplate = phaseTemplateObj; //TODO
        incidentPhasesList.add(incidentPhasesObj);
        
        EverBridgeRequestFromJSON reqObj = new EverBridgeRequestFromJSON();
        reqObj.name = 'Case with Severity 1 . Case Number:' + caseRec.CaseNumber;
        reqObj.incidentAction = 'Launch';
        reqObj.incidentPhases = incidentPhasesList;
        
        
        String strReq = JSON.serialize(reqObj);      
        System.debug('strReq:'+strReq);
        return strReq;
        
    }
	
    public class EverbridgeResponse {

        public String message;
        public String id;
        public String baseUri;
        public String instanceUri;
            
        public EverbridgeResponse parse(String json) {
            return (EverbridgeResponse) System.JSON.deserialize(json, EverbridgeResponse.class);
        }
	}
    
}