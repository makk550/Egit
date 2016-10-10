@isTest
private class Renewal_ConvToOppController_Test {

public static testmethod void testMoveRenewals(){
    
    SystemIdUtility.skipOpportunityTriggers = true;
SystemIdUtility.skipOpportunityLineItemTriggers  = true;
        
    Account ac= new Account(Name='testAccount',Commercial_Id__c = 'test',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');       
    insert ac;   
    Renewal_Currency__c renCurrency = new Renewal_Currency__c(name='INR');        
    insert renCurrency;
    Active_Contract__c activeContract = new Active_Contract__c(name='TestActiveContract',Account__c=ac.Id,Contract_Term_Months__c=10,Renewal_Currency__c=renCurrency.Id);       
    insert activeContract;     
    User u = [select id from user where IsActive=:true limit 1];
    Territory terr = [Select Territory_Country__c from Territory where Territory_Country__c != null LIMIT 1];
    
    Renewal__c renewal = new Renewal__c(name='TestRenewal2',Account__c=ac.Id,Segmentation__c='HT');
    renewal.Expected_Close_Date__c=Date.valueOf('2011-05-05');
    renewal.Reason_duration_is_1_year__c = 'Bridge Contract';
    renewal.Status_at_end_of_term__c = 'Re-Renew';
    renewal.Converted_To_Opportunity__c=false;
    renewal.Overall_Comments__c='Test';
    renewal.CurrencyIsoCode='USD';
    renewal.Projected_Time_Duration_Months__c=6;
    renewal.OwnerId=u.Id;
    renewal.OCV__c=100000;
    renewal.Annual_OCV_LC__c=200000;
    renewal.Sold_to_Ship_to_Party_Site_ID__c='1234';
    renewal.Projected_Renewal__c=50000;
    renewal.Territory_Country__c = terr.Territory_Country__c;
    insert renewal;
    
    Product2 prod = new Product2(Name = 'TestProd', Family='Renewal',IsActive=true);        
    insert prod;
    
    Renewal_Product__c rnwlProdct= new Renewal_Product__c(name='TestRnwlPrdct',Product__c=prod.Id,Renewal__c=renewal.Id);       
    insert rnwlProdct;    
    
     Id recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Opportunity').getRecordTypeId();     
   
    String BusinessType;
             if(renewal.Segmentation__c == 'HT')
                 BusinessType = 'High Touch';
             else if(renewal.Segmentation__c == 'MT')
                 BusinessType = 'Medium Touch';
             else if(renewal.Segmentation__c == 'LT')
                 BusinessType = 'Low Touch';
             else if(renewal.Segmentation__c == 'NT')
                 BusinessType = 'No Touch'; 
     
    Opportunity opp = new Opportunity(name=renewal.name,AccountId=renewal.Account__c,
       CloseDate=System.today(),Description=renewal.Overall_Comments__c,
       StageName='10% - Identification & Qualification',
       New_Deal_Term_months__c=renewal.Projected_Time_Duration_Months__c,OwnerId=renewal.OwnerId,
       Original_CV__c=renewal.OCV__c,Site_ID__c=renewal.Sold_to_Ship_to_Party_Site_ID__c,Type='Direct',RPD_Status__c='Requested',
       Renewal__c=renewal.id,RecordTypeId = recId,
        Business_Type__c = BusinessType);
       insert opp;
        
         
     List<Active_Contract_Product__c> actvContPrd = new List<Active_Contract_Product__c>();       
        for(integer i=0;i<15;i++)
        {
            Active_Contract_Product__c actvContPrd1= new Active_Contract_Product__c(name='TestACP'+i,Active_Contract__c=activeContract.Id,Renewal_Product__c=rnwlProdct.Id,Product__c=prod.Id);
            if(i == 2 || i == 4 || i == 6) {
                actvContPrd1.Converted_To_Opportunity__c = false;            
            } else {
                actvContPrd1.Converted_To_Opportunity__c = true;
            }
            actvContPrd.add(actvContPrd1);
            i=i++;
        }
        insert actvContPrd;
        
    Active_Contract_Product__c acp =[select Converted_To_Opportunity__c from Active_Contract_Product__c where id=:actvContPrd[0].id];    
    acp.Converted_To_Opportunity__c = true;
    update acp;    
    
    Pricebook2 pb = new Pricebook2();
    pb = [Select Id from Pricebook2 where IsStandard=true];
    
    PricebookEntry p = new PricebookEntry(Product2Id=prod.Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true);
    insert p;
   
     
     List<CA_Product_Renewal__c> caProdRnwl = new List<CA_Product_Renewal__c>();
    for(integer i=0;i<15;i++)
        {
            CA_Product_Renewal__c ca = new CA_Product_Renewal__c(name= 'Rnwaltest'+i,Active_Contract_Product__c=actvContPrd[i].Id,Renewal_Opportunity__c=opp.id);
            caProdRnwl.add(ca);
            i=i++;
        }
           insert caProdRnwl;
    
    List<OpportunityLineItem> oppitmlist =new List<OpportunityLineItem>();
        for(integer i=0;i<15;i++)
        {
            OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId =p.id,CA_Contract_Product_Name__c = 'Test'+ i,Opportunityid = opp.id,Active_Contract_Product__c= actvContPrd[i].id);
            oppitmlist.add(oli);
            i=i++;
        }
           insert oppitmlist;
         
    ApexPages.StandardController convcont = new ApexPages.StandardController(renewal);
    Renewal_ConvToOppController cntrl = new Renewal_ConvToOppController(convcont);
   Test.startTest();
    if(cntrl.rnwl.id <> null){
    cntrl.acc = ac;
    cntrl.rnwl = renewal;
    cntrl.creatOppRecord();  
    if(caProdRnwl.size()>0){ 
      
    cntrl.updateRnwlFields(opp.id,opp.currencyisocode);  }
     }
   Test.stopTest();    
      
 }



}