/************************************************************************************************************************
Name : Partner_Lead_Routing

Type : Apex Trigger

Desc : Assign leads based on records in Partner Lead Routing Rules 

Auth : Deloitte Consulting LLP

*************************************************************************************************************************

LastMod                Developed By                 Desc

5/1/2012               Diti Mansata              Assign leads based on records in Partner Lead Routing Rules 
************************************************************************************************************************/

trigger Partner_Lead_Routing on Lead (before insert, before update) {

list<Partner_Lead_Routing_Rules__c> rules2 = new list< Partner_Lead_Routing_Rules__c>() ; 
List<String> listterritory = new List<String>();
List<String> listproduct = new List<String>();
List<String> listNcvDriver = new List<String>();

List<String> listSegment = new List<String>();
List<Lead> lstlead = new List<Lead>();
List<Account> acc = new List<Account>();
List<Account> tiedPartnerAcc = new List<Account>();
List<Account> partnerAcc = new List<Account>();
Id validAcc ;
Date dt;


List<GroupMember> GroupMemberList = new List<GroupMember>();

GroupMember GM; 
Map<String,id> que = new Map<String, Id>();
List<QueueSobject> quelist = new List<QueueSobject>();

Boolean eligibleLeads = false;

if(trigger.isInsert )
    eligibleLeads = true;

else if(Trigger.isUpdate)
{
    for(Lead l: trigger.New)
        {
            if(Trigger.OldMap.get(l.id).isSubmitPartner__c== FALSE && l.isSubmitPartner__c== TRUE)
            {   eligibleLeads = true;
                return;
            }

        }   
}



if(eligibleLeads)//Trigger.isInsert || (Trigger.isUpdate && Trigger.Old[0].isSubmitPartner__c== FALSE && Trigger.New[0].isSubmitPartner__c== TRUE))
{
    //Trigger.New[0].isSubmitPartner__c= FALSE; //moved in the loop
    //quelist = [Select QueueId,Queue.Name from QueueSobject where SobjectType = : 'Lead' AND (Queue.Name = : QueueCust__c.getInstance('Common Partner Lead Pool').Name OR Queue.Name = : QueueCust__c.getInstance('Partner Admin').Name OR Queue.Name = : QueueCust__c.getInstance('Data Management Leads').Name) order By Queue.Name];  

        que.put(QueueCust__c.getInstance('Common Partner Lead Pool').Name,QueueCust__c.getInstance('Common Partner Lead Pool').Queue_ID__c);
        que.put(QueueCust__c.getInstance('Data Management Leads').Name,QueueCust__c.getInstance('Data Management Leads').Queue_ID__c);
        que.put(QueueCust__c.getInstance('Partner Admin').Name,QueueCust__c.getInstance('Partner Admin').Queue_ID__c);


/*for(Integer i=0; i<quelist.size(); i++)
{
    if(quelist[i].Queue.Name == QueueCust__c.getInstance('Common Partner Lead Pool').Name)
    {
        que.put(QueueCust__c.getInstance('Common Partner Lead Pool').Name,quelist[i]);
    }
    else if (quelist[i].Queue.Name == QueueCust__c.getInstance('Data Management Leads').Name)
    {
         que.put(QueueCust__c.getInstance('Data Management Leads').Name,quelist[i]);
    }
    else if (quelist[i].Queue.Name == QueueCust__c.getInstance('Partner Admin').Name)
    {
         que.put(QueueCust__c.getInstance('Partner Admin').Name,quelist[i]);
    }    
}
*/


Integer count =0;
Boolean flag = false;


Decimal score;
Id partnerRules;

//Checking for BU and NCV Driver
for(lead leadrouting : trigger.new)
{   
     leadrouting.isSubmitPartner__c= FALSE; 

  /* PRM 4 - 76.00 - Commented out. 
   if(leadrouting.MKT_BU_Category__c == 'Data Management' && (leadrouting.MKT_Solution_Set__c == 'RM Other' || leadrouting.MKT_Solution_Set__c == 'DM Other'))
    {
         leadrouting.ownerId = que.get('Data Management Leads') ;         
    }
*/

  //  PRM 4 - 76.00 - Commented out. - if(leadrouting.MKT_BU_Category__c != 'Data Management' && (leadrouting.MKT_Solution_Set__c != 'RM Other' || leadrouting.MKT_Solution_Set__c != 'DM Other'))
   {       
        listterritory.add(leadrouting.Sales_Territory__c);
        listNcvDriver.add(leadrouting.MKT_Solution_Set__c);
        
        listSegment.add(leadrouting.Segment__c);
        lstlead.add(leadrouting);
        
    }
}
// Querying the Partner Lead Routing Rules Object for matching NCV Driver
if(listNcvDriver.size() > 0 || listSegment.size() > 0)
    rules2 = [Select id, Segment__c, CA_Lead_Admin__c,Tie_Breaker_Rule__c, NCV_Driver__c,RTM__c, Territory_Region__c,Program_Level__c, RTM_Type__c, Rule_Expiration_Date__c,Account__r.Lead_Champion__c from Partner_Lead_Routing_Rules__c where NCV_Driver__c IN : listNcvDriver OR Segment__c IN : listSegment ];

set<string> terrRegionSet = new set<string>();
set<string> RTMtype = new set<string>();

for(Partner_Lead_Routing_Rules__c plrr:rules2 )
{
    if(plrr.Territory_Region__c !=null)
        terrRegionSet.add(plrr.Territory_Region__c);
    if(plrr.RTM_Type__c != null)
        RTMtype.add(plrr.RTM_Type__c);

}


// Querying the Accounts object 
if(terrRegionSet.size() > 0 )
    acc = [Select id, Sales_Region__c,Lead_Champion__c, Lead_Routing_Score__c, OwnerId, Last_Accepted_Lead_Date__c, Alliance__c,Alliance_Program_Level__c, Solution_Provider__c, Solution_Provider_Program_Level__c, Service_Provider__c,Service_Provider_Program_level__c,  Velocity_Seller__c, Velocity_Seller_Program_Level__c from Account where Sales_Region__c IN : terrRegionSet AND (Alliance__c = TRUE OR Solution_Provider__c = TRUE OR Service_Provider__c = TRUE OR  Velocity_Seller__c = TRUE) AND Lead_Champion__c != null];


for(Integer i=0;i<rules2.size();i++)
    {
        for(Integer j=0; j<lstlead.size(); j++)
        {  
            for (Integer k = 0; k<acc.size(); k++) 
            {    
                //Checking for matching NCV Driver or Segment         
                if(rules2.size()>0 && lstlead[j].MKT_Solution_Set__c != null && lstlead[j].MKT_Solution_Set__c ==  rules2[i].NCV_Driver__c && lstlead[j].Lead_RTM__c!=null && lstlead[j].Lead_RTM__c == rules2[i].RTM__c && rules2[i].Rule_Expiration_Date__c >= system.today() || (lstlead[j].Segment__c != null && lstlead[j].Segment__c == rules2[i].Segment__c) )
                {
                    // Check for matching Territory
                    If(rules2[i].Territory_Region__c == acc[k].Sales_Region__c )
                    {
                     
                        // Checking for RTM and Program Level
                        if(rules2[i].RTM__c == 'Alliance' && acc[k].Alliance__c == TRUE )
                        {
                            if(rules2[i].Program_Level__c == acc[k].Alliance_Program_Level__c)
                            {
                                  partnerAcc.add(acc[k]);
                                  
                            } 
                        }
                        else if(rules2[i].RTM__c == 'Data Management' && acc[k].Velocity_Seller__c == TRUE)
                        {
                            if(rules2[i].Program_Level__c == acc[k].Velocity_Seller_Program_Level__c)
                            {
                                partnerAcc.add(acc[k]);
                            }
                        }
                        else if(rules2[i].RTM__c == 'Service Provider' && acc[k].Service_Provider__c == TRUE)
                        {
                            if(rules2[i].Program_Level__c == acc[k].Service_Provider_Program_level__c)
                            {
                                partnerAcc.add(acc[k]);
                            }
                        }
                        else if(rules2[i].RTM__c == 'Solution Provider' && acc[k].Solution_Provider__c == TRUE) 
                        {
                            if(rules2[i].Program_Level__c == acc[k].Solution_Provider_Program_Level__c)
                            {
                                partnerAcc.add(acc[k]);
                            }
                           
                        }
               
                    }
                        
                }
                
                
            }
        }
    }

// If there are no Partners found then assign to Partner Admin Queue
if(partnerAcc.size() == 0)
{
    for(Integer i = 0; i<partnerAcc.size(); i++ )
    {
        for(Integer j= 0;j<lstlead.size();j++)
        {
                // PRM 4 - 76.00 - If,Else introduced.
                if(lstlead[j].MKT_BU_Category__c == 'Data Management' && (lstlead[j].MKT_Solution_Set__c == 'RM Other' || lstlead[j].MKT_Solution_Set__c == 'DM Other'))
                {
                     lstlead[j].ownerId = que.get('Data Management Leads') ;         
                }
                else
                {
                        lstlead[j].ownerId = que.get('Partner Admin') ;
                }
        }
    }
}
// If there is just one Partner found then assign to the related Lead Champion
else if(partnerAcc.size() == 1)
{
    for(Integer i = 0; i<partnerAcc.size(); i++ )
    {
        for(Integer j= 0;j<lstlead.size();j++)
        {        
           
            lstlead[j].ownerId = partnerAcc[i].Lead_Champion__c ;
            
        }
    }

}
// If there are more than 1 partners found then apply Tie Braking Rules
else if(partnerAcc.size() > 1)
{
    for(Integer i = 0; i<partnerAcc.size(); i++ )
    {
        for(Integer j= 0;j<lstlead.size();j++)
        {
            for(Integer k= 0;k<rules2.size();k++)
            {
                // If Tie Breaker Rule is Round Robin then assign to the Partner with least Last Accepted lead Date
                if(rules2[k].Tie_Breaker_Rule__c == 'Round Robin')
                {
                     if(dt==null)
                     {
                         dt = partnerAcc[i].Last_Accepted_Lead_Date__c;
                         validAcc = partnerAcc[i].Lead_Champion__c;
                         
                     }
                     
                     
                     else if(dt > partnerAcc[i].Last_Accepted_Lead_Date__c)
                     {
                         dt = partnerAcc[i].Last_Accepted_Lead_Date__c;
                         validAcc = partnerAcc[i].Lead_Champion__c;
                         
                     }
                     
                     lstlead[j].ownerId = validAcc; 
                }
                // If Tie Braker Rule is Score then assign to the Partner having highest score
                else if(rules2[k].Tie_Breaker_Rule__c == 'Score')
                {
                    
                    if(score == null)
                    {
                        score = partnerAcc[i].Lead_Routing_Score__c;
                        validAcc = partnerAcc[i].Lead_Champion__c;
                        tiedPartnerAcc.add(partnerAcc[i]);
                    }
                    
                    if(partnerAcc[i].Lead_Routing_Score__c > score)
                    {
                        tiedPartnerAcc.clear();
                        score = partnerAcc[i].Lead_Routing_Score__c;
                        validAcc = partnerAcc[i].Lead_Champion__c;
                        tiedPartnerAcc.add(partnerAcc[i]);
                    } 
                    else if (partnerAcc[i].Lead_Routing_Score__c==score)
                    {
                    tiedPartnerAcc.add(partnerAcc[i]);
                    }
                    
                    //lstlead[j].ownerId = validAcc;
                }
                
                // If Tie Breaker Rule is Shark Tank then assign to Common Partner Lead Pool queue
                else if(rules2[k].Tie_Breaker_Rule__c == 'Shark Tank')
                {
                    lstlead[j].ownerId = que.get('Common Partner Lead Pool');
                }
                // If Tie Breaker Rule is Manual then assign to Partner Admin queue
                else if(rules2[k].Tie_Breaker_Rule__c == 'Manual')
                {
                    lstlead[j].ownerId = que.get('Partner Admin');
                }
                
               
            }
            
            if (tiedPartnerAcc.size() > 0) // Breaking the tied partner accounts having same score using Round Robin
            {
                Date dtlocal = null;
                for(Account a : tiedPartnerAcc)
                {
                    if(dtlocal==null)
                             {
                                 dtlocal = a.Last_Accepted_Lead_Date__c;
                                 lstlead[j].ownerId = a.Lead_Champion__c;                                
                             }
                             
                             
                    else if(dtlocal > a.Last_Accepted_Lead_Date__c)
                             {
                                 dtlocal = a.Last_Accepted_Lead_Date__c;
                                 lstlead[j].ownerId = a.Lead_Champion__c;                                
                             }                       
                }
            }
        }
        
        tiedPartnerAcc.clear();
    }    
    
    
}
}
//update lstlead;
}