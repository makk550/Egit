public class Opportunity_ContactRole_Class
{
    public static Set<Id> insertedOpps = new Set<Id>();
    public static boolean skipPartnerOppTrg = false;
    public static boolean skipTAQBatch = false;
    public static boolean skipTAQ_NHTT = false;
    public static boolean userIsBypass = [SELECT Id, Opportunity_Validation_Bypass__c FROM USER WHERE Id = :UserInfo.getUserID()][0].Opportunity_Validation_Bypass__c;
    public static integer fymonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
    public static List<User> ulist_st = [Select id,UserType, ContactId, Is_Partner_User__c, IsPortalEnabled, AccountId, contact.Account.Solution_Provider_CAM_PMFKey__c, PMFKey__c from user where Isactive=true limit 50000]; //check the limit
    public static List<CurrencyType> crncyType = [SELECT ConversionRate, IsoCode FROM CurrencyType];    
    /*
    //AR:3503
    public static Map<Id,boolean> oppPrimaryContactRole(Set<Id> oppIdset){  
        Map<Id,boolean> oppPrimaryCntRoleMap = new Map<Id,boolean>();            
        List<OpportunityContactRole> oppPrimaryContactRoleList = [select id,contactId,IsPrimary,OpportunityId from OpportunityContactRole where OpportunityId IN :oppIdset AND IsPrimary = true];
        for(OpportunityContactRole ocr:oppPrimaryContactRoleList){
            
            oppPrimaryCntRoleMap.put(ocr.OpportunityId,ocr.IsPrimary);
        }
        return oppPrimaryCntRoleMap;        
    }*/

    
}