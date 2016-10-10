@isTest
private class LiveAgentFeedbackHandlerTest {
    public static testMethod void testlinkToAnswers(){
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        
        insert lcv;
        
        List<LiveChatTranscript> chatList = new List<LiveChatTranscript>();
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.ChatKey = 'chatkey';  
        lct.LiveChatVisitorId = lcv.Id;
        chatList.add(lct);
        
        insert chatList;
        
        LiveAgent_Post_Survey_Answers__c lpsa= new LiveAgent_Post_Survey_Answers__c();
        lpsa.Live_Chat_Transcript__c = lct.Id;
        lpsa.Chat_Key__c = 'chatkey';
        insert lpsa;
        Test.startTest();
        	LiveAgentFeedbackHandler.linkToAnswers(chatList);
        Test.stopTest();
        
    }
     public static testMethod void testlinkToCases(){
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        
        insert lcv;
        
        List<LiveChatTranscript> chatList = new List<LiveChatTranscript>();
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.ChatKey = 'chatkey';  
        lct.LiveChatVisitorId = lcv.Id;
        chatList.add(lct);
        
        insert chatList;
        
        LiveAgent_Post_Survey_Answers__c lpsa= new LiveAgent_Post_Survey_Answers__c();
        lpsa.Live_Chat_Transcript__c = lct.Id;
        lpsa.Chat_Key__c = 'chatkey';
        insert lpsa;
        Test.startTest();
        	LiveAgentFeedbackHandler.linkToCases(chatList);
        Test.stopTest();
        
    }
    
}