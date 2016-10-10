/**
Class Name: Renewal_ConvToOppController
Author: Sandeep D.S
Description: This class is to convert renewal in to oppertunity.  
*/

    public class Renewal_ConvToOppController {
    
    public Boolean showEmailLogButton {get;  set;}
    
    
    public Map<String, String> errorLog { get; set; }
    public Map<String, String> geterrorLog() {                
        return errorLog;
    }


    public Renewal__c rnwl{get;set;}
    public Account acc{get;set;}
    Boolean flag;
    public Renewal_ConvToOppController(ApexPages.StandardController controller) {    
         showEmailLogButton  =false;       
        errorLog = new Map<String, String>();      
        rnwl = (Renewal__c)controller.getRecord();
        if(rnwl.Id!=null){
            rnwl = [select id, Segmentation__c, name, Account__c, OwnerId, Expected_Close_Date__c, 
                           Converted_To_Opportunity__c, Overall_Comments__c, CurrencyIsoCode,
                           Projected_Time_Duration_Months__c, OCV__c, Annual_OCV_LC__c, 
                           Sold_to_Ship_to_Party_Site_ID__c, Projected_Renewal__c,owner.isActive,
                           Local_Currency__c, New_Site_Id__c, Territory__c , // Changed for FY14 - was Territory_Country__c
                           Reason_duration_is_1_year__c,Status_at_end_of_term__c // AR 3051
                      from Renewal__c 
                     where Id =:rnwl.Id];
            acc = [select id from Account where id=:rnwl.Account__c];       
          }
    }
    
    
    public Pagereference creatOppRecord(){  
      SystemIdUtility.skipTrigger  = true;   
        if(rnwl.owner.isActive ==false)
        {
            errorLog.put(rnwl.name,'The Owner of the renewal is inactive and the renewal cannot be converted to Opportunity');
            showEmailLogButton = true;
            return null;    
        }
        
        if(rnwl.Converted_To_Opportunity__c==true){
            errorLog.put(rnwl.name,'The selected Renewal already been Converted into an Opportunity.');
            showEmailLogButton = true;
            return null;    
        }
        // based on Req. 10.09 LT option is addded by subsa03
         
        if(rnwl.Segmentation__c != 'HT' && rnwl.Segmentation__c  != 'MT' && rnwl.Segmentation__c  != 'LT'){
            errorLog.put(rnwl.name,'This Renewal has the Segmentation ' + rnwl.Segmentation__c  + ', so it cannot be Converted into an Opportunity.');
                        showEmailLogButton = true;
            return null;    
        }

        // Check all ACP associated with the Renewal. If there are no ACP with Converted_to_Opportunity = false, 
        // do not create oppty (because ACPs are already on another oppty. - lfc - 03Mar2012
        Integer howManyACP = [Select COUNT() From Active_Contract_Product__c
                                            Where Converted_To_Opportunity__c <> true and
                                                  Renewal_Product__r.Renewal__c = :rnwl.Id];

        if(howManyACP == 0){
                        errorLog.put(rnwl.name,'All Active Contract Products are already associated to Opportunities.');
                                    showEmailLogButton = true;
            return null;    
            }
        
        //FY13 Add the Territory to Opp
        //FY14 Territory terr = [Select Id from Territory Where Territory_Country__c = : rnwl.Territory_Country__c LIMIT 1 ];
        Territory terr = [Select Id from Territory Where Country__c = : rnwl.Territory__c LIMIT 1 ]; //FY14
        
        // based on Req. 10.09 LT option is addded by subsa03
        Id recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Opportunity').getRecordTypeId();
        String BusinessType;
             if(rnwl.Segmentation__c == 'HT')
                 BusinessType = 'High Touch';
             else if(rnwl.Segmentation__c == 'MT')
                 BusinessType = 'Medium Touch';
             else if(rnwl.Segmentation__c == 'LT')
                 BusinessType = 'Low Touch';
             else if(rnwl.Segmentation__c == 'NT')
                 BusinessType = 'No Touch';
             else 
                 BusinessType = 'Unknown';    
    
        // FY13 - Set oppty close date to a date >= current date
        Date expCloseDate;
        if(rnwl.Expected_Close_Date__c >= date.today())
            expCloseDate = rnwl.Expected_Close_Date__c;
        else
            expCloseDate = date.today();
     
     
     /***********************************/       
            
                   List <Active_Contract_Product__c> ACP = 
             [Select Id, 
                     Sales_Price__c, 
                     name, 
                     Converted_To_Opportunity__c,
                     Dismantle_Date__c,
                     Active_Contract__c, 
                     AOCV__c, 
                     OCV__c, 
                     ATTRF_CRV__c, 
                     Segmentation__c, 
                     Pre_Segmentation__c,
                     Raw_Maint_Calc_LC__c, 
                     Projected_Renewal_Calc__c, 
                     Active_Contract_Number__c, 
                     Renewal_Product__r.Renewal__r.Name,
                     Renewal_Product__r.Projected_Time_Duration_Months__c,
                     Active_Contract__r.Name,
                     Active_Contract__r.Contract_Term_Months__c, 
                     Product__c, 
                     Product__r.Name, 
                     Product__r.Family
                From Active_Contract_Product__c
               where Renewal_Product__r.Renewal__c=:rnwl.Id
                 and Converted_To_Opportunity__c <> true]; // exclude ACPs already converted to Opptys - lfc - 06Mar2012
              

        
        set<Id> prod = new set<Id>();       
        for(Active_Contract_Product__c actvCP : ACP){ 
              prod.add(actvCP.Product__c);
        }       

        Map<id,PricebookEntry> ACPProd = new Map<id,PricebookEntry>();  //([Select Id,Name From PricebookEntry where Product2Id  in : prod and Pricebook2.Name='CA Product List' and IsActive =:true and CurrencyIsoCode =:currencycode]);          
        for(PricebookEntry p : [Select Id,Name,Product2Id From PricebookEntry where Product2Id in :prod and Pricebook2.Name='CA Product List' and IsActive =:true and CurrencyIsoCode =:rnwl.Local_Currency__c]){ 
              ACPProd.put(p.Product2Id,p);
        }
            
       if(ACPProd == null || ACPProd.size() <= 0 || ACPProd.size() < prod.size()){
           system.debug('ACPProd --> ' + ACPProd.size());
           system.debug('prod--> ' + prod.size());
          errorLog.put('Error','Pricebook Entry is not active for selected Renewal product(s)!');        
            return null;  
        } 
            
     /*********************************/       
    
//        System.debug('rnwl.Projected_Renewal__c' +rnwl.Projected_Renewal__c);        
        Opportunity opp = new Opportunity(name=rnwl.name,
                                          AccountId=rnwl.Account__c,
                                          CloseDate=rnwl.Expected_Close_Date__c,
                                          Description=rnwl.Overall_Comments__c,
                                          New_Site_Id__c=rnwl.New_Site_Id__c,                                        
                                          CurrencyIsoCode=rnwl.Local_Currency__c,
                                          Inside_Outside__c='Outside',
                                          StageName='10% - Identification & Qualification',
                                          New_Deal_Term_months__c=rnwl.Projected_Time_Duration_Months__c,
                                          Stretch_Deal_Term_Months__c=rnwl.Projected_Time_Duration_Months__c,
                                          OwnerId=rnwl.OwnerId,
                                          Original_CV__c=rnwl.OCV__c,
                                          Site_ID__c=rnwl.Sold_to_Ship_to_Party_Site_ID__c,
                                          Type='Direct',
                                          RPD_Status__c='Requested',
                                          RecordTypeId = recId,
                                          Renewal__c=rnwl.id,
                                          Business_Type__c = BusinessType,
                                          Projected_Renewal__c = rnwl.Projected_Renewal__c
// FY13                                          ,Comfort__c = rnwl.Projected_Renewal__c
                                         );
                   //AR 3051
                   If(rnwl.Reason_duration_is_1_year__c!=null && rnwl.Status_at_end_of_term__c!=null)
                   {
                         opp.Reason_duration_is_1_year__c = rnwl.Reason_duration_is_1_year__c ;
                         opp.Status_at_end_of_term__c = rnwl.Status_at_end_of_term__c ;
                           
                    }
                                         
                                         
                                         

        //System.debug('Opp Proj Renewal$$1 '+opp.Projected_Renewal__c);
        try{            
            //FY13 - Assign the Terr on Opp from the Renewal Territory/Country Field
            if(terr <> null)
                opp.TerritoryId = terr.id;
            insert opp;
         }      
         catch (DMLException e) {           
            for (Integer index = 0; index < e.getNumDml(); index++){
                            errorLog.put(rnwl.name,e.getDmlMessage(index));
                                        showEmailLogButton = true;
                      }
            //errorLog.put('Error','This Renewal cannot be converted to an opportunity. Please check the error message above for more information.');
            return null;  
         }            

        Id id = opp.Id;
        rnwl.Opportunity__c=id;
        if(updateRnwlFields(id,opp.currencyisocode))
        {
          //System.debug('Opp Proj Renewal$$3 '+opp);
    
            //redirect the page to the RPD Review for opportunity page.
            SystemIdUtility.skipTrigger  = false;  
            PageReference pg =new PageReference('/'+id);
            
            if(errorLog.size() > 0 )
                showEmailLogButton  = true;
            else
               showEmailLogButton = false;
               
            pg.setRedirect(true);   
            return pg;
        }
        else
        {
          errorLog.put('Error','Pricebook Entry is not active for selected Renewal product(s)!');
        
         return null;
        }
    }
    
    public void emailLogs()
   {
   
       
      if(errorLog != null && errorLog.size() > 0)
     {
       String strResult;
       string subject1;
       strResult = strResult + 'Renewal Name' + '~' + 'Message' + '\n';
       Set<String> errorSet= new Set<String>();
       errorSet= errorLog.keySet();

       for(String s: errorSet)
        strResult = strResult + s + '~' + errorLog.get(s) +'\n';
       
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        strResult = strResult.replaceAll(',', ' ');          
 strResult = strResult.replaceAll('~', ',');          
 strResult = strResult.replaceAll('TRUE', 'Yes');          
 strResult = strResult.replaceAll('FALSE', 'No');          
 strResult = strResult.replaceAll('null', '');   
        blob csvBlob =   Blob.valueOf(strResult);
        string csvname= 'ErrorLog.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        
        email.setSubject('Error Log');


        email.setToAddresses(new String[] {UserInfo.getUserEmail() }); 
       
        email.setPlainTextBody('Error Log');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        if (r.get(0).isSuccess())
        {
        Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.CONFIRM,'Mail Sent')); 
        }
        else
        {
        Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.ERROR,'Mail not sent')); 
        }
        
  }
      else
     {
        Apexpages.addMessage(new Apexpages.message(APEXPAGES.SEVERITY.ERROR,'No Records to Email')); 
     }
   }
    
    public boolean updateRnwlFields(Id oppId, string currencycode){
        
        List<CA_Product_Renewal__c> caProdRnwl = new List<CA_Product_Renewal__c>();
        List<OpportunityLineItem> RnwlOppLnItm = new List<OpportunityLineItem>();       
        
        rnwl.Converted_To_Opportunity__c=true;      

        //get all ACP's Associate with the renewal and change the status of the field Converted To Opportunity to true;     
        List <Active_Contract_Product__c> ACP = 
             [Select Id, 
                     Sales_Price__c, 
                     name, 
                     Converted_To_Opportunity__c,
                     Dismantle_Date__c,
                     Active_Contract__c, 
                     AOCV__c, 
                     OCV__c, 
                     ATTRF_CRV__c, 
                     Segmentation__c, 
                     Pre_Segmentation__c,
                     Raw_Maint_Calc_LC__c, 
                     Projected_Renewal_Calc__c, 
                     Active_Contract_Number__c, 
                     Renewal_Product__r.Renewal__r.Name,
                     Renewal_Product__r.Projected_Time_Duration_Months__c,
                     Active_Contract__r.Name,
                     Active_Contract__r.Contract_Term_Months__c, 
                     Product__c, 
                     Product__r.Name, 
                     Product__r.Family
                From Active_Contract_Product__c
               where Renewal_Product__r.Renewal__c=:rnwl.Id
                 and Converted_To_Opportunity__c <> true]; // exclude ACPs already converted to Opptys - lfc - 06Mar2012
              

        
        set<Id> prod = new set<Id>();       
        for(Active_Contract_Product__c actvCP : ACP){ 
              prod.add(actvCP.Product__c);
        }       

        Map<id,PricebookEntry> ACPProd = new Map<id,PricebookEntry>();  //([Select Id,Name From PricebookEntry where Product2Id  in : prod and Pricebook2.Name='CA Product List' and IsActive =:true and CurrencyIsoCode =:currencycode]);          
        for(PricebookEntry p : [Select Id,Name,Product2Id From PricebookEntry where Product2Id in :prod and Pricebook2.Name='CA Product List' and IsActive =:true and CurrencyIsoCode =:currencycode]){ 
              ACPProd.put(p.Product2Id,p);
        }       
        
        if(ACPProd != null && ACPProd.size() > 0){
        for(Active_Contract_Product__c actvCP:ACP){ 
         //for(PricebookEntry p:[Select Id,Name From PricebookEntry where Product2Id =: actvCP.Product__c and Pricebook2.Name='CA Product List' and IsActive =:true and CurrencyIsoCode =:currencycode limit 1])
       
        if(ACPProd.get(actvCP.Product__c)!=null){
            actvCP.Converted_To_Opportunity__c=true;
            actvCP.Opportunity__c = oppId;      

            // avoid issue where null value causes OpportunityLiItm.UnitPrice to default to 1.0
            if(actvCP.Projected_Renewal_Calc__c != null)
                actvCP.Sales_Price__c = actvCP.Projected_Renewal_Calc__c;
            else 
                actvCP.Sales_Price__c = 0;
            
            String RenewalName= actvCP.Product__r.Name;
            String RenewalproductName= actvCP.Active_Contract__r.Name;
            String segment;
             If(actvCP.Segmentation__c =='HT'||actvCP.Segmentation__c =='MT'||actvCP.Segmentation__c =='LT'||actvCP.Segmentation__c =='NT'){
                   segment=actvCP.Segmentation__c;  
             }else{ segment = actvCP.Pre_Segmentation__c; }
            
            if(RenewalName!=null && RenewalName.length()>30)
               RenewalName = RenewalName.Substring(0,30);
            if(RenewalproductName !=null && RenewalproductName.length()>50)
               RenewalproductName =RenewalproductName.Substring(0,50);
            
            caProdRnwl.add(new CA_Product_Renewal__c(
                               name=RenewalproductName +'-'+RenewalName,
                               Active_Contract_Product__c=actvCP.Id,
                               Contract__c=actvCP.Active_Contract__c,
                               CAProductRenewal_Amount__c=actvCP.AOCV__c,
                               Renewal_Opportunity__c=oppId,
                               Raw_Maintenance__c = actvCP.Raw_Maint_Calc_LC__c,
                               ATTRF__c = actvCP.ATTRF_CRV__c,
                               trr__C = actvCP.AOCV__c, 
                               currencyIsoCode = currencycode,
                               Projected_Renewal__c= actvCP.Sales_Price__c
// FY13                               ,Inside_Outside__c ='Outside'
                               ));  
                           
                     
            RnwlOppLnItm.add(new OpportunityLineItem(
                                 PricebookEntryId= ACPProd.get(actvCP.Product__c).Id ,//p.id,
                                 CA_Contract_Product_Name__c = RenewalproductName +'-'+RenewalName,
                                 Active_Contract_Product__c = actvCP.Id,
                                 Active_Contract__c=actvCP.Active_Contract__c,
                                 Opportunityid = oppId,
                                 Raw_Maintenance__c=actvCP.Raw_Maint_Calc_LC__c,
                                 ATTRF__c=actvCP.ATTRF_CRV__c,
                                 Old_TRR__c=actvCP.AOCV__c,
                                 Stretch__c=actvCP.Sales_Price__c,
                                 UnitPrice=actvCP.Sales_Price__c,
// FY13                                 Comfort__c = actvCP.Sales_Price__c,
                                 Business_Type__c = 'Renewal',                                                         
                                 Segmentation__c = segment ,
                                 Original_Expiration_Date__c = actvCP.Dismantle_Date__c,
                                 Original_Deal_Term_Months__c= actvCP.Active_Contract__r.Contract_Term_Months__c,
                                 New_Deal_Term_Months__c = actvCP.Renewal_Product__r.Projected_Time_Duration_Months__c,
                                 Original_CV__c= actvCP.OCV__c,
                                 Original_Contract_IDs__c= actvCP.Active_Contract_Number__c
// FY13                                 ,Inside_Outside__c ='Outside'                                                             
                               ));
                    }
                    else{ flag = true;}          
                              
                }
        }
       if(flag==true){
            errorLog.put('Error','Pricebook Entry is not active for selected Renewal product(s)!');
                Opportunity oppdelete = [select id from opportunity where id = :oppId];
                system.debug('**hi**');
                delete  oppdelete;
                return false;    
        }else{
        
        //updates
        update rnwl;

           //FY13 -   start
            Map<id,id> mOLIACP = new Map<id,id>(); //MAP to store the ids of Active Contract Product, Opplineitem
            Map<id,id> mRCPACP = new Map<id,id>(); //MAP to store the ids of Active Contract Product, Renewal Contract Product
                
           //FY13 end

        if(caProdRnwl.size()>0){
            insert caProdRnwl;

                    //FY13 - storing the ids of Active Contract Product, Renewal Contract Product in map
                    for(CA_Product_Renewal__c cpr: caProdRnwl)
                    { 
                        mRCPACP.put(cpr.Active_Contract_Product__c, cpr.id);
                    }
         }       
        if(RnwlOppLnItm.size() >0){
           insert RnwlOppLnItm; 

           //FY13 - storing the ids of Active Contract Product, Opplineitem in map
           for(OpportunityLineItem oli: RnwlOppLnItm)
                    { 
                        mOLIACP.put(oli.Active_Contract_Product__c,oli.id);
                    }
         } 

        //FY13 - Updating the ids of Renewal Contract Product, Opplineitem on Active Contract Product from the maps
        for(Active_Contract_Product__c a:ACP)
        {
              a.Opportunity_Product__c =mOLIACP.get(a.id);//FY13
              a.Renewal_Contract_Product__c =mRCPACP.get(a.id);//FY13
        }

        if(ACP.size()>0){
            update ACP;
        }
         return true;
       }                         
  }
    
}