public without sharing class ApproveOpportunityOverride {
    
private final Opportunity dealRegOppT;
public opportunity dealregopp{get;set;}
  	
  	public ApproveOpportunityOverride(){}
    
	public ApproveOpportunityOverride(ApexPages.StandardController controller) {
		this.dealRegOppT = (Opportunity)controller.getrecord();
		this.dealRegOpp = this.dealRegOppT;
		system.debug('dealRegOpp '+dealRegOpp );
		dealRegOpp = [select MinMaxError__c,id,name from opportunity where id=:dealRegOpp.id];
		system.debug('after query dealRegOpp '+dealRegOpp );            
	}
    
    public pageReference ApproveOpp(){        
        pagereference redirect = new PageReference('/006/o'); 
        pagereference redirect1 =new PageReference('/'+dealRegOpp.id);
        redirect.setRedirect(true);        
        try{
        	if(!dealRegOpp.MinMaxError__c){
				Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	            req.setComments('Submitted for approval. Please approve.');
	            req.setObjectId(dealRegOpp.Id);
	            system.debug('approval process'+req );
	            Approval.ProcessResult result = Approval.process(req);
	            system.debug('Approve Yes'+dealRegOpp );        		
        	}
        	else{
        		System.debug('MinMaxError__c is set to true.Cant submit');
        	}        	
        }
        catch(Exception e){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage()));
        }
        return redirect1;
    }
    
    public pageReference ReturntoOpp(){  
         pagereference redirect1 =new PageReference('/'+dealRegOpp.id);
         return redirect1;
    }
    
}