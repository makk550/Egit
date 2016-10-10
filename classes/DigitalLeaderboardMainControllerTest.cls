@isTest(SeeAllData=true)
public class DigitalLeaderboardMainControllerTest {
    
    @isTest static void testtickerdata(){
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v29.0/analytics/reports/00Oa0000008e2AU', 'testDigitalsalesLeaderboardTicker');
        multimock.setStaticResource('https://login.salesforce.com/services/oauth2/token', 'testDigitalsalesLeaderboardoauth');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
 		Test.setMock(HttpCalloutMock.class, multimock);
        DigitalLeaderboardMainController.GetTickerData('NA');
        //DigitalLeaderboardMainController.getSFDCReportsID('NA','topISRsbySAOsID');
        
    } 
    @isTest static void testdealsdata(){
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v29.0/analytics/reports/00Oa0000008e2Vr/describe', 'testDigitalsalesLeaderboardDeal1');
        multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v29.0/analytics/reports/00Oa0000008e2Vr?includeDetails=true', 'testDigitalsalesLeaderboardDeal2');
        multimock.setStaticResource('https://login.salesforce.com/services/oauth2/token', 'testDigitalsalesLeaderboardoauth');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
 		Test.setMock(HttpCalloutMock.class, multimock);
        DigitalLeaderboardMainController.GetDealsData('bookedDealsByQuarter','NA');
        //DigitalLeaderboardMainController.getSFDCReportsID('NA','topISRsbySAOsID'); DigitalLeaderboardMainController.SaveTeamPhotos('NA');
        
    } 
     @isTest static void testsavephotos(){
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        //multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v29.0/analytics/reports/00Oa0000008e2Vr/describe', 'testDigitalsalesLeaderboardsavephotos');
        multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v29.0/analytics/reports/00Oa0000008qn0A?includeDetails=true', 'testDigitalsalesLeaderboardsavephotos');
        multimock.setStaticResource('https://login.salesforce.com/services/oauth2/token', 'testDigitalsalesLeaderboardoauth');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
 		Test.setMock(HttpCalloutMock.class, multimock);
        DigitalLeaderboardMainController.SaveTeamPhotos('NA');
        //DigitalLeaderboardMainController.getSFDCReportsID('NA','topISRsbySAOsID'); DigitalLeaderboardMainController.SaveTeamPhotos('NA');
        
    } 
    @isTest static void testdashboard(){
        /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('testDigitalsalesLeaderboardoauth');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);*/
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        //multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v29.0/analytics/reports/00Oa0000008e2Vr/describe', 'testDigitalsalesLeaderboardsavephotos');testDigitalsalesLeaderboardDashfilter
        multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v31.0/analytics/dashboards/01Za000000171eG', 'testDigitalsalesLeaderboardDash1');
        multimock.setStaticResource('https://ca.my.salesforce.com/services/data/v31.0/analytics/dashboards/01Za000000171eG?filter1=0ICa000000052awGAA', 'testDigitalsalesLeaderboardDashfilter');
        multimock.setStaticResource('https://login.salesforce.com/services/oauth2/token', 'testDigitalsalesLeaderboardoauth');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
 		Test.setMock(HttpCalloutMock.class, multimock);
        DigitalLeaderboardMainController.RefreshDashboardAndFilters('NA');
        //DigitalLeaderboardMainController.getSFDCReportsID('NA','topISRsbySAOsID'); DigitalLeaderboardMainController.SaveTeamPhotos('NA');
      
    }

}