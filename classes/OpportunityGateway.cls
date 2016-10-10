/**
 * Class OpportunityGateway
 *
 * Provides finder methods for accessing data in the Opportunity object.
 */
public class OpportunityGateway
{
    private static string recordtypeIdSMBAccount = (RecordTypes_Setting__c.getValues('SMB') <> null ? RecordTypes_Setting__c.getValues('SMB').RecordType_Id__c : '');
    private static string recordtypeIdNewOpp = (RecordTypes_Setting__c.getValues('New Opportunity') <> null ? RecordTypes_Setting__c.getValues('New Opportunity').RecordType_Id__c : '');
    private static string recordtypeIdAcquisition = (RecordTypes_Setting__c.getValues('Acquisition') <> null ? RecordTypes_Setting__c.getValues('Acquisition').RecordType_Id__c : '');
    private static string recordtypeIdQuoteRequest = (RecordTypes_Setting__c.getValues('Quote Request') <> null ? RecordTypes_Setting__c.getValues('Quote Request').RecordType_Id__c : '');
  
  
    public static Set<Id> s_IdsForAccountUpdates = new Set<Id>();
    public static Set<Id> s_IdsForDealDesk = new Set<Id>();
    public static Set<Id> s_IdsClosedOpps = new Set<Id>();
    public static Set<Id> s_IdsForQuoteRequest = new Set<Id>();
    public static Set<Id> s_IdsForServiceRequest = new Set<Id>();
    public static Set<Id> s_IdsForRFx = new Set<Id>();
    public static Set<Id> s_IdsForVolumeCustomer = new Set<Id>();
    public static Set<Id> s_IdsForSalesTeamforEA = new Set<Id>();
    public static Set<Id> s_IdsForSalesTeam = new Set<Id>();
    public static Set<Id> s_IdsForSalesTeamFromTAQ= new Set<Id>();
    public static Set<Id> s_IdsForOLI = new Set<Id>();
    public static Set<id> s_AccountIds = new Set<id>();  
    public static Map<ID, Account> m_AccountUpdateSiteRequest = new Map<ID, Account>();
    public static set<id> s_oppidsforotm = new set<id>();  
    public static Map<ID, Account> m_entcommaccount = new Map<id,Account>();
    public static List<OpportunityShare> lstOS=new List<OpportunityShare>();
    public static List <OpportunityTeamMember> lstOTM = new List <OpportunityTeamMember>();
    public static Map<string,id> mPmfkeyToUserId = new Map<string,id>();
    public static Map<id,Volume_Customer__c> m_volumeCustomers=new Map<id,Volume_Customer__c>();
    public static List<Deal_Desk_Review__c> lst_dealDesk = new List<Deal_Desk_Review__c>(); //Deal_Desk_Review__c
    public static List<Quote_Request__c> lst_QuoteRequest = new List<Quote_Request__c>(); //OppUpdateQuoteRequestTrigger
    
    private static Map<id,user> mUser = new Map<id, user>();    
    //UpdateOpportunityUSDCurrencyExchange - start
    private static Set<string> currencyCodeList=new Set<string>();
    private static Date maxCloseDate=null;
    private static Date MinCloseDate=null;  
    public static List<DatedConversionRate> conversionRates = new List<DatedConversionRate>();
    //UpdateOpportunityUSDCurrencyExchange - end
    
    private static List<Trial_Request__c> lst_trialRequest = new List<Trial_Request__c>();
    
    
    
    private static Set<ID> s_requestorIds=new Set<Id>();
    private static Set<ID> s_entcommaccountIds=new Set<Id>();
    private static set<id> s_accountid_otm = new Set<id>();
    private static set<id> s_Distributor_6_otm  = new Set<id>();
    private static set<id> s_Reseller_otm = new Set<id>();
    private static set<id> s_Partner_otm = new Set<id>();
    private static set<id> s_Partner_1_otm = new Set<id>();
    private static set<id> s_Alliance_Partner_2_otm = new Set<id>();
    private static Set<ID> s_serviceProviderClient_otm =new Set<ID>();
    private static Set<ID> s_volumeCustomerId=new Set<ID>();
    
    public static Map<ID,Account> m_account=new Map<ID,Account>();
    
