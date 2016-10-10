public class OppLineitem_View_Edit_controller_PRM
    {
        public string salesPrice_usd {get;set;}
    // fy13    public string comfort_usd {get;set;}
        public string actiontitle {get;set;}
        public string actionsubtitle {get;set;}
        
        private String strOppLineID = '';
        private String ProdId = '';
        private OpportunityLineItem lineitemrecord;
        private Map<Id,Product2> prdmap;
        private String stroppid = '';
        private String strooppid = '';
        public boolean show_ondemand {get;set;}
        public OpportunityLineItem lineitemrec {get;set;}
        public Opportunity headerrec {get;set;}
        public Boolean isRenewal {get;set;}
        public Boolean isProduct {get;set;}
      
        public String prdfamily {get;set;}
        
        public Boolean isUF {get;set;}

         
        public String prdbu {get;set;}
        public String prdname {get;set;}
        public String replace_expirydate_label {get;set;}
        public Boolean isView {get;set;}
        public Boolean isEdit {get;set;}
        public Boolean isclosedlost {get;set;}
        public Boolean showreason {get;set;}
        public Boolean otherreason {get;set;}
         
        public Boolean isViewOfferings {get;set;}
        public Boolean isEditOfferings {get;set;}
        public Boolean isOffering {get;set;}
        public Boolean isServices {get;set;}
        public Boolean isEducation {get;set;}
        public Boolean isSupport {get;set;}
        
        public Boolean isCompetitorRequired {get;set;}
        public Boolean isWinLoss {get;set;}
        public Boolean isDeallostTo {get;set;}
        public List<SelectOption> selbustype {get;set;}
        public List<SelectOption> selcloudplatformuse {get;set;}
        public String bustype {get;set;}
        public String cloudplatformuse {get;set;}
        public Boolean showmilestone {get;set;}
        public Boolean isMainFrame {get;set;}

        public List<Active_Contract_Product__c>  ACPLineItems = new List<Active_Contract_Product__c>();      

        public List<SelectOption> cldplatformuse_entries = new List<SelectOption>();
        
        public Id oppId {get;set;}        // fy13
        public String oppName {get;set;}  // fy13

        public OppLineitem_View_Edit_controller_PRM(ApexPages.Standardcontroller stdcontroller)
        {
            stroppid = ApexPages.currentPage().getParameters().get('retURL');
            System.debug(stroppid);
            //incase returnurl is present, means its an edit
            if(stroppid !=null)
            {
                isEdit = true;
                isView = false; 
            }   
            else
            {
                isEdit = false;
                isView = true;
            }   
            //get lineitem id    
            strOppLineID = ApexPages.currentPage().getParameters().get('id');
            lineitemrecord = new OpportunityLineItem();
            //fetch the lineitem details
            lineitemrecord = [SELECT OpportunityId,Stretch__c,UF_License_Fee__c,X1st_Year_Maintenance__c,Business_Type__c,
                                     Quote_Number__c,Contract_Number__c,Quantity, ListPrice,
                                     PriceBookEntry.UnitPrice,Sales_Price_USD__c, PricebookEntry.Name,PricebookEntry.product2Id,Partner_Sales_Price__c,
                                     Partner_Term__c,   
                                     CurrencyISOCode 
                                FROM OpportunityLineItem 
                               where ID=:strOppLineID
                                 and Business_Type__c != 'Renewal' ];
            String prdid = lineitemrecord.PricebookEntry.product2Id;

            headerrec = new Opportunity(); // fy13
            headerrec = [select Id, Name, New_Deal_Term_months__c, Stretch_Deal_Term_Months__c, 
                                Stretch_Sales_Price_Gap_Reason__c
                           from Opportunity where Id =: lineitemrecord.OpportunityId]; // fy13
    //        oppId = opp.Id;      // fy13
    //        oppName = opp.Name;  // fy13


            salesPrice_usd = String.ValueOf(lineitemrecord.Sales_Price_USD__c);
                    //comfort_usd = String.ValueOf(lineitemrecord.comfort_USD__c);
            //get product details
            Product2 oppprd = [select Name,Family,Market_Focus_Area__c,Upfront_Revenue_Eligible__c from Product2 where Id =: prdid];
            prdfamily = oppprd.Family; 
            prdbu = oppprd.Market_Focus_Area__c;
            prdname = oppprd.Name;
                       
            strooppid =lineitemrecord.OpportunityId;
            if(stroppid!=null && stroppid.contains('/apex/'))
            {
                stroppid = '/'+lineitemrecord.OpportunityId;
                
            }
            //set all flags
            if(prdfamily.toLowerCase() == 'product')
            {
                actiontitle = 'Add/Edit Products';
                actionsubtitle = 'Product Details';
                replace_expirydate_label = 'Replace';
                isProduct = true;
                isRenewal = false;
                isOffering = false;
                showmilestone = false;
                isMainFrame = false;
               
                if(oppprd.Upfront_Revenue_Eligible__c == 'Yes') 
                {
                    isUF = true;               
                }            
            }
            else if(prdfamily.toLowerCase() == 'renewal' || prdfamily.tolowercase() == 'time' || prdfamily.tolowercase() == 'mainframe capacity')
            {
                actiontitle = 'Edit Renewing Products';
                actionsubtitle = 'Renewal Details';
                replace_expirydate_label = 'Original Expiration Date';
                isProduct = false;
                isRenewal = true;
                isOffering = false;
                showmilestone = false;
                isMainFrame = false;
            }
            else if(prdfamily.toLowerCase() == 'services' || prdfamily.toLowerCase() == 'education' || prdfamily.toLowerCase() == 'support')
            {
                actiontitle = 'Add/Edit Offerings';
                if(prdfamily.toLowerCase() == 'services')
                {
                    isServices = true;
                    isEducation = false;
                    isSupport = false;
                    showmilestone = true;
                    actionsubtitle = 'Services Details';
                }
                else if(prdfamily.toLowerCase() == 'education')
                {
                    isServices = false;
                    isEducation = true;
                    isSupport = false;
                    showmilestone = true;
                    actionsubtitle = 'Education Details';
                }
                else if(prdfamily.toLowerCase() == 'support')
                {
                    isServices = false;
                    isEducation = false;
                    isSupport = true;
                    showmilestone = false;
                    actionsubtitle = 'Support Details';
                }
                isProduct = false;
                isRenewal = false;
                isOffering = true;
                isEdit = false;
                isView = false;
                isMainFrame = false;
                if(stroppid !=null)
                {
                    isEditOfferings = true;
                    isViewOfferings = false;
                }
                else
                {
                    isEditOfferings = false;
                    isViewOfferings = true;
                }   
            }
            //Opportunity opp = [select CloseDate,StageName,Probability,ForecastCategory from Opportunity where Id =: lineitemrecord.OpportunityId];
            
            this.lineitemrec = (OpportunityLineItem)stdController.getRecord();  
            fetchbusinesstype();
            bustype = lineitemrecord.Business_Type__c; 
            
            //Anitha
            //Schema.DescribeFieldResult cloudplatformusevalues = OpportunityLineItem.Cloud_Platform_Use__c.getDescribe();
            //Schema.PicklistEntry[] entries_cldplatformuse_temp = cloudplatformusevalues.getPicklistValues();
            //for(Schema.PicklistEntry entry : entries_cldplatformuse_temp)
            //    cldplatformuse_entries.add(new SelectOption(entry.getLabel(),entry.getValue()));
            
            //selcloudplatformuse = new List<SelectOption>();
           // selcloudplatformuse.add(new SelectOption('--Select--','--Select--'));
            //for(SelectOption entry : cldplatformuse_entries)
             //   selcloudplatformuse.add(new SelectOption(entry.getvalue(), entry.getlabel()));
            //selcloudplatformuse  = lstoppoli[k].Cloud_Platform_Use__c;
            
            //cloudplatformuse = lineitemrecord.Cloud_Platform_Use__c; 
            //system.debug('_______'+cldplatformuse_entries);
            
            if(isproduct)
            {
            List<Products_for_On_Demand__c> lst_Ondemand = Products_for_On_Demand__c.getall().values();
            Set<string> set_ondemand = new Set<string>{};
            
            for(Products_for_On_Demand__c   pod:lst_Ondemand)
                set_ondemand.add(pod.product__c.toLowerCase());
            show_ondemand =   set_ondemand.contains(prdname.toLowerCase());
            
            }
            
            if(prdfamily.tolowercase() == 'mainframe capacity' && prdname.tolowercase()== 'mainframe capacity') 
             {                          
                  actiontitle = 'Add/Edit Mainframe Capacity';
                  actionsubtitle = 'Mainframe Capacity Details';
                  isProduct = false;                          
                  isRenewal = false;                          
                  isOffering = false;                          
                  showmilestone = false;                
                  isMainFrame = true;                
                               
              }
        }
        public void fetchbusinesstype()
        {
            selbustype = new List<SelectOption>();
            selbustype.add(new SelectOption('--Select--','--Select--'));
            
            Schema.DescribeFieldResult bustypevalues = OpportunityLineItem.Business_Type__c.getDescribe();
            for(Schema.PicklistEntry entry : bustypevalues.getPicklistValues())
            {
                //business type to be restricted to particular values for products and renewals
                if(prdfamily.toLowerCase() == 'renewal' || prdfamily.tolowercase() == 'time' || prdfamily.tolowercase() == 'mainframe capacity')
                {
                    if(entry.getValue() == 'Renewal' || entry.getValue() == 'Medium Touch' || entry.getValue() == 'Indirect Medium Touch')
                        selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
                }
                else if(prdfamily.toLowerCase() == 'product' || prdfamily.toLowerCase() == 'support')
                {
                    if(entry.getValue() == 'New' || entry.getValue() == 'Time' || entry.getValue() == 'Maintenance')
                        selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
                    
                    if(entry.getValue() == 'Capacity' || entry.getValue() == 'Upgrade' )
                    {
                        if(prdfamily.toLowerCase() == 'product')
                        {
                            if(prdbu.toLowerCase() != 'mainframe')
                                selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
                        }
                        else
                            selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
                    }       
                    
                }
            }
            
        }
        public PageReference updateproduct()
        {          

        //if all fields are not populated, display error message
            if(lineitemrec.Partner_Sales_Price__c!=null)
            {
                /*if(isOffering)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please complete the details.');
                    ApexPages.addMessage(msg);
                    return null;
                }*/
                if(bustype != '--Select--')
                    lineitemrec.Business_Type__c = bustype;
                else
                {
                    //lineitemrec.Business_Type__c = null;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please select the Business Type.');
                    ApexPages.addMessage(msg);
                    return null;
                }
               // if(cloudplatformuse != '--Select--')
                //    lineitemrec.Cloud_Platform_Use__c = cloudplatformuse;
                //else
                //{
                //    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please select the Cloud Platform.');
                 //   ApexPages.addMessage(msg);
                //    return null;
                //}    
                
                if(isMainframe){

                    // fy13 - BR165 - default stretch deal term if not specified
                    if(headerrec.Stretch_Deal_Term_Months__c == null || headerrec.Stretch_Deal_Term_Months__c == 0)
                        headerrec.Stretch_Deal_Term_Months__c = headerrec.New_Deal_Term_months__c;
                    }

                if(!isRenewal && ! isProduct ) //to exclude re-newals and products from this check
                 {                
                       //lineitemrec.Win_Loss_Reason__c = null;
                 }
                                
                //set Probability and Forecast category based upon SalesMilestone
                
                    //lineitemrec.Probability__c = 0;
                    //lineitemrec.Forecast_Category__c = 'Closed';
                
                try{
                   update lineitemrec;
                   
                   decimal salesPrice;
                    salesPrice = 0;
                   for(OpportunityLineItem opli : [SELECT OpportunityId,Partner_Sales_Price__c,
                                     Partner_Term__c,   
                                     CurrencyISOCode FROM OpportunityLineItem where OpportunityId=:strooppid and Business_Type__c != 'Renewal' and partner_added__c = true])
                    {
                      salesPrice = salesPrice + opli.Partner_Sales_Price__c;
                    }
                    System.debug('adfadsf --> ' + salesPrice );
                    System.debug('adfadsf --> ' + strooppid );
                   Opportunity oppr = [select Partner_Sales_Price__c from Opportunity where Id =: strooppid];
                    
                     //   salesprice   -- added by danva01
                  
                   if(oppr != null )
                   {
                       oppr.Partner_Sales_Price__c = salesPrice;
                       system.debug('error' + oppr.Partner_Sales_Price__c);                
                       update oppr;
                   }
                    
                }catch(Exception ex){
                    ApexPages.addMessages(ex);
                    return null;
                }

                // fy13 - BR165 - update at opportunity level is required to handle stretch term and reason
                if(isMainframe){
                    try{
                        update headerrec;
                    }catch(Exception ex){
                        ApexPages.addMessages(ex);
                        return null;
                        }
                    }
          //Remove the Extra Renwal Code- Not needed - anssa01 2/16/2011 
                /* 
                 //danva01             
                     
                 ProdID = lineitemrecord.PricebookEntry.product2Id;
                 system.debug ('ProdID-->' + ProdID) ;              
                 ACPLineItems = [select id,Sales_Price__c  from active_contract_product__c  where active_contract_product__c.product__r.id =: ProdID] ;
                 system.debug ('Opp Line Item --> ' + ACPLineItems);
                 
                for(Integer i=0;i<ACPLineItems.size();i++)
                {
                   ACPLineItems[i].Sales_Price__c  = lineitemrec.Partner_Sales_Price__c;  
                }
                 update(ACPLineItems);
       

                //update other Line item overview details... for renewals
                String oppid = stroppid.replace('/','');
                System.debug('oppid='+oppid);
                if(prdfamily.tolowercase() != 'services' && prdfamily.tolowercase() != 'support' && prdfamily.tolowercase() != 'education')
                {
                    List<OpportunityLineItem> opplist = [select Id,Original_Deal_Term_Months__c,Business_Type__c,Quote_Number__c,Contract_Number__c,New_Deal_Term_Months__c,Original_Contract_IDs__c,Original_CV__c,Renewal_Quota_CV__c,PricebookEntry.Product2Id from OpportunityLineItem where OpportunityId =: oppid and ID !=: lineitemrec.Id];
                    System.debug(opplist);
                    if(opplist.size()>0)
                    {
                        List<OpportunityLineItem> lstoppoliupd = new List<OpportunityLineItem>();
                        Set<ID> prdids = new Set<ID>();
                        for(Integer i=0;i<opplist.size();i++)
                        {
                            prdids.add(opplist[i].PricebookEntry.Product2Id);
                        }
                        if(prdids.size()>0)
                        {
                            // do not fetch if 'Offerings'
                            prdmap = new Map<Id,Product2>([select Id,Family from Product2 where Id in:prdids and Family not in ('Services','Services labor Pool','Support','Education')]);
                            System.debug(prdmap);
                            if(prdmap != null)
                            {
                                
                                for(Integer k=0;k<opplist.size();k++)
                                {
                                    if(prdmap.containsKey(opplist[k].PricebookEntry.Product2Id))
                                    {
                                        Product2 p = prdmap.get(opplist[k].PricebookEntry.Product2Id);
                                        if(p.Family == 'Renewal' || p.Family == 'Time' || p.Family == 'Mainframe Capacity')
                                        {
                                            opplist[k].New_Deal_Term_Months__c = lineitemrec.New_Deal_Term_Months__c;
                                            opplist[k].Original_Contract_IDs__c = lineitemrec.Original_Contract_IDs__c;
                                            opplist[k].Original_CV__c = lineitemrec.Original_CV__c;
                                            opplist[k].Renewal_Quota_CV__c = lineitemrec.Renewal_Quota_CV__c;                                        
    // fy13                                        opplist[k].Comfort_Term__c = lineitemrec.Comfort_Term__c;
                                            opplist[k].Original_Deal_Term_Months__c = lineitemrec.Original_Deal_Term_Months__c;
    // fy13                                        opplist[k].Renewal_Gap_Reason_Codes__c = lineitemrec.Renewal_Gap_Reason_Codes__c;
                                            opplist[k].Business_Type__c = lineitemrec.Business_Type__c;
                                            opplist[k].Quote_Number__c = lineitemrec.Quote_Number__c;
                                            opplist[k].Contract_Number__c = lineitemrec.Contract_Number__c; 

                                            lstoppoliupd.add(opplist[k]);
                                        }
                                        
                                    }
                                }
                            }
                            System.debug(lstoppoliupd);
                            if(lstoppoliupd.size()>0)
                                update lstoppoliupd;
                        }
                    }
                }  */
                
            }
            else
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please complete the details.');
                ApexPages.addMessage(msg);
                return null;
            }
            PageReference pref = new PageReference(stroppid);
            pref.setRedirect(true);
            return pref;
        }
        public PageReference dodelete()
        {
            String opid = lineitemrecord.OpportunityId;
            delete lineitemrec;
            PageReference pref = new PageReference('/'+opid);
            pref.setRedirect(true);
            return pref;
        }
        
        public PageReference docancel()
        {
            if(stroppid == null || stroppid == '')
                stroppid = '/'+lineitemrecord.OpportunityId;
            PageReference pref = new PageReference(stroppid);
            pref.setRedirect(true);
            return pref;
        }
        
        @isTest(SeeAllData=true)
        static void testVF()
        {
              user u1=new user(id='00530000003rQuJ');
    
   system.runas(u1){
            SystemIdUtility.skipOpportunityLineItemTriggers = true;
            Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
            Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
            //Get the opportunity recordtype id
            Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
            
            Product2 prd1 = new Product2(Name='Prd1', Family='Product',Market_Focus_Area__c='Test1',IsActive=true);
            Product2 prd2 = new Product2(Name='Prd2', Family='Time',Market_Focus_Area__c='Test2',IsActive=true);
            Product2 prd3 = new Product2(Name='Prd3', Family='Mainframe Capacity',Market_Focus_Area__c='Test1',IsActive=true);
            Product2 prd4 = new Product2(Name='Prd4', Family='Services',Market_Focus_Area__c='Test2',IsActive=true);
            Product2 prd5 = new Product2(Name='Prd5', Family='Support',Market_Focus_Area__c='Test1',IsActive=true);
            Product2 prd6 = new Product2(Name='Prd6', Family='Education',Market_Focus_Area__c='Test1',IsActive=true);
            Product2[] prd = new Product2[]{prd1,prd2,prd3,prd4,prd5,prd6};
            insert prd;
            
            Pricebook2 pb = new Pricebook2();
            pb = [Select Id from Pricebook2 where IsStandard=true];
            
            PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
            PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
            PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
            PricebookEntry pbe4 = new PricebookEntry(Product2Id=prd[3].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
            PricebookEntry pbe5 = new PricebookEntry(Product2Id=prd[4].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
            PricebookEntry pbe6 = new PricebookEntry(Product2Id=prd[5].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
            PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3,pbe4,pbe5,pbe6};
            insert pbe; 
           
            ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
            ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
            
            Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
            insert resellerAcct;                
            
            Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
            insert smbAcct;    

            Opportunity opp = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp1',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='10% - Identification & Qualification',Initial_Billing__c=2);
            insert opp; 
            test.starttest();
            OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[0].Id,UnitPrice=1000);
            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[1].Id,UnitPrice=1000);
            OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[2].Id,UnitPrice=1000);
            OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[3].Id,UnitPrice=1000);
            OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[4].Id,UnitPrice=1000);
            OpportunityLineItem oli6 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[5].Id,UnitPrice=1000);
            OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1,oli2,oli3,oli4,oli5,oli6};
            insert oli;
             
            PageReference opplinewpage1 = Page.OppLineitem_View_Edit;
            opplinewpage1.getParameters().put('retURL',opp.Id);
            opplinewpage1.getParameters().put('id',oli[0].Id);
            Test.setCurrentPage(opplinewpage1);
            ApexPages.StandardController stdcon1 = new ApexPages.StandardController(oli[0]);
            OppLineitem_View_Edit_controller_PRM opplicontroller1 = new OppLineitem_View_Edit_controller_PRM(stdcon1);
            opplicontroller1.updateproduct();
            opplicontroller1.dodelete();
            opplicontroller1.docancel();
            
            PageReference opplinewpage2 = Page.OppLineitem_View_Edit;
            opplinewpage2.getParameters().put('retURL',opp.Id);
            opplinewpage2.getParameters().put('id',oli[1].Id);
            Test.setCurrentPage(opplinewpage2);
            ApexPages.StandardController stdcon2 = new ApexPages.StandardController(oli[1]);
            OppLineitem_View_Edit_controller_PRM opplicontroller2 = new OppLineitem_View_Edit_controller_PRM(stdcon2);
            opplicontroller2.updateproduct();
            
            PageReference opplinewpage3 = Page.OppLineitem_View_Edit;
            opplinewpage3.getParameters().put('retURL',opp.Id);
            opplinewpage3.getParameters().put('id',oli[3].Id);
            Test.setCurrentPage(opplinewpage3);
            ApexPages.StandardController stdcon3 = new ApexPages.StandardController(oli[3]);
            OppLineitem_View_Edit_controller_PRM opplicontroller3 = new OppLineitem_View_Edit_controller_PRM(stdcon3);
            opplicontroller3.updateproduct();
            test.stoptest();
            }
        } 
        
        public boolean inIt{get;set;}
        
        public void calculateUFLicenseFee()
        {
        
                  if(isUF)
                         {     
                            Decimal totMaint;   
                            Decimal totSalesPrice = (lineitemrec.Partner_Sales_Price__c <> null? lineitemrec.Partner_Sales_Price__c : 0);
                            Decimal termInYears =   (lineitemrec.Partner_Term__c <> null? lineitemrec.Partner_Term__c /12 : 0);     
                        
                            Decimal UFLicenseFee = 0;
                            
                            if(termInYears <> 0)
                                UFLicenseFee  = (10 *  totSalesPrice ) /  (10 + 2 * termInYears);      
                            
                            totMaint  =  0.2 * UFLicenseFee * termInYears ;
                            Decimal FirstYearMaint = 0;
                            if(termInYears <> 0)
                                FirstYearMaint = totMaint / termInYears;
                    
                         }
                         

        }
      
        
        
    }