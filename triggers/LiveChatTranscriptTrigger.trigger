Trigger LiveChatTranscriptTrigger on LiveChatTranscript (After Insert, Before Delete) {
      
    /*if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            System.debug('Before insert calling****');
            LiveAgentFeedbackHandler.linkToCases(Trigger.New);
        }        
    }*/
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            LiveAgentFeedbackHandler.linkToAnswers(Trigger.New);
        }        
    }
    
 /*   if (Trigger.isDelete) {
        Profile p = [select name from Profile where id =:UserInfo.getProfileId()];
        String pname=p.name;
        for(LiveChatTranscript chatTranscript:Trigger.old){ 
          if(!pname.contains('Admin')) {             
                chatTranscript.addError('You cannot delete Live Chat Transcript.');
                }
              }
       
       } */

}