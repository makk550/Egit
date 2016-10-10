/*
Created By: Tarun Sharma
Created On: 10/13/2015
Purpose: Test Class for setup data
Modified By:
*/
@isTest
public class Test_SetupData{
    
   public static testMethod void createTestData(){
        
        List<RecordTypes_Setting__c> listOfRecordType = new List<RecordTypes_Setting__c>();
        RecordTypes_Setting__c recordTypeObj = new RecordTypes_Setting__c();
        recordTypeObj.Name = 'SMB';
        recordTypeObj.SObject_Name__c = 'Account';
        recordTypeObj.RecordType_Id__c = '01230000001L55j';
        listOfRecordType.add(recordTypeObj);
        
        RecordTypes_Setting__c recordTypeObj1 = new RecordTypes_Setting__c();
        recordTypeObj1.Name = 'Territory Covered Account';
        recordTypeObj1.SObject_Name__c = 'Account';
        recordTypeObj1.RecordType_Id__c = '01230000001L55o';
        listOfRecordType.add(recordTypeObj1);
        
        RecordTypes_Setting__c recordTypeObj2 = new RecordTypes_Setting__c();
        recordTypeObj2.Name = 'Account Team Covered Account';
        recordTypeObj2.SObject_Name__c = 'Account';
        recordTypeObj2.RecordType_Id__c = '01230000001L55e';
        listOfRecordType.add(recordTypeObj2);
        
        RecordTypes_Setting__c recordTypeObj3 = new RecordTypes_Setting__c();
        recordTypeObj3.Name = 'Commercial Account';
        recordTypeObj3.SObject_Name__c = 'Account';
        recordTypeObj3.RecordType_Id__c = '01230000000GaFY';
        listOfRecordType.add(recordTypeObj3);
        
        RecordTypes_Setting__c recordTypeObj4 = new RecordTypes_Setting__c();
        recordTypeObj4.Name = 'CA Enterprise Account';
        recordTypeObj4.SObject_Name__c = 'Account';
        recordTypeObj4.RecordType_Id__c = '01230000000DNfM';
        listOfRecordType.add(recordTypeObj4);
        
        RecordTypes_Setting__c recordTypeObj5 = new RecordTypes_Setting__c();
        recordTypeObj5.Name = 'Support Account';
        recordTypeObj5.SObject_Name__c = 'Account';
        recordTypeObj5.RecordType_Id__c = '012a00000018GH7';
        listOfRecordType.add(recordTypeObj5);
        
        RecordTypes_Setting__c recordTypeObj6 = new RecordTypes_Setting__c();
        recordTypeObj6.Name = 'Acquisition';
        recordTypeObj6.SObject_Name__c = 'Account';
        recordTypeObj6.RecordType_Id__c = '012300000013vtw';
        listOfRecordType.add(recordTypeObj6);
        
        RecordTypes_Setting__c recordTypeObj7 = new RecordTypes_Setting__c();
        recordTypeObj7.Name = 'Approved Quote';
        recordTypeObj7.SObject_Name__c = 'Account';
        recordTypeObj7.RecordType_Id__c = '012a0000001VvqT';
        listOfRecordType.add(recordTypeObj7);
        
        RecordTypes_Setting__c recordTypeObj8 = new RecordTypes_Setting__c();
        recordTypeObj8.Name = 'CA Global Lead';
        recordTypeObj8.SObject_Name__c = 'Account';
        recordTypeObj8.RecordType_Id__c = '01230000000DUOh';
        listOfRecordType.add(recordTypeObj8);
        
        RecordTypes_Setting__c recordTypeObj9 = new RecordTypes_Setting__c();
        recordTypeObj9.Name = 'CA Indirect Lead';
        recordTypeObj9.SObject_Name__c = 'Account';
        recordTypeObj9.RecordType_Id__c = '01230000000Dhu2';
        listOfRecordType.add(recordTypeObj9);
        
        RecordTypes_Setting__c recordTypeObj10 = new RecordTypes_Setting__c();
        recordTypeObj10.Name = 'Deal Registration';
        recordTypeObj10.SObject_Name__c = 'Account';
        recordTypeObj10.RecordType_Id__c = '01230000000yspg';
        listOfRecordType.add(recordTypeObj10);
        
        RecordTypes_Setting__c recordTypeObj11 = new RecordTypes_Setting__c();
        recordTypeObj11.Name = 'Reseller/Distributor Account';
        recordTypeObj11.SObject_Name__c = 'Account';
        recordTypeObj11.RecordType_Id__c = '01230000000GaFd';
        listOfRecordType.add(recordTypeObj11);
       
        insert listOfRecordType;
        
        Account accountObj = new Account();
        accountObj.Name = 'Generic Support Account'; 
        accountObj.Enterprise_ID__c = '7777777777';
        accountObj.BillingStreet='Street';
        accountObj.BillingCountry='US';
        accountObj.BillingCity='Islandia'; 
        insert accountObj;
        
        Site_Association__c siteAssociationObj = new Site_Association__c();
        siteAssociationObj.Name = 'IBM';
        siteAssociationObj.SAP_Site_ID__c = '280125';
        siteAssociationObj.SC_SITE_Sanctioned_Party__c = 'NO';
        siteAssociationObj.Enterprise_ID__c = accountObj.Id;
        siteAssociationObj.SC_TOPS_ID__c = '1299636';
        siteAssociationObj.Country_picklist__c= 'US - UNITED STATES';
        siteAssociationObj.State__c='New York';
        siteAssociationObj.ProviSite__c = 1;
        insert siteAssociationObj;
        
        Contact contactObj = new Contact();
        contactObj.FirstName ='testAuto';
        contactObj.LastName ='contact';
        insert contactObj;
        
        Contacts_Site_Association__c csaObj = new Contacts_Site_Association__c();
        csaObj.SC_CSA_SITE__c = siteAssociationObj.Id ;
        csaObj.SC_CSA_CONTACTS__c = contactObj.Id; 
        insert csaObj; 
              
        CA_Product_Controller__c caProductObj = new CA_Product_Controller__c();
        caProductObj.name='2E';
        insert caProductObj;
        
        CA_Product_Component__c prodcomp = new CA_Product_Component__c();
        prodcomp.Name='2E';
        prodcomp.CA_Product_Component_Ext_ID__c='Test';
        prodcomp.Default_Component_for_CA_Product__c=True;
        prodcomp.CA_Product_Controller__c=caProductObj.id;
        prodcomp.CA_Product_Text__c='Test';
        prodcomp.Component_Code__c='Test';
        prodcomp.Component_Text__c='Test';
        prodcomp.Default_Component_for_this_CA_Product__c=True;
        prodcomp.SFDC_Support_System__c=True;
        insert prodcomp;
        
        id queueGroupId= [Select Id from Group where type='Queue' limit 1].Id;
      
        Component_Release__c componentReleaseObj = new Component_Release__c();
        componentReleaseObj.Name = 'EARL';
        componentReleaseObj.Component_Release__c = '6.1';
        componentReleaseObj.Component_Code__c='Tape ';
        insert componentReleaseObj;
        
        Case caseObject =new Case();
        caseObject.Accountid=accountObj.Id;
        caseObject.Site_Association__c=siteAssociationObj.Id;
        caseObject.CA_Product_Controller__c=caProductObj.id;
        caseObject.CA_Product_Component__c=prodcomp.id;
        caseObject.ContactId=contactObj.Id;        
        caseObject.Origin='Email';
        caseObject.OwnerId=queueGroupId;
        caseObject.Case_Type__c='Standard';
        caseObject.Subject='test subject TPC';
        caseObject.Description='asdf';
        caseObject.Reason='Instructions Not Clear';
        caseObject.Priority='3';        
        caseObject.Status='Open';
        caseObject.Severity__c='1';
        caseObject.Sev_1_Impact_c__c='Customer set Sev 1 for focus';
        caseObject.Internal_Priority__c='2';
        caseObject.Production_Down_Status__c='Investigating';
        caseObject.Alternate_email__c='vamsi.r@gmail.com';        
        caseObject.Component_Release_Only_Selection__c=  componentReleaseObj.Id;
        insert caseObject;
        
        Defect__c defectObject = new Defect__c();
        defectObject.Defect_URL__c = 'https://www.abc.com';
        defectObject.Defect_Object_ID__c = 'https://www.abc.com';
        defectObject.Defect_Submitted_By__c = 'tarun';
        defectObject.Defect_Owner__c = 'tarun';
        defectObject.Name = 'DE1111';
        //defectObject.OwnerId = queueGroupId;
        defectObject.Priority__c = '1';
        defectObject.Targeted_Release_Number__c = '8';
        defectObject.Target_Release_date__c = system.today();
        defectObject.Type__c = 'Defect';
        defectObject.Subject__c = 'test';
        defectObject.Status__c = 'New';
        defectObject.Severity__c = '1';
        defectObject.Resolution__c = 'fixed';
        defectObject.R_D_System__c = 'Rally';
        defectObject.Description__c = 'test testclass';
        insert defectObject;
         
        Defect_Case_Association__c defectAssociationObject = new Defect_Case_Association__c();
        defectAssociationObject.Case__c = caseObject.Id;
        defectAssociationObject.Defect__c = defectObject.Id;
        insert defectAssociationObject;
        
        apexpages.currentpage().getparameters().put('caseId',caseObject.Id); 
            
   }   
    
