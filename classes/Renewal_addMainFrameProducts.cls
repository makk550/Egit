public class Renewal_addMainFrameProducts {
    public String salesPrice_usd {get;set;}
//    public String Stretch_usd {get;set;}
    public List<OpportunityLineItem> lstoppoli {get;set;}
    public Opportunity opportunity {get;set;}
    public OpportunityLineItem oppLineItem {get;set;}
    public Boolean alert {get; set;}   //allha02 3576  
    public Renewal_addMainFrameProducts(ApexPages.StandardController controller) {
        
        alert=false ;
        opportunity = [select Name,Business_Type__c,Original_Contract_IDs__c,New_Deal_Term_Months__c, CurrencyIsoCode ,
                              Stretch_Deal_Term_Months__c, Original_Expiration_Quarter__c, 
                              Projected_Renewal__c,Stretch_Sales_Price_Gap_Reason__c,  Contract_Number_EU4cast__c,
                              Quote_Number__c,Business_Partner_ID__c,Status_at_end_of_term__c,Reason_duration_is_1_year__c,
                              Renewal_Quota_CV__c,Original_CV__c,Original_Deal_Term_Months__c,CloseDate,StageName,
                          (select id, Contract_Number__c, Business_Type__c, Quote_Number__c, OpportunityId, UnitPrice,
                                  Stretch__c, Sales_Price_USD__c, Term_Month__c, New_Deal_Term_Months__c
                             from OpportunityLineItems
                            where PricebookEntry.product2.Family ='Mainframe Capacity'
                              and PricebookEntry.product2.name ='Mainframe Capacity'
                              and PricebookEntry.product2.Market_Focus_Area__c = 'Mainframe Capacity')
                         from Opportunity 
                        where Id=:ApexPages.currentPage().getParameters().get('oppid')
                     order by createddate asc]; 
        oppLineItem = new  OpportunityLineItem();       
        if(opportunity.OpportunityLineItems.size()>0){                                    
            oppLineItem = opportunity.OpportunityLineItems.get(0);
//             Stretch_usd = String.ValueOf(oppLineItem.Stretch_USD__c);
             salesPrice_usd = String.ValueOf(oppLineItem.Sales_Price_USD__c);            
        }
        else{
            List<PricebookEntry> oldPr = [select name,product2Id,pricebook2Id from  PricebookEntry where
                                        CurrencyIsoCode =:opportunity.CurrencyIsoCode 
                                        and product2.Family ='Mainframe Capacity'
                                        and product2.name ='Mainframe Capacity'
                                        and product2.Market_Focus_Area__c = 'Mainframe Capacity'
                                        and Pricebook2.IsActive = true];
            oppLineItem.PricebookEntryId = oldPr.get(0).Id;                            
            oppLineItem.OpportunityId = opportunity.Id;
            oppLineItem.Business_Type__c = 'MF Capacity';
            
        }        
        /*if(lstoppoli.size()>0){
            
            oppLineItem.UnitPrice = lstoppoli.get(0).UnitPrice;
            oppLineItem.Term_Month__c= lstoppoli.get(0).Term_Month__c;
        }*/
       
    }
    public pagereference saveproducts(){
    alert=false ; //allha02 3576
    try {
       
  
        
        // fy13 - BR165 - default stretch deal term if not specified
        if(opportunity.Stretch_Deal_Term_Months__c == null || opportunity.Stretch_Deal_Term_Months__c == 0) {
            opportunity.Stretch_Deal_Term_Months__c = opportunity.New_Deal_Term_months__c;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Stretch Deal Term is required. Stretch Deal Term value adjusted to New Deal Term.');
           ApexPages.addMessage(myMsg);
           alert= true;
        }

        // fy13 - BR165 - default stretch amount if not specified
        if(oppLineItem.Stretch__c == null || oppLineItem.Stretch__c < oppLineItem.UnitPrice){
            oppLineItem.Stretch__c = oppLineItem.UnitPrice; //allha02 3576
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Stretch is required and must be greater than or equal to Sales Price.  Stretch value adjusted.');
           ApexPages.addMessage(myMsg);
           alert= true;
        }

        oppLineItem.New_Deal_Term_Months__c= opportunity.New_Deal_Term_months__c;
        oppLineItem.Original_Deal_Term_Months__c = opportunity.Original_Deal_Term_Months__c;
        oppLineItem.Original_Contract_IDs__c = opportunity.Original_Contract_IDs__c;
        oppLineItem.Business_Type__c = 'MF Capacity';
        oppLineItem.MF_Cap__c = TRUE;
        
        
      if((Opportunity.Reason_duration_is_1_year__c == null &&  oppLineItem.New_Deal_Term_Months__c < 12) ||(Opportunity.Status_at_end_of_term__c == null && oppLineItem.New_Deal_Term_Months__c < 12))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Reason duration is < 1 year and Status at end of term are required when New Deal Term (Months) < 12 for Renewal Opportunities');
           ApexPages.addMessage(myMsg);
           return null;
        }
        
        if(alert){ //allha02 3576
        return null;
        }
        
        update opportunity;
        upsert oppLineItem;
        }
        catch(DMLException e){
        
           ApexPages.addMessages(e);
           return null;
        }

        
        pagereference pr = new pagereference('/'+opportunity.Id);
        return pr;        
    }
//Test method for page 

public static testMethod void Renewal_addMainFrameProductsTest()
{
 recordtype[] recs = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType ='account' and r.name in ('SMB','Reseller/Distributor Account')];
                    id res;
                    id com;
                    for(recordtype rec: recs)
                        if(rec.name == 'SMB')
                                com = rec.id;
                        else
                                res = rec.id;
                    account a = new account(name ='we', recordtypeid =res);
                    a.customer_Category__c= 'Reseller';
                    a.hq__c= true;
                    a.Commercial_Account_Name__c='test 11111114'  ;
                    a.Commercial_ID__c= 'test 11111115';
                    a.Country_Picklist__c= 'JP - JAPAN';
                    a.GEO__c= 'JAPAN';
                    a.Sales_Area__c= 'JAPAN';
                    a.Sales_Region__c= 'JAPAN';
                    a.Billingstate= 'A';
                    a.Billingcity= 'B';
                    a.Billingstreet= 'C';
                    insert a;
        Opportunity Opp = new Opportunity(Name='testOpp',Reseller__C = a.Id,CloseDate=System.Today(),StageName='10% Milestone'); 
        insert Opp;   
        ApexPages.currentPage().getParameters().put('oppid', Opp.id);      
        ApexPages.StandardController testPage = new ApexPages.StandardController(Opp);
        Renewal_addMainFrameProducts  obj = new Renewal_addMainFrameProducts(testPage);
        Test.startTest();
        obj.saveproducts();
        Test.stopTest();
}


}