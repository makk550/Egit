@isTest(seeAllData=true)
public class TestContractsInvalidation{    
    public static testMethod void ContractsInvalidationTest(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='test@test.com';
        String contactEmail = 'jsmith@salesforce.com';
        email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
        email.subject = 'Dummy Account Name 123';
          
        List<Account> accntList = new List<Account>();
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.BillingStreet = 'Arlington';
        ac.BillingCountry = 'US';
        ac.BillingCity = 'VA';
           
        ac.Customer_Category__c = 'Enterprise';
        //ac.Account_Status__c = 'Approved';        
        ac.GEO__c='NA';
        
        ac.Enterprise_ID__c = '1234te';
        
        ac.Enterprise_Account_Name__c = 'rdName';
        ac.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();
        ac.Commercial_ID__c = 'asdf';
        //ac.Sales_Area__c =''
        accntList.add(ac);
        Account ac1 = new Account();
        ac1.Name = 'Test Account';
        ac1.Customer_Category__c = 'Enterprise';
        //ac1.Account_Status__c = 'Approved';       
        ac1.BillingStreet = 'Arlington';
        ac1.BillingCountry = 'US';
        ac1.BillingCity = 'VA';
        ac1.GEO__c='LA';
        ac1.Enterprise_ID__c = '1234te';
        ac1.Enterprise_Account_Name__c = 'rdName1';
        ac1.Commercial_ID__c = 'asdf';
        ac1.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();
        accntList.add(ac1);
        insert accntList;
          
        Renewal_Currency__c renCurrency = new Renewal_Currency__c(name='INR');
        insert renCurrency;  
          
        List<Active_Contract__c> activeContractList = new List<Active_Contract__c>(); 
        Active_Contract__c activeContract = new Active_Contract__c(
        name='TestActiveContract',Account__c=ac.Id,Contract_Term_Months__c=10,Renewal_Currency__c=renCurrency.Id);
        activeContractList.add(activeContract);
        Active_Contract__c activeContract2 = new Active_Contract__c(name='TestActiveContract2',Account__c=ac1.Id);
        activeContractList.add(activeContract2);
        insert activeContractList;
        
        List<product2> prodList = new List<product2>();
        Product2 prod = new Product2(Name = 'Specific Product');
        prodList.add(prod);  
        
        insert prodList;
        
        List<Active_Contract_Product__c> activeContractProdList = new List<Active_Contract_Product__c>();              
        Active_Contract_Product__c actvContPrd= new Active_Contract_Product__c(name='TestACP',Active_Contract__c=activeContract.Id,
        Product__c=prod.Id,Dismantle_Date__c =date.parse('10/20/2013'),Pre_Segmentation__c ='LT');
        activeContractProdList.add(actvContPrd);
        Active_Contract_Product__c actvContPrd2= new Active_Contract_Product__c(name='TestACP2',Active_Contract__c=activeContract2.Id,
        Product__c=prod.Id,Dismantle_Date__c =date.parse('10/20/2013'),Pre_Segmentation__c ='MT');
        activeContractProdList.add(actvContPrd2);
        Active_Contract_Product__c actvContPrd3= new Active_Contract_Product__c(name='TestACP3',Active_Contract__c=activeContract.Id,
        Product__c=prod.Id,Dismantle_Date__c =date.parse('11/20/2013'),Pre_Segmentation__c ='MT');
        activeContractProdList.add(actvContPrd3);
        Active_Contract_Product__c actvContPrd4= new Active_Contract_Product__c(name='TestACP4',Active_Contract__c=activeContract2.Id,
        Product__c=prod.Id,Dismantle_Date__c =date.parse('11/20/2013'),Pre_Segmentation__c ='MT');
        activeContractProdList.add(actvContPrd4);
        insert activeContractProdList;
        
        List<Active_Contract_Line_Item__c> actLineItemsList = new List<Active_Contract_Line_Item__c>();
        Active_Contract_Line_Item__c acp = new Active_Contract_Line_Item__c(
        AOCV__c = 300000,Raw_Maint_Calc_LC__c = 30000,
        OCV__c = 200000,
        ATTRF_CRV__c = 14000, Contract_Product__c =actvContPrd.Id, ACL_Status__c = 'invalid');
        Active_Contract_Line_Item__c acp2 = new Active_Contract_Line_Item__c(
        AOCV__c = 300000,Raw_Maint_Calc_LC__c = 40000,
        OCV__c = 200000,
        ATTRF_CRV__c = 14000, Contract_Product__c =actvContPrd2.Id, ACL_Status__c = 'invalid');
        Active_Contract_Line_Item__c acp3 = new Active_Contract_Line_Item__c(
        AOCV__c = 300000,Raw_Maint_Calc_LC__c = 35000,
        OCV__c = 200000,
        ATTRF_CRV__c = 14000, Contract_Product__c =actvContPrd3.Id, ACL_Status__c = 'invalid');
        Active_Contract_Line_Item__c acp4 = new Active_Contract_Line_Item__c(
        AOCV__c = 300000,Raw_Maint_Calc_LC__c = 40000,
        OCV__c = 200000,
        ATTRF_CRV__c = 14000,Contract_Product__c =actvContPrd4.Id, ACL_Status__c = 'invalid');
        
        actLineItemsList.add(acp);
        actLineItemsList.add(acp2);
        actLineItemsList.add(acp3);
        actLineItemsList.add(acp4);
        insert actLineItemsList;
        
        ContractsInvalidation CI = new ContractsInvalidation();
        SystemIdUtility.runTestContractsInvalidation = true;
        Test.startTest();
        Messaging.InboundEmailResult result = CI.handleInboundEmail(email, env);
        Test.stopTest();
    }   
    public static testMethod void ContractsInvalidationTest1(){

        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.BillingStreet = 'Arlington';
        ac.BillingCountry = 'US';
        ac.BillingCity = 'VA';
        ac.Customer_Category__c = 'Enterprise';
        ac.GEO__c='NA';
        ac.Enterprise_ID__c = '1234te';
        ac.Enterprise_Account_Name__c = 'rdName';
        ac.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();
        ac.Commercial_ID__c = 'asdf';
        insert ac;
        
        
        Product2 prod = new Product2(Name = 'Specific Product');
        insert prod;
        Active_Contract__c activeContract = new Active_Contract__c(CRV_Process_completed__c = true,
        name='TestActiveContract',Account__c=ac.Id,Contract_Term_Months__c=10, Invalid__c = false);
        insert activeContract;
        Active_Contract_Product__c actvContPrd= new Active_Contract_Product__c(name='TestACP',Active_Contract__c=activeContract.Id,
        Product__c=prod.Id,Dismantle_Date__c =date.parse('10/20/2013'),Pre_Segmentation__c ='LT');
        insert actvContPrd;
        
        
        OpportunityLineItem oli1 = [Select id,Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, OpportunityId 
                                                        FROM OpportunityLineItem where  Business_Type__c = 'Renewal' limit 1];
                                                        
        oli1.Active_Contract__c = activeContract.id;
        update oli1;    
        
        Active_Contract__c activeContract2 = new Active_Contract__c(name='TestActiveContract2',Account__c=ac.Id);
        insert activeContract2 ;
        activeContract2.Invalid__c = true;
        update activeContract2 ;
        activeContract.Invalid__c = true;
        update activeContract ;
       
        }
           
