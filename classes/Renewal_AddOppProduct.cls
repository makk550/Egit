public class Renewal_AddOppProduct {
    
        String strOppId;   
        String strAccountId;
        String WhereCond;
        String strAccName;
        public integer npages{get;set;}    
        private integer remainder;
        private string strpricebookid;
        private integer reminder;
        public integer acpage{get;set;}  
        public boolean hasPrevious {get;set;}
        public boolean hasNext {get;set;}
        private boolean pricebkmsg {get;set;}
        public string Contract_No_Filter{get;set;}
        public string Contract_Name_Filter{get;set;}
        public  string  Dismantle_Date_Filter{get;set;}
        public Integer pages ;
        private String sortDirection = 'ASC'; 
        private String sortExp = 'name';  
        Integer respg; 
        
        public Integer getPages() {
            return pages;    
        }
                               
        public void setPages(Integer pages) {
            this.pages = pages;            
        } 
        
        public Integer pageSize = pages; 

    public List<RenewalProductDetails> RenewalProductList = new List<RenewalProductDetails>();
    public List<Active_Contract_Product__c>  ActProduct = new List<Active_Contract_Product__c>();
    public List<Active_Contract_Product__c>  ActPdtlst = new List<Active_Contract_Product__c>();
    public Map <String,Active_Contract_Product__c> ActProductMap =   new Map<String,Active_Contract_Product__c>();
    Opportunity opp;
    String currencyISOCode;
    public Renewal_AddOppProduct(ApexPages.StandardSetController controller) {
        Pricebook2 pbe = new Pricebook2();
        pbe = [select Id from Pricebook2 where Name='CA Product List' and IsActive=true];
        if(pbe!=null)
            strpricebookid = pbe.Id;

        pricebkmsg = false;
        pages = 5;
        acpage=1;
        npages =1;
        strOppId=System.currentPageReference().getParameters().get('Id'); 

        opp = [Select o.Name,o.Id,o.Account.Name,o.CurrencyIsoCode, o.AccountId,CloseDate,StageName 
                From Opportunity o where o.Id =: strOppId];
       
        String qry;
        strAccountId = opp.AccountId ;         
        for(Active_Contract_Product__c ac: [Select Projected_Renewal_Calc__c, ATTRF_CRV__c,dismantle_date__c,Opportunity__r.Opportunity_Number__c,Opportunity__r.Name,a.Renewal_Currency_Name__c,a.Renewal_Product__r.Renewal__r.name,
           a.Renewal_Product__c,a.Active_Contract__r.name,a.Name,a.Product__r.Name, a.Id, a.Converted_To_Opportunity__c, a.Active_Contract__r.Renewal_Currency__c,a.Active_Contract__c,a.AOCV__c,a.OCV__c,a.Active_Contract_Number__c,a.Sales_Price__c,a.Segmentation__c,a.Pre_Segmentation__c,
            a.Active_Contract__r.Account__r.name,a.Renewal_Product__r.Renewal__r.Converted_To_Opportunity__c,a.Renewal_Product__r.Projected_Renewal_LC__c,a.Renewal_Product__r.Projected_Time_Duration_Months__c,a.Active_Contract__r.Contract_Term_Months__c,a.Raw_Maint_Calc_LC__c,a.Product__r.Family 
            From Active_Contract_Product__c a where a.Active_Contract__r.Account__c =:opp.AccountId 
            and (a.Converted_To_Opportunity__c = true or a.Converted_To_Opportunity__c = false) limit 1000]){
             
                    if(opp.CurrencyIsoCode == ac.Renewal_Currency_Name__c)
                    {
                        RenewalProductList.add(new RenewalProductDetails(ac)); 
                        ActProductMap.put(String.ValueOf(ac.id),ac);
                    }
                    
                    if(ac.Name=='ControlMinder')
                        System.debug(ac.Name+'<----________ControlMinder------->'+ac.Opportunity__r.Name+'------------> Number '+ac.Opportunity__r.Opportunity_Number__c);
                                     
        }                                

        hasNext = getHasNext();
        hasPrevious = getHasPrevious();  
              
    }
    
    
        public String sortExpression  
    {     get 
            { 
                   return sortExp;    
             }  
          set   
             {
                 if (value == sortExp)   
                    sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
                 else         sortDirection = 'ASC';       sortExp = value;     
             }
    }
    
    public String getSortDirection() 
    {  
         if (sortExpression == null || sortExpression == '')      
               return 'ASC';  
          else   
              return sortDirection; 
     } 
    
    public void setSortDirection(String value) 
     {  
         sortDirection = value;
     }


    public pagereference clearFilter()
    {

        Contract_No_Filter = '';
        Contract_Name_Filter='';
        Dismantle_Date_Filter='';
        
        RenewalProductList.clear();
        ActProductMap.clear();
     
        
        for(Active_Contract_Product__c ac: [Select a.Projected_Renewal_Calc__c, a.ATTRF_CRV__c,a.dismantle_date__c,a.Opportunity__r.Opportunity_Number__c,a.Opportunity__r.Name,a.Renewal_Currency_Name__c,a.Renewal_Product__r.Renewal__r.name,a.Renewal_Product__c,a.Active_Contract__r.name, 
            a.Name,a.Product__r.Name, a.Id,a.Converted_To_Opportunity__c,a.Active_Contract__r.Renewal_Currency__c,a.Active_Contract__c,a.AOCV__c,a.OCV__c,a.Active_Contract_Number__c,a.Sales_Price__c,a.Segmentation__c,a.Pre_Segmentation__c,
            a.Active_Contract__r.Account__r.name,a.Renewal_Product__r.Renewal__r.Converted_To_Opportunity__c,a.Renewal_Product__r.Projected_Renewal_LC__c,a.Renewal_Product__r.Projected_Time_Duration_Months__c,a.Active_Contract__r.Contract_Term_Months__c,a.Raw_Maint_Calc_LC__c,a.Product__r.Family //,(Select PricebookEntryId From Opportunity_Product__r)
            From Active_Contract_Product__c a where a.Active_Contract__r.Account__c =:opp.AccountId 
            and (a.Converted_To_Opportunity__c = true or a.Converted_To_Opportunity__c = false) limit 1000]){
              
                    if(opp.CurrencyIsoCode == ac.Renewal_Currency_Name__c){
                        RenewalProductList.add(new RenewalProductDetails(ac)); 
                        ActProductMap.put(String.ValueOf(ac.id),ac);
                       }                        
              }                                
        
        hasNext = getHasNext();
        hasPrevious = getHasPrevious();        

        return null;
    }
    public pagereference ViewData()
    {
        
        Contract_No_Filter = Contract_No_Filter.replaceAll(',','');
        Contract_Name_Filter = Contract_Name_Filter.replaceAll(',','') ;
        
     try{
     WhereCond = '';
    if(Contract_No_Filter != '')
        WhereCond = '  and a.Active_Contract__r.name = \'' + Contract_No_Filter  + '\'';
    if(Contract_Name_Filter != '')
       WhereCond = WhereCond +  '  and a.Name = \'' + Contract_Name_Filter + '\'';
    if(Dismantle_Date_Filter != '')
       WhereCond = WhereCond +  '  and dismantle_date__c = ' + date.parse(Dismantle_Date_Filter);
 
       WhereCond = '\'' + strAccountId + '\'' + WhereCond ;

        string sortFullExp = sortExpression  + ' ' + sortDirection;        

        RenewalProductList.clear();
        ActProductMap.clear();
        
                String qry  = 'Select a.ATTRF_CRV__c,a.dismantle_date__c,a.Opportunity__r.Opportunity_Number__c,a.Opportunity__r.Name,a.Renewal_Currency_Name__c,a.Renewal_Product__r.Renewal__r.name,a.Renewal_Product__c,a.Active_Contract__r.name,';
                qry  = qry + 'a.Name,a.Product__r.Name,a.Id,a.Converted_To_Opportunity__c,a.Active_Contract__r.Renewal_Currency__c,a.Active_Contract__c,a.AOCV__c,a.OCV__c,a.Active_Contract_Number__c,a.Sales_Price__c,a.Segmentation__c,a.Pre_Segmentation__c,a.Active_Contract__r.Account__r.name,';
                qry  = qry + 'a.Projected_Renewal_Calc__c, a.Renewal_Product__r.Renewal__r.Converted_To_Opportunity__c,a.Renewal_Product__r.Projected_Renewal_LC__c,a.Renewal_Product__r.Projected_Time_Duration_Months__c,a.Active_Contract__r.Contract_Term_Months__c,a.Raw_Maint_Calc_LC__c,a.Product__r.Family';
                qry  = qry + ' From Active_Contract_Product__c a where ';
                qry  = qry + ' (a.Converted_To_Opportunity__c = false or a.Converted_To_Opportunity__c = true) and a.Active_Contract__r.Account__c = ' + WhereCond;
                qry  = qry + '  order by ' +   sortFullExp + ' limit 1000';                   
                RenewalProductList.clear();
                ActProductMap.clear();
                List<Active_Contract_Product__c> act_temp = new List<Active_Contract_Product__c>();
                
                //System.debug('_________________________Anitha Query on Sort'+qry);
                act_temp = Database.query(qry);
                
                for(Active_Contract_Product__c ac: act_temp){                        
                                RenewalProductList.add(new RenewalProductDetails(ac)); 
                                ActProductMap.put(String.ValueOf(ac.id),ac);
                        }                        
                act_temp = null; 
                hasNext = getHasNext();
                hasPrevious = getHasPrevious();   
               List<RenewalProductDetails> my_plist = new List<RenewalProductDetails>();
                 pageSize = pages;
                 
                 
                if(getResultSize() > pageSize)
                {
                  
                    respg = (getResultsize()/pagesize);
                    
                  
                    
                    reminder = math.mod(getResultsize(),pagesize);
                    
                    
                    if(reminder != 0)
                    {
                        npages = respg + 1;
                    }
                    else
                    {
                        npages = respg;
                    }
                    
                    if((acpage > npages) || (acpage <=0))
                    {
                        acpage = 1;
                    }
                    
                    pageSize = pages;
                   
                   
                    
                    remainder = getResultsize() - (pageSize*npages);   
                    
                    for (integer i=0; i<pagesize; i++)
                    {
                        if(((acpage-1)*pagesize +i) < getResultsize())
                        my_plist.add(RenewalProductList[(acpage-1)* pageSize + i]); 
                    }
                    
                }        
                else
                {
                    acpage = 1;
                    npages = 1; 
                }
                
                if(npages == 1)
                {
                    hasNext = false;
                    hasPrevious = false;
                    
                }
                else
                {
                    hasNext = getHasNext();
                    hasPrevious = getHasPrevious();   
                }
                                     
                return null; 
     }catch(Exception e){
        ApexPages.addMessages(e);
           return null;                 
     }           
    }

    public pagereference applyFilter()
        {                     
         ViewData();
         return null;            
        }
    List<OpportunityLineItem> oppLineItm = new List<OpportunityLineItem>();
    List<CA_Product_Renewal__c> caProdRnwl = new List<CA_Product_Renewal__c>();
    
    public pagereference addProduct(){
                      
     try
        {

            Map<id, PricebookEntry> mapPE = new Map<id,PricebookEntry>();
            Set<id> prodIds = new Set<id>();
            for(RenewalProductDetails lstVal:RenewalProductList)
              {                   
                if(lstVal.selected)
                {   
                    prodIds.add(lstVal.activeContractProd.Product__c);
                }
             }

             for(PricebookEntry pe:[Select Id,Name, Product2id From PricebookEntry where Product2id in : prodIds and currencyIsoCode=:opp.CurrencyIsoCode and Pricebook2Id=: strpricebookid  and IsActive =:true])
                    {
                        if(! mapPE.keyset().contains(pe.Product2id))
                            mapPE.put(pe.Product2id, pe);
                    }



              for(RenewalProductDetails lstVal:RenewalProductList)
              {                   
                if(lstVal.selected)
                {                                                                
                   OpportunityLineItem oli = new OpportunityLineItem();
                        
                   String RenewalName=lstVal.activeContractProd.Active_Contract__r.Name;
                   String RenewalproductName=lstVal.activeContractProd.name;
                   String segment;
                     If(lstVal.activeContractProd.Segmentation__c =='HT'||lstVal.activeContractProd.Segmentation__c =='MT'||lstVal.activeContractProd.Segmentation__c =='LT'||lstVal.activeContractProd.Segmentation__c =='NT'){
                           segment=lstVal.activeContractProd.Segmentation__c;  
                     }else{ segment = lstVal.activeContractProd.Pre_Segmentation__c; }
                        
                        if(RenewalName.length()>20)
                        {
                           RenewalName =RenewalName.Substring(0,20);
                        }
                    if(RenewalproductName.length()>60)
                    {
                       RenewalproductName =RenewalproductName.Substring(0,60);
                    }
                    caProdRnwl.add(new  CA_Product_Renewal__c(
                     Name= RenewalName+ '-' +RenewalproductName,
                     Active_Contract_Product__c= lstVal.activeContractProd.id,
                     Contract__c = lstVal.activeContractProd.Active_Contract__c,
                     Raw_Maintenance__c =lstVal.activeContractProd.Raw_Maint_Calc_LC__c,
                     Renewal_Opportunity__c= opp.Id,
                     currencyIsoCode = opp.CurrencyIsoCode,
                     CAProductRenewal_Amount__c = lstVal.activeContractProd.AOCV__c,
                     ATTRF__c = lstVal.activeContractProd.ATTRF_CRV__c,
                     TRR__c= lstVal.activeContractProd.AOCV__c,
                     Projected_Renewal__c= lstVal.activeContractProd.Projected_Renewal_Calc__c
                     //,Inside_Outside__c ='Outside'
                    ));
                                    
                 
                    PricebookEntry p= mapPE.get(lstVal.activeContractProd.Product__c);
                                   
                                
                        if(p != null){
                        oli.PricebookEntryId= p.Id;
                        oli.CA_Contract_Product_Name__c = RenewalName+ '-' +RenewalproductName;
                        oli.Active_Contract_Product__c = lstVal.activeContractProd.id;
                        oli.Active_Contract__c =  lstVal.activeContractProd.Active_Contract__c;
                        oli.OpportunityId = opp.Id;
                        oli.Raw_Maintenance__c = lstVal.activeContractProd.Raw_Maint_Calc_LC__c;
                        oli.ATTRF__c = lstVal.activeContractProd.ATTRF_CRV__c;
                        oli.Old_TRR__c= lstVal.activeContractProd.AOCV__c;
                        if(lstVal.activeContractProd.Projected_Renewal_Calc__c <> null)
                            oli.UnitPrice= lstVal.activeContractProd.Projected_Renewal_Calc__c;
                        else 
                            oli.UnitPrice= 0;

        
                       //oli.Stretch__c=oli.UnitPrice;                           
                        oli.Business_Type__c  = 'Renewal';
                        oli.Segmentation__c= segment;
                        oli.Original_Expiration_Date__c = lstVal.activeContractProd.Dismantle_Date__c;
                        oli.Original_Deal_Term_Months__c= lstVal.activeContractProd.Active_Contract__r.Contract_Term_Months__c;
                        oli.New_Deal_Term_Months__c= lstVal.activeContractProd.Renewal_Product__r.Projected_Time_Duration_Months__c;
                        oli.Original_CV__c= lstVal.activeContractProd.OCV__c;
                        oli.Original_Contract_IDs__c= lstVal.activeContractProd.Active_Contract_Number__c;
                        //oli.Inside_Outside__c ='Outside';
                        //oli.Close_Date__c = opp.CloseDate;
                        //oli.Sales_Milestone__c = opp.StageName;
                        
                        }
                      
                        oppLineItm.add(oli);
                        ActPdtlst.add(ActProductMap.get(String.ValueOf(lstVal.activeContractProd.id)));                             
                      }   
                       
                    } 
                      
                      
                 ActProductMap.clear();
                
                //FY13 start
                Map<id,id> mOLIACP = new Map<id,id>();
                Map<id,id> mRCPACP = new Map<id,id>();
                
                //FY13 end
                
                        
                                   
                 if(oppLineItm.size()>0){
                    insert oppLineItm;
                    //FY13
                    for(OpportunityLineItem oli: oppLineItm)
                    { 
                        mOLIACP.put(oli.Active_Contract_Product__c,oli.id);
                    }
                    
                 }
                 if(caProdRnwl.size()>0){
                    insert caProdRnwl;
                    //FY13
                    for(CA_Product_Renewal__c cpr: caProdRnwl)
                    { 
                        mRCPACP.put(cpr.Active_Contract_Product__c, cpr.id);
                    }
                 }       
                 If(ActPdtlst.size() > 0){
                     for(Active_Contract_Product__c a:ActPdtlst){
                         a.Converted_To_Opportunity__c = true;
                         a.Opportunity__c = opp.id; 
                         a.Sales_Price__c= a.Projected_Renewal_Calc__c;
                         a.Opportunity_Product__c =mOLIACP.get(a.id);//FY13
                         a.Renewal_Contract_Product__c =mRCPACP.get(a.id);//FY13
                         ActProduct.add(a);                          
                         }
                        ActPdtlst = null;
                  } 
                        
                         
                         
                 if(ActProduct.size() > 0)
                 {
                     update ActProduct;
                 }
                 PageReference pageRef = new PageReference('/'+opp.Id);
                 pageRef.setRedirect(true);
                 return pageRef;
                }
            catch(Exception e)
            {
                  if(e.getDmlType(0)==StatusCode.REQUIRED_FIELD_MISSING)
                    {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Pricebook is not active for selected product(s)!');    
                   ApexPages.addMessage(myMsg);
                   return null;
                    } 
                   else{ 
                    ApexPages.addMessages(e);
                    return null;
                  }
            } 
           
          
        
        
    }
    
     public List<SelectOption> getPageno() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('5','5'));
            options.add(new SelectOption('10','10'));
            options.add(new SelectOption('15','15'));
            options.add(new SelectOption('25','25'));
            options.add(new SelectOption('50','50'));
            options.add(new SelectOption('100','100'));
            options.add(new SelectOption('200','200'));
            
            return options;
        }
    
    public PageReference check(){
     pageSize = pages;
      if((acpage > npages) || (acpage <=0))
            {
               acpage = 1;
            }
          hasNext = getHasNext();
          hasPrevious = getHasPrevious(); 
          return null;
    }
    
    public List<RenewalProductDetails> getRenewalProductList(){
        pageSize = pages;
        
        if(getResultSize() > pageSize)
     {
             List<RenewalProductDetails> my_plist = new List<RenewalProductDetails>();
             respg = (getResultsize()/pagesize);          
             reminder = math.mod(getResultsize(),pagesize);         
            
            if(reminder != 0)
            {
                npages = respg + 1;
            }
            else
            {
                npages = respg;
            }
                                 
             remainder = getResultsize() - (pageSize*npages);   
                
              for (integer i=0; i<pagesize; i++)
              {
                 if(((acpage-1)*pagesize +i) < getResultsize())
                 my_plist.add(RenewalProductList[(acpage-1)* pageSize + i]); 
               }
            return my_plist;
     }else{
         acpage = 1;
         npages = 1; 
         }
         
          if(npages == 1)
                {
                    hasNext = false;
                    hasPrevious = false;
                    
                }
                else
                {
                    hasNext = getHasNext();
                    hasPrevious = getHasPrevious();   
                }
                 
     return RenewalProductList;
              
    }  
    
    
    
    public boolean getHasNext() {
        pageSize = pages;
          if(((npages == acpage)&&(remainder==0)) || getResultSize() == 0 || getResultSize() < pageSize || (acpage*pageSize) >=getResultSize())
            return false;
        else    
            return true;
    }

    public Boolean getHasPrevious() {
       pageSize = pages;
       if( getResultSize() == 0 || acpage == 1 )
            return false;
        else
            return true;    
    }
    
    public Integer getPageSize() {  
           return pageSize;   
    }  

    public void setPageSize(Integer pages) {
           if(pages != pageSize)
            {       
                acpage =1;
                pageSize = pages;
            }
   }
    public void next() {           
           acpage +=1;        
           hasNext=getHasNext();
           hasPrevious = getHasPrevious();
          
    }
  
    public void previous() {
           acpage-=1;        
           hasNext=getHasNext();
           hasPrevious = getHasPrevious();
    }
    
    public Integer getResultSize() {
        if(RenewalProductList== null)
            return 0;
        else
            return RenewalProductList.size();
   }
   
   public class RenewalProductDetails{
        public Active_Contract_Product__c activeContractProd{get; set;}
        public Boolean selected {get; set;}
        
        public RenewalProductDetails(Active_Contract_Product__c a){
            activeContractProd= a;
            selected = false;
        }
    }
}