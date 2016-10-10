@isTest(seeAllData = true)

public class testDE_ConverLead_cls{
   public static testMethod void testMeth_leadConvert(){
    RecordType r1t = [select id from recordtype where name='Reseller/Distributor Account' and sObjectType='Account' limit 1];
    
    Account acc = new Account();
    
   
   
       RecordType rt = [select id from recordtype where name='CA Global Lead' and sObjectType='Lead' limit 1];
       Lead l = new Lead();
       l.FirstName = 'Lead';
       l.LastName = 'test123';
       l.Status = 'New';
       l.Meeting_Rating__c = 'N/A';
       l.Street = 'bay';
       l.City = 'jacksonville';
       l.State = 'FL - Florida';
       l.Country = 'US - United States';
       l.Company = 'CA-ITC';
       
       if(rt.Id != null)
                l.RecordTypeId= rt.id;
       insert l;
       
       ApexPages.StandardController stdCtrl = new ApexPages.StandardController(l);
       DE_ConverLead_cls classObj = new DE_ConverLead_cls(stdCtrl);
       classObj.isOpportunityCreate = true;
       classObj.setSendNotificationEmail = false;
       
       List<SelectOption> lstoptiosn = classObj.getConvertedStatusList();
      
       PageReference pageRef1 = classObj.ConvertLeadRecord_1();
       PageReference pageRef2 = classObj.cancelMeth();       
       PageReference pageRef3 = classObj.CheckIsConverted();
   }
}