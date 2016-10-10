public class LiveAgentFeedbackHandler {
    
        public static void linkToAnswers(List<LiveChatTranscript> liveChatTranscripts){
        System.debug('****liveChatTranscripts***'+liveChatTranscripts);
        Set<String> chatKeys = new Set<String>();
        Map<String,ID> transcriptMap = new Map<String,ID>();
        Map<String,ID> caseMap = new Map<String,ID>();
        for(LiveChatTranscript liveChatTranscript : liveChatTranscripts){
            chatKeys.add(liveChatTranscript.ChatKey);
            transcriptMap.put(liveChatTranscript.ChatKey , liveChatTranscript.Id); 
        }
        List<LiveAgent_Post_Survey_Answers__c> answers = new List<LiveAgent_Post_Survey_Answers__c> ();
  
        for(LiveAgent_Post_Survey_Answers__c answer : [SELECT Id, Name, Chat_Key__c,  Live_Chat_Transcript__c FROM LiveAgent_Post_Survey_Answers__c where Chat_Key__c in : chatKeys ]){  
            if(transcriptMap.get(answer.Chat_Key__c)!=null){
                answer.Live_Chat_Transcript__c = transcriptMap.get(answer.Chat_Key__c);
                answers.add(answer);
            }
        }
        System.debug('****answers***'+answers);
        if(answers.size()>0){
            update answers;
        }
        
    }
    
    public static void linkToCases(List<LiveChatTranscript> liveChatTranscripts){
        System.debug('****l before insert iveChatTranscripts***'+liveChatTranscripts);
        Set<String> chatKeys = new Set<String>();
        Map<String,ID> transcriptMap = new Map<String,ID>();
        Map<String,ID> caseMap = new Map<String,ID>();
        for(LiveChatTranscript liveChatTranscript : liveChatTranscripts){
            chatKeys.add(liveChatTranscript.ChatKey);
            transcriptMap.put(liveChatTranscript.ChatKey , liveChatTranscript.Id); 
        }
        List<LiveAgent_Post_Survey_Answers__c> answers = new List<LiveAgent_Post_Survey_Answers__c> ();
           
    }
    


}