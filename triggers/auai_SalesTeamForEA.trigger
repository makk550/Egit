trigger auai_SalesTeamForEA on Opportunity (after update, after insert) 
{
  Set<ID> accids = new set<Id>();
  List<Opportunity> lstOpp=Trigger.new;
  Set<ID> userIds=new Set<Id>();
  for(Opportunity opp:lstOpp)
      if(opp.Ent_Comm_Account__c != null)
          accids.add(opp.Ent_Comm_Account__c);
/*************************************************/ 
/***Code added by Balasaheb Wani on  13/10/2010***/
  List<OpportunityShare> lstOS=new List<OpportunityShare>();
  List <OpportunityTeamMember> lstOTM = new List <OpportunityTeamMember>();//move this list at top level Balasaheb Wani .....13/10/2010

  Map<Id,User> mOppUsers=new Map<Id,User>();
  
  if(Trigger.isInsert){
  for(Opportunity op :lstOpp)
  {
    if(op.Requestor_Information__c !=null)
    userIds.add(op.Requestor_Information__c);
  }
  if(userIds.size() > 0)
  {
    User[] lstUser=[Select Id,IsActive,Name from User where Id in :userIds ];
    if(lstUser.size() > 0 )
    {
        for(User u:lstUser)
        {
            for(Opportunity op :lstOpp)
            {
                if(op.Requestor_Information__c==u.Id && u.IsActive)
                mOppUsers.put(op.Id,u);
            }
        }
    } 
  }
  if(mOppUsers.size() > 0)
  {
    for(Opportunity op: lstOpp)
    {
        if(mOppUsers.containsKey(op.Id))
        {
          OpportunityTeamMember otm = new OpportunityTeamMember();
          //otm.TeamMemberRole = 'Partner User';//'IND-Reseller'; //changed by Heena
          //Changed by prmr2 IDC , CR:48456 , As per comments in QC
          otm.TeamMemberRole = 'IND-Reseller';
          otm.OpportunityId = op.Id;
          otm.UserId = mOppUsers.get(op.Id).Id;
          lstOTM.add(otm);
          /*****************/
            OpportunityShare os =new OpportunityShare ();
            os.OpportunityId=op.Id;
            os.UserOrGroupId=mOppUsers.get(op.Id).Id;
            os.OpportunityAccessLevel='edit';
            lstOS.add(os);
          /*****************/
        }
    }
  }
  }
  /*******************Code Ends Balasaheb Wani**********************/
  //Size check condition added by Nomita on 03/02/2010 , to avoid the SOQL query incase the Set has no values.
  if(accids.size()>0)
  {
      Map<ID, Account> m = new Map<ID, Account>([Select id,Owner.PMFKEY__C,Customer_Category__c,OwnerId,Owner.IsActive from Account Where Id in :accids]);
      for(Opportunity opp:lstOpp){
            if(opp.Ent_Comm_Account__c!=null){
                Id AccId = opp.Ent_Comm_Account__c;
                Account acc = m.get(accId); //lstacc[getaAccountIndex(accId,lstacc)];
                if(acc !=null){
                    {
                    System.debug('acc.Owner.IsActive'+acc.Owner.IsActive+acc.Owner.PMFKEY__C );
                        //Modified by Nomita on 03/25/2010 , since the trigger was hitting errors if the account owner was Inactive.
                        //assign only if Account Owner is Active..
                        if(acc.Owner.IsActive && acc.Owner.PMFKEY__C<>'APPARTN'&& acc.Owner.PMFKEY__C<>'NAPARTN' && 
                           acc.Owner.PMFKEY__C<>'EMPARTN' && acc.Owner.PMFKEY__C<>'JPPARTN' && acc.Owner.PMFKEY__C<>'LAPARTN')
                        {
                            OpportunityTeamMember otm = new OpportunityTeamMember();
                            otm.TeamMemberRole = 'IND-Reseller';
                            otm.OpportunityId = opp.Id;
                            otm.UserId = acc.OwnerId;
                            lstOTM.add(otm);
                        }
                    }
                }
            }
        }
//     upsert lstotm;  Team members will be inserted later on ... after adding partner to Team member
  }
  if(lstOTM.size()>0)
  {
    Database.UpsertResult[] sr=DataBase.upsert(lstOTM,false);
  }
  if(lstOS.size()>0)
  {
    Database.UpsertResult[] sr=DataBase.upsert(lstOS,false);
  }
}