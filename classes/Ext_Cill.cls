public without sharing class Ext_Cill {
    
    public  List<account> lstGlobal{get;set;}
    public string accid{get;set;}
    public account acc {get;set;}
    public List<Active_Contract_product__c> lstACP {get;set;}
    public List<SelectOption> prodcsus {get;set;}
    public id delid {get;set;}
      
    public Set<String> gbus {get; set;}
      
    //Filters
    public List<string> prodgroup{get;set;}
    public List<string> prods{get;set;}
    public List<string> csu{get;set;}
    public List<String> drivers{get;set;}
    
    public List<SelectOption> prodgroups{get;set;}
    public List<SelectOption> products{get;set;}
    public List<SelectOption> csus{get;set;}
    public List<SelectOption> driverOptions{get;set;}
   
    //private List<Account_Competitor_Install__c> lstACI;    
    public  List<WrapACI> lstWrap{get;set;}
    public  List<WrapACP> lstWrapACP{get;set;} 
    private  Map<id,WrapACP> mapWrapACP; //For building the ACP List Grouped by the Product;
    public List<Active_Contract_product__c> lstACPGroupedByProduct {get;set;}
    public boolean dispayglobalpg{get;set;}  
    public integer totalpagesglobal{get;set;}
  
  
  public pagereference prevglobal()
  {
      pgno_acc--;
      return null;
  }
  
  public pagereference nextglobal()
  {
      pgno_acc ++;
      return null;
  }
  
  
    
  public pagereference delAccInstall()
  {
      //if(delid <> null)
      {
          Account_Competitor_Install__c aci = new Account_Competitor_Install__c(id = delid);
          delete aci;
          delid  = null;
          populateACI();
      }
      
      return null;
  
  }  
    
    
  
   public void populatelstACPGroupedByProduct()
  {
      List<Active_Contract_Product__c> lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c 
                  FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today()
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
      
      populateLogic(lst);
        
  } 
  
  
   public void populateLogic(List<Active_Contract_Product__c> lst )
   {
        mapWrapACP = new  Map<id,WrapACP>();
      
        Set<string> setprodname;
        Set<string> setprodgroup;
        Set<string> setcsu;
        Set<string> setdriver;
          
        if(products == null)
            {products = new List<SelectOption>();
            setprodname = new Set<string>();}
        if(prodgroups == null)    
            {prodgroups= new List<SelectOption>();
            setprodgroup= new Set<string>();}
        if(csus == null)
            {csus= new List<SelectOption>();
            setcsu= new Set<string>(); }
        if(driverOptions == null)
            {driverOptions= new List<SelectOption>();
            setdriver= new Set<string>(); }
            
         List<id> lstsortedproductid = new List<id>();
              
        
         
       if(lst <> null && lst.size() > 0)
       {
            Map<string,id> mprodname = new Map<string,id>();
            List<string> prod_temp = new List<string>();
            List<string> prodgroup_temp = new List<string>();
            List<string> csu_temp = new List<string>();
            List<string> driver_temp = new List<string>();   
       
       
            List<Active_Contract_Product__c> lst_temp;
            WrapACP w;
            
            for(Active_Contract_Product__c a: lst)
            {
                //Wrap Logic Start
                    w = mapWrapACP.get(a.Product__c);
                    if(w <>  null)
                        lst_temp = w.lstACP;
                    else
                    {
                        lst_temp = new List<Active_Contract_Product__c>();
                        lstsortedproductid.add(a.Product__c);
                     }    
                
                    lst_temp.add(a);
                    
                    w = new WrapACP(lst_temp);
                    mapWrapACP.put(a.Product__c, w);
                //Wrap Logic End
                
                //Filter Logic Start
                 
                
                if(setprodname <> null && !setprodname.contains(a.Product__c))
                    {
                        setprodname.add(a.Product__c);
                        prod_temp.add(a.Product__r.Name);
                        mprodname.put(a.Product__r.Name,a.Product__c);
                    }
                if(setprodgroup <> null && !setprodgroup.contains(a.Product__r.Product_Group__c))
                    {
                        setprodgroup.add(a.Product__r.Product_Group__c);
                        prodgroup_temp.add(a.Product__r.Product_Group__c);
                    }    
                   
                if(setcsu <> null && !setcsu.contains(a.Product__r.csu2__c))
                    {
                        setcsu.add(a.Product__r.csu2__c);
                        csu_temp.add(a.Product__r.csu2__c);
                    }
                if(setdriver <> null && !setdriver.contains(a.Product__r.CSU_Driver__c))
                    {
                        setdriver.add(a.Product__r.CSU_Driver__c);
                        driver_temp.add(a.Product__r.CSU_Driver__c);
                    }
                    
                //Filter Logic End  
            }
            
            
                if(prod_temp.size() > 0)
                {   
                 prod_temp.sort();
                 for(string selopt:prod_temp)
                 {    products.add(new SelectOption(mprodname.get(selopt),selopt)); 
                 }
                }    
                 
                if(prodgroup_temp.size() > 0)
                {   
                 prodgroup_temp.sort();
                 for(string selopt:prodgroup_temp)
                 {    prodgroups.add(new SelectOption(selopt,selopt)); 
                 }
               }
                
                if(csu_temp.size() > 0)
                {   
                 csu_temp.sort();
                 for(string selopt:csu_temp)
                 {    csus.add(new SelectOption (selopt,selopt)); 
                 }  
                }
                
                if(driver_temp.size() > 0)
                {   
                 driver_temp.sort();
                 for(string selopt:driver_temp)
                 {    driverOptions.add(new SelectOption (selopt,selopt)); 
                 }  
                }
                
        }
        
        //lstWrapACP = mapWrapACP.values();
        lstWrapACP = new List<WrapACP>();
        for(id pid:lstsortedproductid)
            lstWrapACP.add(mapWrapACP.get(pid));
   }    
  
        
        
    public Ext_Cill(ApexPages.StandardController controller) 
    {
    
        acc = (Account) controller.getRecord();
        accid =ApexPages.CurrentPage().getPArameters().get('id');
        string guns = [select GU_DUNs_NUMBER__c from account where id =:accid].GU_DUNs_NUMBER__c;
        
        if(lstGlobal == null)
        {
            lstGlobal = [Select id, name,Enterprise_ID__c  from Account where GU_DUNs_NUMBER__c =:guns  and GU_DUNs_NUMBER__c <> null ORDER BY Name];
             if(pgno_acc  == null) pgno_acc = 1;
             if(pgsize_acc == null) pgsize_acc = 1000;
            }
            
         if(lstGlobal <> null && lstGlobal.size() > pgsize_acc)
          {  dispayglobalpg = true;
             totalpagesglobal   = (lstGlobal.size()/pgsize_acc ) +1;
           }
           
         if(prodcsus == null)
        {
            Schema.DescribeFieldResult F = Product2.CSU2__c.getDescribe();
            List<Schema.PicklistEntry> P = F.getPicklistValues();
    
            prodcsus = new List<SelectOption>();
            prodcsus.add(new SelectOption ('','--None--')); 
            
            gbus = new Set<String>();
            
            for(Schema.PicklistEntry pe:p)
            {
                prodcsus.add(new SelectOption (pe.getVAlue(),pe.getLabel()));
                gbus.add(pe.getValue());
            } 
        }
 
       
        if(lstWrap == null)
            populateACI();
            
        
        if(lstWrapACP == null)
            populatelstACPGroupedByProduct();
    }
   
   
   
   
   
   public integer pgno_acc{get;set;}
   public integer pgsize_acc{get;set;}
   
   public  List<account> getlstGlobal_paged()
   {
 
       if(lstGlobal <> null && lstGlobal.size() > pgsize_acc)
        { 
            List<account> lst = new List<account>();
            integer i;
            if((pgno_acc-1)*pgsize_acc < lstGlobal.size())
            {
            integer startIndex = (pgno_acc-1)*pgsize_acc; 
            integer stopIndex = startIndex  + pgsize_acc; 
            if(stopIndex  > lstGlobal.size()) 
                stopIndex = lstGlobal.size();
            
            for(i=startIndex; i< stopIndex; i++)
                lst.add(lstGlobal[i]);
            }
                
            return lst;     
        }
       else
           return lstglobal;
       
   }
    public static integer pgno = 1;
   public static integer pgsize = 1000;
   
   public List<WrapACI> getlstWrap_paged()
   {
       if(lstWrap <> null && lstWrap.size() > pgsize)
        { 
            List<WrapACI> lst = new List<WrapACI>();
            integer i;
            if((pgno-1)*pgsize < lstWrap.size())
            {
            integer startIndex = (pgno-1)*pgsize; 
            integer stopIndex = (pgno)*pgsize; 
            if(stopIndex  > lstWrap.size()) stopIndex = lstWrap.size();
            
            for(i=startIndex; i< stopIndex; i++)
                lst.add(lstWrap[i]);
            }
                
            return lst;     
        }
       else
           return lstWrap;
       
   }
   
   
   
  public static integer pgno_acp = 1;
   public static integer pgsize_acp = 1000;
   
  
   public List<WrapACP> getlstWrapACP_paged()
   {
       if(lstWrap <> null && lstWrap.size() > pgsize)
        { 
            List<WrapACP> lst = new List<WrapACP>();
            integer i;
            if((pgno_acp-1)*pgsize_acp < lstWrapACP.size())
            {
            integer startIndex = (pgno_acp-1)*pgsize_acp; 
            integer stopIndex = (pgno_acp)*pgsize_acp; 
            if(stopIndex  > lstWrapACP.size()) 
                stopIndex = lstWrapACP.size();
            
            for(i=startIndex; i< stopIndex; i++)
                lst.add(lstWrapACP[i]);
            }                
            return lst;     
        }
       else
           return lstWrapACP;
       
   }
    
   
    public class WrapACP
    {
        public List<Active_Contract_product__c> lstacp{get;set;}
        public id oldcontact {get;set;}
        public string oldpistatus {get;set;}
        public string oldpa {get;set;}
        public string oldcs {get;set;}
        public string oldcause {get;set;}
        
        public WrapACP(List<Active_Contract_Product__c> lst)
        {
             this.oldContact = lst[0].Contact__c;
             this.oldpistatus = lst[0].Product_Install_Status__c;
             this.oldpa = lst[0].CA_Product_Adoption__c;
             this.oldcs = lst[0].Customer_Satisfaction__c;
             this.oldcause = lst[0].Cause__c;
             
             
            this.lstacp = lst;
        }
    }
    
    
    public class WrapACI
    {
        public Account_Competitor_Install__c  aci{get;set;}
        public List<SelectOption> lstCsu{get;set;}
        public string csu{
            get;
            set{
                System.debug('+++CSU: ' + csu + ' ---> ' + value);
                if(lstDriver == NULL)
                {
                    lstDriver = new List<SelectOption>();
                    lstDriver.add(new SelectOption('','--None--'));
                }
                
                if(value == csu)
                    return;
                
                lstDriver.clear();
                lstDriver.add(new SelectOption('','--None--'));
                
                //Modified as part of  Product picklist updates AR#2193,2194,2195
                if(value == 'API MANAGEMENT'){  //*
                    lstDriver.add(new SelectOption('API Management','API Management'));
                }
                
                else if(value == 'APPLICATION DELIVERY') //*else
                {
                    lstDriver.add(new SelectOption('Application Delivery Other','Application Delivery Other'));
                    lstDriver.add(new SelectOption('Automation','Automation'));
                    lstDriver.add(new SelectOption('Cloud Manager','Cloud Manager'));
                    //lstDriver.add(new SelectOption('Process Automation','Process Automation'));
                    lstDriver.add(new SelectOption('Release Automation','Release Automation'));
                    lstDriver.add(new SelectOption('Service Virtualization','Service Virtualization'));
                    lstDriver.add(new SelectOption('Software Change Manager','Software Change Manager'));
                    lstDriver.add(new SelectOption('Workload Automation','Workload Automation'));
                    
                    lstDriver.add(new SelectOption('Data Mining','Data Mining'));           //*
                    //lstDriver.add(new SelectOption('Client automation','Client automation'));
                    //lstDriver.add(new SelectOption('N/A','N/A'));
                }
                
                else if (value == 'APPLICATION DEVELOPMENT')
                {
                    lstDriver.add(new SelectOption('Application Development','Application Development'));
                }

                else if (value == 'DATA ANALYTICS AND MANAGEMENT')
                {
                    lstDriver.add(new SelectOption('Big Data','Big Data'));
                    lstDriver.add(new SelectOption('Data Analytics and Management','Data Analytics and Management'));
                }
                
                else if (value == 'ENTERPRISE MANAGEMENT') //*
                {
                    //lstDriver.add(new SelectOption('App Synthetic Monitor','App Synthetic Monitor')); //AR#2247
                    lstDriver.add(new SelectOption('Application Delivery Analysis','Application Delivery Analysis'));
                    lstDriver.add(new SelectOption('Application Performance Mgmt','Application Performance Mgmt'));
                    lstDriver.add(new SelectOption('Capacity Manager','Capacity Manager'));
                    //lstDriver.add(new SelectOption('Cloud Service Delivry Platform','Cloud Service Delivry Platform'));
                    lstDriver.add(new SelectOption('DCIM','DCIM'));
                    lstDriver.add(new SelectOption('Ehealth','Ehealth'));
                    //lstDriver.add(new SelectOption('Infrastructure Management','Infrastructure Management'));
                    lstDriver.add(new SelectOption('Infrastructure Mgmt Other','Infrastructure Mgmt Other'));
                    //lstDriver.add(new SelectOption('Mediation Manager','Mediation Manager'));
                    //lstDriver.add(new SelectOption('NETQOS','NETQOS'));
                    lstDriver.add(new SelectOption('Network Flow Analysis','Network Flow Analysis'));
                    lstDriver.add(new SelectOption('Performance Management','Performance Management'));
                    lstDriver.add(new SelectOption('Service Operations Insight','Service Operations Insight'));
                    lstDriver.add(new SelectOption('Spectrum','Spectrum'));
                    lstDriver.add(new SelectOption('Unified Infrastructure Management','Unified Infrastructure Management'));
                    //lstDriver.add(new SelectOption('VAIM','VAIM'));
                    //lstDriver.add(new SelectOption('N/A','N/A'));                   
                }
                else if (value == 'NBI/DOM')
                {
                    //lstDriver.add(new SelectOption('Mobile App Analytics','Mobile App Analytics'));
                    lstDriver.add(new SelectOption('Dev Ops for Mobile','Dev Ops for Mobile'));
                }
                
                /*                
                    else if(value == 'APPLICATION PERFORMANCE MGMT')
                    {
                        lstDriver.add(new SelectOption('APM Cloud Monitor','APM Cloud Monitor'));
                        lstDriver.add(new SelectOption('Application Performance Mgmt','Application Performance Mgmt'));
                    }                
                */
                
                else if(value == 'CLOUD')
                {
                    lstDriver.add(new SelectOption('Applogic','Applogic'));
                    //lstDriver.add(new SelectOption('N/A','N/A'));   //*
                }
                else if(value == 'ERWIN')
                {
                    lstDriver.add(new SelectOption('Erwin','Erwin'));
                    //lstDriver.add(new SelectOption('DM Other','DM Other'));
                    //lstDriver.add(new SelectOption('RM Other','RM Other'));
                }
               /* else if(value == 'INFRASTRUCTURE MANAGEMENT')
                {
                    lstDriver.add(new SelectOption('Capacity Manager','Capacity Manager'));
                    lstDriver.add(new SelectOption('Cloud Service Delivery Platform','Cloud Service Delivery Platform'));
                    lstDriver.add(new SelectOption('DCIM','DCIM'));
                    lstDriver.add(new SelectOption('Ehealth Performance Manager','Ehealth Performance Manager'));
                    lstDriver.add(new SelectOption('Infrastructure Management','Infrastructure Management'));
                    lstDriver.add(new SelectOption('Infrastructure Mgmt Other','Infrastructure Mgmt Other'));
                    lstDriver.add(new SelectOption('Mediation Manager','Mediation Manager'));
                    lstDriver.add(new SelectOption('NETQOS','NETQOS'));
                    lstDriver.add(new SelectOption('Nimsoft Monitoring','Nimsoft Monitoring'));
                    lstDriver.add(new SelectOption('Service Operations Insight','Service Operations Insight'));
                    lstDriver.add(new SelectOption('Spectrum Infrastructure Manager','Spectrum Infrastructure Manager'));
                    lstDriver.add(new SelectOption('VAIM','VAIM'));
                } */
                else if(value == 'IT Business Management')
                {
                    lstDriver.add(new SelectOption('Business Service Insight','Business Service Insight'));
                    lstDriver.add(new SelectOption('Clarity on Demand','Clarity on Demand'));
                    lstDriver.add(new SelectOption('Clarity On Premise','Clarity On Premise'));
                    //lstDriver.add(new SelectOption('Clarity Playbook','Clarity Playbook'));
                    //lstDriver.add(new SelectOption('Executive Playbook','Executive Playbook'));
                    //lstDriver.add(new SelectOption('IT Asset Manager','IT Asset Manager'));
                    //lstDriver.add(new SelectOption('Nimsoft Service Desk','Nimsoft Service Desk'));
                    //lstDriver.add(new SelectOption('PPM Vision','PPM Vision'));
                    //lstDriver.add(new SelectOption('Service Catalog','Service Catalog'));
                    //lstDriver.add(new SelectOption('Service Desk Manager','Service Desk Manager'));                      
                   
                    lstDriver.add(new SelectOption('Cloud Service Management','Cloud Service Management'));   //*
                    lstDriver.add(new SelectOption('ITBM Other','ITBM Other'));
                    //lstDriver.add(new SelectOption('System Z Security', 'System Z Security'));
                    lstDriver.add(new SelectOption('ITSM', 'ITSM'));
                    //lstDriver.add(new SelectOption('N/A','N/A'));                    
                }
                
                else if(value == 'IT MANAGEMENT AND ANALYTICS')
                {
                    lstDriver.add(new SelectOption('IT Management and Analytics','IT Management and Analytics'));
                }
                
                else if(value == 'IT ORCHESTRATION')
                {
                    lstDriver.add(new SelectOption('IT Orchestration','IT Orchestration'));
                    lstDriver.add(new SelectOption('MF Workload Automation','MF Workload Automation'));
                }
                                
                /* else if(value == 'Mainframe')
                {
                    lstDriver.add(new SelectOption('Data Center Modernization','Data Center Modernization'));
                    lstDriver.add(new SelectOption('Enterprise Workload Automation','Enterprise Workload Automation'));
                    lstDriver.add(new SelectOption('System Z Application Development','System Z Application Development'));
                    lstDriver.add(new SelectOption('System Z Automation and Management','System Z Automation and Management'));
                    lstDriver.add(new SelectOption('System Z Cloud and Small Business','System Z Cloud and Small Business'));
                    lstDriver.add(new SelectOption('System Z Data and Analytics', 'System Z Data and Analytics'));
                    lstDriver.add(new SelectOption('System Z Performance Management', 'System Z Performance Management'));
                    lstDriver.add(new SelectOption('System Z Security', 'System Z Security'));
                    //lstDriver.add(new SelectOption('XCOM', 'XCOM'));
                    lstDriver.add(new SelectOption('IT Management','IT Management'));
                    lstDriver.add(new SelectOption('IT Orchestration', 'IT Orchestration'));
                    lstDriver.add(new SelectOption('Application Development', 'Application Development'));
                    lstDriver.add(new SelectOption('Data Management', 'Data Management'));
                    //lstDriver.add(new SelectOption('N/A', 'N/A'));
                } */
                
                else if(value == 'NBI/EMM') //*
                {
                    lstDriver.add(new SelectOption('EMM','EMM'));                   
                    //lstDriver.add(new SelectOption('Enterprise Mobility Suite','Enterprise Mobility Suite'));
                    //lstDriver.add(new SelectOption('Mobile Application Management','Mobile Application Management'));
                    //lstDriver.add(new SelectOption('Mobile Content Management','Mobile Content Management'));
                    //lstDriver.add(new SelectOption('Mobile Device Management','Mobile Device Management'));
                    //lstDriver.add(new SelectOption('Mobile Email Management','Mobile Email Management'));                   
                }
                /*
                else if(value == 'New Business Innovation')
                {
                    lstDriver.add(new SelectOption('Client Automation','Client Automation'));
                    lstDriver.add(new SelectOption('Enterprise Mobility Suite','Enterprise Mobility Suite'));
                    lstDriver.add(new SelectOption('Mobile Application Management','Mobile Application Management'));
                    lstDriver.add(new SelectOption('Mobile Content Management','Mobile Content Management'));
                    lstDriver.add(new SelectOption('Mobile Device Management','Mobile Device Management'));
                    lstDriver.add(new SelectOption('Mobile Email Management','Mobile Email Management'));
                } */
                else if(value == 'Other')
                {
                    lstDriver.add(new SelectOption('N/A','N/A'));
                }
                else if(value == 'NBI/ECOMMERCE') //*
                {                    
                    lstDriver.add(new SelectOption('Ecommerce Advcd Authentication','Ecommerce Advcd Authentication'));
                }
                
                else if(value == 'Security')
                {
                    lstDriver.add(new SelectOption('Advanced Authentication','Advanced Authentication'));
                    //lstDriver.add(new SelectOption('Ecommerce Advcd Authentication','Ecommerce Advcd Authentication'));
                    lstDriver.add(new SelectOption('Identity Mgmt and Govrnce','Identity Mgmt and Govrnce'));
                    //lstDriver.add(new SelectOption('Layer 7 API Security','Layer 7 API Security'));
                    lstDriver.add(new SelectOption('Privileged Identity Management','Privileged Identity Management'));
                    lstDriver.add(new SelectOption('Security Other','Security Other'));
                    //lstDriver.add(new SelectOption('Single Sign on/Siteminder','Single Sign on/Siteminder'));
                    lstDriver.add(new SelectOption('Single Sign On','Single Sign On'));
                    lstDriver.add(new SelectOption('Secure Cloud','Secure Cloud'));
                    //lstDriver.add(new SelectOption('N/A','N/A'));   //*
                }
                else if(value == NULL)
                {
                    //lstDriver.add(new SelectOption('','--None--'));
                }
                else
                {
                    //lstDriver.add(new SelectOption('','--None--'));
                    lstDriver.add(new SelectOption('N/A','N/A'));
                }
                
                if(aci.GBU_Driver__c!= NULL && aci.GBU_Driver__c!='' && initialDriverLoad)
                {
                    if(!containsOption(lstDriver, aci.GBU_Driver__c))
                        lstDriver.add(new SelectOption(aci.GBU_Driver__c, aci.GBU_Driver__c));
                        
                    initialDriverLoad = false;
                }   
                csu = value;
            }
        }
        
        public List<SelectOption> lstDriver{get;set;}
        public string driver{get;set;}
        public boolean initialDriverLoad = true;
        
        public WrapACI(Account_Competitor_Install__c  aci, List<SelectOption> lstCSU)
        {
            this.aci = aci;
            this.csu = this.aci.csu__c;
            this.lstCSU = lstCSU;
            
            this.driver = this.aci.GBU_Driver__c;
        }     
    }
    
    public static boolean containsOption(List<SelectOption> lst, String opt)
    {
        for(SelectOption so : lst)
            if(so.getValue()==opt)
                return true;
                
        return false;
    }
    
    public boolean validationErrorFound=false;
    
    public PageReference saveInfo()
    {
        try{
        if(acc.id <> null)
            update acc; 
        }
        catch(Exception e)
        {
            
        }
       
        List<Active_Contract_Product__c> lstUpdateACP = new List<Active_Contract_Product__c>();
        List<Active_Contract_Product__c> lst_temp;
        Active_Contract_Product__c acp;
        
        for(WrapACP w: lstWrapACP)
        {
                
                lst_temp = w.lstAcp;
                acp = lst_temp[0];
            if(w.oldcontact <> acp.Contact__c ||w.oldpistatus <> acp.Product_Install_Status__c || w.oldpa <> acp.CA_Product_Adoption__c || w.oldcs <> acp.Customer_Satisfaction__c || w.oldcause <> acp.Cause__c)
            {
                for(Active_Contract_Product__c a:lst_temp)
                {
                    
                        a.contact__c = acp.Contact__c;
                        a.Product_Install_Status__c = acp.Product_Install_Status__c;
                        a.CA_Product_Adoption__c = acp.CA_Product_Adoption__c;
                        a.Customer_Satisfaction__c = acp.Customer_Satisfaction__c;
                         a.Cause__c = acp.Cause__c;
                        lstUpdateACP.add(a);
               }   
            }
            
        }
        
        if(lstUpdateACP.size() > 0)
            update lstUpdateACP;
            
        
        List<Account_Competitor_Install__c>  lstACI = new List<Account_Competitor_Install__c>();
        
        validationErrorFound = false;
        integer countRemove = 0;
        for(integer i =0; i < lstWrap.size(); i++)
            {
             // if(lstWrap[i].aci.Top_Competitor__c == null ||lstWrap[i].aci.Competitor_Product__c == null ||lstWrap[i].aci.Renewal_Date__c == null ||lstWrap[i].aci.Number_of_Licenses__c == null 
             //   ||lstWrap[i].aci.Competitor_Product_Install_Stickiness__c == null ||lstWrap[i].aci.Is_there_opportunity_to_replace__c == null ||lstWrap[i].aci.Contact_Support_for_CA__c == null ||lstWrap[i].aci.Contact_Relationship__c == null)
             
             /* if( (lstWrap[i].csu == '' || lstWrap[i].csu == NULL) || (lstWrap[i].driver == '' || lstWrap[i].driver == NULL) || lstWrap[i].aci.Top_Competitor__c == null ||lstWrap[i].aci.Competitor_Product__c == null)
                {
                    if( (lstWrap[i].csu != '' && lstWrap[i].csu != NULL) || (lstWrap[i].driver != '' && lstWrap[i].driver != NULL) || lstWrap[i].aci.Top_Competitor__c != null || lstWrap[i].aci.Competitor_Product__c != null )
                    {
                        lstWrap[i].aci.csu__c = lstWrap[i].csu;
                        lstWrap[i].aci.GBU_Driver__c = lstWrap[i].driver;
                        lstACI.add(lstWrap[i].aci);
                        
                        validationErrorFound = true;
                    }
                }
                 else
                 {
                     lstWrap[i].aci.csu__c = lstWrap[i].csu;
                     lstWrap[i].aci.GBU_Driver__c = lstWrap[i].driver;
                     lstACI.add(lstWrap[i].aci); 
                 }*/
                 
                 if( (lstWrap[i].csu != '' && lstWrap[i].csu != NULL) || (lstWrap[i].driver != '' && lstWrap[i].driver != NULL) || lstWrap[i].aci.Top_Competitor__c != null || lstWrap[i].aci.Competitor_Product__c != null 
                     || lstWrap[i].aci.Renewal_Date__c != null || lstWrap[i].aci.Number_of_Licenses__c != null || lstWrap[i].aci.Competitor_Product_Install_Stickiness__c != null 
                     || lstWrap[i].aci.Is_there_Opportunity_to_Replace__c != null || lstWrap[i].aci.Replace_Reasons__c != null || lstWrap[i].aci.Contact_Support_for_CA__c != null || lstWrap[i].aci.Contact_Relationship__c != null)
                 {
                     lstWrap[i].aci.csu__c = lstWrap[i].csu;
                     lstWrap[i].aci.GBU_Driver__c = lstWrap[i].driver;
                     lstACI.add(lstWrap[i].aci);
                 }
            }
            
            if(validationErrorFound)
            {
                acc.addError('CILL:  GBU, GBU Driver, Competitor, Competitor Product fields are required');
            }
            else if(lstACI.size() > 0)
            {
                upsert lstACI;
                populateWrapList(lstACI);
            }
           
           if(countRemove > 0)
            for(integer rcount= 0; rcount < countRemove ; rcount ++)
                addNewACIRow();
           
         
        return null;
    
    }
    
    public void populateWrapList(List<Account_Competitor_Install__c> lst)
    {
        lstWrap = new List<WrapACI>();
        if(lst <> null && lst.size() >0)
        {
            for(Account_Competitor_Install__c a: lst)
            {
               if(a.CSU__c == NULL || a.CSU__c == '' || gbus.contains(a.CSU__c) )
               {
                   lstWrap.add(new WrapACI(a,prodcsus));
               }
               else
               {
                   List<SelectOption> extended_lst = prodcsus.clone();
                   extended_lst.add( new SelectOption(a.CSU__c, a.CSU__c) );
                   lstWrap.add(new WrapACI(a,extended_lst));
               }   
            }
                
        }
         
    
    }
    
    
    public void populateACI()
    {
       
        List<Account_Competitor_Install__c>  lstACI = [Select name, Account__c,Top_Competitor__c, Competitor_Product__c, Competitor_Product_Install_Stickiness__c, Contact_Support_for_CA__c 
                 ,CSU__c, Is_there_opportunity_to_replace__c, Number_of_Licenses__c, Renewal_Date__c,  Contact_Relationship__c,Replace_Reasons__C, GBU_Driver__c 
                 from Account_Competitor_Install__c Where Account__c =: accid ORDER By CreatedDate ];
        
       
        populateWrapList(lstACI);
                
        addNewACIRow();
        
        if(lstACI.size() < 3)
            for(integer rcount= 0; rcount < 3- lstACI.size(); rcount ++)
                addNewACIRow();
   
                    

    }

    public void addNewACIRow()
    {
        if(lstWrap == null)
            lstWrap = new List<WrapACI>();
        lstWrap.add(new WrapACI(new Account_Competitor_Install__c(Account__c=accid),prodcsus));
    }


     public List<SelectOption> getlstCSU() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            return options;
        }
        
        
    
        
    public pagereference refreshPage()
    {
                return null;
    }
     
    public pagereference filterItems()
    {
      List<Active_Contract_product__c> lst;
      if( drivers <> null && drivers.size() > 0)
      {
          if((prodgroup <> null && prodgroup.size() > 0 ) && (prods <> null && prods.size() > 0)&& (csu <> null && csu.size() > 0))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c 
                  FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.Product_Group__c in : prodgroup and Product__r.csu2__c in : csu and Product__r.CSU_Driver__c in : drivers
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if((prodgroup <> null && prodgroup.size() > 0 ) && (prods <> null && prods.size() > 0))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.Product_Group__c in : prodgroup and Product__r.CSU_Driver__c in : drivers  
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if((prodgroup <> null && prodgroup.size() > 0 ) && (csu <> null && csu.size() > 0))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.Product_Group__c in : prodgroup and Product__r.csu2__c in : csu and Product__r.CSU_Driver__c in : drivers
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if((prods <> null && prods.size() > 0) && (csu <> null && csu.size() > 0 ))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.csu2__c in : csu and Product__r.CSU_Driver__c in : drivers
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if (prodgroup <> null && prodgroup.size() > 0)
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.Product_Group__c in : prodgroup and Product__r.CSU_Driver__c in : drivers 
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else  if (prods <> null && prods.size() > 0)
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.CSU_Driver__c in : drivers 
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else  if (csu <> null && csu.size() > 0)
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.csu2__c in : csu and Product__r.CSU_Driver__c in : drivers
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];
          else 
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.CSU_Driver__c in : drivers
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];      
      }
      else
      {
        if( (prodgroup <> null && prodgroup.size() > 0 ) || (prods <> null && prods.size() > 0) || (csu <> null && csu.size() > 0) )
        {      
          
          if((prodgroup <> null && prodgroup.size() > 0 ) && (prods <> null && prods.size() > 0)&& (csu <> null && csu.size() > 0))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c 
                  FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.Product_Group__c in : prodgroup and Product__r.csu2__c in : csu
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if((prodgroup <> null && prodgroup.size() > 0 ) && (prods <> null && prods.size() > 0))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.Product_Group__c in : prodgroup  
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if((prodgroup <> null && prodgroup.size() > 0 ) && (csu <> null && csu.size() > 0))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.Product_Group__c in : prodgroup and Product__r.csu2__c in : csu
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if((prods <> null && prods.size() > 0) && (csu <> null && csu.size() > 0 ))
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods and Product__r.csu2__c in : csu 
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else if (prodgroup <> null && prodgroup.size() > 0)
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.Product_Group__c in : prodgroup 
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else  if (prods <> null && prods.size() > 0)
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and product__c in : prods 
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
          else
              lst = [Select Product__r.csu2__c, Product__r.CSU_Driver__c, Product__c, Product__r.Product_Group__c, Product__r.Name, Name, Cause__c, Contact__c, Customer_Satisfaction__c, Product_Install_Status__c, CA_Product_Adoption__c  
                FROM Active_Contract_product__c where Active_Contract__r.Account__c =: accid AND Active_Contract__r.Contract_End_Date__c >= : Date.Today() and Product__r.csu2__c in : csu
                  ORDER BY Product__r.csu2__c,  Product__r.Product_Group__c, Product__r.Name ];   
      
        }
        else
        {
              return null;
          
        }
      }
      populateLogic(lst);
      return null;
    
    }
           
    public pagereference resetItems()
    {
      csu= new List<string>();
      prods = new List<string>();
      prodgroup = new List<string>();
      drivers = new List<String>();
      
      populatelstACPGroupedByProduct();
      
      return null;
    
    }
    
    public integer getCSUsize()
    {
        return csus.size();
    }
    
    public integer getprodgroupsize()
    {
        return prodgroups.size();
    }    
        
    public integer getprodsize()
    {
        return products.size();
    }   
 
    public integer getdriversize()
    {
        return driverOptions.size();
    }
    
 }