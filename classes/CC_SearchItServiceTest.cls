@IsTest
global class CC_SearchItServiceTest {

  @IsTest
  static void doSearch_should_perform_search_and_return_articles() {
    // Given
    CC_SearchItService svc = new CC_SearchItService();
    CA_Product_Controller__c product = new CA_Product_Controller__c(Name='PPM');
    insert product;
    SCKBProductMap__c sCKBProductMap = new SCKBProductMap__c(KB_Product_Name__c = 'CA PPM', SCProduct__c = product.Id);
    insert sCKBProductMap;

    String expectedResult = jsonResult2;
    HttpResponse resp = new HttpResponse();
    resp.setHeader('Content-Type', 'application/json');
    resp.setBody(expectedResult);
    resp.setStatusCode(200);
    CalloutMock httpMock = new CalloutMock(resp);
    Test.setMock(HttpCalloutMock.class, httpMock);

    // When
    Test.startTest();
    CC_SearchItService.SearchItResults results = svc.doSearch('Clarity', product.Id);
    Test.stopTest();

    // Then
    System.assertEquals(5, results.articles.size());
    for (CC_SearchItService.SearchItArticle article : results.articles) {
      System.assertNotEquals(null, article.url);
      System.assertNotEquals(null, article.title);
      System.assertNotEquals(null, article.snippet);
      System.assertNotEquals(null, article.contentSource);
      System.assertNotEquals(null, article.products);
      System.assertNotEquals(null, article.productVersions);
      System.assertNotEquals(null, article.fileSize);
      System.assertNotEquals(null, article.typeOfContent);
      System.assertNotEquals(null, article.lastModifiedTime);
    }
  }

  @IsTest
  static void buildSearchEndpoint_should_build_search_endpoint() {
    // Given
    CC_SearchItService svc = new CC_SearchItService();

    // When
    String endpoint = svc.buildSearchEndpoint('my title', 'my product');

    // Then
    String path = endpoint.split('\\?')[0];
    Set<String> qs = new Set<String>(endpoint.split('\\?')[1].split('&'));
    System.assertEquals('callout:search_ca_com', path);
    System.assert(qs.contains('QueryTemplatePropertiesUrl=%27spfile://webroot/queryparametertemplate.xml%27'));
    System.assert(qs.contains('sourceid=%27' + svc.sourceId + '%27'));
    System.assert(qs.contains('rankingmodelid=%2797cbcebd-037c-4346-9bc4-582d8c560204%27'));
    System.assert(qs.contains('rowlimit=5'));
    System.assert(qs.contains('querytext=%27my+title%27'));
    System.assert(qs.contains('refinementFilters=%27Products:equals(%22my+product%22)%27'));
    System.assert(qs.contains('selectproperties=%27' + String.join(svc.selectproperties, ',') + '%27'));
  }

  @IsTest
  static void callSearchIt_should_perform_search() {
    // Given
    CC_SearchItService svc = new CC_SearchItService();

    String expectedResult = jsonResult2;
    HttpResponse resp = new HttpResponse();
    resp.setHeader('Content-Type', 'application/json');
    resp.setBody(expectedResult);
    resp.setStatusCode(200);
    CalloutMock httpMock = new CalloutMock(resp);
    Test.setMock(HttpCalloutMock.class, httpMock);

    String endpoint = svc.buildSearchEndpoint('my title', 'my product');

    // When
    String jsonResult = svc.callSearchIt(endpoint);

    // Then
    System.assertEquals(expectedResult, jsonResult);
    HttpRequest req = httpMock.requests.get(0);
    System.assertEquals('GET',req.getMethod());
    System.assertEquals('application/json; odata=verbose',req.getHeader('Accept'));
  }

  @IsTest
  static void parseCell_should_parse_Title() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('Title', 'my title');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.title);
    System.assertEquals(cell.Value, article.title);
  }

  @IsTest
  static void parseCell_should_parse_CATOPSPublishUrlOWSMTXT() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('CATOPSPublishUrlOWSMTXT', 'http://google.com');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.url);
    System.assertEquals(cell.Value, article.url);
  }

  @IsTest
  static void parseCell_should_parse_ConfluenceURL() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('ConfluenceURL', 'http://yahoo.com');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.url);
    System.assertEquals(cell.Value, article.url);
  }

  @IsTest
  static void parseCell_should_parse_Path_if_url_is_null() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('Path', 'http://altavista.com');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.url);
    System.assertEquals(cell.Value, article.url);
  }

  @IsTest
  static void parseCell_should_not_parse_Path_if_url_is_not_null() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('Path', 'http://altavista.com');
    CC_SearchItService.parseCell(article, cell);
    System.assertNotEquals(null, article.url);

    // When
    cell = new CC_SearchItService.ResultCell('Path', 'http://dogpile.com');
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(cell.Value, article.url);
  }

  @IsTest
  static void parseCell_should_parse_HitHighlightedSummary() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('HitHighlightedSummary', 'some text with <ddd/> and <c0>bold text</c0>\\r\\n and &lt;a href="http://google.com?q=1&p=2"&gt;a link&lt;/a&gt; and a &amp;nsbp;');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.snippet);
    System.assertEquals('some text with <b>...</b> and <b>bold text</b><br/> and a link and a &nsbp;', article.snippet);
  }

  @IsTest
  static void cleanseSnippet_should_clean_escaped_html() {
    // Given
    String snippet = 'some text with &lt;a href="http://google.com?q=1&p=2"&gt;a link&lt;/a&gt; and stuff';

    // When
    String result = CC_SearchItService.cleanseSnippet(snippet);

    // Then
    System.assertEquals('some text with a link and stuff', result);
  }

  @IsTest
  static void cleanseSnippet_should_unescaped_html() {
    // Given
    String snippet = '&amp;nsbp;';

    // When
    String result = CC_SearchItService.cleanseSnippet(snippet);

    // Then
    System.assertEquals('&nsbp;', result);
  }

  @IsTest
  static void cleanseSnippet_should_replace_ddd() {
    // Given
    String snippet = '<ddd/>';

    // When
    String result = CC_SearchItService.cleanseSnippet(snippet);

    // Then
    System.assertEquals('<b>...</b>', result);
  }

  @IsTest
  static void cleanseSnippet_should_replace_c0() {
    // Given
    String snippet = '<c0>so bold!</c0>';

    // When
    String result = CC_SearchItService.cleanseSnippet(snippet);

    // Then
    System.assertEquals('<b>so bold!</b>', result);
  }

  @IsTest
  static void cleanseSnippet_should_replace_line_breaks() {
    // Given
    String snippet = '\\r\\n';

    // When
    String result = CC_SearchItService.cleanseSnippet(snippet);

    // Then
    System.assertEquals('<br/>', result);
  }

  @IsTest
  static void parseCell_should_parse_Products() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('Products', 'my product');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.products);
    System.assertEquals(cell.Value, article.products);
  }

  @IsTest
  static void parseCell_should_parse_ContentSource() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('ContentSource', 'Wiki');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.contentSource);
    System.assertEquals(cell.Value, article.contentSource);
  }

  @IsTest
  static void parseCell_should_parse_ProductVersions() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('ProductVersions', '12345');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.productVersions);
    System.assertEquals(cell.Value, article.productVersions);
  }

  @IsTest
  static void parseCell_should_parse_Size() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('Size', '12345');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.fileSize);
    Long value = Long.valueOf(cell.Value);
    System.assertEquals(value, article.fileSize);
  }

  @IsTest
  static void parseCell_should_parse_FileType() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('FileType', 'html');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.fileType);
    System.assertEquals(cell.Value, article.fileType);
  }

  @IsTest
  static void parseCell_should_parse_TypeOfContent() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('TypeOfContent', 'Wiki');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.typeOfContent);
    System.assertEquals(cell.Value, article.typeOfContent);
  }

  @IsTest
  static void parseCell_should_parse_LastModifiedTime() {
    // Given
    CC_SearchItService.SearchItArticle article = new CC_SearchItService.SearchItArticle();
    CC_SearchItService.ResultCell cell = new CC_SearchItService.ResultCell('LastModifiedTime', '2016-01-01T00:00:00.000Z');

    // When
    CC_SearchItService.parseCell(article, cell);

    // Then
    System.assertNotEquals(null, article.lastModifiedTime);
    DateTime value = DateTime.valueOf(cell.Value.replace('T', ' '));
    System.assertEquals(value, article.lastModifiedTime);
  }

  @IsTest 
  static void SearchItResults_should_build_from_params(){
    // Given
    CC_SearchItService.SearchItArticle[] articles = new CC_SearchItService.SearchItArticle[]{new CC_SearchItService.SearchItArticle()};
    String queryText = 'text'; 
    String productName = 'name';

    // When
    CC_SearchItService.SearchItResults results = new CC_SearchItService.SearchItResults(articles, queryText, productName);

    // Then
    System.assertEquals(articles, results.articles);
    System.assertEquals(queryText, results.searchParameters.get('queryText'));
    System.assertEquals(productName, results.searchParameters.get('productName'));
  }

  static String jsonResult = '{"1":{"1-1":"1-1","1-2":{"1-2-1":"1-2-1"}},"2":"2","3":{"3-1":{"3-1-1":"3-1-1","3-1-2":[1,2,3]},"3-2":[{"3-2-1":"3-2-1"},{"3-2-2":"3-2-2"}],"3-3":{"3-3-1":[],"3-3-2":"3-3-2Value"}}}';
  static String jsonResult2 = '{"d":{"query":{"__metadata":{"type":"Microsoft.Office.Server.Search.REST.SearchResult"},"ElapsedTime":738,"PrimaryQueryResult":{"__metadata":{"type":"Microsoft.Office.Server.Search.REST.QueryResult"},"CustomResults":{"__metadata":{"type":"Collection(Microsoft.Office.Server.Search.REST.CustomResult)"},"results":[]},"QueryId":"bdd28f52-0194-43ce-877b-a670c6f88497","QueryRuleId":"00000000-0000-0000-0000-000000000000","RefinementResults":null,"RelevantResults":{"__metadata":{"type":"Microsoft.Office.Server.Search.REST.RelevantResults"},"GroupTemplateId":null,"ItemTemplateId":null,"Properties":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"GenerationId","Value":"9223372036854775806","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ExecutionTimeMs","Value":"702","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"QueryModification","Value":"Clarity (((ContentSource=TechInfo) ((CAAccessLevel=0) OR (CAAccessLevel:{\\\\User.AccessLevel}) OR (VisibleToParnter={\\\\User.IsPartner}))) OR ((ContentSource=Problems) OR (ContentSource=Solutions)) OR (ContentSource=KnowledgeBase  CAIsRetiredOWSBOOL=0) OR (ContentSource=ConfluenceContent)) (isdocument=1)","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"RenderTemplateId","Value":"~sitecollection/_catalogs/masterpage/Display Templates/Search/Group_Default.js","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piPageImpressionBlockType","Value":"2","ValueType":"Edm.Byte"}]},"ResultTitle":null,"ResultTitleUrl":null,"RowCount":5,"Table":{"__metadata":{"type":"SP.SimpleDataTable"},"Rows":{"results":[{"__metadata":{"type":"SP.SimpleDataRow"},"Cells":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"Rank","Value":"24.3521041870117","ValueType":"Edm.Double"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DocId","Value":"24440047","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Products","Value":"CA PPM","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ContentSource","Value":"ConfluenceContent","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Title","Value":"Release Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Path","Value":"http://usilasp00215:8000/_layouts/esc.Search.Services/Redirect.aspx?URL=https://docops.ca.com/display/CCPPMOP144/Release+Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CATOPSPublishUrlOWSMTXT","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ConfluenceURL","Value":"https://docops.ca.com/display/CCPPMOP144/Release+Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedSummary","Value":"The\\u00a0 14.4 Release Notes include enhanced features, compatibilities (formerly, PAS), patches, known issues, and resolved defects <ddd/> This information helps you plan for this release <ddd/> ","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ProductVersions","Value":"14 4","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Size","Value":"70012","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileType","Value":"html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"TypeOfContent","Value":"Wiki","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"LastModifiedTime","Value":"2016-06-08T17:20:39.0000000Z","ValueType":"Edm.DateTime"},{"__metadata":{"type":"SP.KeyValue"},"Key":"OriginalPath","Value":"http://usilasp00215:8000/_layouts/esc.Search.Services/Redirect.aspx?URL=https://docops.ca.com/display/CCPPMOP144/Release+Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SecondaryFileExtension","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Author","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Description","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"EditorOWSUSER","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CollapsingStatus","Value":"0","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedProperties","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileExtension","Value":"aspx","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsLifeTime","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ParentLink","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsRecent","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsContainer","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DisplayAuthor","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"docaclmeta","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeIdList","Value":"16","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"PartitionId","Value":"0c37852b-34d0-418e-91c6-2ac25af4be5b","ValueType":"Edm.Guid"},{"__metadata":{"type":"SP.KeyValue"},"Key":"UrlZone","Value":"0","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"AAMEnabledManagedProperties","Value":"AttachmentURI;deeplinks;DefaultEncodingURL;ExternalMediaURL;HierarchyUrl;OrgParentUrls;OrgUrls;OriginalPath;ParentLink;Path;PictureThumbnailURL;PictureURL;PublishingImage;recommendedfor;ServerRedirectedEmbedURL;ServerRedirectedPreviewURL;ServerRedirectedURL;SiteLogo;SitePath;SPSiteURL;UserEncodingURL","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeId","Value":"16","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"RenderTemplateId","Value":"~sitecollection/_catalogs/masterpage/Display Templates/Search/Item_WebPage.js","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piSearchResultId","Value":"0_1","ValueType":"Edm.String"}]}},{"__metadata":{"type":"SP.SimpleDataRow"},"Cells":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"Rank","Value":"24.2611541748047","ValueType":"Edm.Double"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DocId","Value":"25830013","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Products","Value":"CA PPM","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ContentSource","Value":"ConfluenceContent","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Title","Value":"Release Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Path","Value":"http://usilasp00215:8000/_layouts/esc.Search.Services/Redirect.aspx?URL=https://docops.ca.com/display/CCPPMOP143/Release+Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CATOPSPublishUrlOWSMTXT","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ConfluenceURL","Value":"https://docops.ca.com/display/CCPPMOP143/Release+Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedSummary","Value":"The  14.3 Release Notes include new features, enhanced features, compatibilities (formerly, PAS), patches, known issues, and resolved defects <ddd/> This information helps you plan for <ddd/> ","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ProductVersions","Value":"14 3","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Size","Value":"92950","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileType","Value":"html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"TypeOfContent","Value":"Wiki","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"LastModifiedTime","Value":"2016-06-10T14:31:01.0000000Z","ValueType":"Edm.DateTime"},{"__metadata":{"type":"SP.KeyValue"},"Key":"OriginalPath","Value":"http://usilasp00215:8000/_layouts/esc.Search.Services/Redirect.aspx?URL=https://docops.ca.com/display/CCPPMOP143/Release+Notes","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SecondaryFileExtension","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Author","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Description","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"EditorOWSUSER","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CollapsingStatus","Value":"0","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedProperties","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileExtension","Value":"aspx","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsLifeTime","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ParentLink","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsRecent","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsContainer","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DisplayAuthor","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"docaclmeta","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeIdList","Value":"16","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"PartitionId","Value":"0c37852b-34d0-418e-91c6-2ac25af4be5b","ValueType":"Edm.Guid"},{"__metadata":{"type":"SP.KeyValue"},"Key":"UrlZone","Value":"0","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"AAMEnabledManagedProperties","Value":"AttachmentURI;deeplinks;DefaultEncodingURL;ExternalMediaURL;HierarchyUrl;OrgParentUrls;OrgUrls;OriginalPath;ParentLink;Path;PictureThumbnailURL;PictureURL;PublishingImage;recommendedfor;ServerRedirectedEmbedURL;ServerRedirectedPreviewURL;ServerRedirectedURL;SiteLogo;SitePath;SPSiteURL;UserEncodingURL","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeId","Value":"16","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"RenderTemplateId","Value":"~sitecollection/_catalogs/masterpage/Display Templates/Search/Item_WebPage.js","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piSearchResultId","Value":"1_1","ValueType":"Edm.String"}]}},{"__metadata":{"type":"SP.SimpleDataRow"},"Cells":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"Rank","Value":"24.1937637329102","ValueType":"Edm.Double"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DocId","Value":"4038404","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Products","Value":"CA PPM","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ContentSource","Value":"TechInfo","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Title","Value":"CA Clarity PPM Release Notes - On Premise","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Path","Value":"http://ecm.ca.com/en-us/Documents/Guides/2943_0/CAClarityPPM_ReleaseNotes_ENU.pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CATOPSPublishUrlOWSMTXT","Value":"https://support.ca.com/cadocs/0/CA%20Clarity%20PPM%2013%203%2000%20%20On%20Premise%20-ENU/Bookshelf_Files/PDF/CAClarityPPM_ReleaseNotes_ENU.pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ConfluenceURL","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedSummary","Value":"If you are a licensed user of the <ddd/> 20 Appendix A: Compatibilities 23 CA <c0>Clarity</c0> PPM Servers <ddd/> about the new release of CA <c0>Clarity</c0> PPM, including the new and enhanced features and <ddd/> ","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ProductVersions","Value":"CA PPM:Release:13.3;CA PPM:Release:13.3 On Demand;CA PPM:Release:13.3 On Premise","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Size","Value":"842042","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileType","Value":"pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"TypeOfContent","Value":"Guides","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"LastModifiedTime","Value":"2014-08-19T19:13:34.0000000Z","ValueType":"Edm.DateTime"},{"__metadata":{"type":"SP.KeyValue"},"Key":"OriginalPath","Value":"http://ecm.ca.com/en-us/Documents/Guides/2943_0/CAClarityPPM_ReleaseNotes_ENU.pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SecondaryFileExtension","Value":"pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Author","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Description","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"EditorOWSUSER","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CollapsingStatus","Value":"0","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedProperties","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileExtension","Value":"pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsLifeTime","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ParentLink","Value":"http://ecm.ca.com/en-us/Documents/Guides/2943_0","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsRecent","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsContainer","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DisplayAuthor","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"docaclmeta","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeIdList","Value":"15","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"PartitionId","Value":"0c37852b-34d0-418e-91c6-2ac25af4be5b","ValueType":"Edm.Guid"},{"__metadata":{"type":"SP.KeyValue"},"Key":"UrlZone","Value":"0","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"AAMEnabledManagedProperties","Value":"AttachmentURI;deeplinks;DefaultEncodingURL;ExternalMediaURL;HierarchyUrl;OrgParentUrls;OrgUrls;OriginalPath;ParentLink;Path;PictureThumbnailURL;PictureURL;PublishingImage;recommendedfor;ServerRedirectedEmbedURL;ServerRedirectedPreviewURL;ServerRedirectedURL;SiteLogo;SitePath;SPSiteURL;UserEncodingURL","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeId","Value":"15","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"RenderTemplateId","Value":"~sitecollection/_catalogs/masterpage/Display Templates/Search/Item_PDF.js","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piSearchResultId","Value":"2_1","ValueType":"Edm.String"}]}},{"__metadata":{"type":"SP.SimpleDataRow"},"Cells":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"Rank","Value":"24.0147018432617","ValueType":"Edm.Double"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DocId","Value":"4242405","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Products","Value":"CA PPM","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ContentSource","Value":"TechInfo","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Title","Value":"CA Clarity PPM CA Clarity PPM Connector Guide - On Premise","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Path","Value":"http://ecm.ca.com/en-us/Documents/Guides/3250_0/AClarityPPM_CatalystConnector_ProductGuide_ENU.pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CATOPSPublishUrlOWSMTXT","Value":"https://support.ca.com/cadocs/0/CA%20Clarity%20PPM%2014%202%2000%20%20On%20Premise%20-ENU/Bookshelf_Files/PDF/CAClarityPPM_CatalystConnector_ProductGuide_ENU.pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ConfluenceURL","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedSummary","Value":"\\u25a0 CA <c0>Clarity</c0>\\u2122 Project &amp; Portfolio Manager (CA <c0>Clarity</c0> PPM <ddd/> 20 Chapter 4: CA <c0>Clarity</c0> PPM Connector and Domain Manager Interaction 23 Outbound from CA <c0>Clarity</c0> PPM Connector Operations <ddd/> ","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ProductVersions","Value":"CA PPM:Release:14.2;CA PPM:Release:14.2 On Demand;CA PPM:Release:14.2 On Premise;CA PPM:Release:14.1;CA PPM:Release:14.1 On Demand;CA PPM:Release:14.1 On Premise","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Size","Value":"546726","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileType","Value":"pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"TypeOfContent","Value":"Guides","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"LastModifiedTime","Value":"2015-03-20T19:32:15.0000000Z","ValueType":"Edm.DateTime"},{"__metadata":{"type":"SP.KeyValue"},"Key":"OriginalPath","Value":"http://ecm.ca.com/en-us/Documents/Guides/3250_0/AClarityPPM_CatalystConnector_ProductGuide_ENU.pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SecondaryFileExtension","Value":"pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Author","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Description","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"EditorOWSUSER","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CollapsingStatus","Value":"0","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedProperties","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileExtension","Value":"pdf","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsLifeTime","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ParentLink","Value":"http://ecm.ca.com/en-us/Documents/Guides/3250_0","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsRecent","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsContainer","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DisplayAuthor","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"docaclmeta","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeIdList","Value":"15","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"PartitionId","Value":"0c37852b-34d0-418e-91c6-2ac25af4be5b","ValueType":"Edm.Guid"},{"__metadata":{"type":"SP.KeyValue"},"Key":"UrlZone","Value":"0","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"AAMEnabledManagedProperties","Value":"AttachmentURI;deeplinks;DefaultEncodingURL;ExternalMediaURL;HierarchyUrl;OrgParentUrls;OrgUrls;OriginalPath;ParentLink;Path;PictureThumbnailURL;PictureURL;PublishingImage;recommendedfor;ServerRedirectedEmbedURL;ServerRedirectedPreviewURL;ServerRedirectedURL;SiteLogo;SitePath;SPSiteURL;UserEncodingURL","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeId","Value":"15","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"RenderTemplateId","Value":"~sitecollection/_catalogs/masterpage/Display Templates/Search/Item_PDF.js","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piSearchResultId","Value":"3_1","ValueType":"Edm.String"}]}},{"__metadata":{"type":"SP.SimpleDataRow"},"Cells":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"Rank","Value":"23.9909324645996","ValueType":"Edm.Double"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DocId","Value":"201744","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Products","Value":"CA PPM","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ContentSource","Value":"TechInfo","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Title","Value":"Release Notes - On Demand Release 14.2.00 - Release Notes: CA Clarity PPM","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Path","Value":"http://ecm.ca.com/en-us/Documents/Guides/3450_19/release_notes_ondemand.html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CATOPSPublishUrlOWSMTXT","Value":"https://support.ca.com/cadocs/0/CA%20Clarity%20PPM%2014%202%2000%20%20On%20Demand%20-ENU/Bookshelf_Files/HTML/OD--releasenotes/release_notes_ondemand.html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ConfluenceURL","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedSummary","Value":"This section contains the following topics <ddd/> Rate This Page The content on this page was useful to me.\\r\\nDisagree strongly\\r\\n 1 2 3 4 5\\r\\nAgree <ddd/> CA <c0>Clarity</c0> Agile,CA <c0>Clarity</c0> Requirements","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ProductVersions","Value":"CA PPM:Release:14.2;CA PPM:Release:14.2 On Demand","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Size","Value":"36128","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileType","Value":"html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"TypeOfContent","Value":"Guides","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"LastModifiedTime","Value":"2015-04-07T12:19:29.0000000Z","ValueType":"Edm.DateTime"},{"__metadata":{"type":"SP.KeyValue"},"Key":"OriginalPath","Value":"http://ecm.ca.com/en-us/Documents/Guides/3450_19/release_notes_ondemand.html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SecondaryFileExtension","Value":"html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Author","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"Description","Value":"Provides important information about CA Clarity PPM Release 13.3, including new and enhanced features, compatibilities, system requirements, and more.","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"EditorOWSUSER","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"CollapsingStatus","Value":"0","ValueType":"Edm.Int64"},{"__metadata":{"type":"SP.KeyValue"},"Key":"HitHighlightedProperties","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"FileExtension","Value":"html","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsLifeTime","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ParentLink","Value":"http://ecm.ca.com/en-us/Documents/Guides/3450_19","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ViewsRecent","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsContainer","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"DisplayAuthor","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"docaclmeta","Value":null,"ValueType":"Null"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeIdList","Value":"0","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"PartitionId","Value":"0c37852b-34d0-418e-91c6-2ac25af4be5b","ValueType":"Edm.Guid"},{"__metadata":{"type":"SP.KeyValue"},"Key":"UrlZone","Value":"0","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"AAMEnabledManagedProperties","Value":"AttachmentURI;deeplinks;DefaultEncodingURL;ExternalMediaURL;HierarchyUrl;OrgParentUrls;OrgUrls;OriginalPath;ParentLink;Path;PictureThumbnailURL;PictureURL;PublishingImage;recommendedfor;ServerRedirectedEmbedURL;ServerRedirectedPreviewURL;ServerRedirectedURL;SiteLogo;SitePath;SPSiteURL;UserEncodingURL","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"ResultTypeId","Value":"0","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"RenderTemplateId","Value":"~sitecollection/_catalogs/masterpage/Display Templates/Search/Item_Default.js","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piSearchResultId","Value":"4_1","ValueType":"Edm.String"}]}}]}},"TotalRows":255401,"TotalRowsIncludingDuplicates":255401},"SpecialTermResults":null},"Properties":{"results":[{"__metadata":{"type":"SP.KeyValue"},"Key":"RowLimit","Value":"5","ValueType":"Edm.Int32"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SourceId","Value":"8fdba11a-c566-4ec0-9b8d-48224cd6a0b2","ValueType":"Edm.Guid"},{"__metadata":{"type":"SP.KeyValue"},"Key":"WasGroupRestricted","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsPartial","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"piPageImpression","Value":"55701119_3985_1033","ValueType":"Edm.String"},{"__metadata":{"type":"SP.KeyValue"},"Key":"IsCached","Value":"false","ValueType":"Edm.Boolean"},{"__metadata":{"type":"SP.KeyValue"},"Key":"SerializedQuery","Value":"<Query Culture=\\"en-US\\" EnableStemming=\\"True\\" EnablePhonetic=\\"False\\" EnableNicknames=\\"False\\" IgnoreAllNoiseQuery=\\"True\\" SummaryLength=\\"180\\" MaxSnippetLength=\\"180\\" DesiredSnippetLength=\\"90\\" KeywordInclusion=\\"0\\" QueryText=\\"Clarity\\" QueryTemplate=\\"\\" TrimDuplicates=\\"True\\" Site=\\"4a855ec4-0c13-4038-8cc0-5977788df6fd\\" Web=\\"2877a3c6-372e-4d1a-979e-9a332393716e\\" KeywordType=\\"True\\" HiddenConstraints=\\"\\" />","ValueType":"Edm.String"}]},"SecondaryQueryResults":{"__metadata":{"type":"Collection(Microsoft.Office.Server.Search.REST.QueryResult)"},"results":[]},"SpellingSuggestion":"","TriggeredRules":{"__metadata":{"type":"Collection(Edm.Guid)"},"results":["6c2c6a9b-e53a-4a00-bd3b-6f33cbc788f8"]}}}}';

}