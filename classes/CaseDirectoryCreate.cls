public class CaseDirectoryCreate
{
    CaseDirectoryCreate()
    {
    }
    
    @future(callout=true)
    public static void callEAIforDirectoryCreate(List<String> xmlStrings)
    {
        System.debug('---In CaseDirectoryCreate---');    
        boolean isProd = false;
        boolean isDev = false;
        boolean isQA = false;
        
        if(UserInfo.getOrganizationId().contains('00D300000006yn4'))
        {
            isProd = true;
        }
        else {
            String userName = UserInfo.getUserName();
            if(userName.contains('ca.com.fsb'))
            {
                isQA = true;
            }
            else
            {
                isDev = true;
            }
        }
        
        String endPoint = '';
        
        if(isProd)
        {
            endPoint = Label.EAI_Prod_Case_Directory_Service;
        }
        else if(isQA)
        {
            endPoint = Label.EAI_FSB_Case_Directory_Service;  
        }
        else if(isDev)
        {
            endPoint = Label.EAI_Dev_Case_Directory_Service; 
        }
        
        System.debug('Case Directory Create EndPoint - ' + endpoint);
        System.debug('Case Directory Create xmlStrings - ' + xmlStrings);
        
        for(String xmlString : xmlStrings)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setBody(xmlString);
            
            req.setHeader('Content-Type', 'text/xml');     
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Result from Case Create - ' + res.getBody());  
        }                    
    }
}