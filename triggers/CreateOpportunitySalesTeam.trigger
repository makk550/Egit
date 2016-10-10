trigger CreateOpportunitySalesTeam on Opportunity (after insert, after update) 
{
//Create Opportunity Sales Team members using Account Team Members
//Considering the data volume, number of script statements and Governors Limit use @future method for bulk insert and update.

 List<Id> AccountIdList = new List<Id>();
 Set<Id> opportunityIdSet = new Set<Id>();
 Map<Id, OpportunityTeamMember> existingOpportunityTeamMemberMap = new Map<Id, OpportunityTeamMember>();
 List<OpportunityTeamMember> newOpportunityTeamMemberList = new List<OpportunityTeamMember>();
  
  //Collect Opportunity RecordType's
  /*String newOpportunityRecordTypeName = 'New Opportunity';
  Schema.DescribeSObjectResult opportunityRTDescribe = Schema.SObjectType.Opportunity;    
  Map<String,Schema.RecordTypeInfo> opportunityRecTypeMap = opportunityRTDescribe.getRecordTypeInfosByName(); 
  Id newOpportunityRecordTypeId = opportunityRecTypeMap.get(newOpportunityRecordTypeName).getRecordTypeId();
  */
  //Updated by Nomita on 03/04/2010 due to error of too many record type describes.
  RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('New Opportunity');
  Id newOpportunityRecordTypeId = rec.RecordType_Id__c;
  
  RecordTypes_Setting__c rec2 = RecordTypes_Setting__c.getValues('Acquisition');
  Id newAcquistionRecordTypeId = rec2.RecordType_Id__c;
     //Collect all the Accounts that are associated to the opportunity
     for(Integer s=0; s<Trigger.size; s++)
     {
        //Only consider the opportunities with the record type "New Opportunity".
        if((Trigger.new[s].RecordTypeId == newOpportunityRecordTypeId)|| (Trigger.new[s].RecordTypeId == newAcquistionRecordTypeId ))
        {
            if(Trigger.isInsert)
            {
                opportunityIdSet.add(Trigger.new[s].Id);
                if(Trigger.new[s].Distributor_6__c != null)
                AccountIdList.add(Trigger.new[s].Distributor_6__c);
                if(Trigger.new[s].Reseller__c != null)AccountIdList.add(Trigger.new[s].Reseller__c);
                if(Trigger.new[s].Partner__c != null)AccountIdList.add(Trigger.new[s].Partner__c);
                if(Trigger.new[s].Partner_1__c != null)AccountIdList.add(Trigger.new[s].Partner_1__c);
            }
            else if(Trigger.isUpdate)
            {
                if(Trigger.new[s].Distributor_6__c != null && Trigger.old[s].Distributor_6__c != Trigger.new[s].Distributor_6__c)
                {
                AccountIdList.add(Trigger.new[s].Distributor_6__c);
                opportunityIdSet.add(Trigger.new[s].Id);
                }
                if(Trigger.new[s].Reseller__c != null && Trigger.old[s].Reseller__c != Trigger.new[s].Reseller__c)
                {
                AccountIdList.add(Trigger.new[s].Reseller__c);
                opportunityIdSet.add(Trigger.new[s].Id);
                }
                if(Trigger.new[s].Partner__c != null && Trigger.old[s].Partner__c != Trigger.new[s].Partner__c)
                {
                AccountIdList.add(Trigger.new[s].Partner__c);
                opportunityIdSet.add(Trigger.new[s].Id);
                }
                if(Trigger.new[s].Partner_1__c != null && Trigger.old[s].Partner_1__c != Trigger.new[s].Partner_1__c)
                {
                AccountIdList.add(Trigger.new[s].Partner_1__c);
                opportunityIdSet.add(Trigger.new[s].Id);
                }
            }
        }
     }
     
     try
     {
         if(AccountIdList.size() != 0)
         {
            // If the incoming records size is 1 execute the below code. for bulk insert/update use @future method.
            if(Trigger.size == 1)
            {   
                //collect all existing opportunity sales team members
                for(OpportunityTeamMember opportunityTeamMember : [SELECT OpportunityAccessLevel, OpportunityId, TeamMemberRole, UserId FROM OpportunityTeamMember WHERE OpportunityId =: Trigger.new[0].Id])
                {
                    existingOpportunityTeamMemberMap.put(opportunityTeamMember.UserId, opportunityTeamMember);
                }
                //collect all Account team members, If the Account team members don't exist in the opportunity sales team then add them into the opportunity sales team.
                //The total numbar of "accountTeamMember" returned by the query wouldnot be more than 1000 at any point of time.
                for(AccountTeamMember accountTeamMember : [SELECT AccountAccessLevel, AccountId, TeamMemberRole, UserId,User.IsActive from AccountTeamMember WHERE AccountId IN : AccountIdList])
                {
                    if(existingOpportunityTeamMemberMap.get(accountTeamMember.UserId) == null)
                    {
                        if(accountTeamMember.User.IsActive && accountTeamMember.TeamMemberRole!='TAQ-PARTN DM'){
                      newOpportunityTeamMemberList.add(new OpportunityTeamMember(
                                                     OpportunityId = Trigger.new[0].Id,
                                                     TeamMemberRole = accountTeamMember.TeamMemberRole,
                                                     UserId = accountTeamMember.UserId
                                                     ));
                        }
                    }
                }
                //Create new Opportunity Team Members
                if(newOpportunityTeamMemberList.size() > 0)
                {
                    //We wouldnot have more tha 15 Account Team members per Account (15 * 3 = 45 Max)
                    /*System.debug('newOpportunityTeamMemberList.size() => '+ newOpportunityTeamMemberList.size());
                    System.debug('System.getLimitDMLRows() => '+ Limits.getLimitDMLRows());
                        
                    if(newOpportunityTeamMemberList.size() > Limits.getLimitDMLRows())
                    {
                        CreateOpportunitySalesTeam_Util.createOpportunitySalesTeam(AccountIdList, opportunityIdSet);
                    }
                    else */
                    insert newOpportunityTeamMemberList;
                }
                System.debug(' No of Opportunity Sales Team Members Created => ' + newOpportunityTeamMemberList.size());
            }
            else
            {
                CreateOpportunitySalesTeam_Util.createOpportunitySalesTeam(AccountIdList, opportunityIdSet);
            }
         }
     }
     catch(Exception e)
     {
        System.Debug(e);
     }

}