    private static map<string,string> m_accountlookup_taqrole = new Map<String, String>{'account' => '%' , 'account_servprov' => 'PARTN SERVPROV' ,'Distributor_6' => 'PARTN SOLPROV', 
        'Reseller' => 'PARTN SOLPROV', 'Partner' => 'PARTN SERVPROV', 'Partner_1' => 'PARTN ALLIANCE' , 'Service_Provider_Client' => '%','Reseller_DM' => 'PARTN DM'};
    private static Map<id,List<TAQ_Account_Team_Approved__c>> mapAccountIdToPMFkey = new Map<id,List<TAQ_Account_Team_Approved__c>>();
    private static Set<ID> s_oppidsDDRQuoteRequest=new Set<ID>();
    
    public static integer classexecuted =0; 


    /**
    * Loads the values of the Ids for each operation in each set before thse execution begins for After Triggers
    *
    */
    public static void loadOpportunityBulkValues()
    {
         System.debug('___!11___');
        if(classexecuted == 0)
            classexecuted ++;
        else
            return; 
        
        List<Opportunity> lstTrigger;
        if(trigger.isDelete)
            lstTrigger = trigger.Old;
        else
            lstTrigger = trigger.New;   
        
        System.debug('___!22___');
        set<id> setuid = new set<id>();
        System.debug('___!33___');
        for(Opportunity opp: lstTrigger)
        {
            Opportunity oldOpp;
            if(Trigger.isUpdate)
                oldOpp = (Opportunity)Trigger.OldMap.get(opp.id);
            if((Trigger.isInsert || (Trigger.isUpdate  && opp.StageName != oldOpp.StageName)) && (opp.probability >=50 && opp.accountid != null) ) //earlier trigger aiau_OppSiteRequestThreshold
                {
                                s_AccountIds.add(opp.accountid);
                                s_IdsForAccountUpdates.add(opp.id);
                }
            
            //UpdateOpportunityUSDCurrencyExchange
             if(Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate &&  (opp.CloseDate<>oldOpp.CloseDate || opp.CurrencyIsoCode<>oldOpp.CurrencyIsoCode))))
             {
                currencyCodeList.add(opp.CurrencyIsoCode);
                if(maxCloseDate==null)
                {
                    maxCloseDate=opp.CloseDate;
                    MinCloseDate=opp.CloseDate;  
                }
                else
                {
                    if(opp.CloseDate>maxCloseDate)
                    {
                        maxCloseDate=opp.CloseDate;
                    }
                    else if(opp.CloseDate<MinCloseDate)
                    {
                        MinCloseDate=opp.CloseDate; 
                    }
                }
            }
                
            if(trigger.isUpdate && (opp.OwnerId!=oldOpp.OwnerId || opp.CloseDate!=oldOpp.CloseDate || opp.Amount!=oldOpp.Amount || opp.StageName!=oldOpp.StageName || opp.Type!=oldOpp.Type)) //OppUpdateDealDeskTrigger
            { 
                s_oppidsDDRQuoteRequest.add(opp.id);
                setuid.add(opp.OwnerId);
            }   
            if(Trigger.isUpdate && opp.isClosed && (opp.probability !=  oldOpp.probability) )
            {       
                s_IdsClosedOpps.add(opp.id);
            }    
            
            if((opp.Requestor_Information__c <> null && oldOpp <> null && opp.Requestor_Information__c <> oldOpp.Requestor_Information__c ) || ( Trigger.isInsert && opp.Requestor_Information__c <> null ))
            {
                s_requestorIds.add(opp.Requestor_Information__c);
            }
            
            if((Trigger.isUpdate && opp.Ent_Comm_Account__c  <> oldOpp.Ent_Comm_Account__c ) || ( Trigger.isInsert && opp.Ent_Comm_Account__c  <> null ))
            {
                s_entcommaccountIds.add(opp.Ent_Comm_Account__c);
            }
            
            //Sales Team from Account Lookups -start
           if(opp.AccountId != null && (oldOpp == null || oldOpp.AccountId == null) )                         
                s_accountid_otm.add(opp.AccountId);
            
           if(opp.Reseller__c != null && (oldOpp == null || oldOpp.Reseller__c == null))                      
                s_Reseller_otm.add(opp.Reseller__c) ; 
         
