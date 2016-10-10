trigger UpdateDDR_status on Deal_Desk_Review__c (before update) {

   // CR 193258308
    
    Set<Id> usersSet = new Set<Id>();
    Set<Id> usersSet1 = new Set<Id>();
    set<Id> ownerIdSet = new set<Id>();
    set<Id> oldOwnerIdSet = new set<Id>();
    for ( Deal_Desk_Review__c tmp : Trigger.New){
        if(Trigger.OldMap.get(tmp.Id).OwnerId <> Trigger.NewMap.get(tmp.Id).OwnerId) {
            ownerIdSet.add (tmp.OwnerId);
            oldOwnerIdSet.add(Trigger.oldMap.get(tmp.Id).OwnerId);
        }
    }
    List<User> usersList = [Select Id from User where Id IN :ownerIdSet];
    for(User tmpUser : usersList) {
        usersSet.add(tmpUser.Id);
    }
    List<User> usersList1 = [Select Id from User where Id IN :oldOwnerIdSet];
    for(User tmpUser : usersList1) {
        usersSet1.add(tmpUser.Id);
    }
    for ( Deal_Desk_Review__c tmp : Trigger.New){
        if(Trigger.OldMap.get(tmp.Id).OwnerId <> Trigger.NewMap.get(tmp.Id).OwnerId) {
            if(usersSet.contains(tmp.OwnerId) && !usersSet1.contains(Trigger.OldMap.get(tmp.Id).OwnerId)) {
                tmp.Deal_Desk_Status__c = 'Assigned – DD';
            }
        }
    }
    
}