           public static testMethod void ContractsInvalidationTest2(){
           
           
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.BillingStreet = 'Arlington';
        ac.BillingCountry = 'US';
        ac.BillingCity = 'VA';
        ac.Customer_Category__c = 'Enterprise';
        ac.GEO__c='NA';
        ac.Enterprise_ID__c = '1234te';
        ac.Enterprise_Account_Name__c = 'rdName';
        ac.RecordTypeId = SystemIdUtility.getSMBAcctRecordTypeId();
        ac.Commercial_ID__c = 'asdf';
        insert ac;
           OpportunityLineItem oli1 = [Select id,Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, OpportunityId 
                                                        FROM OpportunityLineItem where  Business_Type__c = 'Renewal'  AND Opportunity.Other_Win_Loss_Reason__c!=null and Opportunity.Deal_lost_to__C!=null limit 1];
            test.starttest();
        Opportunity opp = [select closedate from opportunity where id=:oli1.OpportunityId];
               opp.closedate = system.today()-4;
               update opp;
            
            Active_Contract__c activeContract2 = new Active_Contract__c(name='TestActiveContract2',Account__c=ac.Id);
        insert activeContract2 ;
        Product2 prod = new Product2(Name = 'Specific Product');
        insert prod;
        
        Active_Contract_Product__c actvContPrd= new Active_Contract_Product__c(name='TestACP',Active_Contract__c=activeContract2.Id,
        Product__c=prod.Id,Dismantle_Date__c =date.parse('10/20/2013'),Pre_Segmentation__c ='LT');
        insert actvContPrd;
        
        
        oli1.active_contract_Product__c = actvContPrd.id; 
        
            update oli1;                                                    

            test.stoptest();
        
           }
           public static testMethod void test1()
           {
                                              
            OpportunityLineItem oli2 = [Select id,Active_Contract_Product__r.Active_Contract__r.Status_Formula__c, Active_Contract_Product__c, OpportunityId 
            FROM OpportunityLineItem  where Opportunity.Other_Win_Loss_Reason__c!=null limit 1];
            
            Opportunity opp1 = [select closedate from opportunity where id=:oli2.OpportunityId];
               opp1.closedate = system.today()-4;
               update opp1;
               test.starttest();
            delete oli2;
               test.stoptest();
           }
           public static testMethod void ContractsInvalidationTest3(){
OpportunityLineItem ol = [select opportunityId, pricebookentryid  from opportunitylineitem limit 1];
        test.starttest();
       
       OpportunityLineItem oliObj = new OpportunityLineItem();
           oliObj.OpportunityId = ol.opportunityId;
           oliObj.totalprice = 200;
           oliObj.pricebookentryid = ol.pricebookentryid  ;         
      insert oliObj;
       
      /* OpportunityLineItem oliObj2 = new OpportunityLineItem();
           oliObj2.OpportunityId = ol.opportunityId;
           oliObj2.totalprice = 200;
           oliObj2.pricebookentryid = ol.pricebookentryid;    
           oliObj2.Business_Type__c = 'Renewal';
           insert oliObj2;           */
           test.stoptest();
        
        }
        
        public static testMethod void ContractsInvalidationTest4(){
OpportunityLineItem ol = [select opportunityId, pricebookentryid  from opportunitylineitem limit 1];
        test.starttest();
       
       OpportunityLineItem oliObj2 = new OpportunityLineItem();
           oliObj2.OpportunityId = ol.opportunityId;
           oliObj2.totalprice = 200;
           oliObj2.pricebookentryid = ol.pricebookentryid;    
           oliObj2.Business_Type__c = 'Renewal';
           insert oliObj2;           
           test.stoptest();
        
        }

}