    public static testMethod void createTestProductData(){
        List<RecordTypes_Setting__c> listOfRecordType = new List<RecordTypes_Setting__c>();
        RecordTypes_Setting__c recordTypeObj = new RecordTypes_Setting__c();
        recordTypeObj.Name = 'SMB';
        recordTypeObj.SObject_Name__c = 'Account';
        recordTypeObj.RecordType_Id__c = '01230000001L55j';
        listOfRecordType.add(recordTypeObj);
        
        RecordTypes_Setting__c recordTypeObj1 = new RecordTypes_Setting__c();
        recordTypeObj1.Name = 'Territory Covered Account';
        recordTypeObj1.SObject_Name__c = 'Account';
        recordTypeObj1.RecordType_Id__c = '01230000001L55o';
        listOfRecordType.add(recordTypeObj1);
        
        RecordTypes_Setting__c recordTypeObj2 = new RecordTypes_Setting__c();
        recordTypeObj2.Name = 'Account Team Covered Account';
        recordTypeObj2.SObject_Name__c = 'Account';
        recordTypeObj2.RecordType_Id__c = '01230000001L55e';
        listOfRecordType.add(recordTypeObj2);
        
        RecordTypes_Setting__c recordTypeObj3 = new RecordTypes_Setting__c();
        recordTypeObj3.Name = 'Commercial Account';
        recordTypeObj3.SObject_Name__c = 'Account';
        recordTypeObj3.RecordType_Id__c = '01230000000GaFY';
        listOfRecordType.add(recordTypeObj3);
        
        RecordTypes_Setting__c recordTypeObj4 = new RecordTypes_Setting__c();
        recordTypeObj4.Name = 'CA Enterprise Account';
        recordTypeObj4.SObject_Name__c = 'Account';
        recordTypeObj4.RecordType_Id__c = '01230000000DNfM';
        listOfRecordType.add(recordTypeObj4);
        
        RecordTypes_Setting__c recordTypeObj5 = new RecordTypes_Setting__c();
        recordTypeObj5.Name = 'Support Account';
        recordTypeObj5.SObject_Name__c = 'Account';
        recordTypeObj5.RecordType_Id__c = '012a00000018GH7';
        listOfRecordType.add(recordTypeObj5);
        
        RecordTypes_Setting__c recordTypeObj6 = new RecordTypes_Setting__c();
        recordTypeObj6.Name = 'Acquisition';
        recordTypeObj6.SObject_Name__c = 'Account';
        recordTypeObj6.RecordType_Id__c = '012300000013vtw';
        listOfRecordType.add(recordTypeObj6);
        
        RecordTypes_Setting__c recordTypeObj7 = new RecordTypes_Setting__c();
        recordTypeObj7.Name = 'Approved Quote';
        recordTypeObj7.SObject_Name__c = 'Account';
        recordTypeObj7.RecordType_Id__c = '012a0000001VvqT';
        listOfRecordType.add(recordTypeObj7);
        
        RecordTypes_Setting__c recordTypeObj8 = new RecordTypes_Setting__c();
        recordTypeObj8.Name = 'CA Global Lead';
        recordTypeObj8.SObject_Name__c = 'Account';
        recordTypeObj8.RecordType_Id__c = '01230000000DUOh';
        listOfRecordType.add(recordTypeObj8);
        
        RecordTypes_Setting__c recordTypeObj9 = new RecordTypes_Setting__c();
        recordTypeObj9.Name = 'CA Indirect Lead';
        recordTypeObj9.SObject_Name__c = 'Account';
        recordTypeObj9.RecordType_Id__c = '01230000000Dhu2';
        listOfRecordType.add(recordTypeObj9);
        
        RecordTypes_Setting__c recordTypeObj10 = new RecordTypes_Setting__c();
        recordTypeObj10.Name = 'Deal Registration';
        recordTypeObj10.SObject_Name__c = 'Account';
        recordTypeObj10.RecordType_Id__c = '01230000000yspg';
        listOfRecordType.add(recordTypeObj10);
        
        RecordTypes_Setting__c recordTypeObj11 = new RecordTypes_Setting__c();
        recordTypeObj11.Name = 'Reseller/Distributor Account';
        recordTypeObj11.SObject_Name__c = 'Account';
        recordTypeObj11.RecordType_Id__c = '01230000000GaFd';
        listOfRecordType.add(recordTypeObj11);
       
        insert listOfRecordType;
        
        Account accountObj = new Account();
        accountObj.Name = 'Generic Support Account'; 
        accountObj.Enterprise_ID__c = '7777777777';
        accountObj.BillingStreet='Street';
        accountObj.BillingCountry='US';
        accountObj.BillingCity='Islandia'; 
        insert accountObj;
        
        Site_Association__c siteAssociationObj = new Site_Association__c();
        siteAssociationObj.Name = 'IBM';
        siteAssociationObj.SAP_Site_ID__c = '280125';
        siteAssociationObj.SC_SITE_Sanctioned_Party__c = 'NO';
        siteAssociationObj.Enterprise_ID__c = accountObj.Id;
        siteAssociationObj.SC_TOPS_ID__c = '1299636';
        siteAssociationObj.Country_picklist__c= 'US - UNITED STATES';
        siteAssociationObj.State__c='New York';
        siteAssociationObj.ProviSite__c = 1;
        insert siteAssociationObj;
        
        Contact contactObj = new Contact();
        contactObj.FirstName ='testAuto';
        contactObj.LastName ='contact';
        insert contactObj;
        
        Contacts_Site_Association__c csaObj = new Contacts_Site_Association__c();
        csaObj.SC_CSA_SITE__c = siteAssociationObj.Id ;
        csaObj.SC_CSA_CONTACTS__c = contactObj.Id; 
        insert csaObj; 
        
        CA_Product_Controller__c caProductObj = new CA_Product_Controller__c();
        caProductObj.name='Alpha';
        insert caProductObj;
        
        CA_Product_Component__c prodcomp = new CA_Product_Component__c();
        prodcomp.Name='Alpha';
        prodcomp.CA_Product_Component_Ext_ID__c='Test';
        prodcomp.Default_Component_for_CA_Product__c=True;
        prodcomp.CA_Product_Controller__c=caProductObj.id;
        prodcomp.CA_Product_Text__c='Test';
        prodcomp.Component_Code__c='Test';
        prodcomp.Component_Text__c='Test';
        prodcomp.Default_Component_for_this_CA_Product__c=True;
        prodcomp.SFDC_Support_System__c=True;
        insert prodcomp;
        
        id queueGroupId= [Select Id from Group where type='Queue' limit 1].Id;
      
        Component_Release__c componentReleaseObj = new Component_Release__c();
        componentReleaseObj.Name = 'EARL';
        componentReleaseObj.Component_Release__c = '6.1';
        componentReleaseObj.Component_Code__c='Tape ';
        insert componentReleaseObj;
        
        Case caseObject =new Case();
        caseObject.Accountid=accountObj.Id;
        caseObject.Site_Association__c=siteAssociationObj.Id;
        caseObject.CA_Product_Controller__c=caProductObj.id;
        caseObject.CA_Product_Component__c=prodcomp.id;
        caseObject.ContactId=contactObj.Id;        
        caseObject.Origin='Email';
        caseObject.OwnerId=queueGroupId;
        caseObject.Case_Type__c='Standard';
        caseObject.Subject='test subject TPC';
        caseObject.Description='asdf';
        caseObject.Reason='Instructions Not Clear';
        caseObject.Priority='3';        
        caseObject.Status='Open';
        caseObject.Severity__c='1';
        caseObject.Sev_1_Impact_c__c='Customer set Sev 1 for focus';
        caseObject.Internal_Priority__c='2';
        caseObject.Production_Down_Status__c='Investigating';
        caseObject.Alternate_email__c='vamsi.r@gmail.com';        
        caseObject.Component_Release_Only_Selection__c=  componentReleaseObj.Id;
        insert caseObject;
        
        Defect__c defectObject = new Defect__c();
        defectObject.Defect_URL__c = 'https://www.abc.com';
        defectObject.Defect_Object_ID__c = 'https://www.abc.com';
        defectObject.Defect_Submitted_By__c = 'tarun';
        defectObject.Defect_Owner__c = 'tarun';
        defectObject.Name = 'DE1111';
        //defectObject.OwnerId = queueGroupId;
        defectObject.Priority__c = '1';
        defectObject.Targeted_Release_Number__c = '8';
        defectObject.Target_Release_date__c = system.today();
        defectObject.Type__c = 'Defect';
        defectObject.Subject__c = 'test';
        defectObject.Status__c = 'New';
        defectObject.Severity__c = '1';
        defectObject.Resolution__c = 'fixed';
        defectObject.R_D_System__c = 'Rally';
        defectObject.Description__c = 'test testclass';
        insert defectObject;
        
        Defect_Case_Association__c defectAssociationObject = new Defect_Case_Association__c();
        defectAssociationObject.Case__c = caseObject.Id;
        defectAssociationObject.Defect__c = defectObject.Id;
        insert defectAssociationObject;
        
        apexpages.currentpage().getparameters().put('caseId',caseObject.Id); 
            
   }   
        
