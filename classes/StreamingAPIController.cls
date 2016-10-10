public class StreamingAPIController  
{  
    //Everytime page is reRendered it will get refreshed values of account  
    public List<Case> getRefreshedCases  
    {  
        get  
        {  
            return [SELECT Id, Subject FROM Case WHERE Status = 'Verify' AND Id = '50018000003LqjTAAS'] ;  
        }  
        set;  
    }  
      
    public StreamingAPIController()  
    {  
    }  
}