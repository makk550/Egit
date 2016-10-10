public class Test_Service_Request{

static testMethod void Test_Service_Request() {
Account testaccount =new Account();              
testaccount.Name ='testaccount';               
testaccount.GEO__c='Japan';                
testaccount.Sales_Area__c='Japan';               
testaccount.Sales_Region__c='Japan';               
testaccount.Country_Picklist__c='JP-JAPAN';               
testaccount.Account_Status__c='Submitted';               
testaccount.Customer_Category__c='Commercial';               
testaccount.Region_Country__c='JP';                
testaccount.Enterprise_ID__c='';              
testaccount.Enterprise_Account_Name__c='';            
testaccount.Commercial_ID__c='10024';           
testaccount.SAP_TOPS_Site__c='S';                      
insert testaccount;

Opportunity opp =new Opportunity(Name='testopp',AccountId=testaccount.Id,Type='Direct',RPD_Comments__c='Test',
                                  Split_Opportunity__c='No',CurrencyIsoCode='USD',Initial_Billing__c=0.00,StageName='10% - Identification & Qualification',CloseDate=Date.today().addDays(10));
insert opp;

Service_Request src = new Service_Request(new ApexPages.StandardController(opp));        
src.ApplySelection();                
Service_Request src2 = new Service_Request(new ApexPages.StandardController(new Opportunity()));        
src2.ApplySelection();
Site_Association__c srObj1 = new Site_Association__c();
       srObj1.Name = 'test srObj1';
       srObj1.Account_Group__c = 'Z00';
       srObj1.Country_picklist__c= 'US - UNITED STATES';
       srObj1.State__c='New York';
       srObj1.City__c ='Austin';
       srObj1.SC_SITE_Source__c = 'Sales';
       insert srObj1;
Site_Association__c siteAsso = [Select id from Site_Association__c LIMIT 1];                
if(siteAsso <> null)
{
    Services_Request__c sr = [Select id, Services_Request_Status__c from Services_Request__c where Services_Request_Status__c != 'DDR Creation' limit 1];        
    if(sr <> null){ 
        try{
            sr.Services_Request_Status__c = 'DDR Creation';
            sr.Ship_To__c='test';
            sr.Ship_To_Site__c=siteAsso.Id; 
            sr.Sold_To_Site__c=siteAsso.Id; 
            sr.Sold_To__c='test';
            sr.Bill_To__c='test';       
            update sr;
        }
        catch(Exception e){}
    }
}
}
}