public  class OppLineItemRemoteActions_PRM{
    
    public OppLineItemRemoteActions_PRM(ApexPages.Standardcontroller stdcontroller){}
    
    @RemoteAction
    public static boolean noPgmExists(String opportunityId){
        boolean noPgm = true;
        for(OpportunityLineItem oli : [select id,OpportunityId,Deal_Program_Eligibility_Status__c,Product2.Name,Deal_Registration__c from OpportunityLineItem where OpportunityId =:opportunityId]){
            if(oli.Deal_Registration__c == 'Yes'){
                noPgm = false;
                break;
            }
        }
        return noPgm;
    }
    
    @RemoteAction
    public static List<String> fetchSepPgmProdList(String opportunityId){
        List<String> sepPgmProdList = new List<String>();
        for(OpportunityLineItem oli : [select id,OpportunityId,Deal_Program_Eligibility_Status__c,Product2.Name from OpportunityLineItem where OpportunityId =:opportunityId]){
            if(oli.Deal_Program_Eligibility_Status__c == 'Separate Program'){   
                sepPgmProdList.add(oli.Product2.Name);
            }
        }
        return sepPgmProdList;    
    }
    
    @RemoteAction
    public static boolean checkBeforeReturn(List<OpportunityLineitem> lstoppoli, List<OppLineItemcontroller_PRM.ProductWrapper> selectedProducts, List<OppLineItemcontroller_PRM.ProductWrapper> searchresults){
        System.debug('lstoppoli'+lstoppoli+'selectedProducts'+selectedProducts+'searchresults'+searchresults);
        for(OpportunityLineitem dbOppLineItem : lstoppoli)
            for(OppLineItemcontroller_PRM.ProductWrapper pw : selectedProducts)
                if(pw.oppline.Id == dbOppLineItem.Id && (pw.BusinessType != dbOppLineItem.Business_Type__c || pw.oppline.Term_Month__c  != dbOppLineItem.Term_Month__c || pw.oppline.UnitPrice != dbOppLineItem.UnitPrice))
                    return true;
        return false;
    }
    
