global class CBRCaseCreateNotificationExtension {
    
    public List<User> userTeamMembers {get;set;}
    public CBRCaseCreateNotificationExtension(ApexPages.StandardController sc){
        
    }
	
    public static String caseNo {get;set;}
    public static string caseId {get;set;}
    public static string Product {get;set;}
    public static string severity {get;set;}
    
    
    @InvocableMethod
    public static void notify(List<Case> caseIds){
         for(Case caseRec:caseIds){
             returnToPage(caseRec);
         }
    }
    
    public static Pagereference returnToPage(Case caseRec){
        caseNo = caseRec.CaseNumber;
        caseId = caseRec.Id;
        Product = caseRec.Product__c;
        severity = caseRec.Severity__c;
		return new PageReference('/apex/CBRCaseCreateNotification2');
    }
    
    
    @RemoteAction
    global static List<String> fetchUsers(){
        List<String> userTeamMembers = new List<String>();
        User currentUser = [select id,managerId from user where id = :userinfo.getUserId()];
        List<String> parallels=new List<String>();
        List<User> users = [select id,name,ManagerId,manager.Name,(Select Id, Name From ManagedUsers where isActive=true) from User where id =: currentUser.ManagerId and isActive=true limit 1];
        System.debug('users:'+users);
        System.debug('currentUser.id:'+currentUser.Id);
        for(User u:users){
            for(User mu:u.ManagedUsers ){
                //System.debug('name:'+mu.name);
                //System.debug('id:'+mu.id);
                //if(mu.id != currentUser.Id )
                    parallels.add(mu.Id);
            }
        }
        System.debug('parallels size:'+parallels.size());
        
        userTeamMembers.addAll(parallels);
        return userTeamMembers;
    }
    
    
    //@RemoteAction
    
    
    
}

/*
 get{
            if(userTeamMembers == null){
                userTeamMembers = new List<User>();
            }
        } 
 
 */