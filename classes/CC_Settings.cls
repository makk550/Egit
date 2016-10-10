public class CC_Settings {
	
  public static String csoUrl { 
    get {
      if (csoUrl == null) {
        csoUrl = [SELECT Value__c FROM Customer_Community_Setting__mdt WHERE DeveloperName = 'CSO_URL'].Value__c;
      }
      return csoUrl;
    }
    set;
  }

  public static Id communityUserProfileId { 
    get {
      if (communityUserProfileId == null) {
        communityUserProfileId = (Id)[SELECT Value__c FROM Customer_Community_Setting__mdt WHERE DeveloperName = 'Community_User_Profile_ID'].Value__c;
      }
      return communityUserProfileId;
    }
    set;
  }

  public static Id communityUserDefaultAccountId { 
    get {
      if (communityUserDefaultAccountId == null) {
        communityUserDefaultAccountId = (Id)[SELECT Value__c FROM Customer_Community_Setting__mdt WHERE DeveloperName = 'Community_User_Default_Account_ID'].Value__c;
      }
      return communityUserDefaultAccountId;
    }
    set;
  }

  public static String searchDotCaDotComSourceId { 
    get {
      if (searchDotCaDotComSourceId == null) {
        searchDotCaDotComSourceId = (String)[SELECT Value__c FROM Customer_Community_Setting__mdt WHERE DeveloperName = 'search_ca_com_SourceId'].Value__c;
      }
      return searchDotCaDotComSourceId;
    }
    set;
  }

  public static Boolean debugEnabled { 
    get {
      if (debugEnabled == null) {
        try {
          debugEnabled = Boolean.valueOf([SELECT Value__c FROM Customer_Community_Setting__mdt WHERE DeveloperName = 'Debug_Enabled'].Value__c);
        } catch (exception ex) {
          debugEnabled = false;
        }
      }
      return debugEnabled;
    }
    set;
  }

  public static Integer caseSearchMaxResults { 
    get {
      if (caseSearchMaxResults == null) {
        try {
          caseSearchMaxResults = Integer.valueOf([SELECT Value__c FROM Customer_Community_Setting__mdt WHERE DeveloperName = 'Case_Search_Max_Results'].Value__c);
        } catch (exception ex) {
          caseSearchMaxResults = 500;
        }
      }
      return caseSearchMaxResults;
    }
    set;
  }

  public static Set<String> allowAccessRoles { 
    get {
      if(allowAccessRoles == null){
        allowAccessRoles = new Set<String>();
        List<Customer_Community_Setting__mdt> rolesAllowed = [SELECT Value__c FROM Customer_Community_Setting__mdt WHERE Type__c = 'Access Role'];
        for(Customer_Community_Setting__mdt role: rolesAllowed){
          allowAccessRoles.add(role.Value__c);
        }
      }
      return allowAccessRoles;
    } 
    set; 
  }
}