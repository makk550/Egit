@isTest(SeeAllData=true)
public class TestTAPRules{
    public static testMethod void testTAPRules(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        
        User u1 = new User(Alias = 'gunsuqq', Email='gunsu03@ca.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='gunsu03_test@ca.com');
        insert u1;
        
        User u = new User(Alias = 'zeidaqq', Email='zeida02@ca.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='zeida02_test@ca.com',ManagerId=u1.Id);
        insert u;
          
        ID ResellerRecTypeId= SystemIdUtility.getResellerDistRecordTypeId();
        ID SMBRecTypeId= SystemIdUtility.getSMBAcctRecordTypeId();
        
        Account resellerAcct = new Account(RecordTypeId= ResellerRecTypeId,Name='Test_Acc2',Customer_Category__c='Enterprise',Enterprise_Id__c='101',Enterprise_Account_Name__c='E_Acc1',GEO__c='NA',BillingStreet = 'Arlington',BillingCountry = 'US',BillingCity = 'VA');        
        insert resellerAcct;                
        
        Account smbAcct = new Account(RecordTypeId= SMBRecTypeId, Name='Test_Acc1',BillingStreet = 'Arlington', BillingCountry = 'US', BillingCity = 'VA');        
        insert smbAcct;    

        opportunity opp = new opportunity(AccountId=smbAcct.Id,Reseller__c=resellerAcct.Id,name='test opp',closedate=system.today(),stagename='10% - Identification & Qualification');
        insert opp;
    
        scpq__SciQuote__c  SQ;
        scpq__SciQuote__c  SQ1;
        Quote_Product_Report__c QPR;
         Quote_Product_Report__c QPR1;
        Product_Material__c PM;
        Product_Material__c PM1;
        System.runAs(u){  
            Group g = new Group(Name='Approval ByPass');
            insert g;
            
            GroupMember GM = new GroupMember(GroupId=g.Id,UserOrGroupId=u.Id);
            insert GM;
            
            ApexPages.StandardController controller;
            ApprovalByPass AB = new ApprovalByPass(controller);
            
            //SQ = new scpq__SciQuote__c (Approver1__c = u.Id,CA_CPQ_Quote_Status__c = 'Draft',CA_Primary_Flag__c=true,name='test',scpq__OpportunityId__c=opp.id, scpq__OrderHeaderKey__c ='2131313', scpq__SciLastModifiedDate__c=system.today());
            //insert SQ;
            //List<sObject> ls = Test.loadData(Account.sObjectType, 'testAccounts');
            /*List<sObject> ls = Test.loadData(scpq__SciQuote__c.sObjectType, 'TestSterlingQuote');
            for(sObject s:ls){
                System.debug('++++++s+++++'+s.Id);
            }
            */
            SQ = new scpq__SciQuote__c (NAME='Test',CURRENCYISOCODE='USD',SCPQ__OPPORTUNITYID__C=opp.Id,
                SCPQ__ORDERHEADERKEY__C='22222',scpq__SciLastModifiedDate__c=system.today(),CA_CPQ_QUOTE_STATUS__C='Draft',
                CA_CPQ_QUOTE_TOTAL__C=4866.66,CA_ADJUSTED_ELIGIBLE_NCV__C=4866.66,CA_BILL_TO_ID__C='48656',
                CA_BILL_TO_NAME__C='NIKE INC',CA_BILLING_CONTACT_NAME__C='Lee Anderson',CA_BOOKING_COUNTRY__C='US',
                CA_CONTRACTED_RENEWAL__C='No',CA_CUSTOMER_NAME_SOLD_TO__C='NIKE INC',CA_DEAL_FINANCED__C='no',
                CA_DIRECT_INDIRECT__C='Direct',CA_GSA_PRICING_FLAG__C=True,CA_NEW_TRR__C=2430,CA_QUOTE_TYPE__C='New Product',
                CA_SALES_AREA__C='West',CA_TOTAL_LIC_SUB_OFF_LIST__C=50,CA_TOTAL_LIST_LICENSE_SUBS_FEE__C=9733.32,
                CA_TOTAL_PROPOSED_LIC_SUB_FEE__C=4866.66,CA_CPQ_PRODUCT_TOTAL__C=4866.66,CA_PAYMENT_SCHEDULE__C='Quarterly',
                CA_USING_QUICK_CONTRACT__C=True,NET_PAYMENT_TERMS__C='Net 30',SUBSCRIPTION_PAYMENT__C=4866.66);
                
            SQ1 = new scpq__SciQuote__c (NAME='Test1',CURRENCYISOCODE='USD',SCPQ__OPPORTUNITYID__C=opp.Id,
                SCPQ__ORDERHEADERKEY__C='22222121',scpq__SciLastModifiedDate__c=system.today(),CA_CPQ_QUOTE_STATUS__C='Draft',
                CA_CPQ_QUOTE_TOTAL__C=4866.66,CA_ADJUSTED_ELIGIBLE_NCV__C=4866.66,CA_BILL_TO_ID__C='48656',
                CA_BILL_TO_NAME__C='NIKE INC',CA_BILLING_CONTACT_NAME__C='Lee Anderson',CA_BOOKING_COUNTRY__C='US',
                CA_CONTRACTED_RENEWAL__C='No',CA_CUSTOMER_NAME_SOLD_TO__C='NIKE INC',CA_DEAL_FINANCED__C='no',
                CA_DIRECT_INDIRECT__C='Direct',CA_GSA_PRICING_FLAG__C=True,CA_NEW_TRR__C=2430,CA_QUOTE_TYPE__C='New Product',
                CA_SALES_AREA__C='West',CA_TOTAL_LIC_SUB_OFF_LIST__C=50,CA_TOTAL_LIST_LICENSE_SUBS_FEE__C=9733.32,
                CA_TOTAL_PROPOSED_LIC_SUB_FEE__C=14866.66,CA_CPQ_PRODUCT_TOTAL__C=14866.66,CA_PAYMENT_SCHEDULE__C='Quarterly',
                CA_USING_QUICK_CONTRACT__C=True,NET_PAYMENT_TERMS__C='Net 30',SUBSCRIPTION_PAYMENT__C=4866.66);
                
            insert SQ;
            insert SQ1;
            
            PM = new Product_Material__c(Name='NCUEBM990',CURRENCYISOCODE='USD',EXPIRED__C=false,
                MATERIAL_TEXT__C='NIMSOFT CLD EX MIN BSC MTR',OPERATIONAL_BU_CODE__C='30',
                OPERATIONAL_BU__C='OPERATIONAL_BU__C',PLATFORM_CATEGORY__C='SAAS',PLATFORM__C='5');
            PM1 = new Product_Material__c(Name='NCUEBM991',CURRENCYISOCODE='USD',EXPIRED__C=false,
                MATERIAL_TEXT__C='NIMSOFT CLD EX MIN BSC MTR',OPERATIONAL_BU_CODE__C='30',
                OPERATIONAL_BU__C='OPERATIONAL_BU__C',PLATFORM_CATEGORY__C='Distributed',PLATFORM__C='5');
            insert PM;
            insert PM1;
            
            QPR = new Quote_Product_Report__c(CURRENCYISOCODE='USD',BUS_TRANSACTION_TYPE__C='New Product',
                LIC_SUB_OFF_LIST__C=50,LICENSE_TYPE__C='Duration Based Subscription',MAINFRAME_DISTRIBUTED__C='Distributed',
                PROPOSED_LIC_SUB_FEE__C=4866.66,TOTAL_PROPOSED_PRICE__C=4866.66,TOTAL_QUANTITY__C=5,
                AUTH_USE_MODEL__C='Duration Based Subscription',BUSINESS_UNIT__C='NIMSOFT',LICENSE_METRIC__C='Basic Monitor',
                LIST_LICENSE_SUBS_FEE__C=9733.32,NEW_ADDITIONAL_QUANTITY__C=5,Sterling_Quote__c=SQ.Id,Total_Disc_off_List__c = 21.23,
                PRODUCT_MATERIAL__C=PM.Id,CA_PRICING_GROUP__C='SAAS',QUICK_QUOTE__C=True,EAI_PRODUCT_MATERIAL__C='NCUEBM990');
                
             QPR1 = new Quote_Product_Report__c(CURRENCYISOCODE='USD',BUS_TRANSACTION_TYPE__C='New Product',
                LIC_SUB_OFF_LIST__C=50,LICENSE_TYPE__C='Duration Based Subscription',MAINFRAME_DISTRIBUTED__C='Distributed',
                PROPOSED_LIC_SUB_FEE__C=14866.66,TOTAL_PROPOSED_PRICE__C=14866.66,TOTAL_QUANTITY__C=15,
                AUTH_USE_MODEL__C='Duration Based Subscription',BUSINESS_UNIT__C='NIMSOFT',LICENSE_METRIC__C='Basic Monitor',
                LIST_LICENSE_SUBS_FEE__C=9733.32,NEW_ADDITIONAL_QUANTITY__C=5,Sterling_Quote__c=SQ1.Id,Total_Disc_off_List__c = 15.23,
                PRODUCT_MATERIAL__C=PM1.Id,CA_PRICING_GROUP__C='Distributed',QUICK_QUOTE__C=True,EAI_PRODUCT_MATERIAL__C='NCUEBM991');
            insert QPR;
            insert QPR1;            
            
         
      
        SQ.Approver1__c = u.Id;
        SQ.Approver2__c = u.Id;
        SQ.Approver3__c = u.Id;
        SQ.Approver4__c = u.Id;
        SQ.Approver5__c = u.Id;
        SQ.Approver6__c = u.Id;
        SQ.Approver7__c = u.Id;
        SQ.Approver8__c = u.Id;
        SQ.Approver9__c = u.Id;
        SQ.Approver10__c = u.Id;
        SQ.CA_CPQ_Quote_Status__c = 'Request Approval';
        SystemIdUtility.skipSterlingQuoteProcessor = true;
        update SQ;
         test.startTest(); 
        ApprovalByPass.updateStatus(SQ.Id);
        System.debug('++++++SQ.Approver1__c+++++'+SQ.Approver1__c);
        System.debug('++++++SQ.CA_CPQ_Quote_Status__c++++++++'+SQ.CA_CPQ_Quote_Status__c);
        
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setObjectId(SQ.Id); 
        submitRequest.setNextApproverIds(new Id[] {UserInfo.getUserId()}); 
        SystemIdUtility.skipSterlingQuoteProcessor = true;      
        Approval.ProcessResult result = Approval.process(submitRequest);
        ApprovalByPass.updateStatus(SQ.Id);
         
        
        test.stopTest();
        
       
        SterlingQuotePendingApprovers SQPA = new SterlingQuotePendingApprovers();
        String schedule = '0 0 23 * * ?';
        try{
            system.schedule('Nightly Update', schedule, SQPA);
        }catch(Exception e){
        }
        
        
      }  
         
    }
}