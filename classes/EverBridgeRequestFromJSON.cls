public class EverBridgeRequestFromJSON{
    public String name; //New: Severity One
    public String incidentAction;   //Launch
    public cls_incidentPhases[] incidentPhases;
    public class cls_incidentPhases {
        public String createdName;  //Andy Evangelos (CA IT Alerting)
        public Integer id;  //10011
        public cls_phaseTemplate phaseTemplate;
    }
    public class cls_phaseTemplate {
        public String templateId;  //1323816294814762
        public String templateName; //Severity One
        public String name; //New | Updated | Closed
        public Integer messageFlag; //3
        public Integer contactsFlag;    //3
        public Integer settingsFlag;    //3
        public cls_phaseDefinitions[] phaseDefinitions;
        public cls_formTemplate formTemplate;
    }
    public class cls_phaseDefinitions {
        public Integer id;  //1001
        public String status;   //A
        public boolean isDefault;
        public String name; //New
        public Integer seq; //0
    }
    public class cls_formTemplate {
        public String subject;  //New: Severity One
        public cls_formVariableItems[] formVariableItems;
    }
    public class cls_formVariableItems {
        //public cls_val[] val;
        public List<String> val; 
        public String variableName; //Assignment Group 1
        public boolean isRequired;
        public Integer seq; //1
        public String variableId;  //3083034899257342
        public String prefixName;   //1
    }
    
    //this can be commented after removing dependency in utility
    public class cls_val {
        public String variableValue;    
    } 
    
    public static EverBridgeRequestFromJSON parse(String json){
        return (EverBridgeRequestFromJSON) System.JSON.deserialize(json, EverBridgeRequestFromJSON.class);
    }

    
}