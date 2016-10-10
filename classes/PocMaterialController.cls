public with sharing class PocMaterialController {
    
    @TestVisible
    private Trial_Request__c poc;

    public boolean ifNoError {get; set;}
    public List<ckProduct> ckProductList {
        get {
            if (ckProductList == null) {
                ckProductList = new ckProduct[]{};
            }
            return ckProductList;
        } 
        set;
    }
    public boolean isViewMode {get; set;}
    public List<ckProduct> currentPocProductMaterials {get; set;}  

    // CTOR
    @TestVisible
    private PocMaterialController(){}

    public PocMaterialController(ApexPages.StandardController controller) {
        controller.addFields(new String[]{'Id', 'Name', 'Opp_Name__c'});
        this.poc = (Trial_Request__c)controller.getRecord();
        init();
    }

    public void editMaterialSelection() {
        isViewMode = false;
    }

    public void cancel() {
        isViewMode = true;
    }

    // handle the action of the commandButton
    public void saveMaterialSelection() {
        // existing pocmaterials on this trial request - we delete all of these
        List<pocMaterial__c> pocProducts = [Select Id from pocMaterial__c where POC_Request__c=:poc.id];
        delete pocProducts;

        // a reference to our trial request.
        List<Trial_Request__c> trRequest = new List<Trial_Request__c>();
        trRequest  =  [Select Id,Materials_For_Email__c,Products_Added__c   from Trial_Request__c where Id =:poc.id];
        trRequest[0].Products_Added__c = -1; // why do this?
        update trRequest;

        // add product materials selected for trials to a list of pocMaterials to save
        List<pocMaterial__c> pmsToSave = buildPmsToSave();

        // save poc materials, if any
        if(pmsToSave.size() > 0) {
            insert pmsToSave;
            trRequest[0].Products_Added__c = pmsToSave.size();
            update trRequest;
            isViewMode = true;
        } 
        // if there are no poc materials to save then do this.
        else {
            trRequest[0].Products_Added__c = 0; // did they mean to save this?
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Materials selected to save.'));
            ifNoError = true;
        }

        FetchTransactionalProducts();
    }   

    private pocMaterial__c[] buildPmsToSave() {
        // add product materials selected for trials to a list of pocMaterials to save
        List<pocMaterial__c> pmsToSave = new List<pocMaterial__c>();
        for(ckProduct selprod: ckProductList){
            for(ckProductMaterial selprodmaterial: selprod.pms){
                if(selprodmaterial.selected){ 
                    pocMaterial__c prodmaterial = new pocMaterial__c();
                    //List<Product2> p = [select Id from Product2 where Id=:selprod.product.Id limit 1];
                    prodmaterial.Product__c = selprod.product.Id;
                    prodmaterial.quantity__c = selprodmaterial.qty;
                    prodmaterial.Product_Material__c = selprodmaterial.materialId;
                    prodmaterial.POC_Request__c = poc.Id;
                    pmsToSave.add(prodmaterial);
                }
            }
        }
        return pmsToSave;
    }

    @TestVisible
    private void init() {
        ifNoError = true;
        ckProductList = new List<ckProduct>();
        //poc = [Select Id, Name, Opp_Name__r.Id from Trial_Request__c where Id=:poc.id];
        
        Boolean viewMaterial = false;

        // phase 1 - Opportunity configuration - build ckProductList
        Opportunity o = [Select Id, Name, (Select PriceBookEntry.Product2Id, PricebookEntry.Product2.Name From OpportunityLineItems) from Opportunity where Id=:poc.Opp_Name__c];    
        List<OpportunityLineitem> ols = o.OpportunityLineItems;
        List<pocMaterial__c> tPocProductMaterials = [Select Id, quantity__c, Product_Material__r.Id, Product_Material__r.Material_Text__c, Product__r.Id, Product__r.Name from pocMaterial__c where POC_Request__c=:poc.id]; 
            
        //build set of productIDs
        Set<Id> productIdSet = new Set<Id>();
        for(OpportunityLineitem ol : ols){
            productIdSet.add(ol.PriceBookEntry.Product2Id);
        }

        //build product map
        Map<Id, Product2> products = buildProductMap(productIdSet);
        Map<Id, List<Product_Material__c>> materialMapByProductId = buildMaterialMap(productIdSet);

        system.debug(ols.size()+'   ols size1*****');
        for(OpportunityLineitem ol : ols) {                
            ckProduct prod = new ckProduct();                
            Product2 product = products.get(ol.PriceBookEntry.Product2Id);
            prod.product = product;
            List<Product_Material__c> materials = materialMapByProductId.get(product.Id); //[select Id, Material_Text__c, Source_System__c, SAP_Product_Mapping__c, Product__r.Id, Product__r.Name from Product_Material__c where Product__r.Id = :prod.product.Id and Source_System__c = 'SAP' and POC_Eligible__c = True];  

            system.debug(materials.size()+'material size1*****');

             //Populate for Edit mode        
             for (Product_Material__c mat : materials) {
                ckProductMaterial prodm = new ckProductMaterial();                        
                prodm.materialId = mat.Id;            
                prodm.materialName = mat.Material_Text__c;    
                prodm.saptopsid = mat.SAP_Product_Mapping__c;
                if (tPocProductMaterials.size() > 0 ) {   
                    prodm.selected = false;           
                }       
                for(pocMaterial__c currentpocmitem: tPocProductMaterials) {
                    system.debug('condition -->' + currentpocmitem.Product_Material__r.Id + '=='+ mat.Id);
                    if(currentpocmitem.Product_Material__r.Id == mat.Id) {                  
                        prodm.selected = true;                   
                        prodm.qty = currentpocmitem.quantity__c;
                    }               
                } 
                prod.pms.add(prodm);        
                viewMaterial = true ;   
            }
            if(materials.size() > 0) {
                ckProductList.add(prod);
            }
            system.debug('sadfds --> ' +  ckProductList);
        }

        // phase 2 - build currentPocProductMaterials
        FetchTransactionalProducts();

        // error handling
        system.debug('material size*****');
        if(ols.size()==0||ols==null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Products added to the opportunity'));
            ifNoError = false;
        } else if(viewMaterial == false) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Product not marked POC eligible in SFDC, please contact GlobalPOCTeam@ca.com'));
            ifNoError = false;
        }
    }

    @TestVisible
    private Map<Id, Product2> buildProductMap(Set<Id> productIds) {
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        // populate map from SOQL
        List<Product2> products = [select Id, Name from Product2 where Id in :productIds];
        productMap.putAll(products);
        return productMap;
    }

    @TestVisible
    private Map<Id, List<Product_Material__c>> buildMaterialMap(Set<Id> productIds){
        Map<Id, List<Product_Material__c>> materialMap = new Map<Id, List<Product_Material__c>>();
        for (Id productId : productIds) {
            materialMap.put(productId, new List<Product_Material__c>());
        }

        //Select materials for each product in set
        List<Product_Material__c> materials = [select Id, Material_Text__c, Source_System__c, SAP_Product_Mapping__c, Product__r.Id, Product__r.Name from Product_Material__c where Product__r.Id IN :productIds and Source_System__c = 'SAP' and POC_Eligible__c = True];

        //add materials to materialMap
        for(Product_Material__c material : materials){
            List<Product_Material__c> updateMaterialList = materialMap.get(material.Product__r.Id);
            updateMaterialList.add(material);
        }
        return materialMap;
    }

    private void FetchTransactionalProducts() {
        currentPocProductMaterials = new List<ckProduct>();            
        List<AggregateResult> currentProducts = [Select Product__r.Id, Product__r.Name  from pocMaterial__c where POC_Request__c=:poc.id group by Product__r.Id, Product__r.Name];        
        List<pocMaterial__c> currentProductMaterials = [Select Product__r.Id, Product__r.Name, Product_Material__r.Id, Product_Material__r.Material_Text__c, Product_Material__r.Source_System__c, Product_Material__r.SAP_Product_Mapping__c, quantity__c from pocMaterial__c where POC_Request__c=:poc.id]; 
        //ckProduct prod = new ckProduct();                
        for (AggregateResult aprod : currentProducts) {
            ckProduct tprod = new ckProduct();
            Product2 p = new Product2();
            p.Id = (String) aprod.get('Id');
            p.Name = (String) aprod.get('Name');
            tprod.product = p;
            for (pocMaterial__c tprodmat : currentProductMaterials) {
                if (p.Id == tprodmat.Product__r.Id) {
                    ckProductMaterial prodm = new ckProductMaterial();
                    prodm.materialId = tprodmat.Product_Material__r.Id;
                    prodm.materialName = tprodmat.Product_Material__r.Material_Text__c;
                    prodm.src = tprodmat.Product_Material__r.Source_System__c;
                    prodm.saptopsid = tprodmat.Product_Material__r.SAP_Product_Mapping__c;
                    prodm.qty = tprodmat.quantity__c;
                    tprod.pms.add(prodm);
                }           
            }                       
            currentPocProductMaterials.add(tprod);                   
        }                
        if(currentPocProductMaterials.size() > 0) {
            isViewMode = true;        
        } else {
            isViewMode = false;               
        }    
    }

    public class ckProduct{   
        public Product2 product {get; set;}        
        public List<ckProductMaterial> pms {get; set;}  

        public ckProduct (){        
            pms = new List<ckProductMaterial>();     
        }
    }

    public class ckProductMaterial{    
        public String materialId {get; set;}    
        public String materialName {get; set;}    
        public String src {get; set;}    
        public String saptopsid {get; set;}            
        public Decimal qty {get; set;}    
        public boolean selected {get; set;}                         
        public ckProductMaterial(){       
            this.selected = false;              //// requirement that all the mateirals to be unchecked by defualt      
            this.qty = 1;     
            this.saptopsid = 'nbjmd';
        }
    }
}