           if(opp.Partner_1__c != null && (oldOpp == null || oldOpp.Partner_1__c == null))                         
                s_Partner_1_otm.add(opp.Partner_1__c) ; 
            
           if(opp.Alliance_Partner_2__c!= null && (oldOpp == null || oldOpp.Alliance_Partner_2__c== null))                         
                s_Alliance_Partner_2_otm.add(opp.Alliance_Partner_2__c) ; 
           
            
            
           if(opp.Distributor_6__c != null && (oldOpp == null || oldOpp.Distributor_6__c == null))                         
                s_Distributor_6_otm.add(opp.Distributor_6__c) ; 
                
           if(opp.partner__c != null && (oldOpp == null || oldOpp.partner__c == null))                        
                s_Partner_otm.add(opp.partner__c) ;
           
            if(opp.Service_Provider_Client__c !=null && (oldOpp == null ||  oldOpp.Service_Provider_Client__c == null)) //Supercare 
                s_serviceProviderClient_otm.add(opp.Service_Provider_Client__c);
                
           if ((opp.AccountId != null && (oldOpp == null || oldOpp.AccountId == null) ) ||                         
                (opp.Reseller__c != null && (oldOpp == null || oldOpp.Reseller__c == null)) ||
                (opp.Partner_1__c != null && (oldOpp == null || oldOpp.Partner_1__c == null))|| 
                (opp.Alliance_Partner_2__c!= null && (oldOpp == null || oldOpp.Alliance_Partner_2__c== null))|| 
                (opp.Distributor_6__c != null && (oldOpp == null || oldOpp.Distributor_6__c == null)) ||
                (opp.partner__c != null && (oldOpp == null || oldOpp.partner__c == null))  || 
                (opp.Service_Provider_Client__c != null && (oldOpp == null || oldOpp.Service_Provider_Client__c == null))
                )
                {
                    s_oppidsforotm.add(opp.id); //lst of all opps where sales team needs to be added 
                }  
            //Sales Team from Account Lookups -end
            
            //OppUpdateAggregateInfo - retrieve vol cust ids - start    
            if(opp.Volume_Account__c!=null && (oldOpp == null ||  opp.Volume_Account__c!=oldOpp.Volume_Account__c)) //
            {
                s_volumeCustomerId.add(opp.Volume_Account__c);
            }
            //OppUpdateAggregateInfo - retrieve vol cust ids - end
            
           
          
        
        }
    
    System.debug('___!44___');
        //SOQL - OppUpdateAggregateInfo - retrieve map of vol customers - start
        if(s_volumeCustomerId.size() > 0)
            m_volumeCustomers=new Map<id,Volume_Customer__c>([Select Id,Account__c,Agg_Acct_Area__c,Agg_Acct_Region__c,Agg_Acct_Territory_Country__c
        from Volume_Customer__c where Id in:s_volumeCustomerId]);
        //SOQL - OppUpdateAggregateInfo - retrieve map of vol customers - end
    
    
    System.debug('___!55___');
        //TBD - Combine the two SOQL under  
       if(s_AccountIds.size()>0)
        {
            m_AccountUpdateSiteRequest = new Map<ID, Account>([Select id, RecordTypeId, Send_Site_Request__c, name, GEO__c from Account Where Id in :s_AccountIds and RecordTypeId = : recordtypeIdSMBAccount AND  Geo__c IN ('EMEA', 'NA', 'APJ', 'Asia-Pacific', 'Japan', 'LA')]);
        }
        
        if(s_entcommaccountIds.size() > 0)
        {    m_entcommaccount= new Map<ID, Account>([Select id,Owner.PMFKEY__C,Customer_Category__c,OwnerId,Owner.IsActive from Account Where Id in :s_entcommaccountIds
                                  AND Owner.IsActive = TRUE AND Owner.PMFKEY__C NOT IN ('APPARTN','NAPARTN','EMPARTN','JPPARTN','LAPARTN')]);
        }
        
        System.debug('___!66___');
        
        if(m_entcommaccount.size() > 0)
        {
            for(account a: m_entcommaccount.values())
                s_requestorIds.add(a.ownerid);
        }
        
        if(currencyCodeList.size()>0)
        {
            //get Dated Conversion Rates
            conversionRates=[Select StartDate, NextStartDate, LastModifiedDate, IsoCode, ConversionRate 
            From DatedConversionRate where IsoCode in:currencyCodeList and StartDate<=:MinCloseDate and NextStartDate>:maxCloseDate];
        }
              System.debug('___!77___');  
        
        Set<String> setpmf = new set<String>(); 
        //Sales Team From TAQ - Start
