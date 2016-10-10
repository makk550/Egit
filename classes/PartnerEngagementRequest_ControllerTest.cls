@isTest(seealldata=true) 
public class PartnerEngagementRequest_ControllerTest {
    public static testMethod void PartnerEngagementRequest_test()
    {
         user u1=new user(id='00530000003rQuJ');
        system.runas(u1){
       test.starttest();
        Account acc=new account(name='test account',Solution_Provider_Program_Level__c='Member',Billingstreet='s',Billingcity='c',Billingstate='US');
        acc.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Technology Partner').getRecordTypeId();
        insert acc;
        contact con=new contact(lastname='con1',accountid=acc.id,Active_User__c=true);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name=:'Partner Champion - DM']; 
        User u = new User(Alias = 'standt1', Email='ra@ca.com', 
            EmailEncodingKey='UTF-8',FirstName='abc', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='ra@ca.com',isactive=true,contactid=con.id);
        insert u;    
    
   Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
   test.stoptest();
          RecordType rt = new RecordType();
        rt = [select id from RecordType where Name='Deal Registration' and isActive = true and sObjectType = 'Opportunity' limit 1];   
       //get standard pricebook
Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
insert pbk1;
Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Family='Product',Market_Focus_Area__c='SECURITY');
insert prd1;
PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
insert pbe1;   
      
          Opportunity opp = new Opportunity();
                opp.Name = 'test opp';
            if(rt.Id != null)
                opp.RecordTypeId = rt.Id;
                opp.AccountId = acc.Id ;
                //opp.End_User_Contact__c = c.Id;
                opp.CloseDate = system.today()+1;
                opp.stageName = 'Negotiation';
                 opp.First_Approver__c=u.id;
                 opp.Initiated_By__c='Partner';
                 opp.Deal_Registration_Status__c='New';            

            insert opp;          
       

OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
insert lineItem1; 
 ApexPages.currentPage().getParameters().put('oppId',opp.id);
 ApexPages.StandardController stdController=new ApexPages.StandardController(new Partner_Engagement_Program__c());
 PartnerEngagementRequest_Controller pec=new PartnerEngagementRequest_Controller(stdController);
 pec.per.Relationship_with_Customer__c =true;
 pec.per.Engagement_Approver__c=u.id;
 pec.save();
 pec.saveNsubmit();
 pec.cancel();
Partner_Engagement_Program__c per1=new Partner_Engagement_Program__c(Customer_Procurement__c=true,Parent_Opportunity__c=opp.id,Engagement_Approver__c=u.id);
insert per1;
 ApexPages.currentPage().getParameters().put('Id',per1.id);
 ApexPages.currentPage().getParameters().put('RETURL','/'+opp.id);
 ApexPages.StandardController stdController1=new ApexPages.StandardController(per1);
 PartnerEngagementRequest_Controller pec1=new PartnerEngagementRequest_Controller(stdController1);
 pec1.per.Customer_Procurement__c=true;
 pec1.per.Engagement_Approver__c=u.id; 
 pec1.per.partner__c=acc.id;
 pec1.per.partner_Contact__c=con.id;
 pec1.save();
 pec1.saveNsubmit();
 pec1.cancel(); 
 per1.partner__c=acc.id;
 per1.partner_Contact__c=con.id;
 per1.status__c='approved';
 update per1;
 per1.status__c='Partner Obligation Not Met';
 update per1;
 ApexPages.currentPage().getParameters().put('Id',per1.id);
 ApexPages.StandardController stdController2=new ApexPages.StandardController(per1);
 PartnerEngagementRequest_Controller pec2=new PartnerEngagementRequest_Controller(stdController2);
 pec2.editPER();

}
    }
    public static testMethod void PartnerEngagementRequest_test1()
    {
        user u1=new user(id='00530000003rQuJ');
        system.runas(u1){
       test.starttest();
        Account acc=new account(name='test account',Solution_Provider_Program_Level__c='Member',Billingstreet='s',Billingcity='c',Billingstate='US');
        acc.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Technology Partner').getRecordTypeId();
        insert acc;
        contact con=new contact(lastname='con1',accountid=acc.id,Active_User__c=true);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name=:'Partner Champion - DM']; 
        User u = new User(Alias = 'standt1', Email='ra@ca.com', 
            EmailEncodingKey='UTF-8',FirstName='abc', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='ra@ca.com',isactive=true,contactid=con.id);
        insert u;    
    
   Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
   test.stoptest();
          RecordType rt = new RecordType();
        rt = [select id from RecordType where Name='Deal Registration' and isActive = true and sObjectType = 'Opportunity' limit 1];   
       //get standard pricebook
Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
insert pbk1;
Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Family='Product',Market_Focus_Area__c='SECURITY');
insert prd1;
PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
insert pbe1;   
      
          Opportunity opp = new Opportunity();
                opp.Name = 'test opp';
            if(rt.Id != null)
                opp.RecordTypeId = rt.Id;
                opp.AccountId = acc.Id ;
                //opp.End_User_Contact__c = c.Id;
                opp.CloseDate = system.today()+1;
                opp.stageName = 'Negotiation';
                 opp.First_Approver__c=u.id;
                 opp.Initiated_By__c='Partner';
                 opp.Deal_Registration_Status__c='New';  

            insert opp;                 

OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
insert lineItem1; 
ApexPages.currentPage().getParameters().put('oppId',opp.id);
 ApexPages.StandardController stdController2=new ApexPages.StandardController(new Partner_Engagement_Program__c());
 PartnerEngagementRequest_Controller pec2=new PartnerEngagementRequest_Controller(stdController2);
 pec2.per.Relationship_with_Customer__c =true;
 pec2.per.Engagement_Approver__c=u.id;
 pec2.per.partner__c=acc.id;
 
 try{
 pec2.save();
 pec2.saveNsubmit();
 }catch(exception e){}
 ApexPages.currentPage().getParameters().put('oppId',opp.id);
 ApexPages.StandardController stdController4=new ApexPages.StandardController(new Partner_Engagement_Program__c());
 PartnerEngagementRequest_Controller pec4=new PartnerEngagementRequest_Controller(stdController4);
 pec4.per.Relationship_with_Customer__c =true;
 pec4.per.Engagement_Approver__c=u.id;
 pec4.per.distributor__c=acc.id; 
 try{
 pec4.save();
 pec4.saveNsubmit();
 }catch(exception e){}
Partner_Engagement_Program__c per1=new Partner_Engagement_Program__c(Customer_Procurement__c=true,Parent_Opportunity__c=opp.id,Engagement_Approver__c=u.id,status__c='new',partner__c=acc.id,partner_Contact__c=con.id);
insert per1;
 ApexPages.currentPage().getParameters().put('Id',per1.id);
 ApexPages.StandardController stdController3=new ApexPages.StandardController(per1);
 PartnerEngagementRequest_Controller pec3=new PartnerEngagementRequest_Controller(stdController3);
ApexPages.currentPage().getParameters().put('oppId',opp.id);
 ApexPages.StandardController stdController=new ApexPages.StandardController(new Partner_Engagement_Program__c());
 try{
 PartnerEngagementRequest_Controller pec=new PartnerEngagementRequest_Controller(stdController);
 }catch(exception e){}
 ApexPages.currentPage().getParameters().put('Id',per1.id);
 ApexPages.currentPage().getParameters().put('retURL',opp.id);
 ApexPages.StandardController stdController1=new ApexPages.StandardController(per1);
 PartnerEngagementRequest_Controller pec1=new PartnerEngagementRequest_Controller(stdController1);
 pec1.SelectedStatus='Partner Obligation Not Met';
 pec1.save(); 
 Partner_Engagement_Program__c per2=new Partner_Engagement_Program__c(Customer_Procurement__c=true,Parent_Opportunity__c=opp.id,Engagement_Approver__c=u.id,status__c='Approved',partner__c=acc.id,partner_Contact__c=con.id);
insert per2;
ApexPages.currentPage().getParameters().put('Id',per2.id);
 ApexPages.currentPage().getParameters().put('retURL',opp.id);
 ApexPages.StandardController stdController5=new ApexPages.StandardController(per2);
 PartnerEngagementRequest_Controller pec5=new PartnerEngagementRequest_Controller(stdController5);

    }
 }
  public static testMethod void PartnerEngagementRequest_test2()
    {
        user u1=new user(id='00530000003rQuJ');
        system.runas(u1){
       test.starttest();
        Account acc=new account(name='test account',Solution_Provider_Program_Level__c='Member',Billingstreet='s',Billingcity='c',Billingstate='US');
        acc.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Technology Partner').getRecordTypeId();
        insert acc;
        contact con=new contact(lastname='con1',accountid=acc.id,Active_User__c=true);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name=:'Partner Champion - DM']; 
        User u = new User(Alias = 'standt1', Email='ra@ca.com', 
            EmailEncodingKey='UTF-8',FirstName='abc', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='ra@ca.com',isactive=true,contactid=con.id);
        insert u;    
    
   Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
   test.stoptest();
          RecordType rt = new RecordType();
        rt = [select id from RecordType where Name='Deal Registration' and isActive = true and sObjectType = 'Opportunity' limit 1];   
       //get standard pricebook
Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
insert pbk1;
Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Family='Product',Market_Focus_Area__c='SECURITY');
insert prd1;
PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
insert pbe1;   
      
          Opportunity opp = new Opportunity();
                opp.Name = 'test opp';
            if(rt.Id != null)
                opp.RecordTypeId = rt.Id;
                opp.AccountId = acc.Id ;
                //opp.End_User_Contact__c = c.Id;
                opp.CloseDate = system.today()+1;
                opp.stageName = 'Negotiation';
                 opp.First_Approver__c=u.id;
                 opp.Initiated_By__c='Partner';
                 opp.Deal_Registration_Status__c='New';  

            insert opp;                 

OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
insert lineItem1; 
Partner_Engagement_Program__c per1=new Partner_Engagement_Program__c(Customer_Procurement__c=true,Parent_Opportunity__c=opp.id,Engagement_Approver__c=u.id,status__c='new',partner__c=acc.id,partner_Contact__c=con.id);
insert per1;
ApexPages.currentPage().getParameters().put('oppId',opp.id);
 ApexPages.StandardController stdController=new ApexPages.StandardController(new Partner_Engagement_Program__c());
 try{
 PartnerEngagementRequest_Controller pec=new PartnerEngagementRequest_Controller(stdController);
 }catch(exception e){}
}
}
 }