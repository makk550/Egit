@istest(seealldata = true)
public class CoTermTest{

@istest(seealldata = true)
public static void createCoTermTest(){
   // try{
         Contact contact = new Contact(lastName='vinay kurudi');
         insert contact;
         
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
        
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
        ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
        
        Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
        insert resellerAcct;                
        
        Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct;    
       
       Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
       Opportunity opp = new Opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,Name='Opp1',Order_Number__c='1234',Type='DM',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='100% - Contract Signed',Initial_Billing__c=2);       
       insert opp; 
   
      Product2 product= new Product2(Name='Prd1',SKU__c = 'CAAAVM1600W00C6', Family='Product',Market_Focus_Area__c='Test1',IsActive=true);
        //Product2 prd2 = new Product2(Name='Prd2', Family='Time',Market_Focus_Area__c='Test2',IsActive=true);
        
       // Product2[] prd = new Product2[]{prd1,prd2};
        insert product;
     // Pricebook2 pb = new Pricebook2();
     // pb = [Select Id from Pricebook2 where IsStandard=true];
        
       // PricebookEntry pbe1 = new PricebookEntry(Product2Id=prd[0].Id,Pricebook2Id=pb.Id,UnitPrice=2,IsActive=true); 
       
      List<PriceBook2>pb = [Select Id from Pricebook2 ];
     PriceBookEntry pr1 = new PriceBookEntry();
        // pr1.PRICEBOOK2ID = '01s30000000602WAAQ';
        pr1.PRICEBOOK2ID  = pb.get(0).id;
         pr1.PRODUCT2ID = product.id;
         pr1.CURRENCYISOCODE = 'USD';
         pr1.UNITPRICE = 222;
         pr1.ISACTIVE = true;
         pr1.USESTANDARDPRICE = false;
         insert pr1;
         
             PriceBookEntry pr2 = new PriceBookEntry();
        // pr2.PRICEBOOK2ID = '01s30000000602WAAQ';
        pr2.PRICEBOOK2ID  = pb.get(1).id;
         pr2.PRODUCT2ID = product.id;
         pr2.CURRENCYISOCODE = 'USD';
         pr2.UNITPRICE = 222;
         pr2.ISACTIVE = true;
         pr2.USESTANDARDPRICE = false;
         insert pr2;
         
          Quote quote = new Quote();
         quote.Name = 'test opp';
         quote.EU_Name__c = contact.id;
         quote.Reseller_Name__c  = contact.id;
         quote.Disti_Name__c  = contact.id;
         quote.OpportunityId= opp.id;
         quote.Pricebook2Id =pb.get(1).id;
         quote.attestation__c = true;
         insert quote;

         Co_Term__c  coTerm = new Co_Term__c();
         coTerm.MSRP_Unit__c = 3;
         coTerm.Product_SKU__c = 'CAAAVM1600W00C6';
         coTerm.Qty__c = 10;
         coTerm.Quote__c = quote.id;
         coTerm.Distil_Disc__c = 10;
         coTerm.Pro_Rata_Total__c = 100;
         coTerm.MSRP_Total__c = 100;
         coTerm.Days_to_Co_term__c = 365;
         coTerm.Add_l_Disc__c=10;
         insert coTerm;
         
         
         
         
        // update coTerm;
         
         
         delete coTerm;
        
       // }catch(Exception ex){}
    
      
}

