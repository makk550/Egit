public class EverbridgeCallout {

    @future(callout=true)
    public static void notifyUsingEverbridge(String reqbody,String caseId){ //String endpoint,String payload
        string service_url = 'https://api.everbridge.net/rest/';
        string org_id = '892807736725550';
        
        service_url += 'incidents/892807736725550';
        
        //Case caseObj = new Case();
        //String reqbody = EverbridgeRequestUtility.prepareRequestBody(caseObj);
        //System.debug('reqbody:'+reqbody);
        
        HttpRequest req = new  HttpRequest();
        req.setEndpoint(service_url);
        req.setMethod('POST');
        req.setBody(reqbody);
        req.setHeader('Content-Type', 'application/json');
        String encodedb64usernamepassword = 'Y2FpdGFwaWFkbWluOkV2ZXJicmlkZ2Ux';
        String authorizationHeader = 'Basic ' + encodedb64usernamepassword;
        req.setHeader('Authorization', authorizationHeader);
        
        Http http =new Http();
        HttpResponse res = http.send(req);
        system.debug('Response :' +res.getBody());   
        
        JSONParser parser = JSON.createParser(res.getBody()); 
        while (parser.nextToken() != null) { 
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
        		parser.nextToken();
                if (fieldName == 'id') {
                    Case c = new Case(id = caseId);
                    c.Everbridge_NotificationID__c = parser.getText();
                    System.debug('caseid:'+caseId + '--Everbridge_NotificationID__c:'+parser.getText());
                    update c;
                }
            }
        }
        
    }    
    
}