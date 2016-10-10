@IsTest
public class CC_Layer7ServiceTest {
  @IsTest
  static void it_should_get_sites_and_products() {
    // Given
    Layer7UtilCalloutMock mock = buildL7Mock();
    CC_Layer7Service svc = buildL7Svc(mock);
    String connectId = 'abcde', siteId = '12345';

    String[] jsonResults = new String[]{
      '{ "site_id": "site1", "name": "product1" }',
      '{ "site_id": "site2", "name": "product1" }',
      '{ "site_id": "site3", "name": "product2" }',
      '{ "site_id": "site4", "name": "product2" }'
    };

    mock.callLogger.recordCall('processLayer7Services', null,
      '{ "status": "success", "data": { "sites": { "site_id": "12345,1234" }, "sites_and_products": [ ' + String.join(jsonResults, ',') + '] } }'
    );

    // When
    Test.startTest();
    CC_Layer7Service.JsonData results = svc.getSitesAndProducts(siteId, connectId);
    Test.stopTest();

    // Then
    // verify L7 call
    mock.callLogger.verify();
    HttpRequest req = (HttpRequest)mock.callLogger.getCall('processLayer7Services').params.get('httpInputRequest');
    System.assert(req.getEndpoint().endsWith('/userProductWithSites?connectId=' + connectId + '&ConnectSiteId=' + siteId));

    // verify results
    System.assertEquals(4, results.sites_and_products.size());
    System.assertNotEquals(null, results.sites);
    System.assertNotEquals(null, results.sites.siteIds);
    System.assertEquals(2, results.sites.siteIds.size(), results.sites.siteIds);
  }

  static Layer7UtilCalloutMock buildL7Mock() {
    return new Layer7UtilCalloutMock();
  }

  static CC_Layer7Service buildL7Svc(Layer7UtilCalloutMock mock) {
    CC_Layer7Service svc = new CC_Layer7Service();
    svc.layer7Callout = mock;
    return svc;
  }
}