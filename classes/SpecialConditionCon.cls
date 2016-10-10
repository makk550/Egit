public class SpecialConditionCon{
    
    public List<Special_Conditions__c> specialConList{get;set;}
    public String selectedSpecId{get;set;}
    public Site_Association__c siteAss{get;set;}
    Integer QueryLimit = 10;
    public Boolean Enable{get;set;}
    
    public SpecialConditionCon(ApexPages.StandardController controller) {
      Enable =true;
      List<String> fieldsToAdd = new List<String>();
      fieldsToAdd.add('Name');
       if (!Test.isRunningTest()) {
          controller.addFields(fieldsToAdd);
      }
      siteAss= (Site_Association__c)controller.getRecord();
      
      LoadData();
      
    }
    private void LoadData() {
        specialConList = [SELECT Active__c,End_Date__c,Id,LastModifiedBy.name,LastModifiedById,LastModifiedDate,Name,Site_Association__c,SPC_Description__c,SPC_Details__c,Special_Condition__c,
                            Start_Date__c FROM Special_Conditions__c where Site_Association__c =: apexpages.currentpage().getparameters().get('Id') ORDER BY Active__c DESC, Start_Date__c ASC limit :QueryLimit];
        
       
        
    }
    
    public PageReference showmore(){
        QueryLimit =10000;
        Enable=false;
        LoadData();
        return null;
    }
   public pagereference doDelete() {
       if(selectedSpecId !=null){
          delete[select Id from Special_Conditions__c where id =:selectedSpecId];
       }
   
      //refresh the data
      LoadData();
     return null;
      
   }
   
  



}