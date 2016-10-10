@IsTest
public class CC_Layer7ServiceMock implements CC_Layer7Service.I {
  public CC_MockCallRecorder callLogger { get; private set; }
	public CC_Layer7ServiceMock() {
		callLogger = new CC_MockCallRecorder();
	}
  public CC_Layer7Service.JsonData getSitesAndProducts(String siteId, String connectId) {
    String methodName = 'getSitesAndProducts';
    Map<String, Object> params = new Map<String, Object> {'siteId' => siteId, 'connectId' => connectId};
    Object returnValue = callLogger.getRecordedCall(methodName, params).returnValue;
    callLogger.logCall(methodName, params, returnValue);
    return (CC_Layer7Service.JsonData)returnValue;
  }
}