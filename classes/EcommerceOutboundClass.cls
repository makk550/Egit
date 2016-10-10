global class EcommerceOutboundClass {

  @future (callout=true)
  public static void SendPocUpdate(String pocid) {
    System.debug('SendPocUpdate called');
    
    Trial_Request__c poc = [Select Id, Name, Request_Status__c,tempsiteid__c, End_Date__c,Site_Association__c from Trial_Request__c where Id=:pocid];
    Site_Association__c site = [select SAP_Site_ID__c,Name,Street__c,City__c,Region__c,Country_Picklist__c from Site_Association__c where Id= :poc.Site_Association__c];
    
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();

String username =  System.Label.POCEAI_UserName;
String password =  System.Label.POCEAI_Password;

req.setHeader('Content-Type','text/xml;charset=UTF-8');

//Blob headerValue = Blob.valueOf(username + ':' + password);
//String authorizationHeader = 'BASIC ' +
//EncodingUtil.base64Encode(headerValue);
//req.setHeader('Authorization', authorizationHeader);

req.setHeader('Authorization', System.Label.POCEAI_Authorization);

    //req.setEndpoint('https://eaisvcqafs.ca.com/orders/r.v1');
    //req.setEndpoint('https://eaisvcqafs.ca.com/orders/r.v1');
    req.setEndpoint(System.Label.POCEAI_EndPoint);
    
    req.setMethod('POST');
    
    String payload = '';
    String strPocId = poc.Name;
    String[] arrPocId = strPocId.split('POC - ');

    String strEndDate = string.Valueof(poc.End_Date__c);
    String[] arrEndDate =  strEndDate.split(' ');
 
    String strCancelDate = string.Valueof(system.today());
    String[] arrCancelDate =  strCancelDate.split(' ');    
    
payload += '<?xml version="1.0" encoding="UTF-8" standalone="yes"?> <order>';
payload += '<id>'+poc.tempsiteid__c+'</id>';
payload += '<caOrderId>' + arrPocId[1] + '</caOrderId>';
if(poc.Request_Status__c  == 'Cancelled')
{
   payload += '<action>CANCEL</action>'; 
   payload += '<cancelDate>' + arrCancelDate[0] + '</cancelDate>';  
}   
else
{
   payload += '<action>EXTEND</action>'; 
   payload += '<extendDate>' + arrEndDate[0] + '</extendDate>';  
}

payload += '</order>';


System.debug('EcommerceOutboundClass payload=' + payload);
    
    
    req.setBody(payload);

        
    try {
        System.debug('EcommerceOutboundClass before calling outbound');

        res = http.send(req);
                
        System.debug('SendPocUpdate res=' + res.getStatusCode());
        
    } catch(System.CalloutException e) {
        System.debug('SendPocUpdate Callout error: '+ e);
        System.debug('SendPocUpdate error=' + res.toString());
    }
    
    System.debug('EcommerceOutboundClass success');
    
        
  }
}