@isTest(SeeAllData=true)
private class EducationRequestTestClass
{
    static testMethod void validateDirectRegi()
    {
        // insert accounts
        Account acc = new Account(name='test account', RecordTypeId=SystemIdUtility.getAccountTeamAcctRecordTypeId());
        insert acc;
        
        // insert opps
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity opp1 = new Opportunity(name='test opp 1',accountId=acc.Id, CloseDate=Date.today()+1, StageName='20% - Researching');
        opps.add(opp1);
        
        Opportunity opp2 = new Opportunity(name='test opp 2',accountId=acc.Id, CloseDate=Date.today()+1, StageName='20% - Researching');
        opps.add(opp2);
        
        insert opps;
        
        // insert quotes
        List<scpq__SciQuote__c> sqList = new List<scpq__SciQuote__c>();
        scpq__SciQuote__c sq1_1 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp1.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 1', CA_Quote_Type__c='Direct Registration');
        sqList.add(sq1_1);
        
        scpq__SciQuote__c sq1_2 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp1.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 2', CA_Quote_Type__c='Direct Registration');
        sqList.add(sq1_2);
        
        scpq__SciQuote__c sq2_1 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp2.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 3', CA_Quote_Type__c='Direct Registration');
        sqList.add(sq2_1);
        
        scpq__SciQuote__c sq2_2 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp2.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 4', CA_Quote_Type__c='Direct Registration');
        sqList.add(sq2_2);
        
        insert sqList;
        
        //insert quote product line items
        List<Quote_Product_Report__c> qpList = new List<Quote_Product_Report__c>();
        
        for(scpq__SciQuote__c sq : sqList)
        {
            qpList.add(new Quote_Product_Report__c(Sterling_Quote__c=sq.Id));            
        }
        
        insert qpList;
        
        //run test to generate education requests
        List<scpq__SciQuote__c> eduQuotes = new List<scpq__SciQuote__c>();
        for(scpq__SciQuote__c sq : sqList)
            eduQuotes.add(new scpq__SciQuote__c(Id=sq.Id, CA_SAP_Status__c = 'In Review'));
        
        update eduQuotes;
        
        List<Education_Request__c> eduReqs = [SELECT Id FROM Education_Request__c WHERE CPQ_Quote__c In :sqList];
        
        // assert an education request was created for each education quote
        System.assertEquals(sqList.size(), eduReqs.size());
        
        
        // update education requests for SAP approval test
        for(Education_Request__c eduReq : eduReqs)
            eduReq.Education_Request_Status__c = 'Pending Approval';
        
        update eduReqs;
        
        for(scpq__SciQuote__c sq : eduQuotes)
            sq.CA_SAP_Status__c = 'Approved';
        
		update eduQuotes;
        
        System.assertEquals(eduReqs.size(), [SELECT COUNT() FROM Education_Request__c WHERE Education_Request_Status__c='Ready for Registration' AND CPQ_quote__c IN :sqList]);
        
        
        // test deletion trigger
        delete qpList;
        
        System.assertEquals(0, [SELECT Count() FROM Education_Request__c WHERE Id IN :eduReqs]);
    }
    
