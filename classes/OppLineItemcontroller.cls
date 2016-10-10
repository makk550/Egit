/*
Edited By      : Sourabh Jain 
Description    : Fetch the products based on the Role [Arcot Development]
 */

public class OppLineItemcontroller
{
    private String strProductType = '';
    private String strOppId = '';
    private List<OpportunityLineItem> lstoppoli = new List<OpportunityLineItem>();
    private Map<Id,Product2> prdmap;
    private String strpricebookid = '';
    private String strcurrencyisocode = '';
    private Opportunity opp = new Opportunity();
     
    public OpportunityLineItem lineitemrecord {get;set;}
    public Integer lineCounter {get;set;}
    public Boolean isRenewal {get;set;}
    public Boolean isProduct {get;set;}
    public List<productclass> lst_prd {get;set;}
    public List<SelectOption> selbu {get;set;}
    public List<renewalclass> lst_ren {get;set;}
    public List<SelectOption> selfamily {get;set;}
    public List<SelectOption> selbustype {get;set;}
    public List<SelectOption> selprdcloudplatformuse {get;set;}
    public String bustypeval {get;set;}
    Set<string> set_ondemand; 
    Set<string> set_ondemandIds  = new Set<String>(); 
    public boolean showOnDemandHeader {get;set;}
    public List<pickval> entries = new List<pickval>();
    public List<pickval> cldplatformuse_entries = new List<pickval>();
    public Id oppId {get;set;}        // fy13
    public String oppName {get;set;}  // fy13
    public boolean alrt {get; set;}    //allha02 AR3576
  
    
    public void calculateUFLicenseFee()
    {
        
                    productclass prdclass = lst_prd[pos];
                    OpportunityLineItem oli = prdclass.oppli;
                decimal totMaint;   
                Decimal totSalesPrice = (oli.UnitPrice <> null? oli.UnitPrice : 0);
                Decimal termInYears =   (oli.Term_Month__c <> null? oli.Term_Month__c /12 : 0);     
            
                Decimal UFLicenseFee = 0;
                
                if(termInYears <> 0)
                    UFLicenseFee  = (10 *  totSalesPrice ) /  (10 + 2 * termInYears);      
                
                totMaint  =  0.2 * UFLicenseFee * termInYears ;
                Decimal FirstYearMaint = 0;
                if(termInYears <> 0)
                    FirstYearMaint = totMaint / termInYears;
                        
        if(oli.License__c == 'SAAS' || oli.License__c == 'Subscription')
        {
            oli.UF_License_Fee__c = oli.UnitPrice;
            oli.Total_Maintenance__c = 0;            
        }
        else if(oli.License__c == 'Upfront' || oli.License__c == 'Ratable')
        {
            oli.UF_License_Fee__c = UFLicenseFee.setScale(2);
            oli.Total_Maintenance__c = totMaint.setScale(2);            
        }
        
        prdclass.oppli = oli;
        lst_prd[pos] = prdclass;
        //return null;
    }
    public void calculateUFLicenseFee_partner()
    {
        
                    productclass prdclass = lst_prd[pos];
                    OpportunityLineItem oli = prdclass.oppli;
                decimal totMaint;   
                Decimal totSalesPrice = (oli.Partner_Sales_Price__c <> null? oli.Partner_Sales_Price__c: 0);
                Decimal termInYears =   (oli.Partner_Term__c <> null? oli.Partner_Term__c /12 : 0);     
            
                Decimal UFLicenseFee = 0;
                
                if(termInYears <> 0)
                    UFLicenseFee  = (10 *  totSalesPrice ) /  (10 + 2 * termInYears);      
                
                totMaint  =  0.2 * UFLicenseFee * termInYears ;
                Decimal FirstYearMaint = 0;
                if(termInYears <> 0)
                    FirstYearMaint = totMaint / termInYears;
                        
                      
        prdclass.oppli = oli;
        lst_prd[pos] = prdclass;
        //return null;
    }
 
     
    public OppLineItemcontroller(ApexPages.Standardcontroller stdcontroller)
    {
    
        Schema.DescribeFieldResult bustypevalues = OpportunityLineItem.Business_Type__c.getDescribe();
        Schema.PicklistEntry[] entries_temp = bustypevalues.getPicklistValues();
        for(Schema.PicklistEntry entry : entries_temp)
            entries.add(new pickval(entry.getLabel(),entry.getValue()));
        
         
        //Schema.DescribeFieldResult cloudplatformusevalues = OpportunityLineItem.Cloud_Platform_Use__c.getDescribe();
        //Schema.PicklistEntry[] entries_cldplatformuse_temp = cloudplatformusevalues.getPicklistValues();
        //for(Schema.PicklistEntry entry : entries_cldplatformuse_temp)
           // cldplatformuse_entries.add(new pickval(entry.getLabel(),entry.getValue()));
        
        
        
        
        List<Products_for_On_Demand__c> lst_Ondemand = Products_for_On_Demand__c.getall().values();
        set_ondemand = new Set<string>{};
        
        
        for(Products_for_On_Demand__c   pod:lst_Ondemand)
            set_ondemand.add(pod.product__c.toLowerCase());
        
            
        
        //get the type , whether Product or Renewal
        strProductType = ApexPages.currentPage().getParameters().get('producttype');
        //get the opportunity id
        strOppId = ApexPages.currentPage().getParameters().get('oppid');
        //fetch other line item details for the opportunity
        lstoppoli = [select Id,Total_Maintenance__c, License__c, OpportunityId,Business_Type__c,Stretch__c , Original_Expiration_Date__c, 
                            Original_Expiration_Quarter__c, Original_Expiration_Year__c, Term_Month__c,X1st_Year_Maintenance__c,
                            UF_License_Fee__c,Quote_Number__c, Business_Partner_ID__c, Contract_Number__c,Renewal_Quota_CV__c,
                            Original_CV__c,Original_Contract_IDs__c,New_Deal_Term_Months__c,Original_Deal_Term_Months__c,
                            UnitPrice,PricebookEntry.Product2Id,PricebookEntry.Product2.Upfront_Revenue_Eligible__c, On_Demand__c ,Partner_Sales_Price__c,
                            Partner_Term__c,Partner_Added__c
                       from OpportunityLineItem 
                      where OpportunityId=:strOppId
                        and Business_Type__c != 'Renewal' 
                   order by createddate asc];
        
        this.lineitemrecord = (OpportunityLineItem)stdController.getRecord(); 
        //fetch Opportunity details for appending to the line item.
        opp = [select Name, RecordTypeId, Recordtype.name, Pricebook2Id,CurrencyISOCode,
                      CloseDate,StageName,Probability,ForecastCategory from Opportunity where Id =: strOppId];
        strcurrencyisocode = opp.CurrencyIsoCode;
        //strpricebookid = opp.Pricebook2Id;
        oppId = opp.Id;     // fy13
        oppName = opp.Name; // fy13
        
        
        //lineitemrecord.Probability__c = opp.Probability;
        //lineitemrecord.Forecast_Category__c = opp.ForecastCategory;
        
        //UPDATING FORECAST CATEGORY
        //ADDED BY AFZAL FOR CR # 189381545 
        /*if(lineitemrecord.Probability__c!=null){ 
            if(lineitemrecord.Probability__c<=50)
                lineitemrecord.Forecast_Category__c = 'Pipeline';
            else if(lineitemrecord.Probability__c ==70)
                lineitemrecord.Forecast_Category__c = 'Best Case';
            else if(lineitemrecord.Probability__c==90)
                lineitemrecord.Forecast_Category__c = 'Commit';
            else if(lineitemrecord.Probability__c==100)
                lineitemrecord.Forecast_Category__c = 'Closed';
            else
                lineitemrecord.Forecast_Category__c = 'Closed';
        }*/
        //
        
        fetchbusinesstype();
        lst_prd = new List<productclass>();
        lst_ren = new List<renewalclass>();
        //incase there are already any products/renewals added to the opportunity, show them on the page
        if(lstoppoli.size()>0)
        {
            Set<ID> prdids = new Set<ID>();
            for(Integer i=0;i<lstoppoli.size();i++)
            {
                prdids.add(lstoppoli[i].PricebookEntry.Product2Id);
            }
            if(prdids.size()>0)
            {
                // do not fetch if 'Offerings'
                prdmap = new Map<Id,Product2>([select Id,Family,Upfront_Revenue_Eligible__c,Market_Focus_Area__c, name from Product2 where Id in:prdids and Family in ('Product','Time','Mainframe Capacity','Renewal')  and Market_Focus_Area__c != null   order by name ]);
                if(prdmap != null)
                {
                    Integer renitemcount = 0;
                    Integer prditemcount = 0;
                     for(Integer k=0;k<lstoppoli.size();k++)
                     {
                        if(prdmap.containsKey(lstoppoli[k].PricebookEntry.Product2Id))
                        {
                            if(strProductType == 'Product')
                            {
                                Product2 p = prdmap.get(lstoppoli[k].PricebookEntry.Product2Id);
                                if(p.Family == 'Product')
                                {
                                    productclass prd = new productclass();
                                    //OpportunityLineItem tempolineitem = new OpportunityLineItem();
                                    prd.oppli = lstoppoli[k];
                                    prd.position = prditemcount;
                                    
                                    prd.strbu = p.Market_Focus_Area__c; 
                                    
                                    prd.strproduct = lstoppoli[k].PricebookEntry.Product2Id;
                                    prd.strbustype = lstoppoli[k].Business_Type__c;
                                    prd.on_demand = lstoppoli[k].On_Demand__c;
                                    prd.isBUDisabled = true;
                                    prd.isPrdDisabled = true;
                                    //added by danva01 for FY13                                     
                                    if(p.Upfront_Revenue_Eligible__c == 'No')
                                    {
                                      prd.isUFLisenceDisabled=true;
                                      prd.is1YearMaintDisabled=true;
                                    }
                                    prd.show_ondemand =  set_ondemand.contains(p.name.toLowerCase());
                                    //For Cloud Platform
                                    prd.selprdcloudplatformuse = new List<SelectOption>();
                                    prd.selprdcloudplatformuse.add(new SelectOption('--Select--','--Select--'));
                                    for(pickval entry : cldplatformuse_entries)
                                            prd.selprdcloudplatformuse.add(new SelectOption(entry.getvalue(), entry.getlabel()));
                                    //prd.strcloudplatformuse  = lstoppoli[k].Cloud_Platform_Use__c;
                                    //End Cloud Platform
                                    if(prd.show_ondemand)
                                        showOnDemandHeader = true;
                                    lst_prd.add(prd);
                                    bu_value =  p.Market_Focus_Area__c;
                                    pos = prditemcount;
                                    prdfamily = p.Family;
                                    fetchproducts();
                                    prditemcount += 1;
                                }
                                
                            }
                            if(strProductType == 'Renewal')
                            {
                                Product2 p = prdmap.get(lstoppoli[k].PricebookEntry.Product2Id);
                                if(p.Family == 'Renewal' || p.Family == 'Time' || p.Family == 'Mainframe Capacity')
                                {
                                    lineitemrecord.New_Deal_Term_Months__c = lstoppoli[k].New_Deal_Term_Months__c;
                                    lineitemrecord.Original_CV__c = lstoppoli[k].Original_CV__c;
                                    
                                    lineitemrecord.Original_Deal_Term_Months__c = lstoppoli[k].Original_Deal_Term_Months__c;
// fy13                             lineitemrecord.Comfort_Term__c = lstoppoli[k].Comfort_Term__c;
                                    lineitemrecord.Original_Contract_IDs__c = lstoppoli[k].Original_Contract_IDs__c;
// fy13                             lineitemrecord.Renewal_Gap_Reason_Codes__c = lstoppoli[k].Renewal_Gap_Reason_Codes__c;
                                    lineitemrecord.Renewal_Quota_CV__c = lstoppoli[k].Renewal_Quota_CV__c;
                                    bustypeval = lstoppoli[k].Business_Type__c;
                                    
                                    lineitemrecord.Quote_Number__c = lstoppoli[k].Quote_Number__c;
                                    lineitemrecord.Business_Partner_ID__c = lstoppoli[k].Business_Partner_ID__c;
                                    lineitemrecord.Contract_Number__c = lstoppoli[k].Contract_Number__c;
                                     
                               
                                    
                                    
                                    renewalclass ren = new renewalclass();
                                    //OpportunityLineItem tempoline = new OpportunityLineItem();
                                    ren.oppli = lstoppoli[k];
                                    ren.position = renitemcount;
                                    ren.strfamily = p.Family;
                                    ren.strbu = p.Market_Focus_Area__c; 
                                    //ren.strbustype = lstoppoli[k].Business_Type__c;
                                    ren.strproduct = lstoppoli[k].PricebookEntry.Product2Id;
                                    ren.isBUDisabled = true;
                                    ren.isPrdDisabled = true;
                                    ren.isFamilyDisabled = true;
                                    lst_ren.add(ren);
                                    renpos = renitemcount;
                                    renfamily = p.Family;
                                    fetchrenewalbu();
                                    
                                    bu_value =  p.Market_Focus_Area__c;
                                    pos = renitemcount;
                                    prdfamily = p.Family;
                                    fetchproducts();
                                    //lst_ren[renitemcount].strproduct = lstoppoli[k].PricebookEntry.Product2Id;
                                    renitemcount += 1;  
                                    
                                    
                                }   
                            }
                            
                            //break;
                        }
                     }  
                }   
            }
        }
        
        
        if(strProductType == 'Renewal')
        {
            isRenewal = true;
            isProduct = false;
            fetchfamily();
            //need to show by default 3 line item rows, incase already existing items are less than 3
            if(lst_ren.size()<3)
            {
                Integer cnt = lst_ren.size();
                Integer linespadding = 3 - cnt;
                for(Integer i=0;i<linespadding;i++)
                {
                    renewalclass ren = new renewalclass();
                    OpportunityLineItem tempoline = new OpportunityLineItem();
                    ren.oppli = tempoline;
                    ren.position = cnt + i;
                    ren.isBUDisabled = false;
                    ren.isPrdDisabled = false;
                    ren.isFamilyDisabled = false;
                    lst_ren.add(ren);
                 
                }
            }
            else
            {
                //if already existing line items are equal to or more than 3, then just show 1 additional blank row.
                renewalclass ren = new renewalclass();
                OpportunityLineItem tempoline = new OpportunityLineItem();
                ren.oppli = tempoline;
                ren.position = lst_ren.size();
                ren.isBUDisabled = false;
                ren.isPrdDisabled = false;
                ren.isFamilyDisabled = false;
                lst_ren.add(ren);
                
            }
                        
        }
        //same as for renewals
        else if(strProductType == 'Product')
        {
            isProduct = true;
            isRenewal = false;
            selbu = new List<SelectOption>();
            selbu.add(new SelectOption('--Select--','--Select--'));
            selbu = fetchBU(strProductType);
            
            //fetchproducts();
            if(lst_prd.size()<3)
            {
                Integer cnt = lst_prd.size();
                Integer linespadding = 3 - cnt;
                for(Integer i=0;i<linespadding;i++)
                {
                    productclass prd = new productclass();
                    OpportunityLineItem tempolineitem = new OpportunityLineItem();
                    
                    prd.oppli = tempolineitem;
                    prd.position = cnt+i;
                    prd.isBUDisabled = false;
                    prd.isPrdDisabled = false;
                    //prd.isUFLisenceDisabled=false;
                    //prd.is1YearMaintDisabled=false;  //to find...
                    prd.selprdbustype = new List<SelectOption>();
                    prd.selprdbustype = selbustype;
                    prd.selprdcloudplatformuse = new List<SelectOption>();
                    prd.selprdcloudplatformuse.add(new SelectOption('--Select--','--Select--'));
                    for(pickval entry : cldplatformuse_entries)
                            prd.selprdcloudplatformuse.add(new SelectOption(entry.getvalue(), entry.getlabel()));

                    lst_prd.add(prd);
                 
                }
            }
            else
            {
                productclass prd = new productclass();
                OpportunityLineItem tempolineitem = new OpportunityLineItem();
                
                prd.oppli = tempolineitem;
                prd.position = lst_prd.size();
                prd.isBUDisabled = false;
                prd.isPrdDisabled = false;
                //prd.isUFLisenceDisabled=false;
                //prd.is1YearMaintDisabled=false;
                prd.position = lst_prd.size();
                prd.selprdcloudplatformuse = new List<SelectOption>();
                prd.selprdcloudplatformuse.add(new SelectOption('--Select--','--Select--'));
                for(pickval entry : cldplatformuse_entries)
                   prd.selprdcloudplatformuse.add(new SelectOption(entry.getvalue(), entry.getlabel()));
                prd.selprdbustype = new List<SelectOption>();
                prd.selprdbustype = selbustype;
                
                lst_prd.add(prd);
            }
        }
            
        try{
        //get pricebook details, required while saving the line item
        Pricebook2 pbe = new Pricebook2();
        pbe = [select Id from Pricebook2 where Name='CA Product List' and IsActive=true];
        if(pbe!=null)
            strpricebookid = pbe.Id;
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
    }
    //wrapper class to store product data    
    public class productclass
    {
        public OpportunityLineItem oppli {get;set;}
        public String strbu {get;set;}
        public String strproduct {get;set;}
        public List<SelectOption> selproduct {get;set;}
        public List<SelectOption> selprdcloudplatformuse {get;set;}
        public Integer position {get;set;}
        public String strbustype {get;set;}
        public String strcloudplatformuse {get;set;}
        public boolean on_demand {get; set;}
        public boolean show_ondemand {get;set;}
        public Boolean isBUDisabled {get;set;}
        public Boolean isPrdDisabled {get;set;}
  
      
        public Boolean isUFLisenceDisabled {get;set;}
        public Boolean is1YearMaintDisabled {get;set;}
        
        public List<SelectOption> selprdbustype {get;set;}
        
    }
    //wrapper class to store renewal data
    public class renewalclass
    {
        public OpportunityLineItem oppli {get;set;}
        public String strfamily {get;set;}
        public List<SelectOption> selrenbu {get;set;}
        public String strbu {get;set;}
        public String strproduct {get;set;}
        public List<SelectOption> selproduct {get;set;}
        public Integer position {get;set;}
        //public String strbustype {get;set;}
        public Boolean isFamilyDisabled {get;set;}
        public Boolean isBUDisabled {get;set;}
        public Boolean isPrdDisabled {get;set;}
    }
    
    
    public String renfamily {get;set;}
    public Integer renpos {get;set;}
    public void fetchrenewalbu()
    {
        
        
        renewalclass renclass = lst_ren[renpos];
        renclass.selrenbu = new List<SelectOption>();
        
        renclass.selrenbu = fetchBU(renfamily);
        
    }
    
  
    public List<SelectOption> fetchBU(String family)
    {
        List<Product2> lstprd = new List<Product2>();
        //lstprd = [select Id,Name from Product2 where Family='Education' and isDeleted = false and isActive = true order by name];
        lstprd = [select Market_Focus_Area__c from Product2 where Family=: family and isActive = true  and Market_Focus_Area__c != null   order by Market_Focus_Area__c];
        
        List<SelectOption> selbu_temp = new List<SelectOption>();
        selbu_temp.add(new SelectOption('--Select--','--Select--'));
        Set<String> setcheckbu = new Set<String>();
        for(Product2 prd : lstprd){
            if(opp.RecordType.Name == 'New Opportunity')
            { 
                if(prd.Market_Focus_Area__c != 'ISBU' && prd.Market_Focus_Area__c != 'RMDM')
                {
                    if(!setcheckbu.contains(prd.Market_Focus_Area__c))
                    {
                        selbu_temp.add(new SelectOption(prd.Market_Focus_Area__c,prd.Market_Focus_Area__c));
                        setcheckbu.add(prd.Market_Focus_Area__c);
                    }
                }
                
            }
            else
            {
                if(!setcheckbu.contains(prd.Market_Focus_Area__c))
                {
                    selbu_temp.add(new SelectOption(prd.Market_Focus_Area__c,prd.Market_Focus_Area__c));
                    setcheckbu.add(prd.Market_Focus_Area__c);
                }
            }             
        }
        return selbu_temp;
    }
    //get family from product table related to Product and Renewals
    public void fetchfamily()
    {
        selfamily = new List<SelectOption>();
        selfamily.add(new SelectOption('--Select--','--Select--'));
        List<Product2> lstprd = new List<Product2>();
        //fetch product families...
        lstprd = [select Family from Product2 where Family in ('Renewal','Time','Mainframe Capacity') and isDeleted = false and isActive = true  and Market_Focus_Area__c != null   order by family];
        Set<String> setcheck = new Set<String>();
        for(Product2 prd : lstprd){
            if(!setcheck.contains(prd.Family)){
                selfamily.add(new SelectOption(prd.Family,prd.Family));
                setcheck.add(prd.Family);
            }
            
        }
        
    }
    
    public List<SelectOption> fetchbusinesstype()
    {
        selbustype = new List<SelectOption>();
        selbustype.add(new SelectOption('--Select--','--Select--'));
        

        for(pickval entry : entries)
        {
            //restrict Business Type to particular values for Renewals and Products
            if(strProductType == 'Renewal')
            {
                if(entry.getValue() == 'Renewal' || entry.getValue() == 'Medium Touch' || entry.getValue() == 'Indirect Medium Touch')
                    selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
            }
            else if(strProductType == 'Product')
            {
                if(entry.getValue() == 'New' || entry.getValue() == 'Time' || entry.getValue() == 'Maintenance')
                    selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
                
                if(entry.getValue() == 'Capacity'  || entry.getValue() == 'Upgrade')
                {
                    if(!(bu_value!=null && bu_value.toLowerCase() == 'mainframe'))
                        selbustype.add(new SelectOption(entry.getLabel(),entry.getValue()));
                }  
                if(lst_prd!=null)
                {  
                    productclass prdclass = lst_prd[pos];
                    prdclass.selprdbustype = new List<SelectOption>();
                    prdclass.selprdbustype = selbustype;
                }
            }
        }
        return selbustype;
    }

    public void getOnDemand()
    {
         
    }

    public String bu_value {get;set;}
    public Integer pos {get;set;}
    public String prdfamily {get;set;}
    public void fetchproducts()
    {
        
        
        
        //fetch products based on family and Business Unit
        List<SelectOption> selproducts = new List<SelectOption>();
        List<Product2> lstprd = new List<Product2>();
        
        //Addition by Sourabh
        List<Product_Role_Relationship__c> lstProdRole= new List<Product_Role_Relationship__c>();
        List<ID> ProdId = new List<ID>();
        String rolName = '';
        String UsrRoleName = '';
        List<UserRole> lstUserRole = [Select Name from UserRole where id =: userinfo.getuserRoleid( )];
        If(lstUserRole.size()>0){
            For(userRole usrdata : lstUserRole){
                rolName = usrdata.Name;
            }
        }
        
        lstProdRole =[Select Product_ID__c,Role_Name__c from Product_Role_Relationship__c where Role_Name__c =:rolName and Business_Unit__c =:bu_value]; 
        

        If(lstProdRole.size()>0){
           For(Product_Role_Relationship__c usrRoleId : lstProdRole){
               UsrRoleName=usrRoleId.Role_Name__c.toUpperCase();
               If(UsrRoleName == rolName.toUpperCase()) 
                  ProdID.add(usrRoleId.Product_ID__c);
           }
        
        // To check if the Role and Product Combination exists in Product Role Object 
        lstprd=[select Id,Name,Upfront_Revenue_Eligible__c  from Product2 where Family=:prdfamily and Market_Focus_Area__c=:bu_value and Id IN:ProdID  and Market_Focus_Area__c != null   and isDeleted = false and isActive = true order by name]; 
        }
        else
        lstprd = [select Id,Name,Upfront_Revenue_Eligible__c from Product2 where Family=:prdfamily and Market_Focus_Area__c=:bu_value and isDeleted = false and isActive = true and Product_Visibility__c = false  and Market_Focus_Area__c != null   order by name];
        
        
        selproducts.add(new SelectOption('--Select--','--Select--'));
        Set<String> setcheck = new Set<String>();
        
        
                
        for(Product2 prd : lstprd){
            if(!setcheck.contains(prd.Id))
            {
                selproducts.add(new SelectOption(prd.Id,prd.Name));                                
                setcheck.add(prd.Id); 
                if(set_ondemand.contains(prd.Name.toLowerCase()))
                    set_ondemandIds.add(prd.Id);
            }
             
        }
        //incase request type is Product addition
        if(strProductType == 'Product')
        {
            productclass prdclass = lst_prd[pos];
            
            prdclass.selproduct = new List<SelectOption>();
            prdclass.selproduct = selproducts;                        
        }
        else if(strProductType == 'Renewal')//incase request type is renewal addition
        {
            renewalclass renclass = lst_ren[pos];
            renclass.selproduct = new List<SelectOption>();
            renclass.selproduct = selproducts;
        }
        fetchbusinesstype();
               
    }
    //adds a blank row to product lineitem addition table
    public PageReference addmore_prds()
    {
        productclass prd = new productclass();
        OpportunityLineItem tempoli = new OpportunityLineItem(); 
        prd.oppli = tempoli;
        prd.position = lst_prd.size();
        prd.selprdcloudplatformuse = new List<SelectOption>();
        prd.selprdcloudplatformuse.add(new SelectOption('--Select--','--Select--'));
        for(pickval entry : cldplatformuse_entries)
           prd.selprdcloudplatformuse.add(new SelectOption(entry.getvalue(), entry.getlabel()));
        lst_prd.add(prd);
        return null; 
    }
    //adds a blank row to renewal lineitem addition table
    public PageReference addmore_ren()
    {
        renewalclass ren = new renewalclass();
        OpportunityLineItem tempoli = new OpportunityLineItem();
        ren.oppli = tempoli;
        ren.position = lst_ren.size();
        lst_ren.add(ren);
        return null; 
    }
    public PageReference saveproducts()
    { 
        alrt= false ; //allha02 
        
        
        List<OpportunityLineItem> ins_lineitem = new list<OpportunityLineItem>();
        Set<String> prdid = new Set<String>();
        //for products
        for(Integer j=0;j<lst_prd.size();j++)
        {
            if(lst_prd[j].strproduct!='--Select--' && lst_prd[j].strproduct!=null)
                prdid.add(lst_prd[j].strproduct);           
            
        }
        //for renewals
        for(Integer k=0;k<lst_ren.size();k++)
        {
            
            if(lst_ren[k].strproduct!='--Select--' && lst_ren[k].strproduct!=null)
                prdid.add(lst_ren[k].strproduct);
        }
       
        //get the pricebookentry ids
        List<PricebookEntry> pbe = new List<PricebookEntry>(); 
        pbe = [Select Id,Product2Id from PricebookEntry Where IsActive=true and Pricebook2Id=: strpricebookid and Product2Id in: prdid and CurrencyISOCode =:strcurrencyisocode];
      
        for(Integer i=0;i<lst_prd.size();i++)
        {  
            
            //proceed to save only if the BU is selected
            if(lst_prd[i].strbu!='--Select--' && lst_prd[i].strbu!=null)
            {
                //If BU is selected, then all other line item details need to be completed.
                if(lst_prd[i].strproduct!='--Select--' && lst_prd[i].strbustype!='--Select--' && lst_prd[i].oppli.License__c != null && lst_prd[i].oppli.UnitPrice != null && lst_prd[i].oppli.Term_Month__c != null && lst_prd[i].strcloudplatformuse != '--Select--')
                {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli = lst_prd[i].oppli;
                    //oli.on_demand__c = lst_prd[i].on_demand;
                   
                    //allha02 AR3576
                    if(lst_prd[i].oppli.Stretch__c== null || lst_prd[i].oppli.Stretch__c < lst_prd[i].oppli.UnitPrice ){  
                                            
                        lst_prd[i].oppli.Stretch__c=lst_prd[i].oppli.UnitPrice;
                        alrt = true ;
                      }
                    
                    //oli.Probability__c = lineitemrecord.Probability__c; 
                    
                    //oli.Forecast_Category__c = lineitemrecord.Forecast_Category__c;
                    
                    
                    if(lst_prd[i].strbustype != '--Select--')
                        oli.Business_Type__c = lst_prd[i].strbustype;
                    
                    //if(lst_prd[i].strbustype != '--Select--')
                       // oli.Cloud_Platform_Use__c = lst_prd[i].strcloudplatformuse;
                  
                 


                    //below data to be added only for new lineitems
                    if(lst_prd[i].oppli.Id==null)
                    {
                        oli.OpportunityId = strOppId;
                        for(Integer prdcnt=0;prdcnt<pbe.size();prdcnt++)
                        {
                            if(lst_prd[i].strproduct == pbe[prdcnt].Product2ID)
                            {
                                oli.PricebookEntryId = pbe[prdcnt].Id;
                                
                                
                                
                                break;
                            }
                        }
                    }
                        //oli.Won_line_item__c = false;
                        //oli.Closed_line_item__c = false;
                    
                    ins_lineitem.add(oli);
                }
                else
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please complete the Product Details.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
        }
        //allha02 AR3576
        if(alrt)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Info,'Stretch is required and must be greater than or equal to Sales Price.  Stretch value adjusted.');
            ApexPages.addMessage(msg);
            return null;
        }
        
        
        
        for(Integer j=0;j<lst_ren.size();j++)
        {
            //proceed to save only if the Family is selected
            if(lst_ren[j].strfamily!='--Select--' && lst_ren[j].strfamily!=null)
            {
                //If Family is selected, then all other line item details need to be completed.
                //BY AFZAL, Making Original Expiration Date non mandatory per CR:189363892 
                //if(lst_ren[j].strbu !='--Select--' && lst_ren[j].strproduct !='--Select--' && lst_ren[j].oppli.UnitPrice != null && lst_ren[j].oppli.Original_Expiration_Date__c != null)
                if(lst_ren[j].strbu !='--Select--' && lst_ren[j].strproduct !='--Select--' && lst_ren[j].oppli.UnitPrice != null)
                {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli = lst_ren[j].oppli;
                    //save the overview details
                    oli.New_Deal_Term_Months__c = lineitemrecord.New_Deal_Term_Months__c;
                    
                    
                    oli.Original_Contract_IDs__c = lineitemrecord.Original_Contract_IDs__c;
                    oli.Original_CV__c = lineitemrecord.Original_CV__c;
                    oli.Renewal_Quota_CV__c = lineitemrecord.Renewal_Quota_CV__c;
                    
// fy13                    oli.Comfort_Term__c = lineitemrecord.Comfort_Term__c;
// fy13                    oli.Renewal_Gap_Reason_Codes__c = lineitemrecord.Renewal_Gap_Reason_Codes__c;
                    oli.Original_Deal_Term_Months__c = lineitemrecord.Original_Deal_Term_Months__c;
                    
                    oli.Quote_Number__c = lineitemrecord.Quote_Number__c;
                    oli.Business_Partner_ID__c = lineitemrecord.Business_Partner_ID__c;
                    oli.Contract_Number__c = lineitemrecord.Contract_Number__c;
                    
                    //allha02 AR3576
                     if(lst_ren[j].oppli.Stretch__c== null || lst_ren[j].oppli.Stretch__c < lst_ren[j].oppli.UnitPrice ){  
                                            
                        lst_ren[j].oppli.Stretch__c=lst_ren[j].oppli.UnitPrice;
                        alrt = true ;
                      }
                    
                    //oli.Probability__c = lineitemrecord.Probability__c;
                    //oli.Forecast_Category__c = lineitemrecord.Forecast_Category__c;
                    
                    String fiscalperiod = '';
                    
                    //oli.Fiscal_Period_lineitem__c = fiscalperiod;
                    
                    if(bustypeval != '--Select--')
                        oli.Business_Type__c = bustypeval;
                    else
                    {
                        //oli.Business_Type__c = null;
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please select the Business Type.');
                        ApexPages.addMessage(msg);
                        return null;
                    }   
                     //below data to be added only for new lineitems
                    if(lst_ren[j].oppli.Id==null)
                    { 
                        oli.OpportunityId = strOppId;
                        for(Integer prdcnt=0;prdcnt<pbe.size();prdcnt++)
                        {
                            if(lst_ren[j].strproduct == pbe[prdcnt].Product2ID)
                            {
                                oli.PricebookEntryId = pbe[prdcnt].Id;
                                break;
                            }
                        }
                    }
                    
                        //oli.Won_line_item__c = false;
                        //oli.Closed_line_item__c = false;
                    
                    ins_lineitem.add(oli);
                }
                else
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please complete the Renewal Details.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
        }
        //allha02 AR3576
        if(alrt)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Info,'Stretch is required and must be greater than or equal to Sales Price.  Stretch value adjusted.');
            ApexPages.addMessage(msg);
            return null;
        }
        if(ins_lineitem.size()>0)
        {
            // do an upsert
            try{
            upsert ins_lineitem;
            
            }catch(DMLException ex){
                if(ex.getMessage().contains('field integrity exception'))
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Opportunity currency is not matching with Product Currency.'));              
                else
                ApexPages.addMessages(ex);      
                
                return null;
            }
            
                
        }
        else
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,'Please add Product Details.');
            ApexPages.addMessage(msg);
            return null;
        }
        // the overview details for renewals should be updated to all existing renewal lineitems of that opportunity
        if(lstoppoli.size()>0)
        {
            Set<ID> prdids = new Set<ID>();
            /*for(Integer i=0;i<opplist.size();i++)
            {
                prdids.add(opplist[i].PricebookEntry.Product2Id);
            }*/
            //if(prdids.size()>0)
            //{
                // do not fetch if 'Offerings'
                //prdmap = new Map<Id,Product2>([select Id,Family from Product2 where Id in:prdids and Family not in ('Services','Services labor Pool') order by family]);
                List<OpportunityLineItem> lstoppoliupd = new List<OpportunityLineItem>();
                
                if(prdmap != null)
                {
                    for(Integer k=0;k<lstoppoli.size();k++)
                    {
                        if(prdmap.containsKey(lstoppoli[k].PricebookEntry.Product2Id))
                        {
                            Product2 p = prdmap.get(lstoppoli[k].PricebookEntry.Product2Id);
                            if(p.Family == 'Renewal' || p.Family == 'Time' || p.Family == 'Mainframe Capacity')
                            {
                                lstoppoli[k].New_Deal_Term_Months__c = lineitemrecord.New_Deal_Term_Months__c;
                                lstoppoli[k].Original_Contract_IDs__c = lineitemrecord.Original_Contract_IDs__c;
                                lstoppoli[k].Original_CV__c = lineitemrecord.Original_CV__c;
                                lstoppoli[k].Renewal_Quota_CV__c = lineitemrecord.Renewal_Quota_CV__c;
                                
// fy13                                lstoppoli[k].Comfort_Term__c = lineitemrecord.Comfort_Term__c;
// fy13                                lstoppoli[k].Renewal_Gap_Reason_Codes__c = lineitemrecord.Renewal_Gap_Reason_Codes__c;
                                
                                lstoppoli[k].Original_Deal_Term_Months__c = lineitemrecord.Original_Deal_Term_Months__c;
                                if(bustypeval != '--Select--')
                                    lstoppoli[k].Business_Type__c = bustypeval;
                                else
                                    lstoppoli[k].Business_Type__c = null;
                                    
                                lstoppoliupd.add(lstoppoli[k]);
                            }
                            
                        }
                    }
                }
                
             /*   if(lstoppoliupd.size()>0)
                    update lstoppoliupd;
              */ 
               
                    
            //}
        }
            
        PageReference pref = new PageReference('/'+strOppId);
        pref.setRedirect(true);
        return pref;
    }
    
    
    public pagereference recalculate()
    {
       Integer i = 0;
       for(productclass pc: lst_prd)
       {                      
           if(pc.strproduct != null)
           {
               Set<Id> smp= new Set<Id>();
               smp.add(pc.strproduct);               
               List<Product2> lstmap = new List<Product2>([select Id,Mainframe_or_Distributed__c, Family,Upfront_Revenue_Eligible__c,Market_Focus_Area__c, name from Product2 where Id =: smp and Family in ('Product','Time','Mainframe Capacity','Renewal') and Market_Focus_Area__c != null   order by name ]); 
               if(i == lineCounter)
               {
                   if(lstmap[0].Upfront_Revenue_Eligible__c == 'Yes')
                   {
                     OpportunityLineItem oli = pc.oppli;
                     //if(!(oli.License__c != null && oli.License__c != ''))  
                         oli.License__c = 'Upfront';
                   }
                   else if(lstmap[0].Mainframe_or_Distributed__c == 'SAAS')
                   {
                     OpportunityLineItem oli = pc.oppli;
                     //if(!(oli.License__c != null && oli.License__c != ''))                     
                         oli.License__c = 'SAAS';
                   }
                   else if(lstmap[0].Mainframe_or_Distributed__c == 'Mainframe')
                   {
                     OpportunityLineItem oli = pc.oppli;
                     //if(!(oli.License__c != null && oli.License__c != ''))                     
                         oli.License__c = 'Subscription';
                   }
                   else if(lstmap[0].Mainframe_or_Distributed__c == 'Distributed')
                   {
                     OpportunityLineItem oli = pc.oppli;
                     //if(!(oli.License__c != null && oli.License__c != ''))                     
                         oli.License__c = 'Ratable';
                   } 
               }              

                              
               if(lstmap[0].Upfront_Revenue_Eligible__c == 'No')
               {
                  pc.isUFLisenceDisabled = true;
                  pc.is1YearMaintDisabled= true;
               }
               else               
               {
                  pc.isUFLisenceDisabled = false;
                  pc.is1YearMaintDisabled= false;
               }
           }                     
           if(pc.isPrdDisabled != true)
            {
                   pc.show_ondemand = set_ondemandIds.contains(pc.strproduct);
                   if(pc.show_ondemand != true)
                       pc.on_demand =false;
                   if(pc.show_ondemand)
                         showOnDemandHeader = true;    
            }
            i++;   
       }
        return null;
    }
    
    public class pickval
    {
        string label;
        string name;
        
        public pickval(string lbl, string val)
        {
            label = lbl;
            name = val;
        }
        public string getLabel()
        {
            return label;
        }
        public string getValue()
        {
            return name;
        }
    }
    
    @isTest(SeeAllData=true)
    static void testVF()
    {
        SystemIdUtility.skipOpportunityLineItemTriggers = true;
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
        //Get the opportunity recordtype id
        Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
        Test.startTest();
        Product2 prd1 = new Product2(Name='Prd1', Family='Product',Market_Focus_Area__c='SECURITY',IsActive=true);
        Product2 prd2 = new Product2(Name='Prd2', Family='Time',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2 prd3 = new Product2(Name='Prd3', Family='Mainframe Capacity',Market_Focus_Area__c='OTHER',IsActive=true);
        Product2[] prd = new Product2[]{prd1,prd2,prd3};
        insert prd;
        
        Pricebook2 pb = new Pricebook2();
        pb = [Select Id from Pricebook2 where IsStandard=true];
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
        PricebookEntry pbe2 = new PricebookEntry(Product2Id=prd[1].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry pbe3 = new PricebookEntry(Product2Id=prd[2].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
        PricebookEntry[] pbe = new PricebookEntry[]{pbe1,pbe2,pbe3};
        insert pbe; 
        
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
        ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
        
        Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
        insert resellerAcct;                
        
        Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct;    

        Opportunity opp = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp1',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='10% - Identification & Qualification',Initial_Billing__c=2);
        insert opp; 
        
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[0].Id,UnitPrice=6);
        OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[1].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem oli6 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[2].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem oli7 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[0].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem oli8 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[1].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem oli9 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[2].Id,Term_Month__c=2,UnitPrice=6);
        OpportunityLineItem[] oli = new OpportunityLineItem[]{oli4,oli5,oli6,oli7,oli8,oli9};
        insert oli;
        
        Test.stopTest();
        OpportunityLineItem oli1_1 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[0].Id,Term_Month__c=5,UnitPrice=6);
        OpportunityLineItem oli1_2 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[1].Id,Term_Month__c=3,UnitPrice=6);
        OpportunityLineItem oli1_3 = new OpportunityLineItem(OpportunityId=opp.Id,PricebookEntryId = pbe[2].Id,Term_Month__c=3,UnitPrice=6);
        //OpportunityLineItem[] oli = new OpportunityLineItem[]{oli1_3,oli1_4,oli1_5};
        
        PageReference opplinewpage1 = Page.OppLineItempage;
        opplinewpage1.getParameters().put('producttype','Product');
        opplinewpage1.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage1);
        ApexPages.StandardController stdcon1 = new ApexPages.StandardController(oli1_1);
        OppLineItemcontroller opplicontroller1 = new OppLineItemcontroller(stdcon1);
        opplicontroller1.addmore_prds();
        opplicontroller1.saveproducts();
        
        PageReference opplinewpage2 = Page.OppLineItempage;
        opplinewpage2.getParameters().put('producttype','Renewal');
        opplinewpage2.getParameters().put('oppid',opp.Id);
        Test.setCurrentPage(opplinewpage2);
        ApexPages.StandardController stdcon2 = new ApexPages.StandardController(oli1_2);
        OppLineItemcontroller opplicontroller2 = new OppLineItemcontroller(stdcon2);
        opplicontroller2.addmore_ren();
        opplicontroller2.saveproducts();
        
        
    } 
}