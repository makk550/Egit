public class redirectCaseController{

    public case caseRec;
    public Integer view{get;set;}
    public boolean showDetail{get;set;}
    public boolean showFeed{get;set;}
    public redirectCaseController(ApexPages.StandardController controller) {
        List<String> fields = new List<String>{'TPC_Team__c','OwnerId'};
        if(!Test.isRunningTest()){
            controller.addFields(fields);
        }
        
        caseRec = (Case)controller.getRecord();
    }

    public pageReference redirectCase(){
        String param = ApexPages.currentPage().getParameters().get('nooverride');
        showFeed=false;
        User communityUser = [select id,contact.TPC_Team__c,Profile.UserLicense.Name  from user where id=: UserInfo.getUserId()];
        if (Label.TPC_Profile_Id != NULL && communityUser.Profile.UserLicense.Name  == String.valueOf(Label.TPC_Profile_License_Name)) {
        //if (Label.TPC_Profile_Id != NULL && UserInfo.getProfileId() == String.valueOf(Label.TPC_Profile_Id)) {
            
            if(caseRec.TPC_Team__c == communityUser.contact.TPC_Team__c || caseRec.OwnerId == communityUser.Id ){
                showDetail = true;
                view=1;
                return NULL;
                
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Sorry You dont have permission to see this.');
                ApexPages.addMessage(myMsg);
                showDetail = false;
                view=0;
                return null;
                
            }
        }
        else{   
            pageReference ref = new PageReference('/'+caseRec.Id+'?nooverride=1');
            ref.setRedirect(false);
            return ref;             
        /*
                showDetail = false;
                showFeed=true;
                view=2;//Support feed.
                return NULL;
*/
        }
    }
}