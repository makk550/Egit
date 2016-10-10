/*
Created By: Tarun Sharma
Created On: 10/13/2015
Purpose: Test Class for user story ---> B-04030: Associate an existing Defect to Case
Modified By:
*/
@isTest
public class Test_DefectAssociateController{
    
    private static testMethod void testDefectAssociateController(){
		Test_SetupData.createTestSuccessData();
        test.startTest();
        checkDefectCalloutMethod();
        checkDefectNullMethod();
        test.stopTest();
    }
    
    private static testMethod void testDefectAssociateControllerError(){
		Test_SetupData.createTestSuccessData();
        test.startTest();
        checkDefectErrorMethod();
        test.stopTest();
    }
        
    private static testMethod void testDefectAssociateController_Fail(){
   	    Test_SetupData.createTestProductData();
        test.startTest();
        checkDefectCalloutMethod();
        test.stopTest();
    }
        
    private static testMethod void testDefectAssociateControllerElseCond(){
   	    Test_SetupData.createTestData();
        test.startTest();
        checkDefectCalloutMethod();
        test.stopTest();
    }
    
    private static testMethod void testNoDefectMatchMethod(){
    	Test_SetupData.createTestNoDefectData();
		test.startTest();
        checkDefectCalloutMethod();
        test.stopTest();        
    } 
    
    private static testMethod void testNoDefectAssociateData(){
		Test_SetupData.createTestNoDefectAssociateData();     
        test.startTest();
        checkNoDefectAssociateMethod();
        test.stopTest();
    }
    
    private static testMethod void testNullResponse(){
		Test_SetupData.createTestProductData();//createTestNoDefectAssociateData();     
        test.startTest();
        checkNullResponseMethod();
        test.stopTest();
    }
        
    private static testMethod void testUpdateResponseFailure(){
		Test_SetupData.createTestNoDefectAssociateData();     
        test.startTest();
        checkUpdateResponseFailureMethod();
        test.stopTest();
    }
    
    private static testMethod void testNoUpdateResponse(){
		Test_SetupData.createTestNoDefectAssociateData();     
        test.startTest();
        checkNoUpdateResponseMethod();
        test.stopTest();
    }
    
    private static void checkNoUpdateResponseMethod(){
        Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMockUdpateResponse());
    	DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
        defectAssociateControllerObj.defectName = 'DE1111';
        defectAssociateControllerObj.submitDefectAssociate();
    }
        
    private static void checkUpdateResponseFailureMethod(){
        Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMockUpdateFailure());
    	DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
        defectAssociateControllerObj.defectName = 'DE1111';
        defectAssociateControllerObj.submitDefectAssociate();
    }
        
    private static void checkNullResponseMethod(){
        Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMockNullResponse());
    	DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
        defectAssociateControllerObj.defectName = 'DE1111';
        defectAssociateControllerObj.submitDefectAssociate();
    }
        
    private static void checkDefectCalloutMethod(){
        Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMock());
    	DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
        defectAssociateControllerObj.defectName = 'DE1111';
        defectAssociateControllerObj.submitDefectAssociate();
    }
        
    private static void checkNoDefectAssociateMethod(){
        Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMock());
    	DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
        defectAssociateControllerObj.defectName = 'DE1111';
        defectAssociateControllerObj.submitDefectAssociate();
    }
        
    private static void checkDefectNullMethod(){
       Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMock());
   	   DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
       defectAssociateControllerObj.defectName = null;
       defectAssociateControllerObj.submitDefectAssociate();
       defectAssociateControllerObj.cancelAssociation();
       defectAssociateControllerObj.continueSubmitAssocaite();
    } 
   
   private static void checkDefectErrorMethod(){
        Test.setMock(HttpCalloutMock.class, new  DefectAssociation_UIMockFaliure());
    	DefectAssociateController defectAssociateControllerObj = new DefectAssociateController();  
        defectAssociateControllerObj.defectName = 'DE1111';
        defectAssociateControllerObj.submitDefectAssociate();
    } 
}