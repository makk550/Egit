public with sharing class controlTranscript {
	public Case cObj;
    public LiveChatTranscript lObj;
    public controlTranscript(ApexPages.StandardController controller) {

    }
  public PageReference saveRecord() {
        update lObj;
        update cObj;
        return null;
    } 
}