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
 
 /*************************************************************************************************
Apex Class Name     : Test_Add_and_Rmve_Part_Users
Version             : 1.0
Date Created        : 25-April-2012
Function            : Test Class for the Add_and_Remove_Partner_Users Trigger
                                                                
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer              Date                    Description
* ---------------        -----------             ----------------------------------------------
* Diti Mansata          25/04/2012              Initial Creation
**************************************************************************************************/
@isTest(SeeAllData=true)
private class Test_Add_and_Rmve_Part_Users {

 static testMethod void Test_Add_and_Rmve_Part_Users() {
 
   // Create the instance of the Account//
     List<Account> TestAcc_lst = new List<Account> ();
     List<RecordTypes_Setting__c> RTS_lst = new List <RecordTypes_Setting__c> ();
      
   // Create the Custom Setting Instance//
      if ( RecordTypes_Setting__c.getInstance('SMB') == null){
           RTS_lst.add(new RecordTypes_Setting__c (Name = 'SMB',RecordType_Id__c ='012V0000000Ckjl',SObject_Name__c='Account'));
         }
      if ( RecordTypes_Setting__c.getInstance('Account Team Covered Account') == null){
           RTS_lst.add(new RecordTypes_Setting__c (Name = 'Account Team Covered Account',RecordType_Id__c ='012V0000000Ckjb',SObject_Name__c='Account'));
         }
      if ( RecordTypes_Setting__c.getInstance('Account Team Covered Account') == null){
           RTS_lst.add(new RecordTypes_Setting__c (Name = 'Territory Covered Account',RecordType_Id__c ='012V0000000Ckjg',SObject_Name__c='Account'));
         } 
      if ( RecordTypes_Setting__c.getInstance('CA Enterprise Account') == null){
           RTS_lst.add(new RecordTypes_Setting__c (Name = 'CA Enterprise Account',RecordType_Id__c ='01230000000DNfM',SObject_Name__c='Account'));
         }      
     insert RTS_lst;
       
     for (Integer i =0;i<5;i++){
        if (Math.Mod(i,2) == 0) 
         TestAcc_lst.add(new Account(Name = 'TestAcc'+i,Solution_Provider_Program_Level__c = 'Advance',Solution_Provider__c =true,Not_eligible_for_Shark_tank_Leads__c = true,RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller/Distributor Account').getRecordTypeId()));
        else{
          TestAcc_lst.add(new Account(Name = 'TestAcc'+i,Solution_Provider_Program_Level__c = 'Advance',Solution_Provider__c =true,Not_eligible_for_Shark_tank_Leads__c = false,RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller/Distributor Account').getRecordTypeId()));
        }
     }
     /*try {
      Insert(TestAcc_lst);
     } Catch (Exception E) {
      system.debug('Account Cant be inserted' + E);
      }*/
     Insert(TestAcc_lst);
    //if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller/Distributor Account').getRecordTypeId() != null){
         for (Integer i =0;i<5;i++){
         TestAcc_lst[i].Not_eligible_for_Shark_tank_Leads__c= true;
          }
        //}
      try {
       Update(TestAcc_lst);
     } Catch (Exception E) {
      system.debug('Account Cant be inserted' + E);
     }
 }

    static testMethod void Test_Add_and_Rmve_Part_Users1() {

        
       
        GroupMember g = [Select id from GroupMember limit 1];
        Set<Id> s1 = new Set<Id>();
        s1.add(g.id);
        
        Remove_Partner_Users.callTrigger(s1);
       
        
         }
         
         static testMethod void Test_Add_and_Rmve_Part_Users2() {

        
       Set<String> strset = new Set<String>();
       User u = [select id, Related_Partner_Account__c from user where Related_Partner_Account__c!=null limit 1];
        strset.add(u.Related_Partner_Account__c);
        Remove_Partner_Users.callTriggerInsert(strset);
       
        
         }
}