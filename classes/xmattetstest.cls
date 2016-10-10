public class xmattetstest {
	
	@Future(callout=true)
	public static void addPDFAttach(String sessionId, String ID){  //bpId
	
	   HttpRequest req = new HttpRequest();	   
      
     req.setEndpoint('https://catech-np.hosted.xmatters.com/api/integration/1/functions/c4cfa943-fb33-4a1d-9884-80a000501930/triggers');
       req.setMethod('POST');      
       	
       req.setBody('{"Case ID":'+JSON.serialize(ID)+'}');
       
 
       req.setHeader('Authorization', 'Bearer '+ sessionId);
       req.setHeader('Content-Type', 'application/json');
       req.setTimeout(20000);
       
       System.debug('In addPDFAttach ID:'+ID);
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