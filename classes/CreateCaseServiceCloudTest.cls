@isTest
public class CreateCaseServiceCloudTest {
     static testMethod void CreateCaseServiceCloudTestMethod()
     {
         SystemIdUtility.skipAccount = true;
         SystemIdUtility.skipAccountOnMIPSUpdate = true;
         SystemIdUtility.skipProductTriggers = true;
         Account testAccount = new Account() ; 
         testAccount.Name = 'Generic Support Account Test'; 
         testAccount.Enterprise_ID__c = 'AR51855';
         testAccount.BillingStreet = 'Admiralty Ctr';
         testAccount.BillingCountry = 'HK';
         testAccount.BillingCity = 'ADMIRALTY';
         insert testAccount ; 
         
         Contact testContact = new Contact();
         testContact.LastName = 'test' ;
         testContact.FirstName = 'test' ; 
         testContact.Email = 'govda@ca.com';
         testcontact.SC_CONTACT_LDAPID__c='GOVDA01';    
         testContact.Phone = '1234567';
         insert testContact ; 
         
         Site_Association__c testSite = new Site_Association__c();
         testSite.Name = 'FINANCIAL SERVICES & THE TREASURY BUREA';
         testSite.ProviSite__c = 2; 
         testSite.Enterprise_ID__c =  testAccount.Id; 
         testSite.SC_SITE_Sanctioned_Party__c = 'No';
         testSite.SC_TOPS_ID__c = '788689';
         testSite.SC_SITE_Source__c = 'Support' ; 
         testSite.State__c = 'california';
         testSite.Country_picklist__c ='US - UNITED STATES';
         insert testSite ;     
         
         CreateCaseServiceCloud obj1 = new CreateCaseServiceCloud();
         CreateCaseServiceCloud.wrapperInput wi = new CreateCaseServiceCloud.wrapperInput();
         CreateCaseServiceCloud.createCase(wi); 
         CreateCaseServiceCloud.wrapperInput wi1 = new CreateCaseServiceCloud.wrapperInput();
         wi1.pmfkey='GOVDA01';
         wi1.siteid='8888886';
         wi1.email='govda@ca.com';
         wi1.rmethod='P';
         wi1.phone1='1234567';
         wi1.phone2='32434554';
         wi1.product='ALM';
         wi1.os='asd';
         wi1.title='test';
         wi1.text='test';
         wi1.topscd='asd';
         wi1.topsrel='test';
         wi1.cmethod='M';
         wi1.technician='test';
         wi1.iss_typ='test';
         wi1.ca_rep='test';
         wi1.action='test';
         wi1.issue_number='123';
         wi1.pty='test';
         wi1.genlevel='1';
         wi1.release='test';
         wi1.business_impact='high';
         wi1.caid='NR4848';
         wi1.connectid='test';
         wi1.fname='test';
         wi1.lname='test';
         wi1.lang1='TAH';
         wi1.lang2='HIN';
         wi1.connectsite='test';
         wi1.loggedInFirstName= 'test';   
         wi1.loggedInLastName=  'test';  
         wi1.loggedInPhoneNumber= 'test'; 
         wi1.loggedInEmailId=  'test@ca.com';    
         wi1.offeringCode= '2';
         wi1.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi1);         
         
