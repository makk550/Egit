public class CalendarViewController {
    
    public list<calEvent> events {get;set;}
    public Roster__c CAProduct {get;set;}
    public boolean showCalendar{get;set;}
	public string eventsJSON ;
    
    public String geteventsJSON(){
        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartArray();
        for (calEvent e: events) {
            g.writeStartObject();
            g.writeStringField('title', e.title);
            g.writeDateTimeField('start', e.startString);
            g.writeDateTimeField('end', e.endString);
            g.writeBooleanField('allDay',e.allDay);
            g.writeStringField('url', e.url);
            g.writeStringField('className', e.className);
            g.writeEndObject();
        }
        g.writeEndArray();
        return g.getAsString();
    }
    
    /*public String eventsJSON  {
        get {
            JSONGenerator g = JSON.createGenerator(true);
            g.writeStartArray();
            for (calEvent e: events) {
                g.writeStartObject();
                g.writeStringField('title', e.title);
                g.writeDateTimeField('start', e.startString);
                g.writeDateTimeField('end', e.endString);
                g.writeBooleanField('allDay',e.allDay);
                g.writeStringField('url', e.url);
                g.writeStringField('className', e.className);
                //g.writeStringField('timezone', timezoneString);
                g.writeEndObject();
            }
            g.writeEndArray();
            return g.getAsString();
        }
    } */
    
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';
    String timezoneString = UserInfo.getTimeZone().getID();
    
    
    //constructor
    public CalendarViewController() {
        showCalendar = false;
        CAProduct = this.CAProduct;
        System.debug('CAProduct:'+CAProduct);
    }
    public CalendarViewController(ApexPages.StandardController con) {
        showCalendar = false;
        CAProduct = this.CAProduct;
        System.debug('***CAProduct:'+CAProduct);
    }
    
    public void pageLoad() {
        showCalendar = true;
        events = new list<calEvent>();  
        
        String startHours = null;
        String startMinutes = null;
        String endHours = null;
        String endMinutes = null;
        System.debug('this.CAProduct:'+this.CAProduct);
        System.debug('showCalendar:'+showCalendar);
        //Get the shift details from Roster
        for(Roster__c rosterRec : [select Id,CA_Product_Controller__c,CA_Product_Controller__r.Name,Role__c,ShiftDate__c,User__r.Name, Shift__r.StartTime__c,Shift__r.EndTime__c from Roster__c]){
            
            if(rosterRec.Shift__r.StartTime__c!= null && rosterRec.Shift__r.StartTime__c!=''){
                startHours = rosterRec.Shift__r.StartTime__c.substringBefore(':');
                startMinutes = rosterRec.Shift__r.StartTime__c.substringAfter(':');
            }
            if(rosterRec.Shift__r.EndTime__c!= null && rosterRec.Shift__r.EndTime__c!=''){
                endHours = rosterRec.Shift__r.EndTime__c.substringBefore(':');
                endMinutes = rosterRec.Shift__r.EndTime__c.substringAfter(':');
            }
            
            DateTime startDT = DateTime.newInstanceGmt(rosterRec.ShiftDate__c.year(),rosterRec.ShiftDate__c.month(),rosterRec.ShiftDate__c.day()); //rosterRec.ShiftDate__c;
            DateTime endDT = startDT;//DateTime.newInstance(rosterRec.ShiftDate__c, null);
    
            
            
            if(startHours!=null){
                startDT = startDT.addHours(Integer.valueOf(startHours));
            }
            if(startMinutes!=null){
                startDT = startDT.addMinutes(Integer.valueOf(startMinutes));
            }
            
            if(endHours!=null){
                endDT = endDT.addHours(Integer.valueOf(endHours));
            }
            if(endMinutes!=null){
                endDT = endDT.addMinutes(Integer.valueOf(endMinutes));
            }
            
            DateTime startDTt = DateTime.valueOfGMT(startDT.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().getID()));
            DateTime endDTt = DateTime.valueOfGMT(endDT.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().getID()));
            
            calEvent rosterEntryToCal = new calEvent();
            rosterEntryToCal.title = rosterRec.User__r.Name + '\n' + rosterRec.CA_Product_Controller__r.Name ;
            rosterEntryToCal.allDay = false;
            rosterEntryToCal.startString = startDTt;
            rosterEntryToCal.endString = endDTt;
            rosterEntryToCal.url = '/' + rosterRec.User__c;
            if(rosterRec.Role__c == 'Primary'){
                rosterEntryToCal.className = 'event-roster-primary';
            }else if(rosterRec.Role__c == 'Secondary'){
                rosterEntryToCal.className = 'event-roster-secondary';
            }
            else{
                rosterEntryToCal.className = 'event-roster';
            }
            System.debug('rosterEntryToCal.title:'+rosterEntryToCal.title);
            events.add(rosterEntryToCal);
            
        }
                
       // return null;
    }
    
    
    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public DateTime startString {get;private set;}
        public DateTime endString {get;private set;}
        public String url {get;set;}
        public String className {get;set;}
    }
}