    public static testMethod void createTestSuccessData(){
        List<RecordTypes_Setting__c> listOfRecordType = new List<RecordTypes_Setting__c>();
        RecordTypes_Setting__c recordTypeObj = new RecordTypes_Setting__c();
        recordTypeObj.Name = 'SMB';
        recordTypeObj.SObject_Name__c = 'Account';
        recordTypeObj.RecordType_Id__c = '01230000001L55j';
        listOfRecordType.add(recordTypeObj);
        
        RecordTypes_Setting__c recordTypeObj1 = new RecordTypes_Setting__c();
        recordTypeObj1.Name = 'Territory Covered Account';
        recordTypeObj1.SObject_Name__c = 'Account';
        recordTypeObj1.RecordType_Id__c = '01230000001L55o';
        listOfRecordType.add(recordTypeObj1);
        
        RecordTypes_Setting__c recordTypeObj2 = new RecordTypes_Setting__c();
        recordTypeObj2.Name = 'Account Team Covered Account';
        recordTypeObj2.SObject_Name__c = 'Account';
        recordTypeObj2.RecordType_Id__c = '01230000001L55e';
        listOfRecordType.add(recordTypeObj2);
        
        RecordTypes_Setting__c recordTypeObj3 = new RecordTypes_Setting__c();
        recordTypeObj3.Name = 'Commercial Account';
        recordTypeObj3.SObject_Name__c = 'Account';
        recordTypeObj3.RecordType_Id__c = '01230000000GaFY';
        listOfRecordType.add(recordTypeObj3);
        
        RecordTypes_Setting__c recordTypeObj4 = new RecordTypes_Setting__c();
        recordTypeObj4.Name = 'CA Enterprise Account';
        recordTypeObj4.SObject_Name__c = 'Account';
        recordTypeObj4.RecordType_Id__c = '01230000000DNfM';
        listOfRecordType.add(recordTypeObj4);
        
        RecordTypes_Setting__c recordTypeObj5 = new RecordTypes_Setting__c();
        recordTypeObj5.Name = 'Support Account';
        recordTypeObj5.SObject_Name__c = 'Account';
        recordTypeObj5.RecordType_Id__c = '012a00000018GH7';
        listOfRecordType.add(recordTypeObj5);
        
        RecordTypes_Setting__c recordTypeObj6 = new RecordTypes_Setting__c();
        recordTypeObj6.Name = 'Acquisition';
        recordTypeObj6.SObject_Name__c = 'Account';
        recordTypeObj6.RecordType_Id__c = '012300000013vtw';
        listOfRecordType.add(recordTypeObj6);
        
        RecordTypes_Setting__c recordTypeObj7 = new RecordTypes_Setting__c();
        recordTypeObj7.Name = 'Approved Quote';
        recordTypeObj7.SObject_Name__c = 'Account';
        recordTypeObj7.RecordType_Id__c = '012a0000001VvqT';
        listOfRecordType.add(recordTypeObj7);
        
        RecordTypes_Setting__c recordTypeObj8 = new RecordTypes_Setting__c();
        recordTypeObj8.Name = 'CA Global Lead';
        recordTypeObj8.SObject_Name__c = 'Account';
        recordTypeObj8.RecordType_Id__c = '01230000000DUOh';
        listOfRecordType.add(recordTypeObj8);
        
        RecordTypes_Setting__c recordTypeObj9 = new RecordTypes_Setting__c();
        recordTypeObj9.Name = 'CA Indirect Lead';
        recordTypeObj9.SObject_Name__c = 'Account';
        recordTypeObj9.RecordType_Id__c = '01230000000Dhu2';
        listOfRecordType.add(recordTypeObj9);
        
        RecordTypes_Setting__c recordTypeObj10 = new RecordTypes_Setting__c();
        recordTypeObj10.Name = 'Deal Registration';
        recordTypeObj10.SObject_Name__c = 'Account';
        recordTypeObj10.RecordType_Id__c = '01230000000yspg';
        listOfRecordType.add(recordTypeObj10);
        
        RecordTypes_Setting__c recordTypeObj11 = new RecordTypes_Setting__c();
        recordTypeObj11.Name = 'Reseller/Distributor Account';
        recordTypeObj11.SObject_Name__c = 'Account';
        recordTypeObj11.RecordType_Id__c = '01230000000GaFd';
        listOfRecordType.add(recordTypeObj11);
       
        insert listOfRecordType;
        
        Account accountObj = new Account();
        accountObj.Name = 'Generic Support Account'; 
        accountObj.Enterprise_ID__c = '7777777777';
        accountObj.BillingStreet='Street';
        accountObj.BillingCountry='US';
        accountObj.BillingCity='Islandia'; 
        insert accountObj;
        
        Site_Association__c siteAssociationObj = new Site_Association__c();
        siteAssociationObj.Name = 'IBM';
        siteAssociationObj.SAP_Site_ID__c = '280125';
        siteAssociationObj.SC_SITE_Sanctioned_Party__c = 'NO';
        siteAssociationObj.Enterprise_ID__c = accountObj.Id;
        siteAssociationObj.SC_TOPS_ID__c = '1299636';
        siteAssociationObj.Country_picklist__c= 'US - UNITED STATES';
        siteAssociationObj.State__c='New York';
        siteAssociationObj.ProviSite__c = 1;
        insert siteAssociationObj;
        
        Contact contactObj = new Contact();
        contactObj.FirstName ='testAuto';
        contactObj.LastName ='contact';
        insert contactObj;
        
        Contacts_Site_Association__c csaObj = new Contacts_Site_Association__c();
        csaObj.SC_CSA_SITE__c = siteAssociationObj.Id ;
        csaObj.SC_CSA_CONTACTS__c = contactObj.Id; 
        insert csaObj; 
        
        CA_Product_Controller__c caProductObj = new CA_Product_Controller__c();
        caProductObj.name='APPLICATION PERFORMANCE MANAGEMENT';
        insert caProductObj;
        
        CA_Product_Component__c prodcomp = new CA_Product_Component__c();
        prodcomp.Name='APPLICATION PERFORMANCE MANAGEMENT';
        prodcomp.CA_Product_Component_Ext_ID__c='Test';
        prodcomp.Default_Component_for_CA_Product__c=True;
        prodcomp.CA_Product_Controller__c=caProductObj.id;
        prodcomp.CA_Product_Text__c='Test';
        prodcomp.Component_Code__c='Test';
        prodcomp.Component_Text__c='Test';
        prodcomp.Default_Component_for_this_CA_Product__c=True;
        prodcomp.SFDC_Support_System__c=True;
        insert prodcomp;
        
        id queueGroupId= [Select Id from Group where type='Queue' limit 1].Id;
        Organization orgObj = [select Id, IsSandbox from Organization limit 1 ];
        
        Component_Release__c componentReleaseObj = new Component_Release__c();
        componentReleaseObj.Name = 'EARL';
        componentReleaseObj.Component_Release__c = '6.1';
        componentReleaseObj.Component_Code__c='Tape ';
        insert componentReleaseObj;
        
        Case caseObject =new Case();
        caseObject.Accountid=accountObj.Id;
        caseObject.Site_Association__c=siteAssociationObj.Id;
        caseObject.CA_Product_Controller__c=caProductObj.id;
        caseObject.CA_Product_Component__c=prodcomp.id;
        caseObject.ContactId=contactObj.Id;        
        caseObject.Origin='Email';
        caseObject.OwnerId=queueGroupId;
        caseObject.Case_Type__c='Standard';
        caseObject.Subject='test subject TPC';
        caseObject.Description='asdf';
        caseObject.Reason='Instructions Not Clear';
        caseObject.Priority='3';        
        caseObject.Status='Open';
        caseObject.Severity__c='1';
        caseObject.Sev_1_Impact_c__c='Customer set Sev 1 for focus';
        caseObject.Internal_Priority__c='2';
        caseObject.Production_Down_Status__c='Investigating';
        caseObject.Alternate_email__c='vamsi.r@gmail.com';        
        caseObject.Component_Release_Only_Selection__c=  componentReleaseObj.Id;
        insert caseObject;
        
        Defect__c defectObject = new Defect__c();
        defectObject.Defect_URL__c = 'https://www.abc.com';
        defectObject.Defect_Object_ID__c = 'https://www.abc.com';
        defectObject.Defect_Submitted_By__c = 'tarun';
        defectObject.Defect_Owner__c = 'tarun';
        defectObject.Name = 'DE1111';
        //defectObject.OwnerId = queueGroupId;
        defectObject.Priority__c = '1';
        defectObject.Targeted_Release_Number__c = '8';
        defectObject.Target_Release_date__c = system.today();
        defectObject.Type__c = 'Defect';
        defectObject.Subject__c = 'test';
        defectObject.Status__c = 'New';
        defectObject.Severity__c = '1';
        defectObject.Resolution__c = 'fixed';
        defectObject.R_D_System__c = 'Rally';
        defectObject.Description__c = 'test testclass';
        insert defectObject;
        ApexPages.StandardController sc = new ApexPages.standardController(defectObject);
        Defect_Case_Association__c defectAssociationObject = new Defect_Case_Association__c();
        defectAssociationObject.Case__c = caseObject.Id;
        defectAssociationObject.Defect__c = defectObject.Id;
        insert defectAssociationObject;
        
        apexpages.currentpage().getparameters().put('caseId',caseObject.Id); 

    }
    
