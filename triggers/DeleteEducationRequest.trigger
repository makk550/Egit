trigger DeleteEducationRequest on Quote_Product_Report__c (before delete) 
{
    delete [SELECT Id FROM Education_Request__c WHERE Quote_Product_Line_Item__c IN :Trigger.old];
}