/**
*Description :Class to handle MDF functionality.
*Methods PopulateApproversOnFundClaim  , with List of SFDC_MDF_Claim__c as input
*Populate approvers and Partner Email Address
*SOQl: 2
* No DML Updates 
*Client: CA technologies
*Developed By:  Balasaheb Wani Oct 27,2010
*Last Updated On Oct 27,2010
*/
public class MDF_Utils
{
    public static void PopulateApproversOnFundClaim(List<SFDC_MDF_Claim__c> lstClaims)
    {
         Map<Id,SFDC_MDF__c> mapMDF=new Map<Id,SFDC_MDF__c>();
         Map<Id,Fund_Programs_Admin__c> mapFP = new Map<Id,Fund_Programs_Admin__c>();
         Map<Id,SFDC_MDF__c> mapMDFForEmail=new Map<Id,SFDC_MDF__c>();
         Set<Id> stFundReq=new Set<Id>();
         Set<Id> stMDFs=new Set<Id>();
         
         //added as a part of R2.1 to populate currency.
         Set<Id> listOfBudgetIds = new Set<Id>();
         Map<Id,SFDC_Budget__c> mapOfBudget=new Map<Id,SFDC_Budget__c>();
         
         for (SFDC_MDF_Claim__c claim :lstClaims)
         {
            if(claim.Fund_Request__c!=null)
            stFundReq.add(claim.Fund_Request__c);
         }
         List<SFDC_MDF__C> lstmf=[Select s.Name,s.CurrencyIsoCode, s.Account__c, s.Partner_Email__c, s.MDF_Program__r.MDF_Program__c, 
         s.MDF_Program__r.Id, s.MDF_Program__c,s.Partner_Name_for_Email__c, s.Id From SFDC_MDF__c s where s.Id in : stFundReq];
         for(SFDC_MDF__C mdf :lstmf)
         {
            mapMDF.put(mdf.Id,mdf);
            stMDFs.add(mdf.MDF_Program__r.MDF_Program__c);
         }
        List<Fund_Programs_Admin__c> lstFundProgramAdmin=[Select f.Id, f.Fund_Claim_Level_3_Approver__c, 
            f.Fund_Claim_Level_2_Approver__c, f.Fund_Claim_Level_1_Approver__c,
            f.Finance_Processor_Email__c,f.Program_Owner_for_questions__r.Email, 
            f.Program_Owner_for_questions__r.LastName, f.Program_Owner_for_questions__r.FirstName 
            From Fund_Programs_Admin__c f 
            where f.Id in :stMDFs];
        
        for(Fund_Programs_Admin__c fp :lstFundProgramAdmin)
        {
            mapFP.put(fp.Id,fp);
        }
        for (SFDC_MDF_Claim__c claim :lstClaims)
         {
             for(SFDC_MDF__C md :mapMDF.values())
             {
                for(Fund_Programs_Admin__c fpa:mapFP.values())
                {
                if(claim.Fund_Request__c==md.Id)
                {
                    mapMDFForEmail.put(claim.Id,md);
                    if(fpa.Id==md.MDF_Program__r.MDF_Program__c)
                    {
                        mapFP.put(claim.Id,fpa);
                    }
                }
                }   
             }
         }


          for (SFDC_MDF_Claim__c claim :lstClaims)
         {
            if(mapFP.containsKey(claim.Id))
            {
                Fund_Programs_Admin__c fp=mapFP.get(claim.Id);
                claim.Finance_Email__c=fp.Finance_Processor_Email__c;
                claim.Approver_1__c=fp.Fund_Claim_Level_1_Approver__c;
                claim.Approver_2__c=fp.Fund_Claim_Level_2_Approver__c;
                claim.Approver_3__c=fp.Fund_Claim_Level_3_Approver__c;
                claim.Program_Owner_Email__c=fp.Program_Owner_for_questions__r.Email;
                claim.Program_Owner_Name_for_Email__c=fp.Program_Owner_for_questions__r.FirstName+' '+fp.Program_Owner_for_questions__r.LastName; 
                claim.Account__c=mapMDFForEmail.get(claim.Id).Account__c;
                claim.CurrencyIsoCode=mapMDFForEmail.get(claim.Id).CurrencyIsoCode;
            //commented by Siddharth PRM R2: This is being done by workflow.
            /*  if(mapMDFForEmail.containsKey(claim.Id))
                {
                    claim.Fund_Champion_Name_for_Email__c=mapMDFForEmail.get(claim.Id).Partner_Name_for_Email__c;
                    claim.Partner_Email__c=mapMDFForEmail.get(claim.Id).Partner_Email__c;
                    claim.Account__c=mapMDFForEmail.get(claim.Id).Account__c;
                }  */
            }
         }                    
    }
    
    public static void populateOwnerOnProgramAdmin(List<Fund_Programs_Admin__c> ListOfMDFPrograms){
        for(Fund_Programs_Admin__c thisProgramAdmin: ListOfMDFPrograms){
            thisProgramAdmin.Program_Owner_for_questions__c=thisProgramAdmin.OwnerId;
        }
    }
    
    @isTest(SeeAllData=true)
    public static void MDF_Utils_test() {
    	List<SFDC_MDF_Claim__c> listClaims = [Select Id, Fund_Request__c from SFDC_MDF_Claim__c LIMIT 1];
    	MDF_Utils.PopulateApproversOnFundClaim(listClaims);
    	Fund_Programs_Admin__c prg = new Fund_Programs_Admin__c(OwnerId = UserInfo.getUserId());
    	List<Fund_Programs_Admin__c> listProg = new List<Fund_Programs_Admin__c>();
    	listProg.add(prg);
    	MDF_Utils.populateOwnerOnProgramAdmin(listProg); 
    }
}