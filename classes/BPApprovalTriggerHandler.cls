public with sharing class BPApprovalTriggerHandler {
	
	@Future(callout=true)
	public static void addPDFAttach(String sessionId, String bpId){  //bpId
	
	   HttpRequest req = new HttpRequest();	   
       req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/apexrest/addBPVersion/');
       req.setMethod('POST');      	
       req.setBody('{"bpId":'+JSON.serialize(bpId)+'}');
       req.setHeader('Authorization', 'Bearer '+ sessionId);
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(20000);
       
       System.debug('In addPDFAttach bpId:'+bpId);
       System.debug('Req Body:'+ req.getBody());
       
       Http http = new Http();
	   if(!test.isRunningTest()){
	   	HTTPResponse res;
	   	try{
	   	   res = http.send(req);
           System.debug('res statusCode:'+ res.getStatusCode() + ';' + 'Status :'+ res.getStatus());
	   	}
	   	catch(System.CalloutException e){
	   		System.debug('Callout error: '+ e);
            System.debug(res.toString());
	   	}
          
       }	
		
	}
	

}