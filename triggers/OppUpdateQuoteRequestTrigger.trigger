//executed everytime an opportuniy is updated
//2 Soql Query
trigger OppUpdateQuoteRequestTrigger on Opportunity (after update) 
{
    //## there is a requirement to update various Quote_Request__c
    //## fields with values from the Opportunity.
    //## This Trigger was added to the Opportunity to meet
    //## that requirement.
    //## See also: OppLIUpdateQuoteRequestTrigger (on OpportunityLineItem)
    
    //IMP # //Updated by Nomita on 03/02/2010 to avoid User SOQL query incase no Quote_Request__c records are present. 
    // # This is done sicne we were hitting the governor limits on number of SOQL queries.
    try 
    {  
        //prepare owner id list and get associated users from salesforce
        set<Id> ownerIdList=new  set<Id>();
        set<Id> changedOpportunityIdList=new set<Id>();
        RecordTypes_Setting__c rec = RecordTypes_Setting__c.getValues('Quote Request');
        String strQRRecTypeId = rec.RecordType_Id__c + '';
        for(Opportunity opp:Trigger.new)
        {
            Opportunity oldOpp=Trigger.oldMap.get(opp.Id);
            //process the opportunity if one of the fields are changed
            if(opp.OwnerId!=oldOpp.OwnerId || opp.CloseDate!=oldOpp.CloseDate || opp.Amount!=oldOpp.Amount || 
            opp.StageName!=oldOpp.StageName || opp.Type!=oldOpp.Type)
            {
                ownerIdList.add(opp.OwnerId);
                changedOpportunityIdList.add(opp.Id);
            }
        }  
        //if there are any opportunities with field changes
        if(ownerIdList.size()>0)
        {  
            //Map<Id,User> oppOwnerMap=new Map<Id,User>([select Id,Name from User where Id in:ownerIdList]);
            
            //prepare a bucket for updated Quote Requests
            //Quote_Request__c[] qrarray = new Quote_Request__c[0];
            List<Quote_Request__c> qrarray = new List<Quote_Request__c>(); 
               
            //## query the associated Quote Request record
            for (Quote_Request__c qreq:[SELECT Id, Name,Opportunity_Name__c FROM Quote_Request__c 
            WHERE Opportunity_Name__c in :changedOpportunityIdList])
            {     
                //get the parent opportunity
                Opportunity opp= Trigger.newMap.get(qreq.Opportunity_Name__c);  
                
                //## get the opportunity owner       
                //User ownr = oppOwnerMap.get(opp.OwnerId);
                              
                //qreq.Owner = opp.Owner;
                qreq.Oppty_Owner__c = opp.OwnerId;
                //qreq.Opportunity_Owner__c = ownr.Name;
                qreq.Opportunity_Close_Date__c = opp.CloseDate;
                qreq.Opportunity_Amount__c  = opp.Amount;
                qreq.Sales_Milestone__c  = opp.StageName;
                qreq.Type__c = opp.Type;

                //ADDED BY AFZAL,CR:189452872
                if(Trigger.oldMap.get(qreq.Opportunity_Name__c).IsClosed==true && opp.IsClosed==false){
                    qreq.RecordTypeId = strQRRecTypeId;
                    qreq.Request_Status__c = 'Updated';
                //}else if(Trigger.oldMap.get(qreq.Opportunity_Name__c).IsClosed==false && opp.IsClosed==true){
                    //qreq.Request_Status__c = 'Updated';
                }
                    
                qrarray.add(qreq);        
            }   
            if(qrarray.size()>0)
            {
                //Updated by Nomita on 03/02/2010 to avoid User SOQL query incase no Quote_Request__c records are present
                
                Map<Id,User> oppOwnerMap=new Map<Id,User>([select Id,Name from User where Id in:ownerIdList]);
                for(Quote_Request__c qr : qrarray)
                {
                    Opportunity opp= Trigger.newMap.get(qr.Opportunity_Name__c); 
                    User ownr = oppOwnerMap.get(opp.OwnerId);
                    qr.Opportunity_Owner__c = ownr.Name;
                }
                update qrarray;
            }
        }
    }
    catch(System.DmlException e)
    {
        for (Integer i =0; i < e.getNumDml(); i++)
        {
            System.debug(e.getDmlMessage(i));
        }
    }
    
}