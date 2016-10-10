global class LiveAgentPreChatFormController {
    
    
    @RemoteAction
    global static String getSiteId(String siteTopId) { 
        System.debug('siteTopId*****'+siteTopId);
        List<Site_Association__c> site = new  List<Site_Association__c> () ;
        if(siteTopId!=null && siteTopId!='')
            site = [select id,SC_TOPS_ID__c from Site_Association__c  where SC_TOPS_ID__c =: siteTopId];           
     
        if(!site.isEmpty())
            return site[0].Id;
        else
            return ('null');
        
        
    }
    
    @RemoteAction
    global static String getProductId(String proName) { 
        List<CA_Product_Controller__c> products = [select id,Name from CA_Product_Controller__c  where Name =: proName];
        if(!products.isEmpty()){
            return products[0].Id;
        }
        else{ 
            return ('null');
        }
    }
    
    @RemoteAction
    global static String getCAProductController(String topsCode) { 
        System.debug('topsCode*****'+topsCode);
        List<Product_Material__c> materials = new List<Product_Material__c>();
        if(topsCode!=null && topsCode!='')
            materials = [SELECT Id,CA_Product_Controller__c FROM Product_Material__c where Name = : topsCode ];
        if(!materials.isEmpty()){
            return materials[0].CA_Product_Controller__c+'='+materials[0].id;
           //return materials[0].CA_Product_Controller__c;
        }
        else{ 
            return ('null');
        }
    }
    
    @RemoteAction
    global static String getCAProductComponent(String controllerId) { 
        List<CA_Product_Component__c> components = new List<CA_Product_Component__c> ();
        if(controllerId!=null && controllerId!='')
        components = [SELECT ID FROM CA_Product_Component__c where CA_Product_Controller__c =: controllerId and Default_Component_for_this_CA_Product__c = True ];
        if(!components.isEmpty()){
            return components[0].Id;
        }
        else{ 
            return ('null');
        }
    }
    
    @RemoteAction
    global static String getContactId(String connectID) { 
        List<Contact> contacts = new  List<Contact>();
        String Id;
        if(connectID!=null && connectID!=''){
            if (connectId.isNumeric()){
                contacts = [Select ID from Contact where SC_CONTACT_LDAPID__c =: connectID];
                if(!contacts.isEmpty()){
                    id = contacts[0].Id + '#contact';
                }
            }else{
                for(User user : [Select id from user where PmfKey__c =:connectID ]){
                    Id  = user.id +'#user';
                }
            }
            
            if(id ==null){
                id= 'null';
            }
            
            return id;
        }else{ 
            return ('null');
        }
    }
}