    @RemoteAction
    public static void executeOptoutFunc(String opportunityId){
        List<OpportunityLineItem> updateOppLineItemWithStatus = new List<OpportunityLineItem>();
        try{
            for(OpportunityLineItem oli : [select id,OpportunityId,Deal_Program_Eligibility_Status__c,Product2.Name from OpportunityLineItem where OpportunityId =:opportunityId]){
                if(oli.Deal_Program_Eligibility_Status__c == 'Separate Program'){               
                    oli.Deal_Program_Eligibility_Status__c = 'Opt Out';                
                    updateOppLineItemWithStatus.add(oli);
                }
             }
            update updateOppLineItemWithStatus;             
        }
        catch(Exception e){
            System.debug('Exception :'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));           
        }
    }
    
    @RemoteAction
    public static String updateRecordTypetoNewOpp(String opportunityId){
        try 
          {
            Opportunity opp = [select id,Deal_Expiration_Date__c,RecordTypeId from Opportunity where id = :opportunityId];
            Id newOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Opportunity').getRecordTypeId();
            opp.RecordTypeId = newOppRecordTypeId;
            opp.Deal_Registration_Status__c='';
            opp.First_Approver__c = null;
            opp.Deal_Expiration_Date__c = null;
            opp.StageName = '10% - Identification & Qualification';
            //opp.Initiated_By__c = '';
            opp.Source__c = 'Partner';  
            update opp;
          }
          catch(DMLException e){
            System.debug('DMLException :'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));           
            System.debug('Error message:'+e.getDmlMessage(0));
            string errorMsg = e.getDmlMessage(0);
            return errorMsg;
          }
          catch(Exception e1){
          	System.debug('Exception :'+e1.getMessage());
          	return e1.getMessage();
          }
          return 'true';
    }
    
    @RemoteAction
    public static String updateRecordTypetoDealReg(String opportunityId){
          try 
          {   
            list<string> allProgsWithRank = new list<string>();
            set<string> allProgramsNumber = new set<string>();
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            Map<ID, Set<String>> oliProgNumberMap = new Map<ID, Set<String>>();
            Map<ID, Set<String>> oliProgNameMap = new Map<ID, Set<String>>();
            List<Messaging.SingleEmailMessage> email = new List<Messaging.SingleEmailMessage>();
              Opportunity opp = [select id,name,AccountId,RecordTypeId,Deal_Registration_Status__c,RecordType.Name,Deal_Registration_Program__c,Deal_Expiration_Date__c,Deal_Registration_Submitted_Date__c,
                                    Distributor_6__c,StageName,Initiated_By__c,Source__c,Partner_Engagement__c,Finance_Email__c,First_Approver__c,Type,Reseller__c,OwnerId
                                    from Opportunity where id = :opportunityId];
              oliList=[select id,OpportunityId,Deal_Program_ID__c,name,Deal_Program_Eligibility_Status__c,Product_Group__C,Product2.Name from OpportunityLineItem where OpportunityId =:opportunityId];
              Id dealRegRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
              System.debug('***opp:'+opp);
              opp.RecordTypeId = dealRegRecordTypeId;
              opp.Deal_Registration_Status__c='New';
              opp.StageName = 'Deal Reg - New';
              opp.Initiated_By__c = 'Partner';
              opp.Source__c = 'Deal Registration';
              opp.Partner_Engagement__c = 'Incremental';
              
              Deal_Registration_Program__c dealProgram = [SELECT Id,Program_Manager__r.Email, Finance_Approver_Email__c,Name, Program_Manager__c,Partner_Friendly_Name__c,End_Date__c, 
																	   Opp_Type__c,
                                                                       First_Approver__c,Deal_Program_Number__c,Expiry_Days__c FROM Deal_Registration_Program__c 
                                                                       WHERE Id= :opp.Deal_Registration_Program__c LIMIT 1];//,Opp_Type__c 3270
              DateTime  createdDate = Date.today();
              Opp.Deal_Registration_Submitted_Date__c = date.newInstance(createdDate.year(),createdDate.month(),createdDate.day());
              if(dealProgram.Expiry_Days__c <> null){
                    if(opp.Deal_Registration_Submitted_Date__c.addDays(Integer.valueOf(dealProgram.Expiry_Days__c)) < dealProgram.End_Date__c) {
                        opp.Deal_Expiration_Date__c = Opp.Deal_Registration_Submitted_Date__c.addDays(Integer.valueOf(dealProgram.Expiry_Days__c));
                    }
                    else {
                    	Opp.Deal_Expiration_Date__c = dealProgram.End_Date__c;
              		} 
              }
                                                                  
              
              if(dealProgram.Finance_Approver_Email__c != null) {
                opp.Finance_Email__c = dealProgram.Finance_Approver_Email__c;
              }
              
              //TODO: recheck  this logic based on mapping of behalfofPartner to Reseller/Distributor
              Account reseller = [select Geo__c from Account where Id =:Opp.Reseller__c];
              List<Deal_Reg_Approvers__c> DRAs = [Select Id, Approver__c from Deal_Reg_Approvers__c where Deal_Registration_Program__c = :dealProgram.Id and Region__c =:reseller.Geo__c];
              if(DRAs != null && DRAs.size() > 0){
                opp.First_Approver__c =  DRAs[0].Approver__c;
              }
              
              String solutionProviderCamPmfKey;
              String velocitySellerCamPmfKey;
              User currentUser = [Select UserType, IsPortalEnabled, AccountId, ContactId, DefaultCurrencyIsoCode From User WHERE Id = :UserInfo.getUserId() LIMIT 1];
              Account userAccount = [Select Customer_Category__c, Name, Alliance__c,Velocity_Seller__c,Solution_Provider__c,Service_Provider__c, 
                                      GEO__c, Region_Country__c, Velocity_Seller_Program_Level__c,Velocity_Seller_Type__c,Alliance_Program_Level__c,
                                      Alliance_Type__c,Service_Provider_Program_level__c,Service_Provider_Type__c,Solution_Provider_Program_Level__c,
                                      Solution_Provider_Type__c,Velocity_Seller_CAM_PMFKey__c,Solution_Provider_CAM_PMFKey__c
                                      From Account where Id = :currentUser.AccountId];
               
              solutionProviderCamPmfKey = userAccount.Solution_Provider_CAM_PMFKey__c;
              velocitySellerCamPmfKey = userAccount.Velocity_Seller_CAM_PMFKey__c;
              
                        
              Account resellerAccount = null;
              String resellervelocitySellerCamPmfKey;
              boolean ispartnerbehalf = false;
              
              
              if( (opp.Type =='2 Tier') || (opp.Type =='Erwin') && opp.What_is_your_Role__c == 'Distributor') { 
                    ispartnerbehalf = true; 
                    resellerAccount = [select Customer_Category__c, Name,Enterprise_ID__c, Alliance__c,Velocity_Seller__c,Solution_Provider__c,Service_Provider__c, 
                                          GEO__c, Region_Country__c, Velocity_Seller_Program_Level__c,Velocity_Seller_Type__c,Alliance_Program_Level__c,
                                          Alliance_Type__c,Service_Provider_Program_level__c,Service_Provider_Type__c,Solution_Provider_Program_Level__c,
                                          Solution_Provider_Type__c,Velocity_Seller_CAM_PMFKey__c,Solution_Provider_CAM_PMFKey__c
                                          From Account where Id = :opp.Reseller__c];
                    resellervelocitySellerCamPmfKey = resellerAccount.Velocity_Seller_CAM_PMFKey__c;
              }
              
              if(dealProgram.Opp_Type__c.contains('DM')) {
                    User userObj = null;
                    if(velocitySellerCamPmfKey != null && velocitySellerCamPmfKey != '') {
                          try {
                            if(ispartnerbehalf && (resellervelocitySellerCamPmfKey <> null && resellervelocitySellerCamPmfKey <> ''))
                                userObj = [select Id from User where PMFKey__c = :resellervelocitySellerCamPmfKey and isActive = true LIMIT 1];
                            else    
                                userObj = [select Id from User where PMFKey__c = :velocitySellerCamPmfKey and isActive = true LIMIT 1];
                          }
                          catch(Exception e) {}
                    }               
                    if(userObj != null) {               
                            opp.OwnerId = userObj.Id;
                    } 
                    else {
                        if(dealProgram.First_Approver__c <> null) 
                            opp.OwnerId = dealProgram.First_Approver__c;                             
                    }
              }
              else {
                    Account endUserAccountObj = [select RecordTypeId,Segment__c,OwnerId from Account where Id = :opp.AccountId LIMIT 1];
                    if(endUserAccountObj.RecordTypeId == SystemIdUtility.getAccountTeamAcctRecordTypeId())
                    {
                        if(endUserAccountObj.OwnerId != null) {
                            opp.OwnerId = endUserAccountObj.OwnerId;
                        }
                        else {
                            opp.OwnerId = dealProgram.First_Approver__c;
                        }
                    }
                    else if(endUserAccountObj.RecordTypeId == SystemIdUtility.getTerritoryAcctRecordTypeId() || endUserAccountObj.RecordTypeId == SystemIdUtility.getSMBAcctRecordTypeId())
                    {
                        User userObj = null;
                        if(solutionProviderCamPmfKey != null && solutionProviderCamPmfKey != '') {
                            try {
                                userObj = [Select Id from User where PMFKey__c = :solutionProviderCamPmfKey and isActive = true LIMIT 1];
                            }
                            catch(Exception e){}
                        }
                        if(userObj != null) {
                            opp.OwnerId = userObj.Id;
                        }
                        else{
                            opp.OwnerId = dealProgram.First_Approver__c;
                        }
                    }
              }
              
              //Added to give read/Write to owner
               List<OpportunityShare> lstOS=new List<OpportunityShare>();
               OpportunityShare os =new OpportunityShare ();
                      os.OpportunityId=opp.Id ;
                      os.UserOrGroupId=opp.Ownerid;
                      os.OpportunityAccessLevel='edit';
                      lstOS.add(os);
                if(lstOS.size() > 0) //Common for All Opp Team additions
                {       Database.saveResult[] MySaveResult1 = Database.insert(lstOS,false);
                    
                     for (integer i=0; i < MySaveResult1.size(); i++) {
                                     database.saveResult sr1 = MySaveResult1[i];
                         System.debug('____sr1____in partner opporutnity class***** '+sr1);
                      }                                        
                         lstOS = new List<OpportunityShare>();
                }
             /* 
              //Added for removing team members 
            system.debug('block number 7 delete oppteammember');
            OpportunityTeamMember DeleteOppTeamMember = [ SELECT id, UserId FROM OpportunityTeamMember 
                                                                        WHERE OpportunityId = : opportunityId AND TeamMemberRole = 'Channel Account Manager' limit 1 ] ;
                                                                                
            if( DeleteOppTeamMember != null ){
            
                try{
                system.debug('block number 7 delete execute');
                    Database.Delete( DeleteOppTeamMember );
                    
                }catch( DMLException ex ){
                    trigger.new[0].adderror(ex);
                    system.debug('*** OpportunityLineItemGateway ***: Exception while deleting Opp Sales Teams --> '+ex );
        
                }
                
            } */
            
            //Ar 3333 : this part gets program details for all the multiprogram products and adds that to email 
            for(OpportunityLineItem oli : oliList){
                if(oli.Deal_Program_ID__c != null && String.ValueOf(oli.Deal_Program_ID__c).contains(';')){ 
                    allProgsWithRank = string.valueOf(oli.Deal_Program_ID__c).split(';');
                    for(string prgName:allProgsWithRank){
                         string PrgNumber = prgName.substring(0,8);
                         allProgramsNumber.add(PrgNumber);
                       if(oliProgNumberMap.get(oli.id)!=null){
                         set<string> allProgsNumber=new set<string>();
                         allProgsNumber=oliProgNumberMap.get(oli.id);
                         allProgsNumber.add(PrgNumber);
                         oliProgNumberMap.put(oli.id,allProgsNumber);
                       }
                       else
                       {
                         set<string> allProgsNumber=new set<string>();
                         allProgsNumber.add(PrgNumber);
                         oliProgNumberMap.put(oli.id,allProgsNumber);
                       }
                        
                    }
                
                }
            }
            
            List<Deal_Registration_Program__c> dealPrograms = [SELECT Id,
																	   opp_type__c,
																	   Program_Manager__r.Email, Finance_Approver_Email__c,Name, Program_Manager__c,Partner_Friendly_Name__c,End_Date__c, 
                                                                       First_Approver__c,Deal_Program_Number__c,Expiry_Days__c FROM Deal_Registration_Program__c 
                                                                       WHERE Deal_Program_Number__c in :allProgramsNumber];
            //populating name map
            for(OpportunityLineItem oli : oliList){
              for(Deal_Registration_Program__c dealPgrm : dealPrograms){
                if(oli.Deal_Program_ID__c != null && String.ValueOf(oli.Deal_Program_ID__c).contains(';')){ 
                  if(oliProgNumberMap.get(oli.id).contains(dealPgrm.Deal_Program_Number__c)){
                    if(oliProgNameMap.get(oli.id)!=null){
                         set<string> allProgsName=new set<string>();
                         allProgsName=oliProgNameMap.get(oli.id);
                         allProgsName.add(dealPgrm.name);
                         oliProgNameMap.put(oli.id,allProgsName);
                       }
                       else
                       {
                         set<string> allProgsName=new set<string>();
                         allProgsName.add(dealPgrm.name);
                         oliProgNameMap.put(oli.id,allProgsName);
                       }
                  }
                }
              }
            }   
            
            String groupName = label.MultiProgResolvers_PRM_ID;
            List<User> results =[select Name, Email from User where id in ( Select UserOrGroupId From GroupMember Where GroupId =:label.MultiProgResolvers_PRM_ID)];
            String accId='';
            if(Opp.Type == '2 Tier' && Opp.Distributor_6__c != null ){
                accId = Opp.Distributor_6__c;
            }        
            else if((Opp.Type=='2 Tier' || Opp.Type=='Erwin' )&& (Opp.What_is_your_Role__c=='Reseller')&& (opp.Reseller__c <> null && opp.Reseller__c <> '') )
                accId = Opp.Reseller__c;
            else{
                accId = currentUser.AccountId;
            }
            Account eligibleAccount = [Select id,Enterprise_ID__c,Name from Account where id=:accId];
                
            for(OpportunityLineItem oli : oliList){
                if(oli.Deal_Program_ID__c != null && String.ValueOf(oli.Deal_Program_ID__c).contains(';')){ 
                  List<string> toEmailAddresses = new List<String>(); 
                  for(User usr:results){
                      toEmailAddresses.add(usr.Email);
                  }            
                    //call email template and sende email block here.
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setReplyTo('donotreply@salesforce.com'); 
                    mail.setSenderDisplayName('Salesforce Support');
                    mail.setToAddresses(toEmailAddresses);
                    mail.setSubject('Please Action: Multiple Active Programs for the same Product');
                    //mail.setHtmlBody('Hi,' + '<br/><br/>' + 'During verification of Opportunity Products for the '+ '<b>' + eligibleAccount.Enterprise_ID__c + '-'+ eligibleAccount.Name + ' </b> the application encountered more than one active Deal Registration Program for the Product, <b>'+ oli.Product2.Name + '</b> of the Product Group <b>' + oli.Product_Group__C +'</b> </b></b>Deal Program Numbers : '+ oliProgNumberMap.get(oli.id) +'</b></b></b> and Deal Program Names : '+ oliProgNameMap.get(oli.id)+'.');
                    mail.setHtmlBody('Hi,' + '<br/><br/>' + 'During verification of the Products line Items for <b>'+opp.name+'</b><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/partner/'+opp.id+'">(click here)</a> the application encountered more than one active Deal Registration Program '+ oliProgNameMap.get(oli.id)+' for <b>'+ oli.Product2.Name+'</b>.<br/><br/><br/>Please take the action to update the Deal Registration Programs accordingly to ensure the same product is not eligible on multiple programs.<br/><br/>Thanks');
                    mail.setBccSender(false);
                    email.add(mail);
                }
             }           
             try {
                    Messaging.sendEmail(email);       
             }
             catch(EmailException ex)
             {
                System.debug('########### Email not Sent-'+ex);
             }
             update opp;            
          }
          catch(DMLException e){
            System.debug('DMLException :'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));           
            System.debug('Error message:'+e.getDmlMessage(0));
            string errorMsg = e.getDmlMessage(0);
            return errorMsg;
          }
          catch(Exception e1){
          	System.debug('Exception :'+e1.getMessage());
          	return e1.getMessage();
          } 
          
          return 'true';
          
    } // end of updateRecordType method
    
    @RemoteAction
    public static void sendEmailForMultiplePrograms(String opportunityId){
        
        try{
            list<string> allProgsWithRank = new list<string>();
            set<string> allProgramsNumber = new set<string>();
            //list<string> allProgsName = new list<string>();
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            Map<ID, Set<String>> oliProgNumberMap = new Map<ID, Set<String>>();
            Map<ID, Set<String>> oliProgNameMap = new Map<ID, Set<String>>();
            List<Messaging.SingleEmailMessage> email = new List<Messaging.SingleEmailMessage>();
            oliList=[select id,OpportunityId,Deal_Program_ID__c,name,Deal_Program_Eligibility_Status__c,Product_Group__C,Product2.Name from OpportunityLineItem where OpportunityId =:opportunityId];
            
            for(OpportunityLineItem oli : oliList){
                if(oli.Deal_Program_ID__c != null && String.ValueOf(oli.Deal_Program_ID__c).contains(';')){ 
                    allProgsWithRank = string.valueOf(oli.Deal_Program_ID__c).split(';');
                    //allProgramsNumber = new list<string>();
                    for(string prgName:allProgsWithRank){
                         string PrgNumber = prgName.substring(0,8);
                         allProgramsNumber.add(PrgNumber);
                       if(oliProgNumberMap.get(oli.id)!=null){
                         set<string> allProgsNumber=new set<string>();
                         allProgsNumber=oliProgNumberMap.get(oli.id);
                         allProgsNumber.add(PrgNumber);
                         oliProgNumberMap.put(oli.id,allProgsNumber);
                       }
                       else
                       {
                         set<string> allProgsNumber=new set<string>();
                         allProgsNumber.add(PrgNumber);
                         oliProgNumberMap.put(oli.id,allProgsNumber);
                       }
                    }
                }
            }
            List<Deal_Registration_Program__c> dealPrograms = [SELECT Id,
																		opp_type__c,
																		Program_Manager__r.Email, Finance_Approver_Email__c,Name, Program_Manager__c,Partner_Friendly_Name__c,End_Date__c, 
                                                                       First_Approver__c,Deal_Program_Number__c,Expiry_Days__c FROM Deal_Registration_Program__c 
                                                                       WHERE Deal_Program_Number__c in :allProgramsNumber];
            
            //populating name map
            for(OpportunityLineItem oli : oliList){
              for(Deal_Registration_Program__c dealPgrm : dealPrograms){
                if(oli.Deal_Program_ID__c != null && String.ValueOf(oli.Deal_Program_ID__c).contains(';')){ 
                  if(oliProgNumberMap.get(oli.id).contains(dealPgrm.Deal_Program_Number__c)){
                    if(oliProgNameMap.get(oli.id)!=null){
                         set<string> allProgsName=new set<string>();
                         allProgsName=oliProgNameMap.get(oli.id);
                         allProgsName.add(oli.name);
                         oliProgNameMap.put(oli.id,allProgsName);
                       }
                       else
                       {
                         set<string> allProgsName=new set<string>();
                         allProgsName.add(oli.name);
                         oliProgNameMap.put(oli.id,allProgsName);
                       }
                    }
                  }
                }
            }                                                                      
           //Ask if there will be more than 10 email invocations for this or else implement one mail list for all Not Eligible programs and Change the langause for the mail being sent.
            Opportunity opp = [select id,name,RecordTypeId,RecordType.Name,Deal_Registration_Program__c,Deal_Expiration_Date__c,Deal_Registration_Submitted_Date__c,Distributor_6__c,
                                    StageName,What_is_your_Role__c,Initiated_By__c,Source__c,Partner_Engagement__c,Finance_Email__c,First_Approver__c,Type,Reseller__c,OwnerId
                                    from Opportunity where id = :opportunityId];
            if(opp.RecordType.Name == 'Deal Registration'){
                 Deal_Registration_Program__c dealProgram = [SELECT Id,
																			opp_type__c,
																			Program_Manager__r.Email, Finance_Approver_Email__c,Name, Program_Manager__c,Partner_Friendly_Name__c,End_Date__c, 
                                                                           First_Approver__c,Deal_Program_Number__c,Expiry_Days__c FROM Deal_Registration_Program__c 
                                                                           WHERE Id= :opp.Deal_Registration_Program__c LIMIT 1];//,Opp_Type__c 3270
                
                // User currentUser;
                 String accId='';
                 if(Opp.Type == '2 Tier' && Opp.Distributor_6__c != null ){
                    accId = Opp.Distributor_6__c;
                 }        
                 else if((Opp.Type=='2 Tier' || Opp.Type=='Erwin' )&& (Opp.What_is_your_Role__c=='Reseller')&& (opp.Reseller__c <> null && opp.Reseller__c <> '') )
                    accId = Opp.Reseller__c;
                 else{
                    User currentUser = [Select UserType, IsPortalEnabled, AccountId, ContactId, DefaultCurrencyIsoCode From User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                    accId = currentUser.AccountId;
                 }  
                 
                 Account eligibleAccount = [Select id,Enterprise_ID__c,Name from Account where id=:accId];
                 system.debug('eligibleAccount'+eligibleAccount);
                 String groupName = label.MultiProgResolvers_PRM_ID;
                 List<User> results =[select Name, Email from User where id in ( Select UserOrGroupId From GroupMember Where GroupId =:label.MultiProgResolvers_PRM_ID)];
                  
                 for(OpportunityLineItem oli : oliList){
                   if(oli.Deal_Program_ID__c != null &&  String.ValueOf(oli.Deal_Program_ID__c).contains(';')){ 
                         List<string> toEmailAddresses = new List<String>(); 
                         for(User usr:results){
                             toEmailAddresses.add(usr.Email);
                         }        
                        //call email template and send email block here.
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setReplyTo('donotreply@salesforce.com'); 
                        mail.setSenderDisplayName('Salesforce Support');
                        mail.setToAddresses(toEmailAddresses);
                        mail.setSubject('Please Action: Multiple Active Programs for the same Product');
                        //mail.setHtmlBody('Hi,' + '<br/><br/>' + 'During verification of Opportunity Products for the '+ '<b>' + eligibleAccount.Enterprise_ID__c + '-'+ eligibleAccount.Name + ' </b> the application encountered more than one active Deal Registration Program for the Product, <b>'+ oli.Product2.Name + '</b> of the Product Group <b>' + oli.Product_Group__C +'</b> </b></b>Deal Program Numbers : '+ oliProgNumberMap.get(oli.id) +'</b></b></b> and Deal Program Names : '+ oliProgNameMap.get(oli.id)+'.');
                        mail.setHtmlBody('Hi,' + '<br/><br/>' + 'During verification of the Products line Items for <b>'+opp.name+'</b><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/partner/'+opp.id+'">(click here)</a> the application encountered more than one active Deal Registration Program '+ oliProgNameMap.get(oli.id)+' for <b>'+ oli.Product2.Name+'</b>.<br/><br/><br/>Please take the action to update the Deal Registration Programs accordingly to ensure the same product is not eligible on multiple programs.<br/><br/>Thanks');
                        mail.setBccSender(false);
                        email.add(mail);                    
                    }
                 } 
                 if(email != null){
                    try
                    {
                        Messaging.sendEmail(email);       
                    }
                    catch(EmailException ex)
                    {
                        System.debug('########### Email not Sent-'+ex);
                    }
                }
            }               
        }
        catch(Exception e){
            System.debug('Exception :'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));                   
        }
    }   
    
}