    public static testMethod void createTestNoDefectData(){
        
        List<RecordTypes_Setting__c> listOfRecordType = new List<RecordTypes_Setting__c>();
        RecordTypes_Setting__c recordTypeObj = new RecordTypes_Setting__c();
        recordTypeObj.Name = 'SMB';
        recordTypeObj.SObject_Name__c = 'Account';
        recordTypeObj.RecordType_Id__c = '01230000001L55j';
        listOfRecordType.add(recordTypeObj);
        
        RecordTypes_Setting__c recordTypeObj1 = new RecordTypes_Setting__c();
        recordTypeObj1.Name = 'Territory Covered Account';
        recordTypeObj1.SObject_Name__c = 'Account';
        recordTypeObj1.RecordType_Id__c = '01230000001L55o';
        listOfRecordType.add(recordTypeObj1);
        
        RecordTypes_Setting__c recordTypeObj2 = new RecordTypes_Setting__c();
        recordTypeObj2.Name = 'Account Team Covered Account';
        recordTypeObj2.SObject_Name__c = 'Account';
        recordTypeObj2.RecordType_Id__c = '01230000001L55e';
        listOfRecordType.add(recordTypeObj2);
        
        RecordTypes_Setting__c recordTypeObj3 = new RecordTypes_Setting__c();
        recordTypeObj3.Name = 'Commercial Account';
        recordTypeObj3.SObject_Name__c = 'Account';
        recordTypeObj3.RecordType_Id__c = '01230000000GaFY';
        listOfRecordType.add(recordTypeObj3);
        
        RecordTypes_Setting__c recordTypeObj4 = new RecordTypes_Setting__c();
        recordTypeObj4.Name = 'CA Enterprise Account';
        recordTypeObj4.SObject_Name__c = 'Account';
        recordTypeObj4.RecordType_Id__c = '01230000000DNfM';
        listOfRecordType.add(recordTypeObj4);
        
        RecordTypes_Setting__c recordTypeObj5 = new RecordTypes_Setting__c();
        recordTypeObj5.Name = 'Support Account';
        recordTypeObj5.SObject_Name__c = 'Account';
        recordTypeObj5.RecordType_Id__c = '012a00000018GH7';
        listOfRecordType.add(recordTypeObj5);
        
        RecordTypes_Setting__c recordTypeObj6 = new RecordTypes_Setting__c();
        recordTypeObj6.Name = 'Acquisition';
        recordTypeObj6.SObject_Name__c = 'Account';
        recordTypeObj6.RecordType_Id__c = '012300000013vtw';
        listOfRecordType.add(recordTypeObj6);
        
        RecordTypes_Setting__c recordTypeObj7 = new RecordTypes_Setting__c();
        recordTypeObj7.Name = 'Approved Quote';
        recordTypeObj7.SObject_Name__c = 'Account';
        recordTypeObj7.RecordType_Id__c = '012a0000001VvqT';
        listOfRecordType.add(recordTypeObj7);
        
        RecordTypes_Setting__c recordTypeObj8 = new RecordTypes_Setting__c();
        recordTypeObj8.Name = 'CA Global Lead';
        recordTypeObj8.SObject_Name__c = 'Account';
        recordTypeObj8.RecordType_Id__c = '01230000000DUOh';
        listOfRecordType.add(recordTypeObj8);
        
        RecordTypes_Setting__c recordTypeObj9 = new RecordTypes_Setting__c();
        recordTypeObj9.Name = 'CA Indirect Lead';
        recordTypeObj9.SObject_Name__c = 'Account';
        recordTypeObj9.RecordType_Id__c = '01230000000Dhu2';
        listOfRecordType.add(recordTypeObj9);
        
        RecordTypes_Setting__c recordTypeObj10 = new RecordTypes_Setting__c();
        recordTypeObj10.Name = 'Deal Registration';
        recordTypeObj10.SObject_Name__c = 'Account';
        recordTypeObj10.RecordType_Id__c = '01230000000yspg';
        listOfRecordType.add(recordTypeObj10);
        
        RecordTypes_Setting__c recordTypeObj11 = new RecordTypes_Setting__c();
        recordTypeObj11.Name = 'Reseller/Distributor Account';
        recordTypeObj11.SObject_Name__c = 'Account';
        recordTypeObj11.RecordType_Id__c = '01230000000GaFd';
        listOfRecordType.add(recordTypeObj11);
       
        insert listOfRecordType;
        
        Account accountObj = new Account();
        accountObj.Name = 'Generic Support Account'; 
        accountObj.Enterprise_ID__c = '7777777777';
        accountObj.BillingStreet='Street';
        accountObj.BillingCountry='US';
        accountObj.BillingCity='Islandia'; 
        insert accountObj;
        
        Site_Association__c siteAssociationObj = new Site_Association__c();
        siteAssociationObj.Name = 'IBM';
        siteAssociationObj.SAP_Site_ID__c = '280125';
        siteAssociationObj.SC_SITE_Sanctioned_Party__c = 'NO';
        siteAssociationObj.Enterprise_ID__c = accountObj.Id;
        siteAssociationObj.SC_TOPS_ID__c = '1299636';
        siteAssociationObj.Country_picklist__c= 'US - UNITED STATES';
        siteAssociationObj.State__c='New York';
        siteAssociationObj.ProviSite__c = 1;
        insert siteAssociationObj;
        
        Contact contactObj = new Contact();
        contactObj.FirstName ='testAuto';
        contactObj.LastName ='contact';
        insert contactObj;
        
        Contacts_Site_Association__c csaObj = new Contacts_Site_Association__c();
        csaObj.SC_CSA_SITE__c = siteAssociationObj.Id ;
        csaObj.SC_CSA_CONTACTS__c = contactObj.Id; 
        insert csaObj; 
        
        CA_Product_Controller__c caProductObj = new CA_Product_Controller__c();
        caProductObj.name='APPLICATION PERFORMANCE MANAGEMENT';
        insert caProductObj;
        
        CA_Product_Component__c prodcomp = new CA_Product_Component__c();
        prodcomp.Name='APPLICATION PERFORMANCE MANAGEMENT';
        prodcomp.CA_Product_Component_Ext_ID__c='Test';
        prodcomp.Default_Component_for_CA_Product__c=True;
        prodcomp.CA_Product_Controller__c=caProductObj.id;
        prodcomp.CA_Product_Text__c='Test';
        prodcomp.Component_Code__c='Test';
        prodcomp.Component_Text__c='Test';
        prodcomp.Default_Component_for_this_CA_Product__c=True;
        prodcomp.SFDC_Support_System__c=True;
        insert prodcomp;
        
        id queueGroupId= [Select Id from Group where type='Queue' limit 1].Id;
        Organization orgObj = [select Id, IsSandbox from Organization limit 1 ];
        
        Component_Release__c componentReleaseObj = new Component_Release__c();
        componentReleaseObj.Name = 'EARL';
        componentReleaseObj.Component_Release__c = '6.1';
        componentReleaseObj.Component_Code__c='Tape ';
        insert componentReleaseObj;
        
        Case caseObject =new Case();
        caseObject.Accountid=accountObj.Id;
        caseObject.Site_Association__c=siteAssociationObj.Id;
        caseObject.CA_Product_Controller__c=caProductObj.id;
        caseObject.CA_Product_Component__c=prodcomp.id;
        caseObject.ContactId=contactObj.Id;        
        caseObject.Origin='Email';
        caseObject.OwnerId=queueGroupId;
        caseObject.Case_Type__c='Standard';
        caseObject.Subject='test subject TPC';
        caseObject.Description='asdf';
        caseObject.Reason='Instructions Not Clear';
        caseObject.Priority='3';        
        caseObject.Status='Open';
        caseObject.Severity__c='1';
        caseObject.Sev_1_Impact_c__c='Customer set Sev 1 for focus';
        caseObject.Internal_Priority__c='2';
        caseObject.Production_Down_Status__c='Investigating';
        caseObject.Alternate_email__c='vamsi.r@gmail.com';        
        caseObject.Component_Release_Only_Selection__c=  componentReleaseObj.Id;
        insert caseObject;
        
        Defect__c defectObject = new Defect__c();
        defectObject.Defect_URL__c = 'https://www.abc.com';
        defectObject.Defect_Object_ID__c = 'https://www.abc.com';
        defectObject.Defect_Submitted_By__c = 'tarun';
        defectObject.Defect_Owner__c = 'tarun';
        defectObject.Name = 'DE12345';
        //defectObject.OwnerId = queueGroupId;
        defectObject.Priority__c = '1';
        defectObject.Targeted_Release_Number__c = '8';
        defectObject.Target_Release_date__c = system.today();
        defectObject.Type__c = 'Defect';
        defectObject.Subject__c = 'test';
        defectObject.Status__c = 'New';
        defectObject.Severity__c = '1';
        defectObject.Resolution__c = 'fixed';
        defectObject.R_D_System__c = 'Rally';
        defectObject.Description__c = 'test testclass';
        insert defectObject;
        
        Defect_Case_Association__c defectAssociationObject = new Defect_Case_Association__c();
        defectAssociationObject.Case__c = caseObject.Id;
        defectAssociationObject.Defect__c = defectObject.Id;
        insert defectAssociationObject;
        
        apexpages.currentpage().getparameters().put('caseId',caseObject.Id); 
    }
    
