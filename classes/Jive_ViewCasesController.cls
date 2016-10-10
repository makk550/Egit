public without sharing class Jive_ViewCasesController {

	private final Case myCase;
    List<contact> tempContacts;
    public Contact tempContact {get;set;}
    User tempUser; 
    public String selectedField {get;set;}
    public String filterSubject{get; set;}
    public String filterCaseNumber{get; set;}
    //pagination variables
    public Integer totalRecs = 0;
    public Integer offsetSize = 0;
    public Integer limitSize = 20;

    //Filtering Picklist properties
    public String filterStatus{get;set;}
    public String testString{get;set;}
    public String testString2{get;set;}
    public String filterSeverity{get;set;}
    public String filterProduct{get;set;}
    public Date dateName{get;set;}
    public ObjWithDateField__c objForStartDate{get;set;}{objForStartDate = new ObjWithDateField__c();}
    public ObjWithDateField__c objForEndDate{get;set;}

    //Filtering picklist variables
    String tempFilterStatus;
    String tempCaseNumber;
    String tempSubject;
    String tempFilterSeverity;
    String tempFilterProduct;
    String startTime = 'T00:00:00.000Z';
    String endTime = 'T23:59:59.999Z';
    DateTime tempStartDate; 
    DateTime tempEndDate = system.now();
    //Datetime testDateTime = system.now();
    //String testDateTimeString = string.valueof(testDateTime);

    //Set<Case> productsList = new set<Case>([select myCase.CA_Product_Controller__c from Case myCase]);

    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Jive_ViewCasesController(ApexPages.StandardController stdController) {
        this.myCase = (Case)stdController.getRecord();
        //objForStartDate = new ObjWithDateField__c();
        objForEndDate = new ObjWithDateField__c();
    }

    public String getRecordName() {
        return 'Hello ' + (String)myCase.get('name') + ' (' + (Id)myCase.get('Id') + ')';
    }

    public void setContactId(){
        tempContacts = [SELECT Id
                         FROM Contact
                         WHERE email = : userinfo.getUserEmail() 
                         LIMIT 1]; 
        tempContact = tempContacts.get(0);
        
        //tempUser = [SELECT Id, LDAP_Id__c 
        //                FROM User
        //                WHERE id = :userinfo.getUserId()];

        //if(tempUser.LDAP_Id__C != null){
        //    tempContact = [SELECT Id
        //                   FROM Contact
        //                   WHERE SC_CONTACT_LDAPID__c = : tempUser.LDAP_Id__c ];

        //} 
    }

    public ApexPages.StandardSetController CaseRecords {
        get {
            if(CaseRecords == null) {
                setContactId(); 
                if(tempContact != null){  
                    totalRecs = [SELECT count() from Case myCase WHERE mycase.ContactId = : tempContact.Id];               
                    CaseRecords = new ApexPages.StandardSetController(
                         [SELECT myCase.CaseNumber, myCase.Title__c, myCase.Description, myCase.Status, myCase.Severity__c,
                          myCase.CA_Product_Controller__c, myCase.Business_Impact__c, myCase.CreatedDate, myCase.Contact.Email, myCase.Subject, myCase.Id, myCase.LastModifiedDate 
                          FROM Case myCase 
                          WHERE myCase.ContactId = : tempContact.Id 
                          ORDER BY myCase.CreatedDate DESC]); 
                
                List<Case> myCases = [SELECT myCase.CreatedDate
                          FROM Case myCase 
                          WHERE myCase.ContactId = : tempContact.Id 
                          ORDER BY myCase.CreatedDate ASC];
                Case caseFirstCase = myCases.get(0);
                tempStartDate = caseFirstCase.CreatedDate;
                }
            }
            return CaseRecords;
            }
            private set;
    }
 


    public List<Case> cases {
        get {
            if(CaseRecords != null){
                return (List<Case>) CaseRecords.getRecords();
            }else{
                return null;
            }
         }
    }

    public Case openCase() {
        return myCase;
    }    

    private String sortDirection = 'ASC';
    private String sortExp = 'name';

    public String sortExpression{
         get
         {
            return sortExp;
         }
         set
         {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp){
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           }
           else{
             sortDirection = 'ASC';
             sortExp = value;
           }
         }
    }    


    public String getSortDirection() {
        if (sortExpression == null || sortExpression == ''){
            return 'ASC';
        }else{
             return sortDirection;
        }
    }

    public void setSortDirection(String direction) {
        sortDirection = direction;
    }

    public void viewCases() {
        
        Id tempId = tempContact.Id;
        String sortFullExp = sortExpression  + ' ' + sortDirection;
        CaseRecords = new ApexPages.StandardSetController(Database.getQueryLocator('Select myCase.CaseNumber, myCase.Title__c, myCase.Description, myCase.Status, myCase.Severity__c, myCase.CA_Product_Controller__c, myCase.Business_Impact__c,' 
          + 'myCase.CreatedDate, myCase.Contact.Email, myCase.Subject, myCase.Id, myCase.LastModifiedDate FROM Case myCase  WHERE myCase.ContactId = : tempId order by  ' + sortFullExp ));
    }

 
    public void previous(){
          
          if(OffsetSize >= limitSize){
              OffsetSize = OffsetSize - LimitSize;
              CaseRecords = new ApexPages.StandardSetController(
                             [SELECT myCase.CaseNumber, myCase.Title__c, myCase.Description, myCase.Status, myCase.Severity__c,
                              myCase.CA_Product_Controller__c, myCase.Business_Impact__c, myCase.CreatedDate, myCase.Contact.Email, myCase.Subject, myCase.Id, myCase.LastModifiedDate
                              FROM Case myCase 
                              WHERE myCase.ContactId = : tempContact.Id 
                              ORDER BY myCase.CreatedDate DESC LIMIT :limitSize OFFSET :offsetSize]);
          }
    }

    public void next(){
          OffsetSize = OffsetSize + LimitSize;
          CaseRecords = new ApexPages.StandardSetController(
                         [SELECT myCase.CaseNumber, myCase.Title__c, myCase.Description, myCase.Status, myCase.Severity__c,
                          myCase.CA_Product_Controller__c, myCase.Business_Impact__c, myCase.CreatedDate, myCase.Contact.Email, myCase.Subject, myCase.Id, myCase.LastModifiedDate 
                          FROM Case myCase 
                          WHERE myCase.ContactId = : tempContact.Id 
                          ORDER BY myCase.CreatedDate DESC LIMIT :limitSize OFFSET :offsetSize]);
    }

    public boolean getPrev(){
        if(OffsetSize == 0)
            return true;
        else
            return false;
    }

    public boolean getNxt(){
        if((OffsetSize + LimitSize) > totalRecs)
            return true;
        else
            return false;
    }

    public void setFilter(){
          setFilterParameters();
          CaseRecords = new ApexPages.StandardSetController(
                         [SELECT myCase.CaseNumber, myCase.Title__c, myCase.Description, myCase.Status, myCase.Severity__c,
                          myCase.CA_Product_Controller__c, myCase.Business_Impact__c, myCase.CreatedDate, myCase.Contact.Email, myCase.Subject, myCase.Id, myCase.LastModifiedDate 
                          FROM Case myCase 
                          WHERE myCase.ContactId = :tempContact.Id 
                          AND myCase.Subject LIKE :tempSubject
                          AND myCase.CaseNumber LIKE :tempCaseNumber
                          AND myCase.Status LIKE :tempFilterStatus
                          AND myCase.Severity__c LIKE :tempFilterSeverity
                          AND myCase.CA_Product_Controller__r.Name LIKE :tempFilterProduct
                          AND myCase.CreatedDate > :tempStartDate AND myCase.CreatedDate < :tempEndDate
                          ORDER BY myCase.CreatedDate DESC ]);
          tempSubject=filterSubject;
          tempCaseNumber=filterCaseNumber;      
          //testString = tempCaseNumber;
    }

    public void setFilterParameters(){
      //variables
      String convertEndDate;
      String convertStartDate;


      tempCaseNumber = '%' + filterCaseNumber + '%';
      tempSubject = '%' + filterSubject + '%';
      //tempStartDate =  objForStartDate.DateField__c + '';
      //tempStartDate = tempStartDate.substring(0,10) + startTime;
     
      if(objForEndDate.DateField__c != null){
        convertEndDate = objForEndDate.DateTimeField__c + '';
        convertEndDate = convertEndDate.substring(0,10) + endTime;
        tempEndDate = datetime.valueOf(convertEndDate);
      }

      if(objForStartDate.DateField__c != null){
        convertStartDate = objForStartDate.DateTimeField__c + '';
        convertStartDate = convertStartDate.substring(0,10) + startTime;
        tempStartDate = datetime.valueOf(convertStartDate);
      }
      
      //testString2 = string.valueof(objForStartDate.DateField__c);
      //DateTime myDate = datetime.valueOf(testString2);

      if(filterStatus == 'All'){
        tempFilterStatus = '%';
        testString = tempFilterStatus;
      }else{
        tempFilterStatus = filterStatus;
      }

      if(filterSeverity == 'All'){
        tempFilterSeverity = '%';
      }else{
        tempFilterSeverity = filterSeverity;
      }

      if(filterProduct == 'All'){
        tempFilterProduct = '%';
      }else{
        tempFilterProduct = filterProduct;
      }
    }

    //picklist Status methods

     public List<SelectOption> getFilterStatusItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('All','All'));
            options.add(new SelectOption('Open','Open'));
            options.add(new SelectOption('Closed','Closed'));
            return options;
     }

      public String getFilterStatus() {
            return filterStatus;
        }
            
        public void setFilterStatus(String filterStatus) {
            this.filterStatus = filterStatus;
        }

    //picklist Severity Methods
    public List<SelectOption> getFilterSeverityItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('All','All'));
            options.add(new SelectOption('1','1'));
            options.add(new SelectOption('2','2'));
            options.add(new SelectOption('3','3'));
            options.add(new SelectOption('4','4'));
            return options;
            }

      public String getFilterSeverity(){
        return filterSeverity;
      }

      public void setFilterSeverity(String filterSeverity){
        this.filterSeverity = filterSeverity;
      }

      //Picklist product methods

      public List<SelectOption> getFilterProductItems() {
              
            if(totalRecs > 0){
                List<Case> productsList = new list<Case>([select myCase.CA_Product_Controller__r.name FROM Case myCase 
                              WHERE myCase.ContactId = : tempContact.Id ]);
                List<String> finalProductsList = getDistinctProducts(productsList);  
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('All','All'));
                
                for(String product : finalProductsList){

                  //options.add(new SelectOption(product.CA_Product_Controller__r.Name, product.CA_Product_Controller__r.Name));   
                  options.add(new SelectOption(product, product));            
                }  
                //return options;
                return options;
            }else{
                return null;
            }
      }

  


      public List<String> getDistinctProducts(List<Case> duplicates){

          //List<Case> distinctProducts = new List<Case>();
          List<String> distinctProducts = new List<String>();
          String tempString;
          if( totalRecs > 0){
          for(Case product: duplicates){

              tempString = product.CA_Product_Controller__r.Name;
              Boolean found = false;

              for(Integer i=0; i< distinctProducts.size(); i++){

              if(tempString.equalsIgnoreCase(distinctProducts[i])){ //Check if current lastname has been added yet
                found=true;

              break;
              }
              }
              if(!found)
              distinctProducts.add(product.CA_Product_Controller__r.Name);
          }
            return distinctProducts;
          }else{
            return null; 
          }

      }

      public String getFilterProduct(){
        return filterProduct;
      }

      public void setFilterProduct(String filterSeverity){
        this.filterProduct = filterProduct;
      }



}