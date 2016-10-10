/*
Created By: Tarun Sharma
Created On: 04/22/2016
Purpose: Test Class for AWS Bucket Access
Modified By:
*/
@isTest
public class Test_AWSBucketAccess{
    private static testMethod void testAWSBucketAccess(){
        createTestData();
        test.startTest();
        awsBucketAccessMockResult();
        test.stopTest();
    }
    
    private static void createTestData(){
        AWS_Credentials__c awsCredentials = new AWS_Credentials__c();
        awsCredentials.Name = 'Case Archival';
        awsCredentials.Secret__c = 'nZOOCL0j+NDww7rfrjA0WDzkx+g9a5OTA+YHaZ/w';
        awsCredentials.Key__c = 'AKIAIXRMUKP2XKCSHNBA';
        insert awsCredentials;
    }
    
    private static void awsBucketAccessMockResult(){
        Test.setMock(HttpCalloutMock.class, new  AWSBucketAccess_MockResponse());
        AWSBucketAccess AWSBucketAccessObj = new AWSBucketAccess();
        AWSBucketAccessObj.AWSBucketAccessMethod('https://s3-us-west-2.amazonaws.com/case-archive-demo/NIMSOFT/00110361/sampleCaseDetails.xml','','');
        AWSBucketAccessObj.AWSBucketAccessMethod('https://s3-us-west-2.amazonaws.com/case-archive-demo/NIMSOFT/00110361/RelatedXMLs/sampleCaseDetails.xml','NIMSOFT','00110361');
    }
}