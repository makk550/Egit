trigger PartnerFundEntry_bi on SFDC_Budget_Entry__c (before insert) {
    
    MDF_PopulateCurrencyOnFundEntry.populateCurrencyOnFundEntry(Trigger.new);
}