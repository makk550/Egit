public without sharing class Jive_CreateCaseController {

	//private final Case newCase;
    User tempUser;
    //Id tempSiteId = '105246'
    Id tempProdId = 'a7Z180000004CtmEAE';
    Id tempSiteAssoc = 'a26180000013gsWAAQ';
    //Id tempContactId = '0031800000B05DWAAZ';
    Id tempContactId;

    List<contact> tempContacts;
    Contact tempContact;
    CA_Product_Component__C myComponent = new CA_Product_Component__C(Name= 'Datacom',
      CA_Product_Controller__c = tempProdId,
      Default_Component_for_this_CA_Product__c = true,
      component_expiration_date__c = Date.today().addDays(1));


    public String printCaseResult { get; private set; }
    public String productReleaseSelection{get;set;}
    public String productOperatingSystem{get;set;}
    public String productServicePack{get;set;}
    public String myRender {get;set;}{myRender = 'false';}

    public Id myCaseId {get;set;}
    public String testString {get;set;}
    public Boolean descriptionVisible{get;set;}{descriptionVisible = false;}


    String tempOrigin = 'Customer Portal';
    String tempType = 'Standard';
    String tempProduct = 'Datacom';

    CC_ngTurkeyService turkey = new CC_ngTurkeyService();




    //public Case newCase {
    //    get {
    //      if (newCase == null)
    //        newCase = new Case();
    //      return newCase;
    //    }
    //    set;
    //}

    public Case newCase {get; set;}

    //public Case setNewCaseDate(Case temp){
    //    this.newCase = temp;
    //    return newCase;
    //}

    public Jive_CreateCaseController(ApexPages.StandardController stdController) {
        this.newCase = (Case)stdController.getRecord();
       //newCase = new Case();
    }


    public void printCase() {
        printCaseResult = JSON.serializePretty(newCase);
    }

    //public void setTempUser(){
    //    tempUser = [SELECT id, contact.id
    //                FROM User
    //                WHERE id = : userinfo.getUserid()];
    //}

    //public void setContactId(){
    //    tempContacts = [SELECT Id
    //                     FROM Contact
    //                     WHERE email = : userinfo.getUserEmail()
    //                     LIMIT 1];
    //    tempContact = tempContacts.get(0);

    //}


        public void setContactId(){

            tempUser = [SELECT Id, LDAP_Id__c
                            FROM User
                            WHERE id = :userinfo.getUserId()];
            if(tempUser.LDAP_Id__C != null){
                tempContact = [SELECT Id
                               FROM Contact
                               WHERE SC_CONTACT_LDAPID__c = : tempUser.LDAP_Id__c ];

            }
        }




    public PageReference createCase() {

        setContactId();

        Case insertCase = new Case();
        insertCase.Subject = newCase.Subject;
        insertCase.Severity__C = newCase.Severity__C;
        insertCase.Description = newCase.Description;
        insertCase.Business_Impact__C = newCase.Business_Impact__C;
        //insertCase.Product_Release_Selection__c = productReleaseSelection;
        //insertCase.Product_Service_Pack_Selection__c = productServicePack;
        //insertCase.Product_Operating_System__c = productOperatingSystem;

        //Testing some required values
        insertCase.Origin = tempOrigin;
        insertCase.Case_Type__C = tempType;
        insertCase.CA_Product_Controller__c  = tempProdId;
        insertCase.Site_Association__C = tempSiteAssoc;
        insertCase.ContactId = tempContact.id;

        
        

        if(insertCase.Description != ''){

            //insert myComponent;
        //  insert insertCase;
        insert myComponent;
        turkey.createCase(insertCase);
        PageReference redirectPage = Page.Jive_ViewSingleCase;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id', insertCase.Id);
        redirectPage.getParameters().put('showCaseCreatedMessage', 'true');
        return redirectPage;
        }else{
            descriptionVisible = true;
            return null;
        }
        

    }



    public void updateCase(Case aCase){
        aCase.Description = aCase.Description + 'Testing callback';
        update aCase;
    }

}