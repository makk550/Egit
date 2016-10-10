trigger PartnerOpportunity on Opportunity(before update, before insert, after insert, after update) {

    if (SystemIdUtility.skipOpportunityTriggers)
        return;
    RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('Deal Registration');
    Id dealRegOppRecordTypeID = rec.RecordType_Id__c;

    rec = RecordTypes_Setting__c.getValues('Partner Opportunity');
    Id partnerOppRecordTypeID = rec.RecordType_Id__c;

    rec = RecordTypes_Setting__c.getValues('New Opportunity');
    Id newOppRecordTypeID = rec.RecordType_Id__c;


    Set < Id > accId = new Set < Id > ();
    List < Opportunity > lstOpp = new List < Opportunity > ();
    List < Opportunity > lstOppPer = new List < Opportunity > ();
    List < Opportunity > lstOpp_Source = new List < Opportunity > ();
    Map < Id, Id > Lead_OppMap = new Map < Id, Id > ();
    Map < Id, Opportunity > OppID_OppMap = new Map < Id, Opportunity > ();
    set < ID > ids = new set < ID > ();
    ExternalSharingHelper sharingHelper = new ExternalSharingHelper();
    /*PartnerAccount Start*/
    Set < Id > partnerAccId = new Set < Id > ();
    List < OpportunityShare > lstOS = new List < OpportunityShare > ();
    List < OpportunityTeamMember > lstOTM = new List < OpportunityTeamMember > ();
    List < AccountShare > lstAS = new List < AccountShare > ();
    /*PartnerAccount End*/
    Set < Id > newOppIds = new Set < Id > ();
    boolean Layer7Opp = false;
    for (Opportunity opp: Trigger.New) {
        if (opp.Source__c == 'Layer7')
            Layer7Opp = true;
        system.debug('==>' + opp);

    }
    if (Trigger.isAfter && Trigger.isInsert) {

        if (Layer7Opp == true) {

            List < Product2 > prod = [Select Id from Product2 where(Name = 'Layer 7 SOA Gateway'
                or Name = 'Layer 7 Services'
                or Name = 'Layer 7 Education') order by Name];
            List < Pricebook2 > pb2 = [Select Id from Pricebook2 where(Name = 'CA Product List') order by Name];
            List < PricebookEntry > pbe = new List < PricebookEntry > ();
            pbe = [Select Id, Name, Product2Id, Pricebook2Id from PricebookEntry Where Pricebook2Id in : pb2 and IsActive = true and CurrencyISOCode = 'USD'
                and Product2Id in : prod
            ];
            Map < string, PricebookEntry > mapPBE = new Map < string, PricebookEntry > ();
            List < OpportunityLineItem > layer7lineitems = new List < OpportunityLineItem > ();
            for (PricebookEntry priceBooke: pbe) {
                mapPBE.put(priceBooke.Name, priceBooke);
            }

            for (Opportunity opp: Trigger.New) {
                if (opp.Source__c == 'Layer7') {
                    //try
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        system.debug('***beforeex2*****+ prod --> ' + pbe);

                        if (opp.L7_Education_Amount__c > 0) {
                            oli.Contract_Length__c = 5;
                            oli.OpportunityId = opp.id;
                            oli.Business_Type__c = 'Education';
                            oli.Stretch__c = opp.L7_Education_Amount__c;
                            oli.UnitPrice = opp.L7_Education_Amount__c;
                            //oli.License__c = 'Upfront';
                            oli.Term_Month__c = 12;
                            oli.PricebookEntryId = mapPBE.get('Layer 7 Education').id;

                            layer7lineitems.add(oli);
                        }
                        system.debug('***services*****');
                        //Services
                        if (opp.L7_Services_Amount__c > 0) {
                            OpportunityLineItem oli_service = new OpportunityLineItem();
                            oli_service.Contract_Length__c = 5;
                            oli_service.OpportunityId = opp.id;
                            oli_service.Business_Type__c = 'Services';
                            oli_service.Stretch__c = opp.L7_Services_Amount__c;
                            oli_service.UnitPrice = opp.L7_Services_Amount__c;
                            //oli_service.License__c= 'Upfront';
                            oli_service.Term_Month__c = 12;
                            oli_service.PricebookEntryId = mapPBE.get('Layer 7 Services').id;
                            layer7lineitems.add(oli_service);
                        }
                        system.debug('***new*****');
                        //New
                        if (opp.L7_PNCV__c > 0) {
                            OpportunityLineItem oli_New = new OpportunityLineItem();
                            oli_New.Contract_Length__c = 5;
                            oli_New.OpportunityId = opp.id;
                            oli_New.License__c = 'Upfront';
                            oli_New.Term_Month__c = 12;
                            if (opp.L7_Support_and_Maintenance_Expiry__c >= system.today())
                                oli_New.Business_Type__c = 'Capacity';
                            else
                                oli_New.Business_Type__c = 'New';
                            oli_New.Stretch__c = opp.L7_PNCV__c;
                            oli_New.UnitPrice = opp.L7_PNCV__c;
                            oli_New.License__c = 'Upfront';
                            oli_New.Term_Month__c = 12;
                            oli_New.UF_License_Fee__c = (10 * opp.L7_PNCV__c) / (10 + 2 * 1);
                            oli_New.Total_Maintenance__c = 0.2 * oli_New.UF_License_Fee__c * 1;
                            oli_New.PricebookEntryId = mapPBE.get('Layer 7 SOA Gateway').id;
                            layer7lineitems.add(oli_New);
                        }
                    }

                }
            }
            if (layer7lineitems.size() > 0) {
                insert layer7lineitems;
                return;
            }

        }
    }

    Decimal p = 0;

    for (Opportunity opp: Trigger.New) {
        if (opp.recordTypeId == partnerOppRecordTypeID)
            p++;
    }


    //sales team
    set < id > s_accountid_otm = new Set < id > ();
    set < id > s_Distributor_6_otm = new Set < id > ();
    set < id > s_Reseller_otm = new Set < id > ();
    set < id > s_Partner_otm = new Set < id > ();
    set < id > s_Partner_1_otm = new Set < id > ();
    set < id > s_Alliance_Partner_2_otm = new Set < id > ();
    Set < ID > s_serviceProviderClient_otm = new Set < ID > ();
    Map < string, id > mPmfkeyToUserId = new Map < string, id > ();
    Map < id, List < TAQ_Account_Team_Approved__c >> mapAccountIdToPMFkey = new Map < id, List < TAQ_Account_Team_Approved__c >> ();
    map < string, string > m_accountlookup_taqrole = new Map < String, String > {
        'account' => '%', 'account_servprov' => 'PARTN SERVPROV', 'Distributor_6' => 'PARTN SOLPROV',
        'Reseller' => 'PARTN SOLPROV', 'Partner' => 'PARTN SERVPROV', 'Partner_1' => 'PARTN ALLIANCE', 'Service_Provider_Client' => '%', 'Reseller_DM' => 'PARTN DM'
    };
    Map < ID, Account > m_account = new Map < ID, Account > ();
    set < id > s_oppidsforotm = new set < id > ();
    Map < id, user > mUser = new Map < id, user > ();
    Set < String > setpmf = new set < String > ();
    // This Code is to update all the child ROI records when Opportunity Sales Milestone is set to 100% Contract Signed or Closed Lost
    set < id > oppSet = new set < id > ();
    List < ROI_Request__c > listROI = new List < ROI_Request__c > ();
    List < ROI_Request__c > listROIFinal = new List < ROI_Request__c > ();

    p = 0;

    Map < Id, User > user_IdMap = new Map < Id, User > ();
    List < User > ulist1 = Opportunity_ContactRole_Class.ulist_st;
    if (ulist1 != null)
        for (User u: ulist1)
            user_IdMap.put(u.id, u);
    User loggedinUser;
    User currentUser;
    if (user_IdMap != null && user_IdMap.get(UserInfo.getUserId()) != null) {
        loggedinUser = user_IdMap.get(UserInfo.getUserId());
        currentUser = loggedinUser;
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        for (Opportunity opp: Trigger.new) {
            if (opp.StageName == '100% - Contract Signed' || opp.StageName == 'Closed - Lost')
                oppSet.add(opp.id);
        }
        if (oppSet != null && oppSet.size() > 0) {
            listROI = [select id, Request_Status__c from ROI_Request__c where Oppty_Name__c in : oppSet and Request_Status__c != 'Closed'];

            if (listROI != null && listROI.size() > 0)
                for (ROI_Request__c recROI: listROI) {
                    recROI.Request_Status__c = 'Closed';
                    listROIFinal.add(recROI);


                }
            Update listROIFinal;
        }

        //Added for 3186 
        if (trigger.new[0].isdeletePartner__c && !trigger.oldMap.get(trigger.new[0].id).isdeletePartner__c) {
            system.debug('Partner Opportunity Trigger before trigger.new[0] call');
            OpportunityDeleteOverride oppDel = new OpportunityDeleteOverride();
            oppDel.deleteOpp(trigger.new[0].id);

        }
    }
    if (Trigger.isBefore) {
        for (Opportunity opp: Trigger.new) //3258
            if (opp.recordtypeid == newOppRecordTypeID) {
                if (currentUser.Is_Partner_User__c == true && opp.source__c == 'Partner') {
                    opp.Partner_Engagement__c = 'Incremental';

                }
            }
        for (Opportunity opp: Trigger.new) {
            if (opp.id != null)
                ids.add(opp.id);           
        }
        system.debug('hi');
        system.debug('ids -->' + ids);
        if (ids.size() > 0) {
            List < Lead > objLead = [Select l.ConvertedOpportunityId, l.Id from Lead l where l.ConvertedOpportunityId in : ids];
            for (Lead oLead: objLead) {
                Lead_OppMap.put(oLead.ConvertedOpportunityId, oLead.ConvertedOpportunityId);
                system.debug(Lead_OppMap.get(oLead.ConvertedOpportunityId));
            }
        }

        for (Opportunity opp: Trigger.new) {
            //when lead is converted to Opportunity                          
            if (Lead_OppMap.size() > 0 && opp.Source__c == null) {
                if (opp.id == Lead_OppMap.get(opp.id))
                    opp.Source__c = 'Lead';
            } else if (currentUser.UserType == 'PowerPartner' && currentUser.IsPortalEnabled && opp.Source__c == null && opp.RecordTypeId != dealRegOppRecordTypeID) {
                opp.Source__c = 'Partner';
            } else if (opp.RecordTypeId == dealRegOppRecordTypeID && opp.Source__c == null) {
                opp.Source__c = 'Deal Registration'; // to fill source field.
            } else if (opp.Source__c == null) {
                opp.Source__c = 'CA Internal';
            }

            lstOpp_Source.add(opp);
        }
    }


    // Oct R2014 - Changed the entry condition
    if ((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore) {
        Set < Id > OppId = new Set < Id > ();

        if (Trigger.isUpdate)
            for (Opportunity opp: Trigger.new) {
                if (opp.Reseller_Contact__c == null) {
                    opp.Reseller_Contact__c = currentUser.ContactId;
                }
            }

        if (currentUser.UserType == 'PowerPartner' && currentUser.IsPortalEnabled) {
            //Opportunity owner Assignment only for partner Opportunities.
            for (Opportunity opp: Trigger.new) {
                if (opp.RecordTypeId == newOppRecordTypeID)
                    ids.add(opp.id);
            }
            if (ids.size() > 0) {
                system.debug('OppId -->' + ids);
                Map < Id, Id > mapOppAccount = new Map < Id, Id > ();


                for (Opportunity opp: Trigger.new) {
                    accId.add(opp.AccountId);
                    mapOppAccount.put(opp.Id, opp.AccountId);
                }

                Map < Id, Id > mapOppPartner = new Map < Id, Id > ();
                for (Opportunity opp: Trigger.new) {
                    partnerAccId.add(opp.Reseller__c);
                    mapOppPartner.put(opp.Id, opp.Reseller__c);
                }

                system.debug('partnerAccId -->' + partnerAccId); //Select Id,contact.Account.Solution_Provider_CAM_PMFKey__c,PMFKey__c from user where Id='005Q0000001BytoIAC'
                system.debug('mapOppPartner --> ' + mapOppPartner);


                system.debug('logged in use: ' + loggedinUser.PMFKey__c);


                Map < Id, Account > mapAccount = new Map < Id, Account > ();
                // Oct R2014 - Added Segment__c field in SOQL
                for (Account Acc: [SELECT Id, Name, Coverage_Model__c, Segment__c, OwnerId, recordtypeid, RecordType.Name, Solution_Provider_CAM_PMFKey__c, Service_Provider_CAM_PMFKey__c, Velocity_Seller_CAM_PMFKey__c, Alliance_CAM_PMFKey__c from Account where Id in : accId]) {
                    mapAccount.put(Acc.Id, Acc);
                }
                Map < String, User > user_pmfMap = new Map < String, User > ();
                List < User > ulist = Opportunity_ContactRole_Class.ulist_st;
                if (ulist != null)
                    for (User u: ulist)
                        user_pmfMap.put(u.PMFKey__c, u);
                Map < Id, Account > mapPartnerAccount = new Map < Id, Account > ();
                // Oct R2014 - Added Segment__c field in SOQL
                for (Account PartnerAcc: [SELECT Id, Name, OwnerId, Segment__c, RecordType.Name, Solution_Provider_CAM_PMFKey__c, Service_Provider_CAM_PMFKey__c, Velocity_Seller_CAM_PMFKey__c, Alliance_CAM_PMFKey__c from Account where Id in : partnerAccId]) {
                    mapPartnerAccount.put(PartnerAcc.Id, PartnerAcc);
                }
                system.debug('mapPartnerAccount --> ' + mapPartnerAccount);
                List < Opportunity > finalilst = new List < Opportunity > ();
                for (Opportunity opp: Trigger.new) {
                    Account tempAccount = new Account();
                    tempAccount = mapAccount.get(mapOppAccount.get(opp.Id));
                    Account tempPartnerAccount = new Account();
                    tempPartnerAccount = mapPartnerAccount.get(mapOppPartner.get(opp.Id));
                    // Oct R2014 - Changed condition to below two if
                    if (trigger.isInsert || trigger.oldMap.get(opp.Id).AccountId != trigger.newMap.get(opp.Id).AccountId) {
                        if (tempAccount != null && tempAccount.Coverage_Model__c == 'Account Team') {
                            system.debug('tempAccount.Id - > ' + tempAccount.Id);
                            system.debug('tempAccount.RecordType.Name - > ' + tempAccount.RecordType.Name);
                            system.debug('tempAccount.OwnerId - > ' + tempAccount.OwnerId);
                            opp.OwnerId = tempAccount.OwnerId;
                        } // Oct R2014 - Changed condition to below if
                        else {
                            if (mapPartnerAccount.size() > 0) {
                                if (tempPartnerAccount != null && tempPartnerAccount.Solution_Provider_CAM_PMFKey__c != null) {
                                    user uDM;
                                    if (user_pmfMap != null && user_pmfMap.get(tempPartnerAccount.Solution_Provider_CAM_PMFKey__c) != null){
                                        uDM = user_pmfMap.get(tempPartnerAccount.Solution_Provider_CAM_PMFKey__c);
                                        opp.OwnerId = uDM.Id; 
                                    }
                                }
                            }
                        }
                    }

                    if (trigger.isInsert || trigger.oldMap.get(opp.Id).AccountId != trigger.newMap.get(opp.Id).AccountId || (trigger.oldMap.get(opp.Id).Type != 'ERWIN' && trigger.newMap.get(opp.Id).Type == 'ERWIN')) {
                        if (mapPartnerAccount.size() > 0) {
                            if (tempPartnerAccount != null && tempPartnerAccount.Velocity_Seller_CAM_PMFKey__c != null) {
                                user uDM;
                                if (user_pmfMap != null && user_pmfMap.get(tempPartnerAccount.Solution_Provider_CAM_PMFKey__c) != null){
                                    uDM = user_pmfMap.get(tempPartnerAccount.Solution_Provider_CAM_PMFKey__c);
                                    opp.OwnerId = uDM.Id; 
                                }
                            }
                        }
                    }

                }
            }
        }
    }


    if (Trigger.isAfter && Trigger.isInsert && (currentUser.UserType == 'PowerPartner' && currentUser.IsPortalEnabled)) {

        for (Opportunity opp: Trigger.new) {
            {

                System.debug('Comment inside PartnerOpp in AfterInsert. Opp Owner id: ' + opp.OwnerId);
                System.debug('Comment inside PartnerOpp in AfterInsert. currentUser id: ' + currentUser.Id);
                addOppTeamMember(currentUser.Id, opp.Id, 'Partner');
                addOppTeamMember(opp.OwnerId, opp.Id, 'Owner');
                system.debug('partnerOpportunity - isAfter and isUpdate');

                fetchSalesTeamfromTAQ(opp);

                //sales team from TAQ - start
                System.debug('In PartnerOpportunity - AccountId is:' + opp.AccountId);
                if (opp.AccountId != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.AccountId, '');
                }
                if (opp.Service_Provider_Client__c != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Service_Provider_Client__c, '');
                }
                if (opp.Reseller__c != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Reseller__c, 'TAQ-PARTN SOLPROV');
                }
                if (opp.Partner_1__c != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Partner_1__c, 'TAQ-PARTN ALLIANCE');
                }


                if (opp.Alliance_Partner_2__c != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Alliance_Partner_2__c, 'TAQ-PARTN ALLIANCE');
                }

                if (opp.Distributor_6__c != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Distributor_6__c, 'TAQ-PARTN SOLPROV');

                }
                if (opp.partner__c != null) {
                    addlistOpportunityTeamMemberfromTAQ(opp.id, opp.Partner__c, 'TAQ-PARTN SERVPROV');
                }
            }
            //sales team from TAQ - end
        }

        //Insert users into Opportunity Sales Team
        try {
            if (lstOTM.size() > 0) //Common for All Opp Team additions
            {
                System.debug('inside insert--' + lstOTM);
                Database.SaveResult[] MySaveResult = Database.insert(lstOTM, false);

                for (integer i = 0; i < MySaveResult.size(); i++) {
                    database.SaveResult sr = MySaveResult[i];
                    System.debug('____sr____in partner opporutnity***** ' + sr);
                }
                for (OpportunityTeamMember ot: lstOTM)
                    system.debug('ot.id-' + ot.id);

                lstOTM = new List < OpportunityTeamMember > ();

            }
            if (lstOS.size() > 0) //Common for All Opp Team additions
            {

                system.debug('Debug for shares 1' + lstOS);
                Database.saveResult[] MySaveResult1 = Database.insert(lstOS, false);
                for (integer i = 0; i < MySaveResult1.size(); i++) {
                    database.saveResult sr1 = MySaveResult1[i];
                    System.debug('____sr1____in partner opporutnity***** ' + sr1);
                }
                lstOS = new List < OpportunityShare > ();

            }




        } catch (Exception ex) {
            System.debug('*****Exception ***' + ex);
        }
    }


    public void addOppTeamMember(id userid, id oppid, string teamrole) {

        System.debug('_____Inside addOppTeamMember in partner opporutnity***** ____');

        set < id > suserid = new set < id > ();
        if (suserid.contains(userid) <> true) {
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.TeamMemberRole = teamrole;
            otm.OpportunityId = oppid;
            otm.UserId = userid;
            lstOTM.add(otm);

            OpportunityShare os = new OpportunityShare();
            os.OpportunityId = oppid;
            os.UserOrGroupId = userid;
            os.OpportunityAccessLevel = 'edit';
            lstOS.add(os);
        }
        System.debug('_____lstOTM size____' + lstOTM.size());
        System.debug('_____lstOS size____' + lstOS.size());
        System.debug('_____lstOS ____' + lstOTM);
        System.debug('_____lstOS ____' + lstOS);
    }


    public void fetchSalesTeamfromTAQ(Opportunity opp) {
          {
            //Sales Team from Account Lookups -start
             if (opp.AccountId != null)
                s_accountid_otm.add(opp.AccountId);

            if (opp.Reseller__c != null)
                s_Reseller_otm.add(opp.Reseller__c);

            if (opp.Partner_1__c != null)
                s_Partner_1_otm.add(opp.Partner_1__c);

            if (opp.Alliance_Partner_2__c != null)
                s_Alliance_Partner_2_otm.add(opp.Alliance_Partner_2__c);

            if (opp.Distributor_6__c != null)
                s_Distributor_6_otm.add(opp.Distributor_6__c);

            if (opp.partner__c != null)
                s_Partner_otm.add(opp.partner__c);

            if (opp.Service_Provider_Client__c != null)
                s_serviceProviderClient_otm.add(opp.Service_Provider_Client__c);

            if ((opp.AccountId != null) ||
                (opp.Reseller__c != null) ||
                (opp.Partner_1__c != null) ||
                (opp.Alliance_Partner_2__c != null) ||
                (opp.Distributor_6__c != null) ||
                (opp.partner__c != null) ||
                (opp.Service_Provider_Client__c != null)
            ) {
                s_oppidsforotm.add(opp.id); //lst of all opps where sales team needs to be added 
            }
            //Sales Team from Account Lookups -end

            System.debug('___999___' + (s_accountid_otm.size() + s_Distributor_6_otm.size() + s_Reseller_otm.size() + s_Alliance_Partner_2_otm.size() + s_Partner_1_otm.size() + s_Partner_otm.size() + s_serviceProviderClient_otm.size()));
            if ((s_accountid_otm.size() + s_Distributor_6_otm.size() + s_Reseller_otm.size() + s_Alliance_Partner_2_otm.size() + s_Partner_1_otm.size() + s_Partner_otm.size() + s_serviceProviderClient_otm.size()) > 0) //No processing if no relevant account id
            {
                System.debug('------*****************-----' + s_accountid_otm);

                Set < string > spmfkey_temp;
                mapAccountIdToPMFkey = new Map < id, List < TAQ_Account_Team_Approved__c >> ();
                //SOQL  - Get the TAQ Account Team records for all the Account lookups
                System.debug('------*****************-----' + s_serviceProviderClient_otm);
                System.debug('------*****************-----' + s_Distributor_6_otm);
                System.debug('------*****************-----' + s_Partner_1_otm);
                System.debug('------*****************-----' + s_Alliance_Partner_2_otm);
                System.debug('------*****************-----' + s_Partner_otm);
                System.debug('------*****************-----' + s_Reseller_otm);
                System.debug('------*****************-----' + m_accountlookup_taqrole);

                m_account = new Map < ID, Account > ([Select Solution_Provider__c, Velocity_Seller__c, Service_Provider__c, Alliance__c
                    from Account Where Id in : s_accountid_otm
                    or Id IN: s_Reseller_otm
                ]);

                System.debug('____11aa_Din partner opporutnity***** ___' + s_accountid_otm);
                List < TAQ_Account_Team_Approved__c > vvv = [select TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name, id, PMFKey__c, taq_Role__c, TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c from TAQ_Account_Team_Approved__c
                    where
                    TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in ('001Q000000YLswx')
                ];

                System.debug('____11aa_e in partner opporutnity***** ___' + vvv.size());

                for (TAQ_Account_Team_Approved__c atm: [select TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name, id, PMFKey__c, taq_Role__c, TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c from TAQ_Account_Team_Approved__c
                        where
                        TAQ_Account_Approved__r.TAQ_Account__c <> null AND
                        TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c <> null AND(
                            (
                                TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_accountid_otm AND(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name in ('SMB', 'Account Team Covered Account', 'Territory Covered Account') OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name = 'Reseller/Distributor Account'
                                    AND(
                                        (TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Service_Provider__c = True and TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Velocity_Seller__c = False AND Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('account_servprov'))) //Added Condition for Service Provider Partners
                                        OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Velocity_Seller__c = True AND TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Service_Provider__c = False AND Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Reseller_DM'))) //Added Condition for DM
                                        OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Service_Provider__c = True AND TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.Velocity_Seller__c = True and(Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('account_servprov')) OR Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Reseller_DM')))) //Added Condition for Hybrid DM, Serv Provider  
                                    ) //End of AND

                                ))
                            )

                            OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_serviceProviderClient_otm AND TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__r.RecordType.Name in ('SMB', 'Account Team Covered Account', 'Territory Covered Account')) OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_Distributor_6_otm AND Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Distributor_6'))) OR(
                                TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_Reseller_otm AND(
                                    Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Reseller')) or Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Reseller_DM'))
                                )
                            ) OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_Partner_1_otm AND Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Partner_1'))) OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_Alliance_Partner_2_otm AND Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Partner_1'))) OR(TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c in : s_Partner_otm AND Partner_Role__c INCLUDES(: m_accountlookup_taqrole.get('Partner')))
                        )
                        AND
                        TAQ_Account_Approved__r.Is_Latest_Record__c = true
                    ]) {
                    System.debug(atm.id + '____into this loop' + atm.pmfkey__c);
                    mapAccountIdtoPMFkey = getmapAccountIdtoPMFkey(atm, mapAccountIdtoPMFkey);
                    setpmf.add(atm.pmfkey__c.toUpperCase());
                }
                mPmfkeyToUserId = new Map < String, id > ();
            }
        }

    }


    public Map < id, List < TAQ_Account_Team_Approved__c >> getmapAccountIdtoPMFkey(TAQ_Account_Team_Approved__c atm, Map < id, List < TAQ_Account_Team_Approved__c >> mAccountToPMFkeyMatch) {
        List < TAQ_Account_Team_Approved__c > listPmfkey_temp = mapAccountIdtoPMFkey.get(atm.TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c);
        if (listPmfkey_temp == null) {
            listPmfkey_temp = new List < TAQ_Account_Team_Approved__c > ();
        }
        listPmfkey_temp.add(atm);
        mapAccountIdtoPMFkey.put(atm.TAQ_Account_Approved__r.TAQ_Account__r.View_Acc_Record__c, listPmfkey_temp);
        return mapAccountIdtoPMFkey;
    }

    public void addlistOpportunityTeamMemberfromTAQ(id oppid, id accountid, String role) {
        List < TAQ_Account_Team_Approved__c > listPmfkey_temp = mapAccountIdtoPMFkey.get(accountid);
        System.debug('PartnerOppertunity___xxx___' + mapAccountIdtoPMFkey);
        System.debug('____1 if____' + listPmfkey_temp);
        System.debug('____2 if____' + accountid);
        system.debug('>>>>>>>>____set' + setpmf);
        set < id > setuid = new set < id > ();
        if (setpmf.size() > 0) //Sales Team + Quote Request
        {
            //SOQL - Retrieve user id for the TAQ Account Team PMFkey   
            mUser = new Map < id, User > ([select id, name, pmfkey__c from user where pmfkey__c in : setpmf and pmfkey__c <> null and isActive = true]);
            for (user u: mUser.values())
                mPmfkeyToUserId.put(u.pmfkey__c.touppercase(), u.id);
        }
        if (listPmfkey_temp <> null && listPmfkey_temp.size() > 0) {
            for (TAQ_Account_Team_Approved__c taqatm: listPmfkey_temp) {
                System.debug('____for___');
                if (mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()) <> null) {
                    System.debug('___meth call');
                    
                    Opportunity Opp = (Opportunity) Trigger.newMap.get(oppid);
                    if (Opp.Reseller__c == accountid || Opp.Distributor_6__c == accountid) {
                        If((Opp.Type == 'ERWIN' && taqatm.taq_role__c == 'TAQ- PARTN DM') ||
                            ((opp.Type == '1 Tier' || opp.Type == '2 Tier' || opp.Type == 'Direct' || opp.Type == 'xSP' || opp.Type == 'Direct') && (taqatm.taq_role__c == 'TAQ-PARTN SOLPROV' || taqatm.taq_role__c == 'TAQ-PARTN SERVPROV' || taqatm.taq_role__c == 'TAQ-PARTN ALLIANCE')))
                        addOppTeamMember(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()), oppid, taqatm.taq_role__c);

                        Else
                        if (Opp.Type != 'ERWIN' && Opp.Type != '1 Tier' && Opp.Type != '2 Tier' && Opp.Type != 'Direct' && Opp.Type != 'xSP' && opp.Type != 'Direct')
                            addOppTeamMember(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()), oppid, taqatm.taq_role__c);
                    }
                    Else
                    addOppTeamMember(mPmfkeyToUserId.get(taqatm.pmfkey__c.toUpperCase()), oppid, taqatm.taq_role__c);

                }
            }
        }

    }

    system.debug('tempAccount.Id - > ' + UserInfo.getUserId());

    //AR 3159 and AR3157 by YEDRA01 

    List < id > OppAccIds = new List < id > ();
    List < account > accList = new List < account > ();
    set < id > oppids = new set < id > ();
    Map < id, account > idAccountMap = new Map < id, account > ();
    for (opportunity opp: trigger.new) {
        OppAccIds.add(opp.accountId);
        if (trigger.isupdate)
            oppids.add(opp.id);
    }
    if (OppAccIds != null && OppAccIds.size() > 0) accList = [select id, Sales_Area__c, Region_Country__c from account where id in : OppAccIds];
    for (Account acc: accList) {
        idAccountMap.put(acc.id, acc);
    }
    map < id, Integer > PERcount = new map < id, Integer > ();
    for (Partner_Engagement_Program__c per: [select id, Parent_Opportunity__c from Partner_Engagement_Program__c where Parent_Opportunity__c in : oppids limit 50000])
        if (PERcount.get(per.Parent_Opportunity__c) != null) {
            integer cou = 0;
            cou = PERcount.get(per.Parent_Opportunity__c) + 1;
            PERcount.put(per.Parent_Opportunity__c, cou);
        } else {
            PERcount.put(per.Parent_Opportunity__c, 1);
        }
    if ((trigger.isbefore && trigger.isinsert) || (trigger.isafter && trigger.isupdate))
        for (opportunity opp: Trigger.new) {
            system.debug('got');
            if (currentUser.UserType != 'PowerPartner' && !currentUser.IsPortalEnabled) {
                if (trigger.isinsert) {
                    if (idAccountMap != null && idAccountMap.get(opp.AccountId) != null && (idAccountMap.get(opp.AccountId).Sales_Area__c != 'E&A') && (idAccountMap.get(opp.AccountId).Region_Country__c != 'ISRAEL') && opp.Opportunity_Type__c != 'Renewal') {
                        system.debug('opportunity values :' + opp);
                        system.debug('got it' + opp.Partner_Engagement__c);
                        if ((opp.type == 'Direct' || opp.type == '1 tier' || opp.type == '2 tier') && opp.Partner_Engagement__c != null && opp.Partner_Engagement__c != '' && opp.Partner_Engagement__c != 'None') {
                            opp.adderror('For 1 Tier and 2 Tier Opportunities, the Partner engagement cannot be changed. Please create a Partner Engagement request');
                            system.debug('got' + opp.Partner_Engagement__c);
                        }

                        if ((opp.type == '1 tier' || opp.type == '2 tier') && !opp.SkipPERValidation__c && (opp.account.Sales_Area__c != 'E&A') && (opp.account.Region_Country__c != 'ISRAEL')) {
                            opp.adderror('For 1 Tier and 2 Tier Transactions :The Partner must create  the Opportunity from the Partner Portal.<br/> If this is a Collaborative or Fulfillment Opportunity  then it  must be created as Direct with Partner Engagement Request.', false);
                        }
                    }
                }
                if (trigger.isupdate) {
                    if (idAccountMap != null && idAccountMap.get(opp.AccountId) != null && (idAccountMap.get(opp.AccountId).Sales_Area__c != 'E&A') && (idAccountMap.get(opp.AccountId).Region_Country__c != 'ISRAEL') && opp.Opportunity_Type__c != 'Renewal') {
                        system.debug('opportunity values :' + opp);
                        date d = Date.newInstance(2015, 7, 11);
                        System.debug(opp.createddate + '@@' + d);
                        if (opp.createddate > d)
                            system.debug('creted later');
                        else
                            system.debug('creted Before');
                        if (PERcount.get(opp.id) != null && PERcount.get(opp.id) > 0) {
                            if ((opp.type == 'Direct' || opp.type == '1 Tier' || opp.type == '2 Tier') && (opp.Partner_Engagement__c == 'Collaborative' || opp.Partner_Engagement__c == 'Fulfillment-Only' || opp.Partner_Engagement__c == 'Pending') && (opp.Reseller__c != trigger.oldmap.get(opp.id).Reseller__c || opp.Reseller_Contact__c != trigger.oldmap.get(opp.id).Reseller_Contact__c) && !opp.SkipPERValidation__c)
                                opp.adderror('Partner & Partner Contact cannot be modified when a Partner Engagement is Pending or Approved .');
                            if ((opp.type == 'Direct' || opp.type == '1 Tier' || opp.type == '2 Tier') && (opp.Partner_Engagement__c == 'Collaborative' || opp.Partner_Engagement__c == 'Fulfillment-Only' || opp.Partner_Engagement__c == 'Pending') && (opp.Distributor_6__c != trigger.oldmap.get(opp.id).Distributor_6__c || opp.Distributor_Contact__c != trigger.oldmap.get(opp.id).Distributor_Contact__c) && !opp.SkipPERValidation__c)
                                opp.adderror('Distributor & Distributor Contact cannot be modified when a Partner Engagement is Pending or Approved.');

                            if (opp.Partner_Engagement__c != trigger.oldmap.get(opp.id).Partner_Engagement__c && (opp.type == '1 tier' || opp.type == '2 tier' || opp.type == 'Direct') && !opp.SkipPERValidation__c)
                                opp.adderror('Partner Engagement cannot be modified. A Partner Engagement request is already pending approval or approved.');

                            if (opp.type != trigger.oldmap.get(opp.id).type && (trigger.oldmap.get(opp.id).type == 'Direct') && (opp.type == '1 tier' || opp.type == '2 tier') && !opp.SkipPERValidation__c && opp.Partner_Engagement__c == null)
                                opp.adderror('Transaction Type cannot be changed from direct to 1 tier or 2 tier. Please create a Partner Engagement request');
                            //system.debug('trigger.oldmap.get(opp.id).type+opp.type'+trigger.oldmap.get(opp.id).type+' '+opp.type+' '+opp.SkipPERValidation__c    );


                            if (opp.type != trigger.oldmap.get(opp.id).type && (trigger.oldmap.get(opp.id).type == 'Direct') && (opp.type == '1 tier' || opp.type == '2 tier') && !opp.SkipPERValidation__c && opp.Partner_Engagement__c != null)
                                opp.adderror('Transaction Type cannot be changed.Partner Engagement Request already Approved or Pending approval.');

                            else if (opp.type != trigger.oldmap.get(opp.id).type && ((trigger.oldmap.get(opp.id).type == '1 tier' || trigger.oldmap.get(opp.id).type == '2 tier')) && !opp.SkipPERValidation__c)
                                opp.adderror('The Transaction Type cannot be modified. A Partner Engagement Request is already Approved or Pending Approval.');
                            else if (opp.type != trigger.oldmap.get(opp.id).type && (trigger.oldmap.get(opp.id).type == '1 tier' && opp.type == '2 tier') && !opp.SkipPERValidation__c)
                                opp.adderror('The Transaction Type cannot be modified. A Partner Engagement Request is already Approved or Pending Approval.');
                            else if (opp.type != trigger.oldmap.get(opp.id).type && (trigger.oldmap.get(opp.id).type == '2 tier' && opp.type == '1 tier') && !opp.SkipPERValidation__c)
                                opp.adderror('The Transaction Type cannot be modified. A Partner Engagement Request is already Approved or Pending Approval.');
                            else if (opp.type != trigger.oldmap.get(opp.id).type && (opp.type == '1 tier' || opp.type == '2 tier') && !opp.SkipPERValidation__c)
                                opp.addError('For 1 Tier and 2 Tier Transactions :The Partner must create  the Opportunity from the Partner Portal.<br/> If this is a Collaborative or Fulfillment Opportunity  then it  must be created as Direct with Partner Engagement Request.', false);

                        } else if (opp.type != trigger.oldmap.get(opp.id).type && (opp.type == '1 tier' || opp.type == '2 tier') && !opp.SkipPERValidation__c && opp.createddate > d)
                            opp.addError('For 1 Tier and 2 Tier Transactions :The Partner must create  the Opportunity from the Partner Portal.<br/> If this is a Collaborative or Fulfillment Opportunity  then it  must be created as Direct with Partner Engagement Request.', false);
                        else if (opp.type != trigger.oldmap.get(opp.id).type && (opp.type == '1 tier' || opp.type == '2 tier') && trigger.oldmap.get(opp.id).type == 'Direct' && !opp.SkipPERValidation__c && opp.createddate < d)
                            opp.addError('For 1 Tier and 2 Tier Transactions :The Partner must create  the Opportunity from the Partner Portal.<br/> If this is a Collaborative or Fulfillment Opportunity  then it  must be created as Direct with Partner Engagement Request.', false);

                    }

                }
            }
        }

    //Added for AR : 3729
    if ((trigger.isbefore) && (trigger.isupdate) && !Opportunity_ContactRole_Class.userIsBypass) {

        /*Moved code from Opportunity_ContactRole trigger to reduce number of queries. Inactivated the Trigger*/
        if (Trigger.isInsert) {
            for (Opportunity o: Trigger.new)
                Opportunity_ContactRole_Class.insertedOpps.add(o.Id);

            System.debug('+1 ' + Opportunity_ContactRole_Class.insertedOpps);
        } else {
            Integer fyMonth = Opportunity_ContactRole_Class.fymonth;
            Integer fyYear = System.today().year();


            Set < Id > updatedOpps = new Set < Id > ();
            for (Opportunity o: Trigger.new) {
                if (o.createddate == o.lastmodifieddate) return;
                Integer closemonth = o.closedate.month();
                Integer closeyear = o.closedate.year();
                if ((o.Probability >= 20 && o.Probability != 100) || (o.Probability == 100 && ((closemonth >= fymonth && closeyear == fyyear) || (closemonth < fymonth && closeyear == fyyear + 1))) && !Opportunity_ContactRole_Class.insertedOpps.contains(o.Id))
                    updatedOpps.add(o.Id);
            }
            System.debug('upadted opps valid: ' + updatedOpps);

            if (!updatedOpps.isEmpty()) {
                Set < Id > oppsWithPrimaryContact = new Set < Id > ();
                for (OpportunityContactRole ocr: [SELECT OpportunityId
                        FROM OpportunityContactRole
                        WHERE IsPrimary = true
                        AND OpportunityId In: updatedOpps
                    ]) {
                    oppsWithPrimaryContact.add(ocr.OpportunityId);
                    System.debug('Ocr Opp Id: ' + ocr.OpportunityId);
                }

                for (Opportunity o: Trigger.new) {
                    Integer closemonth = o.closedate.month();
                    Integer closeyear = o.closedate.year();
                    System.debug('oppsWithPrimaryContact : ' + oppsWithPrimaryContact);
                    if ((o.Probability >= 20 && o.Probability != 100) || (o.Probability == 100 && ((closemonth >= fymonth && closeyear == fyyear) || (closemonth < fymonth && closeyear == fyyear + 1))) && !Opportunity_ContactRole_Class.insertedOpps.contains(o.Id)) {
                        if (!oppsWithPrimaryContact.contains(o.Id)) {
                            if (currentUser.UserType != 'PowerPartner' && !currentUser.IsPortalEnabled) {
                                System.debug('Opp checking with ' + o.Id);
                                o.addError('No Primary Contact Exists. Please go to the Contact Role and select a primary contact');
                            }

                        }
                    }
                }

                System.debug('+2 ' + Opportunity_ContactRole_Class.insertedOpps);
            }
        }
    }
      
}