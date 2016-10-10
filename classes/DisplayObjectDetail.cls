public class DisplayObjectDetail{
public String selectedObject {set; get;}
 private List<ApexClass>     lstClasses = new List<ApexClass>();
 private List<ApexComponent> lstComponent = new List<ApexComponent>();
 private List<ApexPage>         lstPage = new List<ApexPage>();
 private List<ApexTrigger>     lstTrigger = new List<ApexTrigger>();
 Map<String, Schema.SObjectType> mapObjects = Schema.getGlobalDescribe();
 public List<FieldsWrapper> lstFieldResult {get; set;}
 
public DisplayObjectDetail(){
 lstClasses = [select Name, Body from ApexClass];
 lstPage = [select Name, Markup from ApexPage];
 lstComponent = [select Name, Markup from ApexComponent];
 lstTrigger = [select Name, Body from ApexTrigger];
 selectedObject = '';
 }
 
public List<SelectOption> getObjects(){
 List<String> sortThis = new List<String>();
 
List<Schema.SObjectType> gd = mapObjects.Values();
 Set<String> lstKeys = mapObjects.keySet();
 sortThis.addAll(lstKeys);
 sortThis.sort();
 
List<SelectOption> options = new List<SelectOption>();
 for(String s : sortThis){
 options.add(new SelectOption(s,s));
 }
 
return options;
 }
 
public PageReference initFields(){
 lstFieldResult = new List<FieldsWrapper>();
 if(mapObjects.containskey(selectedObject)){
 Schema.SObjectType s = mapObjects.get(selectedObject);
 Schema.DescribeSObjectResult r = s.getDescribe();
 
Map<String, Schema.SObjectField> fields = r.fields.getMap() ;
 Set<String> fieldnames = fields.keySet();
 List<String> fieldList = new List<String>();
 fieldList.addAll(fieldNames);
 fieldList.sort();
 String fName = '';
 for(integer i=0; i<fieldList.size(); i++){
 fName = fieldList[i];
 if(fName.endswith('__c')){ //only include the custom fields
 FieldsWrapper field = new FieldsWrapper();
 field.FieldApiName = fName;
 field.isUsed = hasReferences(fName);
 lstFieldResult.add(field);
 }
 }
 }
 return null;
 }
 
private boolean hasReferences(string fieldName){
 Boolean bRet = false;
 for(ApexClass cls:lstClasses){
 if(cls.body.contains(fieldName)){
 bRet = true;
 break;
 }
 }
 
if(!bRet){
 for(ApexPage pg:lstPage){
 if(pg.Markup.contains(fieldName)){
 bRet = true;
 break;
 }
 }
 }
 
if(!bRet){
 for(ApexTrigger trg:lstTrigger){
 if(trg.Body.contains(fieldName)){
 bRet = true;
 break;
 }
 }
 }
 
if(!bRet){
 for(ApexComponent com:lstComponent){
 if(com.Markup.contains(fieldName)){
 bRet = true;
 break;
 }
 }
 }
 
return bRet;
 }
 
public class FieldsWrapper{
 public string FieldApiName {set; get;}
 public string FieldLabel {set; get;}
 public boolean isUsed {set; get;}
 }
 
}