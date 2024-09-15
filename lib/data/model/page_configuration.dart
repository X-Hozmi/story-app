class PageConfiguration {
  final bool unknown;
  final bool register;
  final bool? loggedIn;
  final bool? addStory;
  final bool? storyMap;
  final String? storyId;

  PageConfiguration.splash()
      : unknown = false,
        register = false,
        loggedIn = null,
        addStory = null,
        storyMap = null,
        storyId = null;

  PageConfiguration.login()
      : unknown = false,
        register = false,
        loggedIn = false,
        addStory = false,
        storyMap = null,
        storyId = null;

  PageConfiguration.register()
      : unknown = false,
        register = true,
        loggedIn = false,
        addStory = false,
        storyMap = null,
        storyId = null;

  PageConfiguration.home()
      : unknown = false,
        register = false,
        loggedIn = true,
        addStory = false,
        storyMap = null,
        storyId = null;

  PageConfiguration.detailStory(String id)
      : unknown = false,
        register = false,
        loggedIn = true,
        addStory = false,
        storyMap = null,
        storyId = id;

  PageConfiguration.addStory()
      : unknown = false,
        register = false,
        loggedIn = true,
        addStory = true,
        storyMap = null,
        storyId = null;

  PageConfiguration.storyMap(String id)
      : unknown = false,
        register = false,
        loggedIn = true,
        addStory = false,
        storyMap = true,
        storyId = id;

  PageConfiguration.unknown()
      : unknown = true,
        register = false,
        loggedIn = null,
        addStory = null,
        storyMap = null,
        storyId = null;

  bool get isSplashPage => unknown == false && loggedIn == null;
  bool get isLoginPage => unknown == false && loggedIn == false;
  bool get isHomePage =>
      unknown == false && loggedIn == true && storyId == null;
  bool get isDetailPage =>
      unknown == false && loggedIn == true && storyId != null;
  bool get isRegisterPage => register == true;
  bool get isAddStoryPage =>
      unknown == false && loggedIn == true && addStory == true;
  bool get isStoryMap =>
      unknown == false &&
      loggedIn == true &&
      (storyId != null || addStory == true);
  bool get isUnknownPage => unknown == true;
}
