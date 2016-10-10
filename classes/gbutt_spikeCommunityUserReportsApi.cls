global with sharing class gbutt_spikeCommunityUserReportsApi {

    private Id scdevReportId = '00O18000000OfzB';
    private Id fsb1ReportId = '00O8A000000GgyT';

    global String reportData { get; set; }

    global void reportApi() {
        //// adjust default date filter to include last quarter so we get some results
        //Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(scdevReportId);
        //Reports.ReportMetadata reportMd = describe.getReportMetadata();
        //Reports.StandardDateFilter stdDateFilter = reportMd.getStandardDateFilter();
        //stdDateFilter.setDurationValue('LAST_QUARTER');
        //Reports.reportResults results = Reports.ReportManager.runReport(scdevReportId, reportMd);

        Reports.ReportResults results = Reports.ReportManager.runReport(scdevReportId, true);
        log.info(results);
        //this.results = results;
        this.reportData = JSON.serializePretty(results.getFactMap());
    }

    global void namedCredential() {
        String restQuery = 'callout:CA_Salesforce_Prod/services/data/v37.0/analytics/reports/' + fsb1ReportId;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(restQuery);

        Http httpService = new Http();
        HttpResponse resp = httpService.send(req);
        log.debug(resp);
        this.reportData = JSON.serializePretty(JSON.deserializeUntyped(resp.getBody()));
    }
}