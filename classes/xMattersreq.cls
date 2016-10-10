global class xMattersreq {
@future(callout=true)
 Webservice static void xRESTCall(String endpoint,String payload) {
        HttpRequest req = new  HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(payload);
        req.setHeader('Content-Type', 'application/json');
        Http http =new Http();
        HttpResponse res = http.send(req);
       system.debug('Response :' +res.getBody());
    }
}