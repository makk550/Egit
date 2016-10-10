@isTest
public class TestingRequired {
    
    public static void ex(){
    
        TestObj__c obj = new TestObj__c();
        obj.ReqObj2__c= 'one';
        insert obj;
    }

}