    public static testMethod void createTestNoDefectAssociateData(){
        
        List<RecordTypes_Setting__c> listOfRecordType = new List<RecordTypes_Setting__c>();
        RecordTypes_Setting__c recordTypeObj = new RecordTypes_Setting__c();
        recordTypeObj.Name = 'SMB';
        recordTypeObj.SObject_Name__c = 'Account';
        recordTypeObj.RecordType_Id__c = '01230000001L55j';
        listOfRecordType.add(recordTypeObj);
        
        RecordTypes_Setting__c recordTypeObj1 = new RecordTypes_Setting__c();
        recordTypeObj1.Name = 'Territory Covered Account';
        recordTypeObj1.SObject_Name__c = 'Account';
        recordTypeObj1.RecordType_Id__c = '01230000001L55o';
        listOfRecordType.add(recordTypeObj1);
        
        RecordTypes_Setting__c recordTypeObj2 = new RecordTypes_Setting__c();
        recordTypeObj2.Name = 'Account Team Covered Account';
        recordTypeObj2.SObject_Name__c = 'Account';
        recordTypeObj2.RecordType_Id__c = '01230000001L55e';
        listOfRecordType.add(recordTypeObj2);
        
        RecordTypes_Setting__c recordTypeObj3 = new RecordTypes_Setting__c();
        recordTypeObj3.Name = 'Commercial Account';
        recordTypeObj3.SObject_Name__c = 'Account';
        recordTypeObj3.RecordType_Id__c = '01230000000GaFY';
        listOfRecordType.add(recordTypeObj3);
        
        RecordTypes_Setting__c recordTypeObj4 = new RecordTypes_Setting__c();
        recordTypeObj4.Name = 'CA Enterprise Account';
        recordTypeObj4.SObject_Name__c = 'Account';
        recordTypeObj4.RecordType_Id__c = '01230000000DNfM';
        listOfRecordType.add(recordTypeObj4);
        
        RecordTypes_Setting__c recordTypeObj5 = new RecordTypes_Setting__c();
        recordTypeObj5.Name = 'Support Account';
        recordTypeObj5.SObject_Name__c = 'Account';
        recordTypeObj5.RecordType_Id__c = '012a00000018GH7';
        listOfRecordType.add(recordTypeObj5);
        
        RecordTypes_Setting__c recordTypeObj6 = new RecordTypes_Setting__c();
        recordTypeObj6.Name = 'Acquisition';
        recordTypeObj6.SObject_Name__c = 'Account';
        recordTypeObj6.RecordType_Id__c = '012300000013vtw';
        listOfRecordType.add(recordTypeObj6);
        
        RecordTypes_Setting__c recordTypeObj7 = new RecordTypes_Setting__c();
        recordTypeObj7.Name = 'Approved Quote';
        recordTypeObj7.SObject_Name__c = 'Account';
        recordTypeObj7.RecordType_Id__c = '012a0000001VvqT';
        listOfRecordType.add(recordTypeObj7);
        
        RecordTypes_Setting__c recordTypeObj8 = new RecordTypes_Setting__c();
        recordTypeObj8.Name = 'CA Global Lead';
        recordTypeObj8.SObject_Name__c = 'Account';
        recordTypeObj8.RecordType_Id__c = '01230000000DUOh';
        listOfRecordType.add(recordTypeObj8);
        
        RecordTypes_Setting__c recordTypeObj9 = new RecordTypes_Setting__c();
        recordTypeObj9.Name = 'CA Indirect Lead';
        recordTypeObj9.SObject_Name__c = 'Account';
        recordTypeObj9.RecordType_Id__c = '01230000000Dhu2';
        listOfRecordType.add(recordTypeObj9);
        
        RecordTypes_Setting__c recordTypeObj10 = new RecordTypes_Setting__c();
        recordTypeObj10.Name = 'Deal Registration';
        recordTypeObj10.SObject_Name__c = 'Account';
        recordTypeObj10.RecordType_Id__c = '01230000000yspg';
        listOfRecordType.add(recordTypeObj10);
        
        RecordTypes_Setting__c recordTypeObj11 = new RecordTypes_Setting__c();
        recordTypeObj11.Name = 'Reseller/Distributor Account';
        recordTypeObj11.SObject_Name__c = 'Account';
        recordTypeObj11.RecordType_Id__c = '01230000000GaFd';
        listOfRecordType.add(recordTypeObj11);
       
        insert listOfRecordType;
        
        Account accountObj = new Account();
        accountObj.Name = 'Generic Support Account'; 
        accountObj.Enterprise_ID__c = '7777777777';
        accountObj.BillingStreet='Street';
        accountObj.BillingCountry='US';
        accountObj.BillingCity='Islandia'; 
        insert accountObj;
        
        Site_Association__c siteAssociationObj = new Site_Association__c();
        siteAssociationObj.Name = 'IBM';
        siteAssociationObj.SAP_Site_ID__c = '280125';
        siteAssociationObj.SC_SITE_Sanctioned_Party__c = 'NO';
        siteAssociationObj.Enterprise_ID__c = accountObj.Id;
        siteAssociationObj.SC_TOPS_ID__c = '1299636';
        siteAssociationObj.Country_picklist__c= 'US - UNITED STATES';
        siteAssociationObj.State__c='New York';
        siteAssociationObj.ProviSite__c = 1;
        insert siteAssociationObj;
        
        Contact contactObj = new Contact();
        contactObj.FirstName ='testAuto';
        contactObj.LastName ='contact';
        insert contactObj;
        
        Contacts_Site_Association__c csaObj = new Contacts_Site_Association__c();
        csaObj.SC_CSA_SITE__c = siteAssociationObj.Id ;
        csaObj.SC_CSA_CONTACTS__c = contactObj.Id; 
        insert csaObj; 
        
        CA_Product_Controller__c caProductObj = new CA_Product_Controller__c();
        caProductObj.name='APPLICATION PERFORMANCE MANAGEMENT';
        insert caProductObj;
        
        CA_Product_Component__c prodcomp = new CA_Product_Component__c();
        prodcomp.Name='APPLICATION PERFORMANCE MANAGEMENT';
        prodcomp.CA_Product_Component_Ext_ID__c='Test';
        prodcomp.Default_Component_for_CA_Product__c=True;
        prodcomp.CA_Product_Controller__c=caProductObj.id;
        prodcomp.CA_Product_Text__c='Test';
        prodcomp.Component_Code__c='Test';
        prodcomp.Component_Text__c='Test';
        prodcomp.Default_Component_for_this_CA_Product__c=True;
        prodcomp.SFDC_Support_System__c=True;
        insert prodcomp;
        
        id queueGroupId= [Select Id from Group where type='Queue' limit 1].Id;
        Organization orgObj = [select Id, IsSandbox from Organization limit 1 ];
        
        Component_Release__c componentReleaseObj = new Component_Release__c();
        componentReleaseObj.Name = 'EARL';
        componentReleaseObj.Component_Release__c = '6.1';
        componentReleaseObj.Component_Code__c='Tape ';
        insert componentReleaseObj;
        
        Case caseObject =new Case();
        caseObject.Accountid=accountObj.Id;
        caseObject.Site_Association__c=siteAssociationObj.Id;
        caseObject.CA_Product_Controller__c=caProductObj.id;
        caseObject.CA_Product_Component__c=prodcomp.id;
        caseObject.ContactId=contactObj.Id;        
        caseObject.Origin='Email';
        caseObject.OwnerId=queueGroupId;
        caseObject.Case_Type__c='Standard';
        caseObject.Subject='test subject TPC';
        caseObject.Description='asdf';
        caseObject.Reason='Instructions Not Clear';
        caseObject.Priority='3';        
        caseObject.Status='Open';
        caseObject.Severity__c='1';
        caseObject.Sev_1_Impact_c__c='Customer set Sev 1 for focus';
        caseObject.Internal_Priority__c='2';
        caseObject.Production_Down_Status__c='Investigating';
        caseObject.Alternate_email__c='vamsi.r@gmail.com';        
        caseObject.Component_Release_Only_Selection__c=  componentReleaseObj.Id;
        insert caseObject;
        
        Defect__c defectObject = new Defect__c();
        defectObject.Defect_URL__c = 'https://www.abc.com';
        defectObject.Defect_Object_ID__c = 'https://www.abc.com';
        defectObject.Defect_Submitted_By__c = 'tarun';
        defectObject.Defect_Owner__c = 'tarun';
        defectObject.Name = 'DE1111';
        //defectObject.OwnerId = queueGroupId;
        defectObject.Priority__c = '1';
        defectObject.Targeted_Release_Number__c = '8';
        defectObject.Target_Release_date__c = system.today();
        defectObject.Type__c = 'Defect';
        defectObject.Subject__c = 'test';
        defectObject.Status__c = 'New';
        defectObject.Severity__c = '1';
        defectObject.Resolution__c = 'fixed';
        defectObject.R_D_System__c = 'Rally';
        defectObject.Description__c = 'test testclass';
        insert defectObject;
        
        apexpages.currentpage().getparameters().put('caseId',caseObject.Id); 
    }
}