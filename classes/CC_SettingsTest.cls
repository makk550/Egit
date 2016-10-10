@isTest
private class CC_SettingsTest{
	@isTest
	static void it_should_initialize_csoUrl(){
		String result = CC_Settings.csoUrl;
		System.assertNotEquals(null ,result);
	}

	@isTest
	static void it_should_initialize_communityUserProfileId(){
		String result = CC_Settings.communityUserProfileId ;
		System.assertNotEquals(null, result);
	}

	@isTest
	static void it_should_instantiate_communityUserDefaultAccountId(){
		String result = CC_Settings.communityUserDefaultAccountId;
		System.assertNotEquals(null, result);		
	}

	@isTest
	static void it_should_instantiate_searchDotCaDotComSourceId (){
		String result = CC_Settings.searchDotCaDotComSourceId ;
		System.assertNotEquals(null, result);	
	}

	@isTest
	static void it_should_instantiate_debugEnabled(){
		Boolean result = CC_Settings.debugEnabled;
		System.assertNotEquals(null, result);
	}
	
	@isTest
	static void it_should_instantiate_caseSearchMaxResults(){
		Integer result = CC_Settings.caseSearchMaxResults;
		System.assertNotEquals(null, result);
	}

	@isTest
	static void it_should_instantiate_allowAccessRoles(){
		Set<String> result = CC_Settings.allowAccessRoles;
		System.assertNotEquals(null, result);
	}
}