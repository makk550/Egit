public class AutoCreateDDR 
{
  public static Deal_Desk_Review__c createDDR(scpq__SciQuote__c sQuote, scpq__SciQuote__c sQuoteExtended)
  {   
    //Nolio Change for Demo new change
    Deal_Desk_Review__c newDDR = new Deal_Desk_Review__c();
    newDDR.Opportunity_Name__c = sQuote.scpq__OpportunityId__c;
    newDDR.Area__c = sQuoteExtended.scpq__OpportunityId__r.Rpt_Area__c;
    newDDR.Oppty_Close_Date__c = sQuoteExtended.scpq__OpportunityId__r.CloseDate;
    newDDR.Sales_Milestone__c = sQuoteExtended.scpq__OpportunityId__r.StageName;
    newDDR.Opportunity_Owner__c = sQuoteExtended.scpq__OpportunityId__r.OwnerId;
    newDDR.Account_Name__c = sQuoteExtended.scpq__OpportunityId__r.AccountId;
    newDDR.Oppty_Number__c = sQuoteExtended.scpq__OpportunityId__r.Opportunity_Number__c;
    newDDR.Oppty_Amount__c = sQuoteExtended.scpq__OpportunityId__r.Amount;
    newDDR.CurrencyIsoCode = sQuoteExtended.scpq__OpportunityId__r.CurrencyIsoCode;
    newDDR.Territory__c = sQuoteExtended.scpq__OpportunityId__r.Rpt_Territory_Country__c;
    newDDR.Type__c = sQuoteExtended.scpq__OpportunityId__r.Type;
    newDDR.Area02__c = sQuoteExtended.scpq__OpportunityId__r.Rpt_Country__c;
    newDDR.Region__c = sQuoteExtended.scpq__OpportunityId__r.Rpt_Region__c;

    newDDR.Sterling_Quote__c = sQuote.Id;

    newDDR.Deal_Desk_Request_Type__c = 'Product-Other';
    newDDR.Deal_Desk_Status__c = 'Request Review -- DD';

    return newDDR; 
  }
  
  public static Quote_Approval_History__c createQuoteApprovalHistory(scpq__SciQuote__c sQuote)
  {
    Quote_Approval_History__c qah = new Quote_Approval_History__c();
    
    qah.Sterling_Quote__c = sQuote.Id;
    qah.CA_Total_Total_Disc_Off_List__c = sQuote.CA_Total_Total_Disc_Off_List__c;
    qah.CA_Total_Total_Disc_Off_Vol_GSA_Price__c = sQuote.CA_Total_Total_Disc_Off_Vol_GSA_Price__c;
    qah.CA_Effective_Date__c = sQuote.CA_Effective_Date__c;
    qah.CA_Contract_End_Date__c = sQuote.CA_Contract_End_Date__c;
    
    // Defect 62147
    qah.CA_Total_List_License_Subs_Fee__c = sQuote.CA_Total_List_License_Subs_Fee__c;
    qah.CA_Total_List_Maintenance_Price__c = sQuote.CA_Total_List_Maintenance_Price__c;
    
    qah.Approval_Date__c = Date.today();
    
    return qah;
  }
  
  public static boolean quoteShouldBeAutoApproved(scpq__SciQuote__c sQuote,  Quote_Approval_History__c qah)
  {
    System.debug('D+++ In quoteShouldBeAutoApproved function +++');
    System.debug(sQuote);
    System.debug(qah);
  
    if(fiscalYearOf(qah.Approval_Date__c) != fiscalYearOf(Date.today())) 
    {
        System.debug('D+++ not in same fiscal year +++');
        return false;
    }
    
    if(qah.Approval_Date__c.addDays(90) < Date.today()) 
    {
        System.debug('D+++ approval date older than 90 days +++');
        return false;
    }
    
    if(sQuote.CA_Using_Quick_Contract__c == false)
    {
        System.debug('D+++ Using quick contract flag is off +++');
        return false;
    }
    if(sQuote.Minimum_Commit__c == true)
    {        
        return false;
    }
    if(sQuote.CA_Total_Total_Disc_Off_List__c > qah.CA_Total_Total_Disc_Off_List__c)
    {
        System.debug('D+++ New Total discount off list > old Total Discount off list');
        System.debug('D+++ N:' + sQuote.CA_Total_Total_Disc_Off_List__c + ' O:' + qah.CA_Total_Total_Disc_Off_List__c); 
        
        return false;
    }
    if(sQuote.CA_Total_Total_Disc_off_Vol_GSA_Price__c > qah.CA_Total_Total_Disc_off_Vol_GSA_Price__c) 
    {
        System.debug('D+++ New Total discount off vol gsa price > old Total discount off vol gsa price +++');
        return false;
    }
    /* if(sQuote.CA_Effective_Date__c != qah.CA_Effective_Date__c) 
    {
        System.debug('D+++ effective date change +++');
        return false;
    } */
    if(sQuote.CA_Contract_End_Date__c  != qah.CA_Contract_End_Date__c )
    {
        System.debug('D+++ effective end date change +++');
        return false;
    }
    
    // Defect 62147
    if(sQuote.CA_Total_List_License_Subs_Fee__c != qah.CA_Total_List_License_Subs_Fee__c )
    {
        System.debug('D+++ Total List License Subs Fee change +++');
        return false;
    }
    if(sQuote.CA_Total_List_Maintenance_Price__c != qah.CA_Total_List_Maintenance_Price__c)
    {
        System.debug('D+++ Total List Maintenance Price change +++');
        return false;
    }
    
    System.debug('D+++ auto approve: true +++');
    return true;
  }
  
  private static Integer fiscalYearOf(Date d)
  {
    if(d.month() < 4)
        return d.year();
    
    return d.year() + 1;
  }
  
  public static boolean quoteRequiresDDR(scpq__SciQuote__c sQuote, scpq__SciQuote__c sQuoteExtended, Map<String, Decimal> isoCodeToConversionRate, DDR_Rules__c ddrRules)
  {
    System.debug('+++++++inside quoteRequiresDDR+++++++');
    if(sQuote.CA_Quote_Type__c == 'New Product') return newProductQuoteRequiresDDR(sQuote, sQuoteExtended, isoCodeToConversionRate, ddrRules);
    if(sQuote.CA_Quote_Type__c == 'Renewal') return renewalQuoteRequiresDDR(sQuote, sQuoteExtended, isoCodeToConversionRate, ddrRules);
    if(sQuote.CA_Quote_Type__c == 'Direct Registration') return false;//changed to exclude the DDR process in case the Quote Type is Direct Registration
    return combinedQuoteRequiresDDR(sQuote, sQuoteExtended);
  }
  
  private static boolean newProductQuoteRequiresDDR(scpq__SciQuote__c quote, scpq__SciQuote__c sQuoteExtended, Map<String, Decimal> isoCodeToConversionRate, DDR_Rules__c ddrRules)
  {
    if(ddrRules.New_Product_Using_Quick_Contract_Rule__c && quote.CA_Using_Quick_Contract__c == false){
        System.debug('++++++CA_Using_Quick_Contract__c++++++++');
        return true;
    }  
     
    if(sQuoteExtended.scpq__OpportunityId__r.Type != '1 Tier') {
        
                if(quote.Minimum_Commit__c == true)
                {        
                    return true;
                } 
             
                if(ddrRules.New_Product_Account_Segment_Rule__c && sQuoteExtended.scpq__OpportunityId__r.Account.Segment__c == ddrRules.New_Product_Account_Segment__c){
                     System.debug('++++++Account Segment++++++++');
                     return true;
                 }
                   
                 if(ddrRules.New_Product_CPQ_Quote_Type_Rule__c && ddrRules.New_Product_CPQ_Quote_Type__c.containsIgnoreCase(quote.CA_Direct_Indirect__c))
                 {
                    System.debug('++++++quote type++++++++');
                    return true;
                 }
                
                Decimal quote_total = quote.CA_CPQ_Quote_Total__c / isoCodeToConversionRate.get(quote.CurrencyIsoCode);
                
                if(ddrRules.New_Product_LA_Quote_Total_Rule__c && quote.Region__c == 'LA' && quote_total > ddrRules.New_Product_Max_Quote_Total_For_LA__c) {
                     System.debug('++++++quote.Region__c == LA && quote_total > *++++++++');
                     return true;
                 }
                if(ddrRules.New_Product_EMEA_Quote_Total_Rule__c && quote.Region__c == 'EMEA' && quote_total > ddrRules.New_Product_Max_Quote_Total_For_EMEA__c) {
                     System.debug('++++++quote.Region__c == EMEA && quote_total > *++++++++');
                     return true;
                 }
                if(ddrRules.New_Product_NA_Quote_Total_Rule__c && quote.Region__c == 'NA' && quote_total > ddrRules.New_Product_Max_Quote_Total_For_NA__c) {
                     System.debug('++++++quote.Region__c == NA && quote_total > *++++++++');
                     return true;
                 }   
                
                
                Decimal term = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
                
                
                if(ddrRules.New_Product_Pricing_Group_Term_Rule__c && term < ddrRules.New_Product_Pricing_Group_Term__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.CA_Pricing_Group__c == ddrRules.New_Product_Pricing_Group__c)
                        {
                            System.debug('++++++Pricing Group and Term++++++++');
                            return true;
                        }
                    }
                }
                
                if(ddrRules.New_Product_Term_Rule__c && term > ddrRules.New_Product_Maximum_Contract_Term__c * 12.0)
                {
                    System.debug('++++++term > *++++++++');
                    return true;
                }
                
                if(ddrRules.New_Product_Net_Payment_Term_Rule__c && quote.Net_Payment_Terms__c == ddrRules.New_Product_Net_Payment_Terms__c)  
                {
                    System.debug('++++++Net Payment Terms++++++++');
                    return true;
                }
                
                if(ddrRules.New_Product_Payment_Schedule_Rule__c && quote.CA_Payment_Schedule__c == ddrRules.New_Product_Payment_Schedule__c)
                {
                    System.debug('++++++Payment Schedule++++++++');
                    return true;
                }
                
                if(ddrRules.New_Product_LT_Combo_Rule_1__c)
                {
                    boolean lt1Found = false;
                
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.License_Type__c == ddrRules.New_Product_LT1_for_LT_Combo_1__c)
                        {
                            lt1Found = true;
                            break;
                        }
                    }
                    
                    if(lt1Found)
                    {
                        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                        {
                            if( (qpr.License_Type__c == ddrRules.New_Product_LT2_for_LT_Combo_1__c) && (ddrRules.New_Product_BTT_for_LT_Combo_1__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c)) )
                            {
                                System.debug('++++++License Type Combo 1++++++++');
                                return true;
                            }
                        }
                    }
                }
                
                if(ddrRules.New_Product_LT_Combo_Rule_2__c)
                {
                    boolean lt1Found = false;
                
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.License_Type__c == ddrRules.New_Product_LT1_for_LT_Combo_2__c)
                        {
                            lt1Found = true;
                            break;
                        }
                    }
                    
                    if(lt1Found)
                    {
                        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                        {
                            if( (qpr.License_Type__c == ddrRules.New_Product_LT2_for_LT_Combo_2__c) && (ddrRules.New_Product_BTT_for_LT_Combo_2__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c)) )
                            {
                                System.debug('++++++License Type Combo 2++++++++');
                                return true;
                            }
                        }
                    }
                }
                
                if(ddrRules.New_Product_LT_Combo_Rule_3__c)
                {
                    boolean lt1Found = false;
                
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.License_Type__c == ddrRules.New_Product_LT1_for_LT_Combo_3__c)
                        {
                            lt1Found = true;
                            break;
                        }
                    }
                    
                    if(lt1Found)
                    {
                        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                        {
                            if( (qpr.License_Type__c == ddrRules.New_Product_LT2_for_LT_Combo_3__c) && (ddrRules.New_Product_BTT_for_LT_Combo_3__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c)) )
                            {
                                System.debug('++++++License Type Combo 3++++++++');
                                return true;
                            }
                        }
                    }
                }
                
                if(ddrRules.New_Product_LT_Combo_Rule_4__c)
                {
                    boolean lt1Found = false;
                
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.License_Type__c == ddrRules.New_Product_LT1_for_LT_Combo_4__c)
                        {
                            lt1Found = true;
                            break;
                        }
                    }
                    
                    if(lt1Found)
                    {
                        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                        {
                            if( (qpr.License_Type__c == ddrRules.New_Product_LT2_for_LT_Combo_4__c) && (ddrRules.New_Product_BTT_for_LT_Combo_4__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c)) )
                            {
                                System.debug('++++++License Type Combo 4++++++++');
                                return true;
                            }
                        }
                    }
                }
                
                if(ddrRules.New_Product_PS_and_LT_Rule__c && quote.CA_Payment_Schedule__c == ddrRules.New_Product_PS_for_PS_and_LT__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.License_Type__c == ddrRules.New_Product_LT_for_PS_and_LT__c && ddrRules.New_Product_BTT_for_PS_and_LT__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c))
                        {
                            System.debug('++++++Payment Schedule and License type++++++++');
                            return true;
                        }
                    }
                }
                
                if(ddrRules.New_Product_PS_and_LT_2_Rule__c && quote.CA_Payment_Schedule__c == ddrRules.New_Product_PS_for_PS_and_LT_2__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.License_Type__c == ddrRules.New_Product_LT_for_PS_and_LT_2__c && ddrRules.New_Product_BTT_for_PS_and_LT_2__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c))
                        {
                            System.debug('++++++Payment Schedule and License type2++++++++');
                            return true;
                        }
                    }
                }
                
                
                if(ddrRules.New_Product_Quick_Quote_Line_Item_Rule__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.Quick_Quote__c == false)
                        {
                            System.debug('++++++Using Quick Quote (line item)++++++++');
                            return true;
                        }
                    }
                }
                
                if(ddrRules.New_Product_Auto_Calc_State_Renewal_Rule__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.AutoCalc_Stated_Renewal__c == 'No' && !ddrRules.New_Product_ACSR_LT_Exceptions__c.containsIgnoreCase(qpr.License_Type__c)
                                                                  && !ddrRules.New_Product_ACSR_BTT_Exceptions__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c))
                        {
                            System.debug('++++++Auto Calc Stated Renewal++++++++');
                            return true;
                        }
                    }
                }
                
                if(ddrRules.New_Product_Auth_Use_Model_Rule__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.Auth_Use_Model__c == ddrRules.New_Product_Auth_Use_Model__c)
                        {
                            System.debug('++++++Auth Use Model++++++++');
                            return true;
                        }
                    }
                }
                
                 //DDR Rule: CA Educatin and Sales area is public Sector
                if(ddrRules.CA_Education_Public_Sector_Rule__c){
                    
                  if(quote.CA_GSA_Pricing_Flag__c){         
                      for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                            if(qpr.CA_Pricing_Group__c == ddrRules.CA_Education_Pricing_Group__c && qpr.Bus_Transaction_Type__c == ddrRules.CA_Education_Bus_Trans_Type__c){
                                  System.debug('+++++++++++ DDR Rule: CA Educatin and Sales area is public Sector +++++++++++');
                                  return true;                        
                            }
                      }
                  } 
                     
                }
                
                //DDR Rule: New Product CA Education combined with any other transaction type 
                if(ddrRules.New_Product_CA_Education_Combo_Rule__c){
                  
                  boolean caEducationFound = false;
                       
                  for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){            
                        if(qpr.Bus_Transaction_Type__c == ddrRules.CA_Education_Bus_Trans_Type__c && qpr.CA_Pricing_Group__c == ddrRules.CA_Education_Pricing_Group__c){
                              caEducationFound = true;
                              break;
                        }
                  }
                  
                  if(caEducationFound)
                  {
                        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                        {
                              if(ddrRules.NON_CA_Education_Bus_Trans_Types__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c))
                              {
                                    System.debug('+++++++++++New Product CA Education combo rule++++++++++');
                                    return true;
                              }
                        }     
                  }
                }
                 
               
                
                //DDR Rule: CA Education with pay as you go payment method 
                if(ddrRules.New_Product_CAEducation_With_PM_Rule__c){
                
                  boolean paymentMethodFound = false;      
                  for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                        System.debug('+++Payment Method+++'+qpr.Payment_Method__c);
                        System.debug('+++Payment Method From Rule+++'+ddrRules.New_Product_CAEducation_PMethod_With_PM__c);
                              
                        if(qpr.Payment_Method__c == ddrRules.New_Product_CAEducation_PMethod_With_PM__c)
                        {
                            paymentMethodFound = true;
                            break;
                        }
                  }
                  
                  if(paymentMethodFound){       
                        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                              if((qpr.CA_Pricing_Group__c == ddrRules.CA_Education_Pricing_Group__c && qpr.Bus_Transaction_Type__c == ddrRules.CA_Education_Bus_Trans_Type__c)){
                                    System.debug('+++++++++++ DDR Rule: CA Educatin and Sales area is public Sector +++++++++++');
                                    return true;               
                              }
                        }
                   }
                }
                
                if(ddrRules.New_Product_IndirectAdvantageSKUs__c) {
                
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                          if(qpr.Product_Material__r.Name == Label.API_Gateway_SKU || qpr.Product_Material__r.Name == Label.Release_Automation_SKU || qpr.Product_Material__r.Name == Label.CSM_SKU_1 || qpr.Product_Material__r.Name == Label.CSM_SKU_2){
                                
                                 System.debug('+++++++++++ DDR Rule: Quote contains Indirect Advantage SKUs+++++++++++');
                                return true;
                          }
                    }
                    
                 }
        
    }
    
    
    if(sQuoteExtended.scpq__OpportunityId__r.Type == '1 Tier'){
    
                if(ddrRules.New_Product_Morethan_1_SKUs__c){
                
                    Integer prodCount =0,SKU = 0;
                
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                     prodCount++;
                    
                          if(qpr.Product_Material__r.Name == Label.API_Gateway_SKU || qpr.Product_Material__r.Name == Label.Release_Automation_SKU || qpr.Product_Material__r.Name == Label.CSM_SKU_1 || qpr.Product_Material__r.Name == Label.CSM_SKU_2){
                                
                                SKU++;
                                       
                          }
                    }
                    
                    if(SKU > 0 && prodCount > 1){
                          System.debug('+++++++++++ DDR Rule: Quote contains morethan one lineitems and one among them as indirect sales SKUs+++++++++++');
                          return true;
                    }
                        
                //Added by Cindy Courcelle to make sure Indirect Advantage products are chosen
                if(SKU == 0 ){
                          System.debug('+++++++++++ No Indirect Advantage Products found+++++++++++');
                          return true;
                    }
                }

                //Added by Cindy Courcelle to verify product line item is QQ eligible
                if(ddrRules.New_Product_Quick_Quote_Line_Item_Rule__c)
                {
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
                    {
                        if(qpr.Quick_Quote__c == false)
                        {
                            System.debug('++++++Using Quick Quote (line item)++++++++');
                            return true;
                        }
                    }
                }

                if(ddrRules.New_Product_Stated_Renewal_Fee__c){
                
                    
                    for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                   
                          if(qpr.Product_Material__r.Name == Label.CSM_SKU_1 && qpr.Stated_Renewal_Fee__c > ddrRules.New_Product_Stated_Renewal_Fee_Input__c){
                                
                                
                                System.debug('+++++++++++ DDR Rule: Stated Renewal Fee greated than zero for Quote with SKU = SPCRS3990 +++++++++++');
                                return true;               
                          }
                    }
                    
                    
                
                }
                if(ddrRules.New_Product_Quote_Term__c){
                
                    
                     Decimal term1 = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
                     for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                    
                          if(qpr.Product_Material__r.Name == Label.CSM_SKU_1 && term1/12.0 != ddrRules.New_Product_Term_Input1__c){
                    
                                System.debug('+++++++++++ DDR Rule: Quote with SKU : SPCRS3990 and Term not equals to given yr(s) +++++++++++');
                                return true;               
                          }
                    }
              
                }
                if(ddrRules.New_Product_Quote_Term2__c){
                
                    
                     Decimal term2 = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
                     for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                    
                          if((qpr.Product_Material__r.Name == Label.API_Gateway_SKU || qpr.Product_Material__r.Name == Label.Release_Automation_SKU || qpr.Product_Material__r.Name == Label.CSM_SKU_2) && ((term2/12.0) != ddrRules.New_Product_Term_Input2__c)){
                    
                                System.debug('+++++++++++ DDR Rule: Quote with SKU : APIGTS990, SPRAPN990, SPCRS1990 and Term npt equal to given yr(s) +++++++++++');
                                return true;               
                          }
                    }
              
                }
                if(ddrRules.New_Product_Number_of_Users__c){
                
                    
                     for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                          if((qpr.Product_Material__r.Name == Label.API_Gateway_SKU || qpr.Product_Material__r.Name == Label.Release_Automation_SKU || qpr.Product_Material__r.Name == Label.CSM_SKU_1 || qpr.Product_Material__r.Name == Label.CSM_SKU_2) && qpr.Total_Quantity__c != ddrRules.New_Product_UserCount_Input__c){
                    
                                System.debug('+++++++++++ DDR Rule: Quote with SKU : APIGTS990, SPRAPN990, SPCRS1990, SPRAPN990 and Number of Ussers not equals to 1 +++++++++++');
                                return true;               
                          }
                    }
              
                }
                if(ddrRules.New_Product_Net_Payment_Term__c){
                
                          if(quote.Net_Payment_Terms__c == ddrRules.New_Product_Net_Term_Input__c){
                    
                                System.debug('+++++++++++ DDR Rule: Payment Terms = Greater than Net 45 +++++++++++');
                                return true;               
                          }
                    
               
                }
                if(ddrRules.New_Product_Payment_Schedule_1__c){
                
                    
                     for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                          if(qpr.License_Type__c == ddrRules.New_Product_License_Type_Input_1__c && sQuoteExtended.CA_Payment_Schedule__c != ddrRules.New_Product_Payment_Schedule_Input_1__c){
                    
                                System.debug('+++++++++++ DDR Rule: license type = Perpetual AND Payment Schedule ≠ Yearly +++++++++++');
                                return true;               
                          }
                    }
              
                }
                if(ddrRules.New_Product_Payment_Schedule_2__c){
                
                    
                     for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                          if(qpr.License_Type__c == ddrRules.New_Product_License_Type_Input_2__c && sQuoteExtended.CA_Payment_Schedule__c == ddrRules.New_Product_Payment_Schedule_Input_2__c){
                    
                                System.debug('+++++++++++ DDR Rule: license type = Duration Based Subscription AND Payment Schedule = Custom +++++++++++');
                                return true;               
                          }
                    }
              
                }
                if(ddrRules.New_Product_Payment_Schedule_3__c){
                
                    
                     for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r){
                    
                          if(qpr.License_Type__c == ddrRules.New_Product_License_Type_Input_3__c && sQuoteExtended.CA_Payment_Schedule__c == ddrRules.New_Product_Payment_Schedule_Input_3__c){
                    
                                System.debug('+++++++++++ DDR Rule: license type = Subscription AND Payment Schedule = Custom +++++++++++');
                                return true;               
                          }
                    }
              
                }
    }
    
       
    return false;
  }
  
  private static boolean renewalQuoteRequiresDDR(scpq__SciQuote__c quote, scpq__SciQuote__c sQuoteExtended, Map<String, Decimal> isoCodeToConversionRate, DDR_Rules__c ddrRules)
  {
    //if(quote.CA_Using_Quick_Contract__c == false) return true;
    
    String renewalType = quote.CA_Commissionable_Area__c;
    
    if(renewalType == 'Medium Touch' || renewalType == 'Acquisition' || renewalType == 'Indirect Medium Touch' || renewalType == 'Medium Touch SaaS')
    
    {   
        if(ddrRules.Renewal_Using_Quick_Contract_Rule__c && quote.CA_Using_Quick_Contract__c == false)
        {
            System.debug('++++++Renewal CA_Using_Quick_Contract__c++++++++');
            return true;
        }   
         
        if(quote.Minimum_Commit__c == true)
        {        
            return true;
        }
        
        
        Decimal quote_total = quote.CA_CPQ_Quote_Total__c / isoCodeToConversionRate.get(quote.CurrencyIsoCode); // is this right?
        Decimal term = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
        Decimal quote_total_per_annum = quote_total / (term / 12.0);
        
    System.debug('++++++quote_total_per_annum++++++++'+quote_total_per_annum);
        System.debug('++++++quote.Region__c++++++++'+quote.Region__c);

        if(ddrRules.Renewal_LA_Quote_Total_Annum_Rule__c && quote.Region__c == 'LA' && quote_total_per_annum > ddrRules.Renewal_Max_Quote_Total_Annum_For_LA__c)
        {
            System.debug('++++++Renewal quote.Region__c == LA && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal_EMEA_Quote_Total_Annum_Rule__c && quote.Region__c == 'EMEA' && quote_total_per_annum > ddrRules.Renewal_Max_Quote_Total_Annum_For_EMEA__c)
        {
            System.debug('++++++Renewal quote.Region__c == EMEA && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal_NA_Quote_Total_Annum_Rule__c && quote.Region__c == 'NA' && quote_total_per_annum > ddrRules.Renewal_Max_Quote_Total_Annum_For_NA__c)
        {
            System.debug('++++++Renewal quote.Region__c == NA && quote_total_Annum > *++++++++');
            return true;
        }
        
         if(ddrRules.Renewal_APJ_Quote_Total_Annum_Rule__c && quote.Region__c == 'APJ' && quote_total_per_annum > ddrRules.Renewal_Max_Quote_Total_Annum_For_APJ__c)
         {
            System.debug('++++++Renewal quote.Region__c == APJ && quote_total_Annum > *++++++++');
            return true;
         }
        
        if(ddrRules.Renewal_Term_Rule__c && term > ddrRules.Renewal_Maximum_Contract_Term__c * 12.0)
        {
            System.debug('++++++Renewal term > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal_Net_Payment_Term_Rule__c && quote.Net_Payment_Terms__c == ddrRules.Renewal_Net_Payment_Terms__c)
        {
            System.debug('++++++Renewal Net Payment Terms++++++++');
            return true;
        }
        
        if(ddrRules.Renewal_Business_Transaction_Type_Rule__c)
        {
            for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
            {
                if(qpr.Bus_Transaction_Type__c == ddrRules.Renewal_Business_Transaction_Type__c)
                {
                    System.debug('++++++Renewal Business Transaction Type++++++++');
                    return true;
                }
            }
        }
    }
    else if(renewalType == 'Medium Touch Nimsoft SaaS')//YEDRA01 for AR:2994
    {
        if(ddrRules.Renewal2_Using_Quick_Contract_Rule__c && quote.CA_Using_Quick_Contract__c == false)
        {
            System.debug('++++++Renewal2 CA_Using_Quick_Contract__c++++++++');
            return true;
        }  
        
        if(quote.Minimum_Commit__c == true)
        {        
            return true;
        }  
        
        
        Decimal quote_total = quote.CA_CPQ_Quote_Total__c / isoCodeToConversionRate.get(quote.CurrencyIsoCode); // is this right?
        Decimal term = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
        Decimal quote_total_per_annum = quote_total / (term / 12.0);
        
        if(ddrRules.Renewal2_LA_Quote_Total_Annum_Rule__c && quote.Region__c == 'LA' && quote_total_per_annum > ddrRules.Renewal2_Max_Quote_Total_Annum_For_LA__c)
        {
            System.debug('++++++Renewal2 quote.Region__c == LA && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal2_EMEA_Quote_Total_Annum_Rule__c && quote.Region__c == 'EMEA' && quote_total_per_annum > ddrRules.Renewal2_Max_Quote_Total_Annum_For_EMEA__c)
        {
            System.debug('++++++Renewal2 quote.Region__c == EMEA && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal2_NA_Quote_Total_Annum_Rule__c && quote.Region__c == 'NA' && quote_total_per_annum > ddrRules.Renewal2_Max_Quote_Total_Annum_For_NA__c)
        {
            System.debug('++++++Renewal2 quote.Region__c == NA && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal2_APJ_Quote_Total_Annum_Rule__c && quote.Region__c == 'APJ' && quote_total_per_annum > ddrRules.Renewal2_Max_Quote_Total_Annum_For_APJ__c)
        {
            System.debug('++++++Renewal2 quote.Region__c == APJ && quote_total_Annum > *++++++++');
            return true;
        }
        
        
        if(ddrRules.Renewal2_Term_Rule__c && term > ddrRules.Renewal2_Maximum_Contract_Term__c * 12.0)
        {
            System.debug('++++++Renewal2 term > *++++++++'+term+ddrRules.Renewal2_Maximum_Contract_Term__c * 12.0);
            return true;
        }
        
        if(ddrRules.Renewal2_Net_Payment_Term_Rule__c && quote.Net_Payment_Terms__c == ddrRules.Renewal2_Net_Payment_Terms__c)
        {
            System.debug('++++++Renewal2 Net Payment Terms++++++++');
            return true;
        }
        
        if(ddrRules.Renewal2_Business_Transaction_Type_Rule__c)
        {
            for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
            {
                if(qpr.Bus_Transaction_Type__c == ddrRules.Renewal2_Business_Transaction_Type__c)
                {
                    System.debug('++++++Renewal2 Business Transaction Type++++++++');
                    return true;
                }
            }
        }
    }
    else if(renewalType == 'High Touch Fast Track')
    {
       if(ddrRules.Renewal3_Using_Quick_Contract_Rule__c && quote.CA_Using_Quick_Contract__c == false)
        {
            System.debug('++++++Renewal3 CA_Using_Quick_Contract__c++++++++');
            return true;
        }
        
        if(quote.Minimum_Commit__c == true)
        {        
            return true;
        }
        
        if(ddrRules.Renewal3_Business_Transaction_Type_Rule__c)
        {
            for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
            {
                if(qpr.Bus_Transaction_Type__c == ddrRules.Renewal3_Business_Transaction_Type__c || qpr.Bus_Transaction_Type__c == ddrRules.Renewal4_Business_Transaction_Type__c)
                {
                    System.debug('++++++Renewal3 Business Transaction Type++++++++');
                    return true;
                }
            }
        }      
              
        Decimal quote_total = quote.CA_CPQ_Quote_Total__c / isoCodeToConversionRate.get(quote.CurrencyIsoCode); 
        Decimal term = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
        Decimal quote_total_per_annum = quote_total / (term / 12.0);
        
        if(ddrRules.Renewal_Term_GT_36_Rule__c && term > ddrRules.Renewal_Term_GT_36__c)
        {
            System.debug('+++++++++Term GT 3 YEARS DDR Rule++++++++');
            return true;
        }
        
        if(ddrRules.Renewal_QuoteTotal_Annum_GT300K_NA_Rule__c && quote_total_per_annum > ddrRules.Renewal_Quote_Total_Annum_GT_300K_NA__c)
        {
            System.debug('+++++++++Quote total GT 300K Per annum for NA++++++++');
            return true;
        }
    }
    else if(renewalType == 'High Touch')
    {
        return true;
    }
    
    //Vinu : New Enhancement, yet to move on Next Release.    
    else if(renewalType == 'Medium Touch Clarity SaaS')
    {
        if(ddrRules.Renewal4_Using_Quick_Contract_Rule__c && quote.CA_Using_Quick_Contract__c == false)
        {
            System.debug('++++++Renewal2 CA_Using_Quick_Contract__c++++++++');
            return true;
        }  
        
        if(quote.Minimum_Commit__c == true)
        {        
            return true;
        }
        
        Decimal quote_total = quote.CA_CPQ_Quote_Total__c / isoCodeToConversionRate.get(quote.CurrencyIsoCode); // is this right?
        Decimal term = getMonthsBetween(quote.CA_Effective_Date__c, quote.CA_Contract_End_Date__c);
        Decimal quote_total_per_annum = quote_total / (term / 12.0);

        if(ddrRules.Renewal3_NA_Qcuote_Total_Annum_Rule__c && quote.Region__c == 'NA' && quote_total_per_annum > ddrRules.Renewal3_Max_Quote_Total_Annum_For_NA__c)
        {
            System.debug('1++++++Renewal2 quote.Region__c == NA && quote_total_Annum > *++++++++');
            return true;
        }

        if(ddrRules.Renewal3_EMEA_Rule__c && quote.Region__c == 'EMEA')
        {
            System.debug('2++++++Renewal2 quote.Region__c == EMEA && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal3_LA_Rule__c && quote.Region__c == 'LA' )
        {
            System.debug('3++++++Renewal2 quote.Region__c == LA && quote_total_Annum > *++++++++');
            return true;            
        }
        
        if(ddrRules.Renewal3_APJ_Rule__c && quote.Region__c == 'APJ')
        {
            System.debug('4++++++Renewal2 quote.Region__c == APJ && quote_total_Annum > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal3_Term_Rule__c && term > ddrRules.Renewal3_Maximum_Contract_Term__c * 12.0)
        {
            System.debug('5++++++Renewal2 term > *++++++++');
            return true;
        }
        
        if(ddrRules.Renewal4_Term_Rule__c && term < ddrRules.Renewal4_Maximum_Contract_Term__c * 12.0)
        {
            System.debug('6++++++Renewal2 term < *++++++++');
            return true;
        }                
    }    
    
    else if(ddrRules.New_Product_LT_Combo_Rule_4__c)
    {
        boolean lt1Found = false;
    
        for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
        {
            if(qpr.License_Type__c == ddrRules.New_Product_LT1_for_LT_Combo_4__c)
            {
                lt1Found = true;
                break;
            }
        }
        
        if(lt1Found)
        {
            for(Quote_Product_Report__c qpr : sQuoteExtended.Quote_Products_Reporting__r)
            {
                if( (qpr.License_Type__c == ddrRules.New_Product_LT2_for_LT_Combo_4__c) && (ddrRules.New_Product_BTT_for_LT_Combo_4__c.containsIgnoreCase(qpr.Bus_Transaction_Type__c)) )
                {
                    System.debug('++++++License Type Combo 4++++++++');
                    return true;
                }
            }
        }
    }
    return false;
  }
  
  private static boolean combinedQuoteRequiresDDR(scpq__SciQuote__c quote, scpq__SciQuote__c sQuoteExtended)
  { 
    return true;
  }
  
  public static decimal getMonthsBetween(date startDate, date endDate) 
  {
    decimal n = 0.0;
           
    if( startDate.month()== endDate.month() && startDate.year()== endDate.year() )
    {
       n =  decimal.valueOf((startDate.daysBetween(endDate) + 1 )) / decimal.valueOf(date.daysInMonth(startDate.year(),startDate.month()));
    }
    else
    {
       Integer monthsBetween = startDate.monthsBetween(endDate)-1;
            
       decimal firstMonth = decimal.valueOf(date.daysInMonth(startDate.year() , startDate.month())-startDate.day()+1) 
                                    / decimal.valueOf(date.daysInMonth(startDate.year(), startDate.month()));
            
       decimal lastMonth =  decimal.valueOf(endDate.toStartOfMonth().daysBetween(endDate)+1)  
                                    / decimal.valueOf(date.daysInMonth(endDate.year(), endDate.month()));
            
       n =  firstMonth + monthsBetween + lastMonth;         
    }   
    
    system.debug('Months'+n.setScale(2, roundingMode.HALF_UP));
    return n.setScale(2, roundingMode.HALF_UP);    
  }
  
  
}