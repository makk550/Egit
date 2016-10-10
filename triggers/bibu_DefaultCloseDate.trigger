trigger bibu_DefaultCloseDate on Opportunity (before insert, before update) {
    String strOldMileStone = '';
    integer i=0;
    for(Opportunity opp:Trigger.new)
    {
        if(Trigger.old!=null)
            strOldMileStone = Trigger.old[i].StageName; 
        else    
            strOldMileStone = '';
        if(strOldMileStone!=opp.StageName && opp.IsClosed)
        {
            opp.CloseDate = Date.today();
        }
        i++; 
    }
}