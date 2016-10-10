public class BreakPeriodCalculator {
    Public static Time CreateTime(String Tim){
        Integer HH,MM;
        	
        		if(Tim.contains('PM'))
					{
    					String str  =Tim.substring(0,Tim.length()-6); 
   						HH = Integer.valueOf(str) + 12;
   					    str  =Tim.substring(Tim.length()-5, Tim.length()-3);
    					MM = Integer.valueOf(str);
					}
                else{
    					String str  =Tim.substring(0, Tim.length()-6); 
   						HH = Integer.valueOf(str);
                        str  =Tim.substring(Tim.length()-5, Tim.length()-3);
    					MM = Integer.valueOf(str);
                    }
				Time myTime = Time.newInstance(HH, MM, 0, 0);
        return myTime;
    }
    Public static boolean validateBreakPeriod(String stTime, String EnTime)
    	{
    		
        	boolean flag = false;
        Time myTime = CreateTime(stTime);
		Time myTime1 = CreateTime(EnTime);
			if(myTime> myTime1){
    						    flag = true;
								}
        return flag;
    }
    
    Public static boolean validateWithBusinessHours(String stTime, String EnTime, Time busStTime, Time busEnTime)
    {
        
        		boolean flag = false;
                Time myTime = CreateTime(stTime);
				Time myTime1 = CreateTime(EnTime);
        
        if(myTime < busStTime || myTime1> busEnTime){
            flag = true;
        }
        return flag;
    }
    
    Public static boolean validateAutoassign(String stTime, String EnTime, String Timezone){
        
        	boolean flag = false;
        
        Time myTime = CreateTime(stTime);
		Time myTime1 = CreateTime(EnTime);
        string sysT = (System.now().format('yyyy-MM-dd HH:mm:ss', 'Asia/Dubai'));
		String str  =sysT.substring(sysT.length()-8, sysT.length()-6); 
  		Integer HHS = Integer.valueOf(str);
        str  =sysT.substring(sysT.length()-5, sysT.length()-3);
  		Integer MMS = Integer.valueOf(str);
        Time sTime = Time.newInstance(HHS, MMS, 0, 0);
        if(myTime < sTime && myTime1 > sTime){ flag = true;}
        return flag;
    }
}