System.debug('___999___'+(s_accountid_otm.size() + s_Distributor_6_otm.size() + s_Reseller_otm.size() +s_Alliance_Partner_2_otm.size()+s_Partner_1_otm.size() + s_Partner_otm.size()+ s_serviceProviderClient_otm.size() ) );
        if((s_accountid_otm.size() + s_Distributor_6_otm.size() + s_Reseller_otm.size()+s_Alliance_Partner_2_otm.size() + s_Partner_1_otm.size() + s_Partner_otm.size()+ s_serviceProviderClient_otm.size() ) > 0  ) //No processing if no relevant account id
        {
            System.debug('------*****************-----'+s_accountid_otm);
            
            Set<string> spmfkey_temp;
            mapAccountIdToPMFkey = new Map<id,List<TAQ_Account_Team_Approved__c>>();
            //SOQL  - Get the TAQ Account Team records for all the Account lookups
            System.debug('------*****************-----'+s_serviceProviderClient_otm);
            System.debug('------*****************-----'+s_Distributor_6_otm);
            System.debug('------*****************-----'+s_Partner_1_otm);
            System.debug('------*****************-----'+s_Alliance_Partner_2_otm);
            System.debug('------*****************-----'+s_Partner_otm);
            System.debug('------*****************-----'+s_Reseller_otm);
            System.debug('------*****************-----'+m_accountlookup_taqrole);
             
            m_account = new Map<ID, Account>([Select Solution_Provider__c,Velocity_Seller__c,Service_Provider__c,Alliance__c 
                            from Account Where Id in :s_accountid_otm
                                            or Id IN :s_Reseller_otm
                            ]);
            
            System.debug('____11aa_D___'+s_accountid_otm);
            List<TAQ_Account_Team_Approved__c> vvv = [select TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name , id,PMFKey__c,taq_Role__c, TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c from TAQ_Account_Team_Approved__c
            where 
                TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in ('0013000000HQXmT') ];
                
                System.debug('____11aa_e___'+vvv.size());
                
            for(TAQ_Account_Team_Approved__c atm: [select TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name , id,PMFKey__c,taq_Role__c, TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c from TAQ_Account_Team_Approved__c
            where 
            TAQ_Account_Approved__r.TAQ_Account__c <> null AND
            TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c <> null AND
            (
                (
                TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in :s_accountid_otm AND
                    ( TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name in ('SMB','Account Team Covered Account','Territory Covered Account')
                      OR (TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name = 'Reseller/Distributor Account' 
                         AND( 
                                (TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Service_Provider__c = True and TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Velocity_Seller__c = False AND Partner_Role__c INCLUDES (: m_accountlookup_taqrole.get('account_servprov'))) //Added Condition for Service Provider Partners
                                OR
                                 (TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Velocity_Seller__c = True AND TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Service_Provider__c = False AND Partner_Role__c INCLUDES (: m_accountlookup_taqrole.get('Reseller_DM')))//Added Condition for DM
                                OR
                                 (TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Service_Provider__c = True AND TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Velocity_Seller__c = True and (Partner_Role__c INCLUDES (: m_accountlookup_taqrole.get('account_servprov')) OR  Partner_Role__c INCLUDES (: m_accountlookup_taqrole.get('Reseller_DM')))  )//Added Condition for Hybrid DM, Serv Provider  
                         )//End of AND
                        
                        )   
                    )
                )
                
                OR( TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_serviceProviderClient_otm AND TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name in ('SMB','Account Team Covered Account','Territory Covered Account') )
                OR( TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in :s_Distributor_6_otm AND Partner_Role__c INCLUDES (: m_accountlookup_taqrole.get('Distributor_6')))
                OR( 
                        TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in :s_Reseller_otm 
                        AND 
                        (
                            Partner_Role__c INCLUDES (:m_accountlookup_taqrole.get('Reseller')) 
                            or
                            Partner_Role__c INCLUDES (:m_accountlookup_taqrole.get('Reseller_DM'))
                        )
                    )
                OR( TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in :s_Partner_1_otm AND Partner_Role__c INCLUDES (:m_accountlookup_taqrole.get('Partner_1')))
                OR( TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in :s_Alliance_Partner_2_otm AND Partner_Role__c INCLUDES (:m_accountlookup_taqrole.get('Partner_1')))
                OR( TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in :s_Partner_otm AND Partner_Role__c INCLUDES (:m_accountlookup_taqrole.get('Partner')))
            )
            AND            
            TAQ_Account_Approved__r.Is_Latest_Record__c = true])
            {
                System.debug(atm.id+'____into this loop' + atm.pmfkey__c);
                 mapAccountIdtoPMFkey = getmapAccountIdtoPMFkey(atm,mapAccountIdtoPMFkey);      
                 setpmf.add(atm.pmfkey__c.toUpperCase());   
            }
             mPmfkeyToUserId = new Map<String,id>();
          }
          
          system.debug('>>>>>>>>____set' + setpmf);
          
        if(setpmf.size() > 0 || setuid.size() > 0) //Sales Team + Quote Request
             {
                //SOQL - Retrieve user id for the TAQ Account Team PMFkey   
                 mUser = new Map<id,User>([select id,name, pmfkey__c from user where ((pmfkey__c in : setpmf ) OR id in: setuid) and pmfkey__c <> null and isActive = true ]); //
                 for(user u:mUser.values())
                    mPmfkeyToUserId.put(u.pmfkey__c.touppercase(), u.id);
             }  
         //Sales Team from TAQ - end
    
    if(s_oppidsDDRQuoteRequest.size() > 0)
        {
            for (Deal_Desk_Review__c dd:[SELECT Id, Name,Opportunity_Name__c FROM Deal_Desk_Review__c WHERE Opportunity_Name__c in :s_oppidsDDRQuoteRequest])
            {    
                //get the parent opportunity
                Opportunity opp= (Opportunity) Trigger.newMap.get(dd.Opportunity_Name__c);            
                dd.Opportunity_Owner__c = opp.OwnerId;
                dd.Oppty_Close_Date__c = opp.CloseDate;
                dd.Oppty_Amount__c  = opp.Amount;
                dd.Sales_Milestone__c  = opp.StageName;
                dd.Type__c = opp.Type;
                if(!addedIds.contains(dd.id))
                {
                lst_dealDesk.add(dd);
                addedIds.add(dd.id);
                }
             }
             
            //OppUpdateQuoteRequestTrigger  
            for (Quote_Request__c qreq:[SELECT Id, Name,Opportunity_Name__c FROM Quote_Request__c WHERE Opportunity_Name__c in :s_oppidsDDRQuoteRequest])
            {     
                //get the parent opportunity
                Opportunity opp= (Opportunity)Trigger.newMap.get(qreq.Opportunity_Name__c);  
                Opportunity oppOld= (Opportunity)Trigger.oldMap.get(qreq.Opportunity_Name__c);  
                
                User ownr = mUser.get(opp.OwnerId);
                qreq.Oppty_Owner__c = opp.OwnerId;
                qreq.Opportunity_Owner__c = (ownr <> null ? ownr.Name:'');
                qreq.Opportunity_Close_Date__c = opp.CloseDate;
                qreq.Opportunity_Amount__c  = opp.Amount;
                qreq.Sales_Milestone__c  = opp.StageName;
                qreq.Type__c = opp.Type;

                if(oppOld.IsClosed==true && opp.IsClosed==false)
                {
                    if(recordtypeIdQuoteRequest <> null && recordtypeIdQuoteRequest <> '' )
                        qreq.RecordTypeId = recordtypeIdQuoteRequest;
                    qreq.Request_Status__c = 'Updated';
                }
               if(!addedIds.contains(qreq.id) )
               {     
                lst_QuoteRequest.add(qreq);
                addedIds.add(qreq.id);
               }        
            }   
        
        
        
        }   
            
   }
   
   Private Static Set<id> addedIds = new Set<id>();
   
   
   public static Map<id,List<TAQ_Account_Team_Approved__c>> getmapAccountIdtoPMFkey(TAQ_Account_Team_Approved__c atm, Map<id,List<TAQ_Account_Team_Approved__c>> mAccountToPMFkeyMatch)
    {     List<TAQ_Account_Team_Approved__c>  listPmfkey_temp = mapAccountIdtoPMFkey.get(atm.TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c);
          if(listPmfkey_temp == null) { listPmfkey_temp = new List<TAQ_Account_Team_Approved__c>();}
          listPmfkey_temp.add(atm);
          mapAccountIdtoPMFkey.put(atm.TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c, listPmfkey_temp);
          return mapAccountIdtoPMFkey;
    }
   
  //Method used mAccountToPMFkeyMatch, mPmfkeyToUserId from outside 
    public static void addlistOpportunityTeamMemberfromTAQ(id oppid, id accountid, String role)
    {   
        List<TAQ_Account_Team_Approved__c>  listPmfkey_temp = mapAccountIdtoPMFkey.get(accountid);
        System.debug('___xxx___'+mapAccountIdtoPMFkey);
        System.debug('____1 if____'+listPmfkey_temp);
        System.debug('____2 if____'+accountid);
        if(listPmfkey_temp <> null && listPmfkey_temp.size() > 0) 
        {  
             for(TAQ_Account_Team_Approved__c  taqatm : listPmfkey_temp)
            {   
            //   System.debug('____for___');
                 if(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()) <> null)  
                 {                                  
               //    System.debug('___meth call');
                 Opportunity Opp = (Opportunity)Trigger.newMap.get(oppid);
               if (Opp.Reseller__c == accountid || Opp.Distributor_6__c == accountid)
               {                                              
                     If ((Opp.Type == 'ERWIN' && taqatm.taq_role__c == 'TAQ-PARTN DM') || ((opp.Type == '1 Tier' || opp.Type == '2 Tier' || opp.Type == 'Direct' || opp.Type == 'xSP' || opp.Type == 'Direct') && (taqatm.taq_role__c == 'TAQ-PARTN SOLPROV' || taqatm.taq_role__c == 'TAQ-PARTN SERVPROV' || taqatm.taq_role__c == 'TAQ-PARTN ALLIANCE')))
                        addOppTeamMember(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()), oppid, taqatm.taq_role__c); 
                     Else if (Opp.Type != 'ERWIN' && Opp.Type != '1 Tier' && Opp.Type != '2 Tier' && Opp.Type != 'Direct' && Opp.Type != 'xSP' && opp.Type != 'Direct') 
                        addOppTeamMember(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()), oppid, taqatm.taq_role__c);   
                     //System.debug('_____Inside addOppTeamMember**************************** ____'+Opp.Type+taqatm.taq_role__c+taqatm.pmfkey__c);
                }
                Else
                {
                 addOppTeamMember(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()), oppid, taqatm.taq_role__c); 
                  }   
                 }
          }
        }
    
    } 
   
  public static map<id, set<id>> mapOppIdsSalesTeamUserId = new map<id, set<id>>();
   
  public static void addOppTeamMember(id userid, id oppid, string teamrole)
  {
    
    System.debug('_____Inside addOppTeamMember**************************** ____');
          set<id> suserid = mapOppIdsSalesTeamUserId.get(oppid);
          if(suserid == null ){ suserid = new set<id>();}
          if(suserid.contains(userid) <> true)
          { 
          
          OpportunityTeamMember otm = new OpportunityTeamMember();
          otm.TeamMemberRole = teamrole;
          otm.OpportunityId = oppid;
          otm.UserId = userid;
          lstOTM.add(otm);
          
          System.debug('--inoppGateway=='+lstOTM);
      
          OpportunityShare os =new OpportunityShare ();
          os.OpportunityId=oppid;
          os.UserOrGroupId=userid;
          os.OpportunityAccessLevel='edit';
          lstOS.add(os);
         } 
         System.debug('_____lstOTM size____'+lstOTM.size());
         System.debug('_____lstOS size____'+lstOS.size());
  }
 
    
    
 
  public static List<Trial_Request__c> getUpdateTrials()
  {
     List<Trial_Request__c> trlReq = new List<Trial_Request__c>();
     if(s_IdsClosedOpps.size()>0 )
     {
        lst_trialRequest = [select Request_Status__c,Opp_Name__c, Opp_Name__r.RecordType.Name from Trial_Request__c where Opp_Name__c in:s_IdsClosedOpps];
        if(lst_trialRequest.size()>0)
        {
            for(Trial_Request__c req:lst_trialRequest)
            {
               //FY13 change req.Request_Status__c = 'Closed';
               if(req.Request_Status__c != 'Complete')
               {
                 if(((Opportunity) Trigger.NewMap.get(req.Opp_Name__c)).StageName == '100% - Contract Signed' || ((Opportunity) Trigger.NewMap.get(req.Opp_Name__c)).StageName == '100% - Closed')
                    {
                      req.Request_Status__c = 'Complete';
                      trlReq.add(req);
                     }
                 if(((Opportunity) Trigger.NewMap.get(req.Opp_Name__c)).StageName == 'Closed - Lost')
                 {
                    req.Request_Status__c = 'Cancelled'; 
                  trlReq.add(req);
                 }                                                            
               }                                  
            }
        }       
     }
        return trlReq;
   }
   
   
  //UpdateLineitems 
  public static List<RFP__c> getUpdateRFPs()
  {
     List<RFP__c> lstRFx = new List<RFP__c>();
     if(s_IdsClosedOpps.size() > 0)
              {
                for(RFP__C rfp: [Select id, Opp_Status__c, Opportunity__c From RFP__c where Opportunity__c in : s_IdsClosedOpps])
                      {
                         if(((Opportunity) Trigger.NewMap.get(rfp.Opportunity__c)).probability == 0)
                              rfp.Opp_Status__c = 'Lost';
                          else
                              rfp.Opp_Status__c = 'Won';
                      
                        lstRFx.add(rfp);
                      } 
                  }
     return lstRFx; 
  }
  
  //UpdateLineitems
  public static List<Services_Request__c> getUpdatedSRs()
  {
     List<Services_Request__c> lstSR = new List<Services_Request__c>();
     lstSR = [Select Services_Request_Status__c from Services_Request__c where Oppty_Name__c in : s_IdsClosedOpps];    
     for(Services_Request__c sr:lstSR)
                sr.Services_Request_Status__c = 'Closed';
     return lstSR; 
  }
  //UpdateLineitems
  public static List<OpportunityLineItem> getUpdatedOpportunityLineItems()
  {
    List<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
    if(s_IdsClosedOpps.size() > 0)
     {
        for(OpportunityLineItem oli:[select OpportunityId,PricebookEntry.Product2.Family from OpportunityLineItem where
         OpportunityId in:s_IdsClosedOpps AND PricebookEntry.Product2.Family IN ('Support','Education','Product','Time','Mainframe Capacity','Renewal','Services')
         AND   Opportunity.RecordTypeId in (:recordtypeIdNewOpp,: recordtypeIdAcquisition)
         order by OpportunityId , PricebookEntry.Product2.Family])
        {
            Opportunity opp = (Opportunity) Trigger.NewMap.get(oli.OpportunityId);
            string family = oli.PricebookEntry.Product2.Family; 
            string opptype = opp.Opportunity_Type__c; 
            
            //Exclude Education, Services
            if((family<> 'Education' && family <> 'Services') || ( opptype <> null && opptype.startsWith('Services')) || ( opptype <> null && opptype.startsWith('Standalone') ) || ( opptype <> null && opptype.startsWith('Education')) || ( opptype <> null && opptype.startsWith('Support'))
                || opp.StageName == 'Closed - Lost')
            {       
                //oli.Probability__c = opp.Probability;
                lstOLI.add(oli);
            }
        
        }  
     }
    return lstOLI;
  }
   


public static List<FeedItem> addFeedToList(List<FeedItem> lstfeed, id parentid, string chattermessage)
    {
        FeedItem renChatterPost = new FeedItem();
        renChatterPost.ParentId = parentid;
        renChatterPost.body = chattermessage;
        lstfeed.add(renChatterPost);
        return lstfeed;
    }
   
    
}