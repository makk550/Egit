@isTest(seealldata=false)
public class TestDefectExtensionController {
  
    public static testMethod void testCreateDefect(){
    	Test_SetupData.createTestSuccessData();
    	Test.setMock(HttpCalloutMock.class, new  DefectCreateMockCallout());
        Test.startTest();
        Case testCase = [select id from Case where Status='Open' limit 1];
        Defect__c defect = new Defect__c();
        Defect_Comment__c comment = new Defect_Comment__c();
        comment.Comments__c = 'test';
        defect.Subject__c = 'test';
        defect.Description__c = 'test';
        Test.setCurrentPage(Page.Defect);
        ApexPages.currentPage().getParameters().put('caseId',testCase.id);
        DefectExtensionController defectController = new DefectExtensionController(new ApexPages.StandardController(defect));
        defectController.comment = comment;
        defectController.save();
        defectController.continueSave();
        
        Test.stopTest();
    }
     public static testMethod void testCancelPage(){
    	Test_SetupData.createTestSuccessData();
        Test.startTest();
        Case testCase = [select id from Case where Status='Open' limit 1];
        Defect__c defect = new Defect__c();
        Defect_Comment__c comment = new Defect_Comment__c();
        comment.Comments__c = 'test';
        defect.Subject__c = 'test';
        defect.Description__c = 'test';
        Test.setCurrentPage(Page.Defect);
        ApexPages.currentPage().getParameters().put('caseId',testCase.id);
        DefectExtensionController defectController = new DefectExtensionController(new ApexPages.StandardController(defect));
        defectController.cancel();
        
        Test.stopTest();
    }
     public static testMethod void testDeleteDefectCaseAssociation(){
    	Test_SetupData.createTestSuccessData();
        Test.startTest();
        Case testCase = [select id from Case where Status='Open' limit 1];
        Defect__c defect = new Defect__c();
        defect.Subject__c = 'test';
        defect.Description__c = 'test';
        insert defect ;
        Defect_Case_Association__c defectCaseAssociation = new Defect_Case_Association__c();
        defectCaseAssociation.Defect__c = defect.Id ; 
        defectCaseAssociation.case__c = testCase.id;
        insert defectCaseAssociation;
        delete defectCaseAssociation;
        Test.stopTest();
    }
}