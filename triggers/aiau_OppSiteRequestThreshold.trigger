trigger aiau_OppSiteRequestThreshold on Opportunity (after update, after insert, before update) 
{
     
  //Updated by Nomita on 04/01/2010 due to governor limit error on number of recordtype describes  
  
  /*Schema.DescribeSObjectResult accountRTDescribe = Schema.SObjectType.Account;    
  Map<String,Schema.RecordTypeInfo> accountRecTypeMap = accountRTDescribe.getRecordTypeInfosByName();
  Id accountRecordTypeId = accountRecTypeMap.get('Commercial Account').getRecordTypeId();
  */
   
  /*   
     List <Quote_Reporting__c> quoList  = [select name,New_TRR__c,Realization_Rate__c,Total_ATTRF__c,TRRPercent__c from Quote_Reporting__c quoteobj where Primary_Quote__c = True and Opportunity__c IN: Trigger.newMap.keySet()];
     List <Opportunity> quoteupdate = new List<Opportunity>();     

  if(Trigger.isBefore){
   for(Opportunity Oq:Trigger.new){
     Oq.New_Annual_Time__c = quoList[0].Total_ATTRF__c * quoList[0].Realization_Rate__c;
     Oq.RR_Percentage__c = quoList[0].Realization_Rate__c;
     Oq.New_TRR__c = quoList[0].New_TRR__c;
     Oq.TRR_Percentage__c = quoList[0].TRRPercent__c;
     quoteupdate.add(Oq);
   }
  }
  update  quoteupdate;
   */
  set<ID> accids = new set<Id>();
  integer intCnt;
  intCnt=0;
  if(Trigger.isUpdate)
  {
   
      for(Opportunity opp:Trigger.new)      
      {

        /* if(quoList.size() > 0)
          {                    
           //   opp.id= Trigger.old[0].id;
              opp.New_Annual_Time__c = quoList[0].Total_ATTRF__c * quoList[0].Realization_Rate__c;
              opp.RR_Percentage__c = quoList[0].Realization_Rate__c;
              opp.New_TRR__c = quoList[0].New_TRR__c;
              opp.TRR_Percentage__c = quoList[0].TRRPercent__c;
          } */
         
                 
        Opportunity old_opp = Trigger.oldMap.get(opp.Id);
        if(opp.StageName != old_opp.StageName)
        {
            //means the stage is changed.. 
            //check if stage is greater than 50% cos, its 50% for EMEA,NA and APJ and 90% for LA
            // if stage condition matches, only then proceed... 
            //this is done to avoid the governor limits we are hitting on SOQL queries
             /* opp.id= old_opp.id;
              opp.New_Annual_Time__c = quoList[0].Total_ATTRF__c * quoList[0].Realization_Rate__c;
              opp.RR_Percentage__c = quoList[0].Realization_Rate__c;
              opp.New_TRR__c = quoList[0].New_TRR__c;
              opp.TRR_Percentage__c = quoList[0].TRRPercent__c; */

            if(opp.StageName != '' && opp.StageName.indexOf('%') > 0 && integer.valueOf(opp.StageName.split('%')[0].trim()) >= 50)
            {
                if(opp.accountid != null)
                    accids.add(opp.accountid);
            }
        }
        //
        intCnt++;
      }
      
  }
  else if(Trigger.isInsert)
  {
      for(Opportunity opp:Trigger.new)
      {
          
          
          
        /*   if(quoList.size() > 0)
          {          
              opp.New_Annual_Time__c = quoList[0].Total_ATTRF__c * quoList[0].Realization_Rate__c;
              opp.RR_Percentage__c = quoList[0].Realization_Rate__c;
              opp.New_TRR__c = quoList[0].New_TRR__c;
              opp.TRR_Percentage__c = quoList[0].TRRPercent__c; 
          } 
            quoteupdate.add(opp); */
            //check if stage is greater than 50% cos, its 50% for EMEA,NA and APJ and 90% for LA
            // if stage condition matches, only then proceed... 
            //this is done to avoid the governor limits we are hitting on SOQL queries
            if(opp.StageName != '' && opp.StageName.indexOf('%') > 0 && integer.valueOf(opp.StageName.split('%')[0].trim()) >= 50)
            {
                if(opp.accountid != null)
                    accids.add(opp.accountid);
            }
            
        //
          
      }
  }
  
  
  if(accids.size()>0)
  {
    Map<ID, Account> m = new Map<ID, Account>([Select id, RecordTypeId,Send_Site_Request__c, name, GEO__c from Account Where Id in :accids]);
    Schema.DescribeSObjectResult accountRTDescribe = Schema.SObjectType.Account;    
  Map<String,Schema.RecordTypeInfo> accountRecTypeMap = accountRTDescribe.getRecordTypeInfosByName();
  Id accountRecordTypeId = accountRecTypeMap.get('SMB').getRecordTypeId();   //updated by danva from "Commertial account" to "SMB"
     for(Opportunity opp:Trigger.new){
           if(opp.AccountId != null)
           {
               try
               {
                           Account acc = m.get(opp.AccountId);
                           if(acc.recordtypeId == accountRecordTypeId )
                           {
                               if(acc.geo__c == 'EMEA' ||acc.geo__c == 'NA'||acc.geo__c == 'APJ' ||acc.geo__c == 'Asia-Pacific' || acc.geo__c == 'Japan')
                               {
                                   if(opp.StageName != '' && opp.StageName.indexOf('%') > 0 && integer.valueOf(opp.StageName.split('%')[0].trim()) >= 50 )     
                                   {
                                         if(acc.Send_Site_Request__c != true)
                                             {
                                                 acc.Send_Site_Request__c = true;
                                             }
                                   }
                               }
                               else if(acc.geo__c == 'LA')
                               {
                                       if(opp.StageName != '' && opp.StageName.indexOf('%') > 0 && integer.valueOf(opp.StageName.split('%')[0].trim()) >= 90 )     
                                       {
                                             if(acc.Send_Site_Request__c != true)
                                             {
                                                 acc.Send_Site_Request__c = true;
                                             }
                                       }
                               }
                           }
                       
              }
              catch(exception ex)
              {
                 
              }      
            } 
      }
     
     List<account> lstAcc = new List<account>();
     lstAcc = m.values();
     try{
             if(lstAcc.size() > 0)
                 upsert lstacc;
        }
      catch(exception ex)
        {
        } 
  }
  
  //Added by vaich01 for chatter update(RPD Status) on opportunity req-8.04
  //change starts
  List<FeedPost> posts = new List<FeedPost>();
  if(Trigger.isupdate)
  {
      if(Trigger.isafter)       
         {    
             for (Opportunity opp :Trigger.New)
             
             {
                opportunity oldOpp = Trigger.oldMap.get(opp.id);
                if(opp.RPD_Status_Formula__c != oldOpp.RPD_Status_Formula__c)
                {
                String bodyText = ' changed the RPD Status from ' +oldOpp.RPD_Status_Formula__c+ ' to ' +opp.RPD_Status_Formula__c+' .';
                FeedPost oppPost = new FeedPost();
                oppPost.parentId = opp.Id;
                oppPost.Body = bodyText;
                system.debug('********'+oppPost.Body );
                posts.add(oppPost);
                }
                
                if(opp.Finance_Valuation_Status__c != oldOpp.Finance_Valuation_Status__c)
                {
                String bodyText = ' changed the Finance Valuation Status from ' +oldOpp.Finance_Valuation_Status__c+ ' to ' +opp.Finance_Valuation_Status__c+'.';
                FeedPost oppPost = new FeedPost();
                oppPost.parentId = opp.Id;
                oppPost.Body = bodyText;
                system.debug('********'+oppPost.Body );
                posts.add(oppPost);
                }
                
             }
             
         } 
     }
     
    if(!posts.isempty())
    {
        insert posts;       
    }   
    
 /*
  //change ends
  //change for valuation status
  Set<ID> opId =new Set<ID>();
  Set<ID> acId =new Set<ID> ();
  List<Opportunity> oppUpdt = new List<Opportunity>();
  List<Active_Contract_Product__c> acplst = new List<Active_Contract_Product__c>();
  List<Active_Contract__c> acList = new List<Active_Contract__c>(); 
  if(Trigger.isbefore)
{
  for(Opportunity op:Trigger.new)
    {
    opId.add(op.id);
    }
  
    List<opportunity> oplst  =[Select Id, Name, Finance_Valuation_Status__c From Opportunity where ID in :opid];
    acplst =[select Id, Name, opportunity__c, Active_Contract__c, Active_Contract__r.Status_Formula__c from Active_Contract_Product__c where opportunity__c in :opid];
    system.debug('*****oplst*****'+oplst);
    system.debug('####**acplst*****'+acplst);
    
    for(Active_Contract_product__c acpTmp :acplst)
    {
     acID.add(acpTmp.Active_Contract__c);
     system.debug('**###**acpTmp*****'+acpTmp);

    }
    
    acList = [select id,name from Active_Contract__c where Id IN:acId];

    for (Opportunity oppTmp:oplst)
    {
    oppUpdt = new List<Opportunity>();
    system.debug('####**oppTmp*****'+oppTmp);
    for(Active_Contract_Product__c acpTmp2:acplst)
    {
    if(acpTmp2.Active_Contract__r.Status_Formula__c != 'Validated')
    {
    oppTmp.Finance_Valuation_Status__c = 'Not Validated';
    oppUpdt.add(oppTmp);
    }
    else
    {
    oppTmp.Finance_Valuation_Status__c = 'Validated';
    oppUpdt.add(oppTmp);
    }
    }
    }
    }**/
}    //update oppUpdt;