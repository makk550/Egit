/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_CreateOpptySalesTeamTriggAndCls {

    static testMethod void testCreateOpportunitySalesTeamTriggerAndClass() 
    {
        try{
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
        List<Id> userIdList = new List<Id>();
        List<Opportunity> opportunityList= new List<Opportunity>();
        User[] u = new List<User>();
        
        /*
        String enterpriseAccountRecordTypeName = 'CA Enterprise Account';
        Schema.DescribeSObjectResult accountRTDescribe = Schema.SObjectType.Account;    
        Map<String,Schema.RecordTypeInfo> accountRecTypeMap = accountRTDescribe.getRecordTypeInfosByName(); 
        Id enterpriseAccountRecordTypeId = accountRecTypeMap.get(enterpriseAccountRecordTypeName).getRecordTypeId();
  
        Account parentAccount = new Account();
        parentAccount.Name = 'Test Account';
        parentAccount.Customer_Category__c = 'Enterprise';
        parentAccount.Account_Status__c = 'Submitted';
        parentAccount.Country_Picklist__c = 'US - UNITED STATES';
        parentAccount.RecordTypeId = enterpriseAccountRecordTypeId;
        insert parentAccount;
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Customer_Category__c = 'Distributor';
        a.Account_Status__c = 'Submitted';
        a.Country_Picklist__c = 'US - UNITED STATES';
        a.Distributor_Type__c = 'Value';
        a.ParentId = parentAccount.Id;
        insert a;
       
        */
        Account distributorAccount = new Account();
        distributorAccount = [Select Id from Account where Customer_Category__c ='Distributor' limit 1];
        Account resellerAccount = new Account();
        resellerAccount = [Select Id from Account where Customer_Category__c ='Reseller' limit 1];
        Account partnerAccount = new Account();
        partnerAccount = [Select Id from Account where Customer_Category__c ='Alliance - Influence' limit 1];
        
        if(distributorAccount != null || resellerAccount != null || partnerAccount != null)
        {
            u = [SELECT Id FROM User WHERE IsActive =: true AND contactId =: null limit 10];
            for(Integer s=0; s<u.size(); s++)
            {
                accountTeamMemberList.add(new AccountTeamMember(
                                                      AccountId = distributorAccount.Id,
                                                      TeamMemberRole = 'AD/AM/GAD',
                                                      UserId = u[s].Id
                                                      ));
            }
            for(Integer s=0; s<u.size(); s++)
            {
                accountTeamMemberList.add(new AccountTeamMember(
                                                      AccountId = resellerAccount.Id,
                                                      TeamMemberRole = 'AD/AM/GAD',
                                                      UserId = u[s].Id
                                                      ));
            }
            for(Integer s=0; s<u.size(); s++)
            {
                accountTeamMemberList.add(new AccountTeamMember(
                                                      AccountId = partnerAccount.Id,
                                                      TeamMemberRole = 'AD/AM/GAD',
                                                      UserId = u[s].Id
                                                      ));
            }
            insert accountTeamMemberList;
            
            System.Debug('accountTeamMemberList => ' + accountTeamMemberList);
             
             RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('New Opportunity');
            Id newOpportunityRecordTypeId = rec.RecordType_Id__c;
   
            Opportunity opty1 = new Opportunity();
            opty1.RecordTypeId = newOpportunityRecordTypeId;
            opty1.Name = 'Test Oppty';
            opty1.StageName ='60% - Proposal';
            opty1.CloseDate = System.today();
            if(distributorAccount != null)
            opty1.Distributor_6__c = distributorAccount.Id;
            if(resellerAccount != null)
            opty1.Reseller__c = resellerAccount.Id;
            if(partnerAccount != null)
            opty1.Partner__c = partnerAccount.Id;
            
            insert opty1;
            
            System.Debug('opty1 => '+ opty1); 
            
            Opportunity opty2 = new Opportunity();
            opty2.RecordTypeId = newOpportunityRecordTypeId;
            opty2.Name = 'Test Oppty';
            opty2.StageName ='60% - Proposal';
            opty2.CloseDate = System.today();
            if(distributorAccount != null)
            opty2.Distributor_6__c = distributorAccount.Id;
            if(resellerAccount != null)
            opty2.Reseller__c = resellerAccount.Id;
            if(partnerAccount != null)
            opty2.Partner__c = partnerAccount.Id;
            opportunityList.add(opty2);
            
            Opportunity opty3 = new Opportunity();
            opty3.RecordTypeId = newOpportunityRecordTypeId;
            opty3.Name = 'Test Oppty';
            opty3.StageName ='60% - Proposal';
            opty3.CloseDate = System.today();
            if(distributorAccount != null)
            opty3.Distributor_6__c = distributorAccount.Id;
            if(resellerAccount != null)
            opty3.Reseller__c = resellerAccount.Id;
            if(partnerAccount != null)
            opty3.Partner__c = partnerAccount.Id;
            opportunityList.add(opty3);
            
            System.Debug('opportunityList Details => '+ opportunityList);  
            insert opportunityList;
            
            update opportunityList;
        }
       }catch(Exception ex)
       {
       System.debug(ex.getMessage());
       }
        
    }
    
    
}