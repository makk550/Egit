@isTest(seeAllData = true)
public class Ext_EditDealRegistration_Test {
    static testMethod void testOpportunity2	(){
         user partnerUserB = Test_CreateOpportunity.createPartnerUserDisti();
         System.runAs(partnerUserB){
            opportunity objOpp2TierDisti = Test_CreateOpportunity.createTestOpp('1 Tier');
            //objOpp2TierDisti.What_is_your_Role__c = 'Distributor';
            objOpp2TierDisti.Did_the_deal_originate_from_a_campaign__c='No';
            system.debug('partnerUserB>>'+partnerUserB);
            partnerUserB = [select accountid ,contactid from user where id=:partnerUserB.id];
            system.debug('Before partnerUserB>>'+partnerUserB);
            system.debug('partnerUserB.AccountId '+partnerUserB.AccountId );
            update objOpp2TierDisti;
            ApexPages.StandardController stdCtrl2TierDisti = new ApexPages.StandardController(objOpp2TierDisti);
            Ext_EditDealRegistration_New objDealReg2TierDisti = new Ext_EditDealRegistration_New(stdCtrl2TierDisti);
            objDealReg2TierDisti.hdnAccountId =  partnerUserB.AccountId;
            objDealReg2TierDisti.hdnContactId = partnerUserB.ContactId;
            objDealReg2TierDisti.hdnDistiAccountId = partnerUserB.AccountId;
            objDealReg2TierDisti.hdnDistiContactId = partnerUserB.ContactId;
            objDealReg2TierDisti.hdnresellAccountId = partnerUserB.AccountId;
            objDealReg2TierDisti.hdnresellContactId = partnerUserB.ContactId;
            system.debug('objDealReg2TierDisti.hdnAccountId '+objDealReg2TierDisti.hdnAccountId);
            objDealReg2TierDisti.autofillDistributor();
            objDealReg2TierDisti.UpdateOpportunity();
            
         }
    }
    
    static testMethod void testOpportunity3	(){
         user partnerUserB = Test_CreateOpportunity.createPartnerUserDisti();
         System.runAs(partnerUserB){
            opportunity objOpp2TierDisti = Test_CreateOpportunity.createTestOpp('2 Tier');
            objOpp2TierDisti.What_is_your_Role__c = 'Distributor';
            update objOpp2TierDisti;
            ApexPages.StandardController stdCtrl2TierDisti = new ApexPages.StandardController(objOpp2TierDisti);
            Ext_EditDealRegistration_New objDealReg2TierDisti = new Ext_EditDealRegistration_New(stdCtrl2TierDisti);
            objDealReg2TierDisti.hdnAccountId=null;
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.hdnAccountId='abc';
            objDealReg2TierDisti.hdnContactId=null;
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.hdnAccountId='abc';
            objDealReg2TierDisti.hdnContactId='abc';
            objDealReg2TierDisti.hdnDistiAccountId=null;
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.hdnAccountId='abc';
            objDealReg2TierDisti.hdnContactId='abc';
            objDealReg2TierDisti.hdnDistiAccountId='abc';
            objDealReg2TierDisti.hdnDistiContactId=null;
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.hdnAccountId='abc';
            objDealReg2TierDisti.hdnContactId='abc';
            objDealReg2TierDisti.hdnDistiAccountId='abc';
            objDealReg2TierDisti.hdnDistiContactId='abc';
            objDealReg2TierDisti.hdnresellAccountId=null;
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.hdnAccountId='abc';
            objDealReg2TierDisti.hdnContactId='abc';
            objDealReg2TierDisti.hdnDistiAccountId='abc';
            objDealReg2TierDisti.hdnDistiContactId='abc';
            objDealReg2TierDisti.hdnresellAccountId='abc';
            objDealReg2TierDisti.hdnresellContactId=null;
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.hdnAccountId='abc';
            objDealReg2TierDisti.hdnContactId='abc';
            objDealReg2TierDisti.hdnDistiAccountId='abc';
            objDealReg2TierDisti.hdnDistiContactId='abc';
            objDealReg2TierDisti.hdnresellAccountId='abc';
            objDealReg2TierDisti.hdnresellContactId='abc'; 
            objDealReg2TierDisti.UpdateOpportunity();
            objDealReg2TierDisti.autofillDistributor();
            
            //objOpp2TierDisti.name=null;
            //objOpp2TierDisti.End_User_Contact__c=null;
            //objOpp2TierDisti.AccountId=null;
            //update objOpp2TierDisti;
           
         }
    }
    static testMethod void testOpportunitySummery() 
    {
        PageReference pageRef = Page.DealRegistrationEdit_New;
        Test.setCurrentPage(pageRef);
        user partnerUserA = Test_CreateOpportunity.createPartnerUser(); 
       
        System.runAs(partnerUserA){
            opportunity objOpp = Test_CreateOpportunity.createTestOpp('1 Tier');
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objOpp);
            Ext_EditDealRegistration_New objDealReg = new Ext_EditDealRegistration_New(stdCtrl);
            objDealReg.UpdateOpportunity();
            
            opportunity objOpp2Tier = Test_CreateOpportunity.createTestOpp('2 Tier');
            ApexPages.StandardController stdCtrl2Tier = new ApexPages.StandardController(objOpp2Tier);
            Ext_EditDealRegistration_New objDealReg2Tier = new Ext_EditDealRegistration_New(stdCtrl2Tier);
            objDealReg2Tier.UpdateOpportunity();
            objDealReg2Tier.autofillDistributor();
            
            opportunity objOpp2TierD = Test_CreateOpportunity.createTestOpp('2 Tier');
            objOpp2TierD.What_is_your_Role__c = 'Distributor';
            update objOpp2TierD;
            ApexPages.StandardController stdCtrl2TierD = new ApexPages.StandardController(objOpp2TierD);
            Ext_EditDealRegistration_New objDealReg2TierD = new Ext_EditDealRegistration_New(stdCtrl2TierD);
            objDealReg2TierD.UpdateOpportunity();
            objDealReg2TierD.autofillDistributor();
        }
        //ApexPages.StandardController std = new ApexPages.StandardController(opp);
    }

}