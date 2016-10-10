@IsTest
public class Layer7UtilCalloutTest {
	
  @IsTest
  static void ctor_should_set_properties() {
    // when
    Layer7UtilCallout l7util = new Layer7UtilCallout();

    // then
    System.assertEquals(System.Label.GatewayAPITokenEndPoint, l7util.tokenEndpointUrl);
    System.assertEquals(System.Label.GatewayAPIClientKey, l7util.clientKey);
    System.assertEquals(System.Label.GatewayAPIClientSecret, l7util.clientSecret);
  }

  @IsTest
  static void getLayer7BaseUrl_gets_url_for_token_endpoint() {
    // given
    Layer7UtilCallout l7util = new Layer7UtilCallout();
    l7util.tokenEndpointUrl = 'http://ca.com/is/awesome.io';
    // when
    String result = l7util.getLayer7BaseUrl();
    // then
    System.assertEquals('http://ca.com', result);
  }

  @IsTest
  static void processLayer7Services_is_impossible_to_test() {
    
  }
}