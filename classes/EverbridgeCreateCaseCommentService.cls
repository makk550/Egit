@RestResource(urlMapping='/CreateCaseComment/*')
global class EverbridgeCreateCaseCommentService {
    
    @HttpPost
    global static void createCaseComment(String resFromEverbridge){//(String caseNo,String caseCommentBody) {
		
		String incidentID;
        String responseBody;
        System.debug('resFromEverbridge:'+resFromEverbridge);
        JSONParser parser = JSON.createParser(resFromEverbridge);
        while (parser.nextToken() != null) { 
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
        		parser.nextToken();
                if (fieldName == 'id') {
                    incidentID = parser.getText();
                }
                if(fieldName == 'responses'){
                    responseBody = parser.getText();
                }
            }
        }
        System.debug('incidentID:'+incidentID);
        System.debug('responseBody:'+responseBody);
        
        
        RestResponse res = RestContext.response;
        ResponseWrapper resMsg  = new ResponseWrapper();
        try{
            Case caseRec = [select id from Case where Everbridge_NotificationID__c = :incidentID];
            
            CaseComment ccRec= new CaseComment();
            ccRec.parentId = caseRec.Id;
            ccRec.CommentBody = responseBody;
            insert ccRec; 
            
            res.statusCode = 200;
            resMsg.status = 'Success';
            resMsg.message = 'Case Comment Created';
            
        }catch(Exception e){
            res.statusCode = 500;
            resMsg.status = 'Failure';
            resMsg.message = e.getMessage();
            system.debug('Error message'+e.getMessage()+' \n Stack Trace:'+e.getStackTraceString());         
        }

    }    
    
    public class ResponseWrapper{
            public string status;
            public string message; 
    }
}