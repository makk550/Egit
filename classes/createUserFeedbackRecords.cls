/*
Created By: Tarun Sharma
Created On: 06/13/2016
Purpose: Create new records in salesforce on the basis of user feedback
Modified By:
*/
@RestResource(urlMapping='/createUserFeedback/*')

    global class createUserFeedbackRecords{
       global class data{
           global String sourceId;
           global String rating;
           global String comments;
           global String emotionCapture;
       }
       
       @HttpPost
       global static void callCreateUserFeedback(data data){
           system.debug('#####userFeedbackObj##########'+data);
           String jsonRequest = JSON.serialize(data);
           RestResponse res = RestContext.response;
           res.addHeader('Content-Type', 'application/json');
           User_Feedback__c userFeedbackObj = new User_Feedback__c();
           userFeedbackObj.Comments__c = data.comments;
           userFeedbackObj.Emotion_Capture__c = data.emotionCapture;
           userFeedbackObj.Rating__c = Decimal.valueOf(data.rating);
           userFeedbackObj.Source__c = data.sourceId;
           insert userFeedbackObj;
       }
    }