/*
@istest(seealldata = true)
public static void insertMultipleCoTerm(){
    // try{
     
         Contact contact = new Contact(lastName='vinay kurudi');
     
        Schema.DescribeSObjectResult oppresult = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> oppRecType = oppresult.getRecordTypeInfosByName();
   
        Account acc = new Account(Name='Test_Acc1',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA');
       insert acc;
       
       Id oppRecId = oppRecType.get('New Opportunity').getRecordTypeId();
       Opportunity opp = new Opportunity(AccountId=acc.Id,Reseller__c=acc.Id,Name='Opp1',Type='DM',RecordTypeId=oppRecId,CloseDate=System.today()+3,StageName='100% - Contract Signed',Initial_Billing__c=2);       
       insert opp; 
   
      Product2 prd1= new Product2(Name='Prd1',SKU__c = 'CAAAVM1600W00C6', Family='Product',Market_Focus_Area__c='Test1',IsActive=true);
      Product2 prd2 = new Product2(Name='Prd2', SKU__c = 'CAD2DCR16A005DG',Family='Time',Market_Focus_Area__c='Test2',IsActive=true);
        
      Product2[] prd = new Product2[]{prd1,prd2};
        insert prd ;
    
      List<PriceBook2>pb = [Select Id from Pricebook2 ];
     PriceBookEntry pr1 = new PriceBookEntry();
         pr1.PRICEBOOK2ID  = pb.get(0).id;
         pr1.PRODUCT2ID = prd.get(0).id;
         pr1.CURRENCYISOCODE = 'USD';
         pr1.UNITPRICE = 222;
         pr1.ISACTIVE = true;
         pr1.USESTANDARDPRICE = false;
         insert pr1;
         
        PriceBookEntry pr2 = new PriceBookEntry();
        pr2.PRICEBOOK2ID  = pb.get(1).id;
         pr2.PRODUCT2ID =  prd.get(0).id;
         pr2.CURRENCYISOCODE = 'USD';
         pr2.UNITPRICE = 222;
         pr2.ISACTIVE = true;
         pr2.USESTANDARDPRICE = false;
         insert pr2;
         
         PriceBookEntry pr11 = new PriceBookEntry();
         pr11.PRICEBOOK2ID  = pb.get(0).id;
         pr11.PRODUCT2ID = prd.get(1).id;
         pr11.CURRENCYISOCODE = 'USD';
         pr11.UNITPRICE = 222;
         pr11.ISACTIVE = true;
         pr11.USESTANDARDPRICE = false;
         insert pr11;
         
        PriceBookEntry pr21 = new PriceBookEntry();
        pr21.PRICEBOOK2ID  = pb.get(1).id;
         pr21.PRODUCT2ID =  prd.get(1).id;
         pr21.CURRENCYISOCODE = 'USD';
         pr21.UNITPRICE = 222;
         pr21.ISACTIVE = true;
         pr21.USESTANDARDPRICE = false;
         insert pr21;
         
          Quote quote = new Quote();
         quote.Name = 'test opp';
         quote.EU_Name__c = contact.id;
         quote.Reseller_Name__c  = contact.id;
         quote.Disti_Name__c  = contact.id;
         quote.OpportunityId= opp.id;
         quote.Pricebook2Id =pb.get(1).id;
         quote.attestation__c = true;
         insert quote;
         
     Co_Term__c  coTerm = new Co_Term__c();
     coTerm.MSRP_Unit__c = 3;
     coTerm.Product_SKU__c = 'CAAAVM1600W00C6';
     coTerm.Qty__c = 10;
     coTerm.Quote__c = quote.id;
     coTerm.Distil_Disc__c = 10;
     coTerm.Pro_Rata_Total__c = 100;
     coTerm.MSRP_Total__c = 100;
     coTerm.Days_to_Co_term__c = 365;
     coTerm.Add_l_Disc__c=10;
     insert coTerm;
     
     Co_Term__c  coTerm1 = new Co_Term__c();
     coTerm1.MSRP_Unit__c = 3;
     coTerm1.Product_SKU__c = 'CAAAVM1600W00C6';
     coTerm1.Qty__c = 10;
     coTerm1.Quote__c = quote.id;
     coTerm1.Distil_Disc__c = 10;
     coTerm1.Pro_Rata_Total__c = 100;
     coTerm1.MSRP_Total__c = 100;
     coTerm1.Days_to_Co_term__c = 365;
     coTerm1.Add_l_Disc__c=10;
     coTerm1.CPMS_Parent_Product_SKU__c = 'CAD2DCR16A005DG';          
    
     insert coTerm1;
     
     Co_Term__c  coTerm2 = new Co_Term__c();
     coTerm2.MSRP_Unit__c = 3;
     coTerm2.Product_SKU__c = 'CAAAVM1600W00C6';
     coTerm2.Qty__c = 10;
     coTerm2.Quote__c = quote.id;
     coTerm2.Distil_Disc__c = 10;
     coTerm2.Pro_Rata_Total__c = 100;
     coTerm2.MSRP_Total__c = 100;
     coTerm2.Days_to_Co_term__c = 365;
     coTerm2.Add_l_Disc__c=10;
     insert coTerm2;
     
     delete coTerm2;
     
    // }catch(Exception ex){}

}
*/
}