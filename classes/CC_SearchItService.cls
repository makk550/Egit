global class CC_SearchItService implements I {
  public interface I {
    SearchItResults doSearch(String title, Id productName);
  }

  @TestVisible
  private String sourceId { get; set; }

  @TestVisible
  private String[] selectProperties = new String[]{
    'Products',
    'ContentSource',
    'Title',
    'Path',
    'CATOPSPublishUrlOWSMTXT',
    'ConfluenceURL',
    'HitHighlightedSummary',
    'ProductVersions',
    'Size',
    'FileType',
    'TypeOfContent',
    'LastModifiedTime'
  };

	public CC_SearchItService() {
		sourceId = CC_Settings.searchDotCaDotComSourceId;
	}

  public SearchItResults doSearch(String title, Id productId) {
    String productName;
    SCKBProductMap__c[] kbProducts = [SELECT KB_Product_Name__c FROM SCKBProductMap__c WHERE SCProduct__c = :productId];
    if (kbProducts.size() > 0) {
      productName = kbProducts[0].KB_Product_Name__c;
    } 
    String endpoint = buildSearchEndpoint(title, productName);
    String jsonResult = callSearchIt(endpoint);
    SearchItArticle[] articles = parseResults(jsonResult);
    return new SearchItResults(articles, title, productName);
  }

  @TestVisible
  private String callSearchIt(String endpoint) {
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod('GET');
    req.setHeader('Accept', 'application/json; odata=verbose');
    HttpResponse res = http.send(req);
    return res.getBody();
  }

  @TestVisible
  private String buildSearchEndpoint(String title, String productName) {
    String[] params = new String[]{
      'QueryTemplatePropertiesUrl=%27spfile://webroot/queryparametertemplate.xml%27',
      'sourceid=%27' + this.sourceId + '%27',
      'rankingmodelid=%2797cbcebd-037c-4346-9bc4-582d8c560204%27',
      'rowlimit=5',
      'selectproperties=%27' + String.join(this.selectproperties, ',') + '%27',
      'querytext=%27' + EncodingUtil.urlEncode(title, 'UTF-8') + '%27'
    };
    if (productName != null) {
      params.add('refinementFilters=%27Products:equals(%22' + EncodingUtil.urlEncode(productName, 'UTF-8') + '%22)%27');
    }
    return 'callout:search_ca_com?' + String.join(params, '&');
  }

  private SearchItArticle[] parseResults(String jsonResult) {
    JSONParser parser = JSON.createParser(jsonResult);
    CC_Utils.navigateToPath(parser, 'd.query.PrimaryQueryResult.RelevantResults.Table.Rows.results');
    SearchResult[] results = (SearchResult[])parser.readValueAs(List<SearchResult>.class);
    return convertResultsToArticles(results);
  }


  @TestVisible
  private SearchItArticle[] convertResultsToArticles(SearchResult[] results) {
    SearchItArticle[] articles = new SearchItArticle[]{};
    for (SearchResult result : results) {
      SearchItArticle article = new SearchItArticle();
      for (ResultCell cell : result.Cells.results) {
        parseCell(article, cell);
      }
      articles.add(article);
    }
    return articles;
  }

  @TestVisible
  private static void parseCell(SearchItArticle article, ResultCell cell) {
    if (cell.Value == null) {
      return;
    }
    if (cell.Key == 'Title') {
      article.title = cell.Value;
    } else if (cell.Key == 'CATOPSPublishUrlOWSMTXT') {
      article.url = cell.Value;
    } else if (cell.Key == 'ConfluenceURL') {
      article.url = cell.Value;
    } else if (cell.Key == 'Path' && article.url == null) {
      article.url = cell.Value;
    } else if (cell.Key == 'HitHighlightedSummary') {
      article.snippet = cleanseSnippet(cell.Value);
    } else if (cell.Key == 'Products') {
      article.products = cell.Value;
    } else if (cell.Key == 'ContentSource') {
      article.contentSource = cell.Value;
    } else if (cell.Key == 'ProductVersions') {
      article.productVersions = cell.Value;
    } else if (cell.Key == 'Size') {
      article.fileSize = Long.valueOf(cell.Value);
    } else if (cell.Key == 'FileType') {
      article.fileType = cell.Value;
    } else if (cell.Key == 'TypeOfContent') {
      article.typeOfContent = cell.Value;
    } else if (cell.Key == 'LastModifiedTime') {
      article.lastModifiedTime = DateTime.valueOf(cell.Value.replace('T', ' '));
    }
  }

  @TestVisible
  private static String cleanseSnippet(String inputSnippet) {
    return inputSnippet
      .replaceAll('&lt;(?!&gt;).*?&gt;','')
      .unescapeHtml4()
      .replace('<ddd/>', '<b>...</b>')
      .replace('<c0>', '<b>')
      .replace('</c0>', '</b>')
      .replace('\\r\\n', '<br/>');
  }

  global class SearchItResults {
    public SearchItArticle[] articles {get; private set;}
    public Map<String, String> searchParameters {get; private set;}
    global SearchItResults(SearchItArticle[] articles, String queryText, String productName) {
      this.articles = articles;
      this.searchParameters = new Map<String, String> {
        'queryText' => queryText,
        'productName' => productName
      };
    }
  }

  global class SearchItArticle {
    public String url {get; private set;}
    public String title {get; private set;}
    public String snippet {get; private set;}
    public String contentSource {get; private set;}
    public String products {get; private set;}
    public String productVersions {get; private set;}
    public Long fileSize {get; private set;}
    public String fileType {get; private set;}
    public String typeOfContent {get; private set;}
    public DateTime lastModifiedTime {get; private set;}
  }

  public class SearchResult {
    public ResultCells Cells;
  }

  public class ResultCells {
    public List<ResultCell> results;
  }

  public class ResultCell {
    public String Key;
    public String Value;
    public ResultCell(String key, String value) {
      this.Key = key;
      this.Value = value;
    }
  }
}