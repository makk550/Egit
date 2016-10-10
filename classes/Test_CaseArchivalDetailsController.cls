/*
Created By: Tarun Sharma
Created On: 04/25/2016
Purpose: Test Class to cover case UI
Modified By:
*/
@isTest
public class Test_CaseArchivalDetailsController{
    private static testMethod void testCaseArchivalDetailsController(){
        createTestData();
        test.startTest();
        caseArchivalDetails_MockResult();
        caseArchivalDetails_MockChild();
        test.stopTest();
    }
    
    private static void createTestData(){
        AWS_Credentials__c awsCredentials = new AWS_Credentials__c();
        awsCredentials.Name = 'Case Archival';
        awsCredentials.Secret__c = 'nZOOCL0j+NDww7rfrjA0WDzkx+g9a5OTA+YHaZ/w';
        awsCredentials.Key__c = 'AKIAIXRMUKP2XKCSHNBA';
        insert awsCredentials;
    }
    
    private static void caseArchivalDetails_MockResult(){
        Test.setMock(HttpCalloutMock.class, new  AWSBucketAccess_MockResponse());
        apexpages.currentpage().getparameters().put('AWSLink', 'https://s3-us-west-2.amazonaws.com/case-archive-demo/NIMSOFT/00110361/sampleCaseDetails.xml');
        apexpages.currentpage().getparameters().put('source','nimsoft');
        CaseArchivalDetailsController controller = new CaseArchivalDetailsController();
    }
    
    private static void caseArchivalDetails_MockChild(){
        Test.setMock(HttpCalloutMock.class, new CaseArchivalDetails_MockResponse());
        CaseArchivalDetailsController.getRelatedChildDetails('Case Comment', 'https://s3-us-west-2.amazonaws.com/case-archive-demo/NIMSOFT/00110361/RelatedXMLs/sampleCaseCommentXML.xml','https://s3-us-west-2.amazonaws.com/case-archive-demo/NIMSOFT/00110361/sampleCaseDetails.xml');
    }
}