    static testMethod void validateReleaseOrder()
    {
        // insert accounts
        Account acc = new Account(name='test account', RecordTypeId=SystemIdUtility.getAccountTeamAcctRecordTypeId());
        insert acc;
        
        // insert opps
        List<Opportunity> opps = new List<Opportunity>();
        
        Opportunity opp1 = new Opportunity(name='test opp 1',accountId=acc.Id, CloseDate=Date.today()+1, StageName='20% - Researching');
        opps.add(opp1);
        
        Opportunity opp2 = new Opportunity(name='test opp 2',accountId=acc.Id, CloseDate=Date.today()+1, StageName='20% - Researching');
        opps.add(opp2);
        
        insert opps;
        
        // insert product
        Product2 prod = new Product2(Name='test product', CSU2__c='test CSU2', Product_Group__c='test product group');
        insert prod;
        
        // insert product material
        Product_Material__c pm = new Product_Material__c(Name='p123', Product__c=prod.Id, Material_Text__c='test material text');
        insert pm;
        
        // insert quotes
        List<scpq__SciQuote__c> sqList = new List<scpq__SciQuote__c>();
        scpq__SciQuote__c sq1_1 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp1.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 1');
        sqList.add(sq1_1);
        
        scpq__SciQuote__c sq1_2 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp1.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 2');
        sqList.add(sq1_2);
        
        scpq__SciQuote__c sq2_1 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp2.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 3');
        sqList.add(sq2_1);
        
        scpq__SciQuote__c sq2_2 = new scpq__SciQuote__c(scpq__OpportunityId__c=opp2.Id, scpq__SciLastModifiedDate__c=DateTime.now(), scpq__OrderHeaderKey__c='test hk 4');
        sqList.add(sq2_2);
        
        insert sqList;
        
        //insert Release Orders
        Integer countRO=1;
        List<Release_Order__c> roList = new List<Release_Order__c>();
        
        for(scpq__SciQuote__c sq : sqList)
        {
            roList.add(new Release_Order__c(Sterling_Quote__c=sq.Id, Release_Order__c='test ro# ' + countRO, Release_Order_Unique_Key__c='test ro cpq# ' + countRO));
			countRO++;            
        }
        
        insert roList;
        
        //insert Release Order Lines
        List<Release_Order_Line_Item__c> roLines = new List<Release_Order_Line_Item__c>();
        Integer countRoLine=1;
        for(Release_Order__c ro : roList)
        {
            roLines.add(new Release_Order_Line_Item__c(Release_Order__c=ro.Id, Release_Order_Line_Unique_Key__c='test ro line# ' + countRoLine));
            countRoLine++;
            roLines.add(new Release_Order_Line_Item__c(Release_Order__c=ro.Id, Release_Order_Line_Unique_Key__c='test ro line# ' + countRoLine, Product_Code__c='p123'));
            countRoLine++;
        }
        
        insert roLines;
        
        
        //run test to verify Release Order lines have the right product material
        for(Release_order_Line_Item__c rol : roLines)
            rol.Product_Code__c = 'p123';
        
        update roLines;
        
        System.assertEquals(roLines.size(), [SELECT COUNT() FROM Release_Order_Line_Item__c WHERE Id IN :roLines AND Product_Material__c = :pm.Id]);
        
        
        //run test to generate education requests
        List<Release_Order__c> release_orders = new List<Release_Order__c>();
        for(Release_Order__c ro : roList)
            release_orders.add(new Release_Order__c(Id=ro.Id, SAP_Order_Status__c = 'In Review'));
        
        update release_orders;
        
        List<Education_Request__c> eduReqs = [SELECT Id FROM Education_Request__c WHERE CPQ_Quote__c In :sqList];
        
        // assert an education request was created for each education release order line
        System.assertEquals(roLines.size(), eduReqs.size());
        
        
        // update education requests for SAP approval test
        for(Education_Request__c eduReq : eduReqs)
            eduReq.Education_Request_Status__c = 'Pending Approval';
        
        update eduReqs;
        
        for(Release_Order__c ro : roList)
            ro.SAP_Order_Status__c = 'Approved';
        
        update roList;
        
        System.assertEquals(eduReqs.size(), [SELECT COUNT() FROM Education_Request__c WHERE Education_Request_Status__c='Ready for Registration' AND CPQ_quote__c IN :sqList]);
    }
    
    static testMethod void testEducationRequestStatusProcess()
    {
        Education_Request__c eduReq = new Education_Request__c(Education_Request_Status__c='Pending Approval');
        insert eduReq;
        
        PageReference pageRef = Page.Education_Request_Status_Action;
        Test.setCurrentPage(pageRef);
      
        ApexPages.StandardController controller = new ApexPages.StandardController(eduReq);
        EducationRequestControllerExtension eduControllerExt = new EducationRequestControllerExtension(controller);
        
        pageRef = eduControllerExt.updateStatus();
        
        System.debug(pageRef);
        System.debug([SELECT Education_Request_Status__c FROM Education_Request__c WHERE Id=:eduReq.Id LIMIT 1]);
    }
}