         CreateCaseServiceCloud obj2 = new CreateCaseServiceCloud();
         CreateCaseServiceCloud.wrapperInput wi2 = new CreateCaseServiceCloud.wrapperInput();
         wi2.pmfkey='GOVDA01';
         wi2.email='govda@ca.com';
         wi2.rmethod='post';
         wi2.phone1='1234567';
         wi2.phone2='32434554';
         wi2.product='ALM';
         wi2.os='asd';
         wi2.title='test';
         wi2.text='test';
         wi2.topscd='asd';
         wi2.topsrel='test';
         wi2.cmethod='test';
         wi2.technician='test';
         wi2.iss_typ='test';
         wi2.ca_rep='test';
         wi2.action='test';
         wi2.issue_number='123';
         wi2.pty='test';
         wi2.genlevel='1';
         wi2.release='test';
         wi2.business_impact='high';
         wi2.caid='NR4848';
         wi2.connectid='121';
         wi2.fname='test';
         wi2.lname='test';
         wi2.lang1='test';
         wi2.lang2='test';
         wi2.connectsite='test';
         wi2.loggedInFirstName= 'test';   
         wi2.loggedInLastName=  'test';  
         wi2.loggedInPhoneNumber= 'test'; 
         wi2.loggedInEmailId=  'test@ca.com';    
         wi2.offeringCode= '2';
         wi2.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi2);
         
         CreateCaseServiceCloud.getContactIdbyEmail('govda@ca.com');
         CreateCaseServiceCloud.getContactIdbyEmail('abc@ca.com');
         CreateCaseServiceCloud.getProjectSiteAssociationByProject('govda@ca.com');
         Product2 prod = new Product2(Name='test product', CSU2__c='test CSU2', Product_Group__c='test product group');
         insert prod;
               
         Product_Material__c pm = new Product_Material__c(Name='p123', Product__c=prod.Id, Material_Text__c='test material text');
         insert pm;
         Product_Release__c testproductrelease=new Product_Release__c();
         testproductrelease.Product_Material__c=pm.id;
         testproductrelease.Name='Testproductrelease';
         insert testproductrelease;
         Product_Release__c testproductrelease1=new Product_Release__c();
         testproductrelease1.Product_Material__c=pm.id;
         testproductrelease1.Name='Testproductrelease';
         testproductrelease1.Product_Release__c = 'a123456';
         insert testproductrelease1;
         
                
         Component_Release__c componentRelease = new Component_Release__c();
         componentRelease.Name = 'EARL';
         componentRelease.Component_Release__c = '6.1';
         componentRelease.Component_Code__c='Tape ';
         insert componentRelease;
         
         CA_Product_Controller__c prodCtl = new CA_Product_Controller__c();
         prodCtl.name='Test';
         insert prodCtl;
         
         CA_Product_Component__c prodcomp = new CA_Product_Component__c();
         prodcomp.Name='Test';
         prodcomp.CA_Product_Component_Ext_ID__c='Test';
         prodcomp.Default_Component_for_CA_Product__c=True;
         prodcomp.CA_Product_Controller__c=prodCtl.id;
         prodcomp.CA_Product_Text__c='Test';
         prodcomp.Component_Code__c='Test';
         prodcomp.Component_Text__c='Test';
         prodcomp.Default_Component_for_this_CA_Product__c=True;
         prodcomp.SFDC_Support_System__c=True;
         insert prodcomp;
         
         Operating_System__c os = new Operating_System__c (Operating_System_Class__c='tet',Operating_System_Ext_ID__c='x234');
         insert os;
         CreateCaseServiceCloud.getOperatingSystem('tet');
         
         Product_Release_and_Operating_System__c pr = new Product_Release_and_Operating_System__c();
         pr.Operating_System__c = os.id;
         pr.Product_Release__c = testproductrelease1.id;
         CreateCaseServiceCloud.getProductReleaseandOperating_System(os.id+'',testproductrelease1.id+'');
         
         CreateCaseServiceCloud.getComponentCodeWoTopsCode ('Test');
         CreateCaseServiceCloud.getProductMaterialByTopscode('p123');
         CreateCaseServiceCloud.getProductMaterialByTopscode('p1234');
         CreateCaseServiceCloud.getProductReleaseByMaterialandRelease(pm.id+'','a123456');
         CreateCaseServiceCloud.getComponentReleaseByProduct('Tape');
         CreateCaseServiceCloud.getComponentReleaseByProduct('Tape1');
         CreateCaseServiceCloud.getComponentCode('Test',prodCtl.id+'');
         CreateCaseServiceCloud.getComponentCode('Test1',prodCtl.id+'');
         CreateCaseServiceCloud.insertProductServicePack('Test',testproductrelease1.id+'','Test','x123');
         CreateCaseServiceCloud.getProductServicePackByGenlevel('Test',testproductrelease1.id+'');
         CreateCaseServiceCloud.getProductServicePackByGenlevel('Test12',testproductrelease1.id+'');
         
         CreateCaseServiceCloud.retrieveLanguage('ARA');

        CreateCaseServiceCloud.retrieveLanguage('ARA'); 
        CreateCaseServiceCloud.retrieveLanguage('ARM') ;
        CreateCaseServiceCloud.retrieveLanguage('BOS') ;
        CreateCaseServiceCloud.retrieveLanguage('BUL') ;
        CreateCaseServiceCloud.retrieveLanguage('BUR') ;
        CreateCaseServiceCloud.retrieveLanguage('CAT') ;
        CreateCaseServiceCloud.retrieveLanguage('CHI') ;
        CreateCaseServiceCloud.retrieveLanguage('CHS') ;
        CreateCaseServiceCloud.retrieveLanguage('CHT') ;
        CreateCaseServiceCloud.retrieveLanguage('CRO') ;
        CreateCaseServiceCloud.retrieveLanguage('CZE') ;
        CreateCaseServiceCloud.retrieveLanguage('DAN') ;
        CreateCaseServiceCloud.retrieveLanguage('DUT') ;
        CreateCaseServiceCloud.retrieveLanguage('ENG') ;
        CreateCaseServiceCloud.retrieveLanguage('EPO') ;
        CreateCaseServiceCloud.retrieveLanguage('EST') ;
        CreateCaseServiceCloud.retrieveLanguage('FIN') ;
        CreateCaseServiceCloud.retrieveLanguage('FRC') ;
        CreateCaseServiceCloud.retrieveLanguage('FRE') ;
        CreateCaseServiceCloud.retrieveLanguage('GER') ;
        CreateCaseServiceCloud.retrieveLanguage('GRE') ;
        CreateCaseServiceCloud.retrieveLanguage('HEB') ;
        CreateCaseServiceCloud.retrieveLanguage('HIN') ;
        CreateCaseServiceCloud.retrieveLanguage('HUN') ;
        CreateCaseServiceCloud.retrieveLanguage('ICE') ;
        CreateCaseServiceCloud.retrieveLanguage('IND') ;
        CreateCaseServiceCloud.retrieveLanguage('IRA') ;
        CreateCaseServiceCloud.retrieveLanguage('IRI') ;
        CreateCaseServiceCloud.retrieveLanguage('ITA') ;
        CreateCaseServiceCloud.retrieveLanguage('JPN') ;
        CreateCaseServiceCloud.retrieveLanguage('KOR') ;
        CreateCaseServiceCloud.retrieveLanguage('LAT') ;
        CreateCaseServiceCloud.retrieveLanguage('MAC') ;
        CreateCaseServiceCloud.retrieveLanguage('MLT') ;
        CreateCaseServiceCloud.retrieveLanguage('MON') ;
        CreateCaseServiceCloud.retrieveLanguage('NEP') ;
        CreateCaseServiceCloud.retrieveLanguage('NOR') ;
        CreateCaseServiceCloud.retrieveLanguage('PBR') ;
        CreateCaseServiceCloud.retrieveLanguage('POL') ;
        CreateCaseServiceCloud.retrieveLanguage('RON') ;
        CreateCaseServiceCloud.retrieveLanguage('RUS') ;
        CreateCaseServiceCloud.retrieveLanguage('SER') ;
        CreateCaseServiceCloud.retrieveLanguage('SIN') ;
        CreateCaseServiceCloud.retrieveLanguage('SLA') ;
        CreateCaseServiceCloud.retrieveLanguage('SLO') ;
        CreateCaseServiceCloud.retrieveLanguage('SLV') ;
        CreateCaseServiceCloud.retrieveLanguage('SMO') ;
        CreateCaseServiceCloud.retrieveLanguage('SOM') ;
        CreateCaseServiceCloud.retrieveLanguage('SPA') ;
        CreateCaseServiceCloud.retrieveLanguage('SRD') ;
        CreateCaseServiceCloud.retrieveLanguage('SSW') ;
        CreateCaseServiceCloud.retrieveLanguage('SUN') ;
        CreateCaseServiceCloud.retrieveLanguage('SWA') ;
        CreateCaseServiceCloud.retrieveLanguage('SWE') ;
        CreateCaseServiceCloud.retrieveLanguage('TAH') ;
        CreateCaseServiceCloud.retrieveLanguage('THA') ;
        CreateCaseServiceCloud.retrieveLanguage('TUR') ;
        CreateCaseServiceCloud.retrieveLanguage('UKR') ;
        CreateCaseServiceCloud.retrieveLanguage('VIE') ;
        CreateCaseServiceCloud.getUserContactRecord('GOVDA01');
        CreateCaseServiceCloud.getUserContactRecord('GOVDA02');
         
         User u3 = [Select id, email, pmfkey__c from user where isactive = true limit 1];
       
         CreateCaseServiceCloud.getUserIdbyConnectId(u3.pmfkey__c);
         CreateCaseServiceCloud.getUserIdbyEmail(u3.email);
         CreateCaseServiceCloud.getUserIdbyConnectId('GOVDA12');
         CreateCaseServiceCloud.getUserIdbyEmail('newuser2@ca.com');
    
         CreateCaseServiceCloud obj_1 = new CreateCaseServiceCloud();
         CreateCaseServiceCloud.wrapperInput wi_1 = new CreateCaseServiceCloud.wrapperInput();
         wi_1.pmfkey='GOVDA01';
         wi_1.email='govda@ca.com';
         wi_1.rmethod='post';
         wi_1.phone1='1234567';
         wi_1.phone2='32434554';         
         wi_1.os='asd';
         wi_1.title='test';
         wi_1.text='test';               
         wi_1.cmethod='P';
         wi_1.technician='test';
         wi_1.iss_typ='test';
         wi_1.ca_rep='test';
         wi_1.action='test';
         wi_1.issue_number='123';
         wi_1.pty='test';
         wi_1.genlevel='1';
         wi_1.release='test';
         wi_1.business_impact='high';
         wi_1.caid='NR4848';
         wi_1.connectid='121';
         wi_1.fname='test';
         wi_1.lname='test';
         wi_1.lang1='test';
         wi_1.lang2='test';
         wi_1.connectsite='test';
         wi_1.loggedInFirstName= 'test';   
         wi_1.loggedInLastName=  'test';  
         wi_1.loggedInPhoneNumber= 'test'; 
         wi_1.loggedInEmailId=  'test@ca.com';    
         wi_1.offeringCode= '2';
         wi_1.siteid='test';
         wi_1.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi_1);
         
         CreateCaseServiceCloud obj3 = new CreateCaseServiceCloud();
         CreateCaseServiceCloud.wrapperInput wi3 = new CreateCaseServiceCloud.wrapperInput();
         wi3.pmfkey='GOVDA01';
         wi3.email='govda@ca.com';
         wi3.rmethod='post';
         wi3.phone1='1234567';
         wi3.phone2='32434554';         
         wi3.os='asd';         
         wi3.text='test';               
         wi3.cmethod='test';
         wi3.technician='test';
         wi3.iss_typ='test';
         wi3.ca_rep='test';
         wi3.action='test';
         wi3.issue_number='123';         
         CreateCaseServiceCloud.createCase(wi3);
         
         CreateCaseServiceCloud obj4 = new CreateCaseServiceCloud();
         CreateCaseServiceCloud.wrapperInput wi4 = new CreateCaseServiceCloud.wrapperInput();
         wi4.pmfkey='GOVDA01';
         wi4.email='govda@ca.com';
         wi4.rmethod='E';
         wi4.phone1='1234567';
         wi4.phone2='32434554';         
         wi4.os='tet';         
         wi4.text='test';               
         wi4.cmethod='test';
         wi4.technician='test';
         wi4.iss_typ='test';
         wi4.ca_rep='test';
         wi4.action='test';
         wi4.issue_number='123';
         wi4.pty='test';
         wi4.genlevel='1';
         wi4.release='test';
         wi4.business_impact='high';
         wi4.caid='NR4848';
         wi4.fname='test';
         wi4.lname='test';
         wi4.lang1='test';
         wi4.lang2='test';
         wi4.connectsite='test';
         wi4.loggedInFirstName= 'test';   
         wi4.loggedInLastName=  'test';  
         wi4.loggedInPhoneNumber= 'test'; 
         wi4.loggedInEmailId=  'test@ca.com';    
         wi4.offeringCode= '2';
         wi4.siteid='test';
         wi4.cmethod = 'M';
         wi4.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi4);
         
         System.debug('wi5++++++++++++++++');
         CreateCaseServiceCloud.wrapperInput wi5 = new CreateCaseServiceCloud.wrapperInput();
         wi5.pmfkey='GOVDA01';
         wi5.siteid='8888886';
         wi5.email='govda@ca.com';
         wi5.rmethod='P';
         wi5.phone1='1234567';
         wi5.phone2='32434554';
         wi5.product='ALM';
         wi5.os='tet';
         wi5.title='test';
         wi5.text='test';
         wi5.topscd='asd';
         wi5.topsrel='test';
         wi5.cmethod='E';
         wi5.technician='test';
         wi5.iss_typ='Q';
         wi5.ca_rep='test';
         wi5.action='test';
         wi5.issue_number='123';
         wi5.pty='test';
         wi5.genlevel='1';
         wi5.release='test';
         wi5.business_impact='high';
         wi5.caid='NR4848';
         wi5.connectid='test';
         wi5.fname='test';
         wi5.lname='test';
         wi5.lang1='TAH';
         wi5.lang2='HIN';
         wi5.connectsite='test';
         wi5.loggedInFirstName= 'test';   
         wi5.loggedInLastName=  'test';  
         wi5.loggedInPhoneNumber= 'test'; 
         wi5.loggedInEmailId=  'test@ca.com';    
         wi5.offeringCode= '2';
         wi5.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi5);
         
         //MANAR08 - starts
         System.debug('wi6 1++++++++++++++++');
         CreateCaseServiceCloud.wrapperInput wi6 = new CreateCaseServiceCloud.wrapperInput();
         wi6.pmfkey='GOVDA01';
         wi6.siteid='8888886';
         wi6.email='govda@ca.com';
         wi6.rmethod='P';
         wi6.phone1='1234567';
         wi6.phone2='32434554';
         wi6.product='ALM';
         wi6.os='tet';
         wi6.title='test';
         wi6.text='test';
         wi6.topscd='asd';
         wi6.topsrel='test';
         wi6.cmethod='E';
         wi6.technician='test';
         wi6.iss_typ='E';
         wi6.ca_rep='test';
         wi6.action='Y';
         wi6.issue_number='123';
         wi6.pty='test';
         wi6.genlevel='1';
         wi6.release='test';
         wi6.business_impact='high';
         wi6.caid='NR4848';
         wi6.connectid='';
         wi6.fname='test';
         wi6.lname='test';
         wi6.lang1='TAH';
         wi6.lang2='HIN';
         wi6.connectsite='test';
         wi6.loggedInFirstName= 'test';   
         wi6.loggedInLastName=  'test';  
         wi6.loggedInPhoneNumber= 'test'; 
         wi6.loggedInEmailId=  'test@ca.com';    
         wi6.offeringCode= '2';
         wi6.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi6);
		System.debug('wi6 2++++++++++++++++');
         wi6.email = 'testing123@gmail.com';
         wi6.cmethod = 'M';
		 CreateCaseServiceCloud.createCase(wi6);           
         System.debug('wi6 3 ++++++++++++++++');
         wi6.cmethod = 'E';
         wi6.email = 'test@cai.com';
         wi6.topscd= null;
         wi6.title = null;
         wi6.text = null;
         wi6.topsrel = null;   
         wi6.genlevel='1';
         CreateCaseServiceCloud.createCase(wi6);
       
         /*
         System.debug('wi8++++++++++++++++');
         CreateCaseServiceCloud.wrapperInput wi8 = new CreateCaseServiceCloud.wrapperInput();
         wi8.pmfkey='GOVDA01';
         wi8.email='GOVDA01@ca.com';
         wi8.rmethod='P';
         wi8.phone1='1234567';
         wi8.phone2='32434554';         
         wi8.os='tet';         
         wi8.text='test';               
         wi8.cmethod='M';
         wi8.technician='test';
         wi8.iss_typ='B';
         wi8.ca_rep='test';
         wi8.action='test';
         wi8.issue_number='123';
         wi8.pty='test';
         wi8.genlevel='1';
         wi8.release='test';
         wi8.business_impact='high';
         wi8.caid='NR4848';
         wi8.fname='test';
         wi8.lname='test';
         wi8.lang1='test';
         wi8.lang2='IND';
         wi8.connectsite='test';
         wi8.loggedInFirstName= 'test';   
         wi8.loggedInLastName=  'test';  
         wi8.loggedInPhoneNumber= 'test'; 
         wi8.loggedInEmailId=  'test@contractor.ca.com';    
         wi8.offeringCode= '2';
         wi8.siteid='105246';
         wi8.designatedSupportEngineer= 'test';
         wi8.connectid = 'GOVDA01';
         CreateCaseServiceCloud.createCase(wi8);*/
         
         System.debug('wi7++++++++++++++++');
         CreateCaseServiceCloud.wrapperInput wi7 = new CreateCaseServiceCloud.wrapperInput();
         wi7.pmfkey='GOVDA01';
         wi7.siteid='8888886';
         wi7.email='govda@ca.com';
         wi7.rmethod='P';
         wi7.phone1='1234567';
         wi7.phone2='32434554';
         wi7.product='ALM';
         wi7.os='tet';
         wi7.title='test';         
         wi7.topscd='asd';
         wi7.topsrel=null;
         wi7.cmethod='E';
         wi7.technician='test';
         wi7.iss_typ='E';
         wi7.ca_rep='test';
         wi7.action='Y';
         wi7.issue_number='123';
         wi7.pty='test';
         wi7.genlevel='1';
         wi7.release='test';
         wi7.business_impact='high';
         wi7.caid='NR4848';
         wi7.connectid='';
         wi7.fname='test';
         wi7.lname='test';
         wi7.lang1='TAH';
         wi7.lang2='HIN';
         wi7.connectsite='test';
         wi7.loggedInFirstName= 'test';   
         wi7.loggedInLastName=  'test';  
         wi7.loggedInPhoneNumber= 'test'; 
         wi7.loggedInEmailId=  'test@ca.com';    
         wi7.offeringCode= '2';
         CreateCaseServiceCloud.createCase(wi7);
         
         
         
     }
    
    static testMethod void createCase1()
    {
        TestSLOMilestonesDataSetup.createTestDataforMilestones();        
        SystemIdUtility.skipAccount = true;
         SystemIdUtility.skipAccountOnMIPSUpdate = true;
         SystemIdUtility.skipProductTriggers = true;
        
         Account testAccount = new Account() ; 
         testAccount.Name = 'Generic Support Account Test'; 
         testAccount.Enterprise_ID__c = 'AR51855';
         testAccount.BillingStreet = 'Admiralty Ctr';
         testAccount.BillingCountry = 'HK';
         testAccount.BillingCity = 'ADMIRALTY';
         insert testAccount ; 
         
         Contact testContact = new Contact();
         testContact.LastName = 'test' ;
         testContact.FirstName = 'test' ; 
         testContact.Email = 'govda@ca.com';
         testcontact.SC_CONTACT_LDAPID__c='GOVDA01';    
         testContact.Phone = '1234567';
         insert testContact ; 
         
         Site_Association__c testSite = new Site_Association__c();
         testSite.Name = 'FINANCIAL SERVICES & THE TREASURY BUREA';
         testSite.ProviSite__c = 2; 
         testSite.Enterprise_ID__c =  testAccount.Id; 
         testSite.SC_SITE_Sanctioned_Party__c = 'No';
         testSite.SC_TOPS_ID__c = '788689';
         testSite.SC_SITE_Source__c = 'Support' ; 
         testSite.State__c = 'california';
         testSite.Country_picklist__c ='US - UNITED STATES';
         insert testSite ;    
        
        CA_Product_Controller__c testCAProduct = new CA_Product_Controller__c();
        testCAProduct.Name = 'testtest' ;
        insert testCAProduct ;
        
        CA_Product_Component__c testCAComponent = new CA_Product_Component__c();
        testCAComponent.Name = 'APPLICATION PERFORMANCE MANAGEMENT CEMINT';
        testCAComponent.CA_Product_Controller__c = testCAProduct.Id ; 
        testCAComponent.Default_Component_for_this_CA_Product__c = true;
        insert testCAComponent;
        
        Product_Material__C productMaterial = new Product_Material__C();
        productMaterial.Name = 'DAL2TO00200';
        productMaterial.CA_Product_Controller__c = testCAProduct.Id;
        productMaterial.Source_System__c = 'TOPS';
        insert productMaterial;
        
        Product_Release__C productRelease =  new Product_Release__C();
        productRelease.Name = 'DAL2TO00200-1-CA-DAL-SERVER FOR DB2';
        productRelease.Product_Material__c = productMaterial.Id; 
        insert productRelease;
        
       	Case caseRec = new Case();
        caseRec.Site_Association__c = testSite.Id ;
        caseRec.subject = 'Test Subject' ; 
        caseRec.Description = 'Test Description' ; 
        caseRec.ContactId = testContact.Id ; 
        caseRec.CA_Product_Controller__c = testCAProduct.Id; 
        caseRec.Origin = 'Phone Call';       
        caseRec.Troubleshooting_Stage__c = '1. Problem Identification';     
        caseRec.Status = 'Open';
        caseRec.Severity__c = '2'; 
        insert caseRec;
        
        CreateCaseServiceCloud.getCaseDetailsById(caseRec.Id);
        CreateCaseServiceCloud.logComment('Test Comment',String.valueOf(caseRec.Id));  
        CreateCaseServiceCloud.getProductReleaseComponentReleaseByProductComponent(productRelease.Id,'');
    }
    
    static testMethod void createCaseFromMobile(){      
        CreateCaseServiceCloud.wrapperInput wi1 = new CreateCaseServiceCloud.wrapperInput();
         wi1.pmfkey='GOVDA01';
         wi1.siteid='105246';
         wi1.email='govda@ca.com';
         wi1.rmethod='P';
         wi1.phone1='1234567';
         wi1.phone2='32434554';
         wi1.product='ALM';
         wi1.os='asd';
         wi1.title='test';
         wi1.text='test';
         wi1.topscd='asd';
         wi1.topsrel='test';
         wi1.cmethod='M';
         wi1.technician='test';
         wi1.iss_typ='test';
         wi1.ca_rep='test';
         wi1.action='test';
         wi1.issue_number='123';
         wi1.pty='test';
         wi1.genlevel='1';
         wi1.release='test';
         wi1.business_impact='high';
         wi1.caid='NR4848';
         wi1.connectid='test';
         wi1.fname='test';
         wi1.lname='test';
         wi1.lang1='TAH';
         wi1.lang2='HIN';
         wi1.connectsite='test';
         wi1.loggedInFirstName= 'test';   
         wi1.loggedInLastName=  'test';  
         wi1.loggedInPhoneNumber= 'test'; 
         wi1.loggedInEmailId=  'test@ca.com';    
         wi1.offeringCode= '2';
         wi1.designatedSupportEngineer= 'test';
         CreateCaseServiceCloud.createCase(wi1);  
    }
    
    
}