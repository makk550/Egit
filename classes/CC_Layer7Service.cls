public without sharing class CC_Layer7Service implements I {

  public interface I {
    JsonData getSitesAndProducts(String siteId, String connectId);
  }

  @TestVisible 
  private Layer7UtilCallout.I layer7Callout { get; set; }

  public CC_Layer7Service() {
    layer7Callout = new Layer7UtilCallout();
  }

  public JsonData getSitesAndProducts(String siteId, String connectId) {
    String urlPart = '/userProductWithSites?connectId=' + connectId + '&ConnectSiteId=' + siteId;
    JsonResult resJson = callLayerSeven(urlPart);
    return resJson.data;
  }

  private JsonResult callLayerSeven(String urlPart) {
    log.debug(urlPart);
    String url = layer7Callout.getLayer7BaseUrl() + urlPart;
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    req.setTimeout(20*1000);
    String resBody = layer7Callout.processLayer7Services(req);
    log.info(resBody);
    //JsonResult resJson = (JsonResult)JSON.deserialize(resBody, JsonResult.class);
    JsonResult resJson = parseJsonResult(resBody);
    return resJson;
  }

  private JsonResult parseJsonResult(String resBody) {
    JsonResult jsonResult = new JsonResult();
    jsonResult.data = new JsonData();

    JSONParser parser = JSON.createParser(resBody);
    CC_Utils.navigateToPath(parser, 'data.sites.site_id');

    jsonResult.data.sites = new JsonSites(parser.getText());

    try {
      parser = JSON.createParser(resBody);
      CC_Utils.navigateToPath(parser, 'data.sites_and_products');
      jsonResult.data.sites_and_products = (JsonSiteProduct[])parser.readValueAs(List<JsonSiteProduct>.class);
    } catch (Exception ex) {
      log.error(ex);
      // default no products when there's a parsing error
      jsonResult.data.sites_and_products = new JsonSiteProduct[]{};
    }
    return jsonResult;
  }


  public class JsonResult {
    public JsonData data;
    public String status;
  }

  public class JsonData {
    public JsonSiteProduct[] sites_and_products;
    public JsonSites sites;
  }

  public class JsonSiteProduct {
    public String site_id;
    public String name;
    public JsonSiteProduct(String siteId, String productName) {
      this.site_id = siteId;
      this.name = productName;
    }
  }

  public class JsonSites {
    String site_id { get; 
      set {
        siteIds = value.split(',');
        site_id = value;
      } 
    }
    public String[] siteIds;
    public JsonSites(String site_id) {
      siteIds = site_id.split(',');
    }
  }
}