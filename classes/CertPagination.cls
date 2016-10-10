public class CertPagination
{
private integer totalRecs = 0;
private integer OffsetSize = 0;
private integer LimitSize= 10;
    {
totalRecs = [select count() from CBR_Certifications_LPAC__c];
}
public List<CBR_Certifications_LPAC__c>  getcertlist()
{
List<CBR_Certifications_LPAC__c> cbr = [SELECT SFDC_ID__c,Employee_Name__c,Employee_Type__c,badge__c,ca_product_code__c,ca_product_description__c,ca_product_name__c,certified__c,certified_status_code__c,certified_status_text__c,
                                                                           completion_percentage__c,ldap_id__c,modify_date__c,previous_status_code__c,previous_status_text__c,resource_type__c,status_reason__c,valid_from__c,valid_to__c FROM CBR_Certifications_LPAC__c  
                     where certified__c='Yes' OR (certified__c='No' and certified_status_code__c IN (700,800)) order BY ldap_id__c];
    

//System.debug(‘Values are ‘ + acc);
return cbr;
}
public void FirstPage()
{
OffsetSize = 0;
}
public void previous()
{
OffsetSize = OffsetSize - LimitSize;
}public void next()
{
OffsetSize = OffsetSize + LimitSize;
}public void LastPage()
{
OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
}
public boolean getprev()
{
if(OffsetSize == 0)
return true;
else
return false;
}
public boolean getnxt()
{
if((OffsetSize + LimitSize) > totalRecs)
return true;
else
return false;
}
}