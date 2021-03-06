public with sharing class Renewal_editOppProduct {
    String strOppId;   
    String WhereCond;   
    //added these variable to get the filter values.
    public String Product_Name_Filter {get;set;}
    public String Orig_Exp_Date_Filter {get;set;}
    public String Raw_Maint_Calc_Filter {get;set;}
    public String Sales_Price_Filter{get;set;}
    public String Stretch_Filter {get;set;}
    public String Quote_Filter {get;set;}
    public String Contract_Filter {get;set;}
    public String BusinessType_Filter {get;set;}
    public String quote {get;set;}
    public Decimal ContractNo {get;set;}
    public integer npages;    
    public integer remainder;
    public integer acpage = 1;
    public Integer PageSize = 10 ;
    public List<OpportunityLineItem> oppItmList;
    public Opportunity opp_temp {get;set;}
    public Decimal TotalSP {get;set;}
    public Boolean showMsg {get;set;}
    private String sortDirection = 'ASC'; 
    private String sortExp = 'CA_Contract_Product_Name__c';   
    public  Map<ID,CA_Product_Renewal__c> mapACPidToRCPrecord = new Map<id,CA_Product_Renewal__c>();
    public  List<CA_Product_Renewal__c> lstUpdateRCP = new List<CA_Product_Renewal__c>();
    public  Map<ID,Active_Contract_Product__c> mapACPidToACPrecord = new Map<id,Active_Contract_Product__c>();
    public  List<Active_Contract_Product__c> lstUpdateACP = new List<Active_Contract_Product__c>();
    public decimal totalStretch;
    public decimal TimeRenewal{get;set;}
    public decimal PageStretch{get;set;}
    public void PopulateRenewalProducts()
    {
         for(CA_Product_Renewal__c ca :[select Id, Quote__C, Contract_No__c, 
                                               Projected_Renewal__c, 
                                               Active_Contract_Product__c 
                                          from CA_Product_Renewal__c 
                                         where Renewal_Opportunity__c =:strOppId ])
            {
                mapACPidToRCPrecord.put(ca.Active_Contract_Product__c, ca);  
            }
         // Code for Updating Active Contract Products - 7 Oct 2011         
         for(Active_Contract_Product__c acp :[select Id, Sales_Price__c, 
                                                     Opportunity_Product__c, 
                                                     Renewal_Contract_Product__c 
                                                from Active_Contract_Product__c 
                                               where Opportunity__c =:strOppId ])
            {
                mapACPidToACPrecord.put(acp.Id, acp);  
            }         
         
    }
    
    
    Set<Id> rwlpdt = new Set<Id>();
    public Renewal_editOppProduct(ApexPages.StandardController controller) 
    {
        strOppId=system.currentPageReference().getParameters().get('Id');
  
        if(strOppId <> null)
            opp_temp = [Select id, Quote_Number__c,Reason_duration_is_1_year__c,Status_at_end_of_term__c, New_Deal_Term_months__c, Contract_Number_EU4cast__c,  name,  
                               Total_Raw_Maintenance_Cacl__c, Stretch_Deal_Term_Months__c, 
                               Stretch_Sales_Price_Gap_Reason__c, Business_Type__c , Projected_Renewal__c, 
                               Time_Renewal_Roll_Up__c
                          From Opportunity 
                         where id = : strOppId];
        else
            opp_temp = new Opportunity();
       
        TotalSP = opp_temp.Projected_Renewal__c;
               
        TimeRenewal = opp_temp.Time_Renewal_Roll_Up__c; //danva01
        TimeRenewal = TimeRenewal.setScale(2,System.RoundingMode.HALF_UP);             

        //TimeRenewal = opp_temp.Time_Renewal_Roll_Up__c.Scale();

        oppItmList = new List<OpportunityLineItem>();
        mainMethod();
    
    }

    public void mainMethod()
    {
        oppItmList = new List<OpportunityLineItem>();
        PopulateRenewalProducts();

        PageStretch = 0;
        
        // modifed based on req. 1.06 by subsa03 
        for(OpportunityLineItem Opplineitm:[select o.Contract_Number__c, o.CA_Contract_Product_Name__c,
                                                   o.Opportunity.New_Deal_Term_months__c, o.Opportunity.Stretch_Deal_Term_Months__c,
                                                   o.Opportunity.Stretch_Sales_Price_Gap_Reason__c,
                                                   o.Opportunity.Business_Type__c, o.Opportunity.id, o.Opportunity.Projected_Renewal__c,
                                                   o.Opportunity.name, o.Opportunity.Total_Raw_Maintenance_Cacl__c, o.Original_Expiration_Date__c,
                                                   o.Active_Contract_Number__c, o.Quote_Number__c, o.UnitPrice, o.Stretch__c,
                                                   o.Segmentation__c,o.Raw_Maintenance__c,o.Business_Type__c,
                                                   o.Active_Contract_Product__r.Active_Contract_Number__c 
                                              from opportunitylineitem o 
                                             where o.opportunity.id=:strOppId
                                               and Business_Type__c = 'Renewal'])
            {
            Opplineitm.UnitPrice = Opplineitm.UnitPrice.setScale(2,System.RoundingMode.HALF_UP);             
            oppItmList.add(Opplineitm);
            rwlpdt.add(Opplineitm.Active_Contract_Product__c);
            System.debug('************');
            if(Opplineitm.Stretch__c <> null)  {       //fy13 - lfc              
               System.debug('************ Opplineitm.stretch'+Opplineitm.Stretch__c);
               PageStretch += Opplineitm.Stretch__c; //fy13 - lfc
               System.debug('************ PageStretch'+PageStretch);   
               }    
            }
        if(PageStretch!=0)
            PageStretch = PageStretch.setScale(2,System.RoundingMode.HALF_UP); // fy13 - lfc
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
        Product_Name_Filter = '';
        Orig_Exp_Date_Filter = '';
        Raw_Maint_Calc_Filter= '';
        Sales_Price_Filter= '';
        Stretch_Filter= '';
        Quote_Filter= '';
        Contract_Filter = '';
        BusinessType_Filter ='';

        oppItmList.clear(); 
        mainMethod();

        return null;
    }
    public pagereference ViewData()
    {
     oppItmList = new List<OpportunityLineItem>();      
     try{
        WhereCond = '';
        if(Product_Name_Filter != '')
            WhereCond = '  and l.CA_Contract_Product_Name__c = \'' + Product_Name_Filter + '\'';
        if(Orig_Exp_Date_Filter != '')
           WhereCond = WhereCond +  '  and l.Original_Expiration_Date__c = ' + date.parse(Orig_Exp_Date_Filter);
        WhereCond = WhereCond.replace(' 00:00:00','');
        WhereCond = '\'' + strOppId + '\'' + WhereCond ;

        string sortFullExp = sortExpression  + ' ' + sortDirection;        
        String qry  = 'Select l.Contract_Number__c, l.CA_Contract_Product_Name__c,l.Opportunity.New_Deal_Term_months__c,' ; 
             qry  = qry + ' l.Opportunity.Stretch_Deal_Term_Months__c, ' ;
             qry  = qry + 'l.Opportunity.Stretch_Sales_Price_Gap_Reason__c,';
             qry  = qry + 'l.Opportunity.Business_Type__c,l.Opportunity.id,';
             qry  = qry + 'l.Opportunity.Projected_Renewal__c,l.Opportunity.name,';
             qry  = qry + 'l.Opportunity.Total_Raw_Maintenance_Cacl__c,';
             qry  = qry + 'l.Original_Expiration_Date__c,l.Active_Contract_Number__c,l.Active_Contract_Product__r.Active_Contract_Number__c,';
             qry  = qry + 'l.Quote_Number__c,l.UnitPrice,l.Stretch__c,l.Segmentation__c,';
             qry  = qry + 'l.Raw_Maintenance__c,l.Business_Type__c From opportunitylineitem l ' ; 
             qry  = qry + 'where  l.OpportunityId = '+ WhereCond + ' AND Business_Type__c =\'Renewal\' order by ' +  sortFullExp + ' limit 1000';                   
            oppItmList = Database.query(qry);
            
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
       }
     return null;
       
    }

    public pagereference applyFilter()
        {                     
      
               ViewData();
                return null;
        }
    // here need to add oppline item
    public pagereference updateOpportunity(){
        
        try {
                        lstUpdateRCP = new List<CA_Product_Renewal__c>(); //Code for Updating Renewal Contract Products
            lstUpdateACP = new List<Active_Contract_Product__c>(); //Code for Updating Active Contract Products - 7 Oct 2011
        
            // FY13 - If specified Total Stretch is less than Total Sales Price, default to Total Sales Price
            if(PageStretch < TimeRenewal){
                PageStretch = TimeRenewal;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Total Stretch may not be less than Sales Price. Value adjusted.'));
                }

//            if(oppItmList.size() > 1){ 

                // handle Opp Line Item list where there are multiple lines
                for(OpportunityLineItem Oli:oppItmList){

                    // Default values if line item raw maint is not > 0 or if total raw maint is not > 0
                    if((Oli.raw_maintenance__c == null || Oli.raw_maintenance__c == 0) ||
                       (opp_temp.Total_Raw_Maintenance_Cacl__c  == null || opp_temp.Total_Raw_Maintenance_Cacl__c == 0)){
                        Oli.UnitPrice = 0;
                        Oli.Stretch__c = 0;
//                        PageStretch = 0;
                        }

                    // Header and line item raw maint is > 0, so we can pro-rate sales price and stretch
//                    else{

                        // Pro-rate the sales price based on raw maint
                        Oli.UnitPrice = (Oli.raw_maintenance__c / opp_temp.Total_Raw_Maintenance_Cacl__c) * TimeRenewal;
                        Oli.UnitPrice = Oli.UnitPrice.setScale(2,System.RoundingMode.HALF_UP);             
        
                        // Pro-rate the total stretch based on total slaes price
                        if(Oli.UnitPrice > 0){
                            Oli.Stretch__c = (Oli.UnitPrice / TimeRenewal) * PageStretch;
                            Oli.Stretch__c = Oli.Stretch__c.setScale(2,System.RoundingMode.HALF_UP);
                            }
                        else
                            Oli.Stretch__c = 0.0;

//                        // FY13 - If Total Stretch is not specified, default line item stretch to Sales Price (even if SP is 0)
//                        if(PageStretch == null || PageStretch == 0) 
//                            Oli.Stretch__c = oli.UnitPrice;
//
//                        // FY13 - If specified Stretch is less than Sales Price, default to Sales Price
//                        else{
//                            if(Oli.Stretch__c < oli.UnitPrice){
//                                Oli.Stretch__c = oli.UnitPrice;
//                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Line Item Stretch may not be less than Sales Price. Value adjusted.'));
//                                }
//                            if(!(PageStretch < TimeRenewal) && !(Oli.Stretch__c < oli.UnitPrice))
//                                Oli.Stretch__c = (Oli.UnitPrice / TimeRenewal)* PageStretch;
//                            }
//                        }
                   
                    // Update Quote Number on line item, if one is specified on the header
                    if(Oli.Quote_Number__c == '' || Oli.Quote_Number__c == Null)
                        Oli.Quote_Number__c = opp_temp.quote_number__c;

                    // Update Contract Number on line items, if one is specified on the header
                    if(Oli.Contract_Number__c == null || Oli.Contract_Number__c == '0' || Oli.Contract_Number__c == '0.0'){
                         if(ContractNo != 0)
                             Oli.Contract_Number__c = String.valueOf(opp_temp.Contract_Number_EU4cast__c);
                         else
                             Oli.Contract_Number__c = '';
                         } 
                
                    //Code for Updating Renewal Contract Products - Start
                    CA_Product_Renewal__c capr = mapACPidToRCPrecord.get(oli.Active_Contract_Product__c);
                    if(capr <> null){
                        capr.Projected_Renewal__c = oli.UnitPrice;
                        // capr.Stretch__c = oli.Stretch__c;
                        capr.Quote__c = oli.Quote_Number__c;
                        capr.Contract_no__c = oli.Contract_Number__c;
                        lstUpdateRCP.add(capr);
                        }   
                    //Code for Updating Renewal Contract Products - End
        
                    //Code for Updating Active Contract Products  - 7 Oct 2011 - Start
                    Active_Contract_Product__c acp = mapACPidToACPrecord.get(oli.Active_Contract_Product__c);
                    if(acp <> null){
                        acp.Sales_Price__c = oli.UnitPrice;
                        acp.Opportunity_Product__c = oli.Id;
                        if(capr<>null)
                            acp.Renewal_Contract_Product__c = capr.Id;
                        lstUpdateACP.add(acp);
                        }   
                    //Code for Updating Active Contract Products - 7 Oct 2011 - End
        
                    }
//                }
//            else{
//                // handle case of 0 or 1 line item by applying values from header - 20120419
//                if(Oli.Stretch__c < oli.UnitPrice || PageStretch < TimeRenewal){
//                    Oli.Stretch__c = oli.UnitPrice;
//                    PageStretch = TimeRenewal;
//                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Stretch may not be less than Sales Price. Values adjusted.'));
//                    }
//                else{
//                    Oli.UnitPrice  = TimeRenewal;
//                    Oli.Stretch__c = PageStretch;
//                    }
//                }
    
            TotalSP = opp_temp.Time_Renewal_Roll_Up__c; //opp_temp.Projected_Renewal__c;
            Renewals_Util.Renewal_updateProjectedRenewalOnOpp = true;         
//          opp_temp.Time_Renewal_Roll_Up__c = TimeRenewal;
            
            update opp_temp;

            if(oppItmList.size()>0)    
                update oppItmList;
        
            //Code for Updating Active Contract Products  - 7 Oct 2011 
            if(lstUpdateACP.size()> 0)
                update lstUpdateACP;   

            if(lstUpdateRCP.size()> 0)
                update lstUpdateRCP;   

            } catch(Exception e)
            {
                if(!e.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception '+e);
                ApexPages.addMessage(msg); 
                }
                else if(e.getmessage().contains('Reason duration is ')){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Reason duration is < 1 year and Status at end of term fields are required when Projected Time Duration (Months) < 12');
                ApexPages.addMessage(msg); 
                }
            }
        
        return null;
        } 

    // Opportunity product is updated based on the 1.06 req by subsa03
    public pagereference updateProducts(){

        decimal newSP = 0;

        try{
        
        // Prep lists for RCP and ACP updates
        lstUpdateRCP = new List<CA_Product_Renewal__c>();
        lstUpdateACP = new List<Active_Contract_Product__c>();

        if(oppItmList.size() > 0){
            newSP = 0;

            for(OpportunityLineItem oli:oppItmList){
                newSP += oli.UnitPrice;

                // Update Renewal Contract Product
                CA_Product_Renewal__c capr = mapACPidToRCPrecord.get(oli.Active_Contract_Product__c);
                if(capr <> null){
                    capr.Quote__C = oli.Quote_Number__c;
                    capr.Contract_No__c = oli.Contract_Number__c;
                    capr.Projected_Renewal__c = oli.UnitPrice;
                    lstUpdateRCP.add(capr);
                    } 

                // Update Active Contract Product - 7 Oct 2011
                Active_Contract_Product__c acp = mapACPidToACPrecord.get(oli.Active_Contract_Product__c);
                if(acp <> null){
                    acp.Sales_Price__c = oli.UnitPrice;
                    acp.Opportunity_Product__c = oli.Id; //FY13
                    if(capr <> null)
                        acp.Renewal_Contract_Product__c = capr.Id; //FY13
                    lstUpdateACP.add(acp);
                    } 
                }                

            // Adjust Total Stretch if Total Sales Price goes above it
            if(PageStretch < newSP) {
                PageStretch = newSP;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Total of Sales Price values may not exceed Stretch. Stretch value adjusted.'));
                }

            // Prorate Total Stretch based on new total sales price
            for(OpportunityLineItem oli:oppItmList){
                if(oli.UnitPrice > 0){
                    oli.Stretch__c = (oli.UnitPrice / newSP) * PageStretch;
                    oli.Stretch__c = oli.Stretch__c.setScale(2,System.RoundingMode.HALF_UP);
                    }
                else
                    oli.Stretch__c = 0.0;

                }
            }       
         
//        if(oppItmList.size() > 0){
//            for(OpportunityLineItem oli:oppItmList){
//                //newSP +=oli.UnitPrice;
//                //oli.stretch__c  = oli.UnitPrice;
//                Active_Contract_Product__c acp = mapACPidToACPrecord.get(oli.Active_Contract_Product__c);
//                if(acp <> null){
//                    acp.Sales_Price__c = oli.UnitPrice;
//                    acp.Opportunity_Product__c = oli.Id; //FY13
//                    lstUpdateACP.add(acp);
//                    } 
//                }
//            }       

            if(TotalSP  <> newSP){
                TotalSP = newSP;
                TimeRenewal = newSP;
                //opp_temp.Time_Renewal_Roll_Up__c= newSP;   //opp_temp.Projected_Renewal__c = newSP;
                //opp_temp.Time_Renewal_Roll_Up__c = TimeRenewal;
                update opp_temp;
                }

            if(oppItmList.size()>0)    
                update oppItmList;

            //Code for Updating Active Contract Products  - 7 Oct 2011 
            if(lstUpdateACP.size() >0)
                update lstUpdateACP;

            if(lstUpdateRCP.size() >0)
                update lstUpdateRCP;
    
            return null;
// Replaced following lines to make the Save Products and Save Opportunity functions consistent. - FY13
//            PageReference pg =new PageReference('/'+strOppId);
//            pg.setRedirect(true);
//            return pg;                    
     
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception '+e);
            ApexPages.addMessage(msg); 
        }
        return null;
        
    }  
      
    public void setOppItmList(List<OpportunityLineItem> oppItmList){
        this.oppItmList = oppItmList;
    }
    

    public List<OpportunityLineItem> getOppItmList(){
        
        if(getResultSize() > pageSize)
     {
             List<OpportunityLineItem> my_plist = new List<OpportunityLineItem>();
             npages = getResultsize()/pagesize;
             remainder = getResultsize() - (pageSize*npages);   
                
              for (integer i=0; i<pagesize; i++)
              {
                 if(((acpage-1)*pagesize +i) < getResultsize())
                 my_plist.add(oppItmList[(acpage-1)* pageSize + i]); 
               }
            return my_plist;
     }        
     return oppItmList;
        
        
    } 
    
    
    
    public boolean getHasNext() {
         if(((npages == acpage)&&(remainder==0)) || getResultSize() == 0 || getResultSize() < pageSize || (acpage*pageSize) >=getResultSize())
            return false;
        else    
            return true;
    }

    public Boolean getHasPrevious() {
        if( getResultSize() == 0 || acpage == 1 )
            return false;
        else
            return true;    
    }
    
    public Integer getPageSize() {  
           return pageSize;   
    }  

    public void setPageSize(Integer ps) {
           if(ps != pageSize)
            {       
                acpage =1;
                pageSize = ps;
            }
   }
    public void next() {
           acpage +=1;
    }
  
    public void previous() {
           acpage-=1;
    }
    

    public Integer getResultSize() {
        if(oppItmList== null)
            return 0;
        else
            return oppItmList.size();
   }
    

}