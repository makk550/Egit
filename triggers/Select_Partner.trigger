/************************************************************************************************************************
Name : Select_Partner

Type : Apex Trigger

Desc : Trigger to check if the new owner of lead belongs to same partner account. If yes, then popup a message "You can not assign a lead to a partner that has previously rejected this lead.
       Please select another partner user and try again.

Auth : Deloitte Consulting LLP

*************************************************************************************************************************

LastMod                Developed By                 Desc

5/1/2012               Diti Mansata           Trigger to check if the new owner of lead belongs to same partner account. If yes, then popup a message "You can not assign a lead to a partner that has previously rejected this lead.
                                              Please select another partner user and try again.
************************************************************************************************************************/


trigger Select_Partner on Lead (before update) {
set<id> setUserId = new set<id>();
map<Id, List<Lead>> mapOwnerLead = new map<Id, List<Lead>>();
for(Integer i=0;i<Trigger.New.size();i++)
{
    if(Trigger.new[i].OwnerId != Trigger.old[i].ownerId)
    {
        //if(Trigger.old[i].Reseller_Status__c =='Rejected')
        
            setUserId.add(Trigger.new[i].OwnerId);
        
            if(!mapOwnerLead.containsKey(Trigger.new[i].Ownerid))
                mapOwnerLead.put(Trigger.new[i].Ownerid,new List<Lead>());

            mapOwnerLead.get(Trigger.new[i].Ownerid).add(Trigger.new[i]);
        
    }
    
}

    if(setUserId.size()>0)
    {
        for(User u : [Select id,Related_Partner_Account__c,contactId,UserType from User where Id in :setUserId AND contactId !=: null AND Related_Partner_Account__c != null AND Related_Partner_Account__c != ''])
        {
            if(mapOwnerLead.containsKey(u.Id))
            {
                for(lead ld : mapOwnerLead.get(u.Id))
                    ld.addError('You can not assign a lead to a partner that has previously rejected this lead. Please select another partner user and try again.');
            
            }
        }
     }
    
    
}