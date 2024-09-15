import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:story_app/data/model/page_configuration.dart';
import 'package:story_app/screen/add_story_screen.dart';
import 'package:story_app/screen/map_screen.dart';
import 'package:story_app/screen/register_screen.dart';
import 'package:flutter/material.dart';

import '../data/db/auth_repository.dart';
import '../screen/login_screen.dart';
import '../screen/story_detail/story_detail_screen.dart';
import '../screen/stories_list_screen.dart';
import '../screen/splash_screen.dart';
import '../screen/unknown_screen.dart';

class MyRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthRepository authRepository;

  bool? isUnknown;

  MyRouterDelegate(
    this.authRepository,
  ) : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    isLoggedIn = await authRepository.isLoggedIn();
    getCurrentLocation();
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String? selectedStory;
  Map<String, dynamic>? storyData;

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool isAddStoryPage = false;
  bool isStoryMap = false;
  LatLng latLon = const LatLng(0, 0);

  void getCurrentLocation() async {
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        log("Location services is not available");
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        log("Location permission is denied");
        return;
      }
    }

    locationData = await location.getLocation();
    latLon = LatLng(locationData.latitude!, locationData.longitude!);
  }

  void _resetLatLon() async {
    getCurrentLocation();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (isUnknown == true) {
      historyStack = _unknownStack;
    } else if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        isRegister = false;

        if (isStoryMap) {
          isStoryMap = false;
        } else {
          isAddStoryPage = false;
          selectedStory = null;
          _resetLatLon();
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  PageConfiguration? get currentConfiguration {
    if (isLoggedIn == null) {
      return PageConfiguration.splash();
    } else if (isRegister == true) {
      return PageConfiguration.register();
    } else if (isLoggedIn == false) {
      return PageConfiguration.login();
    } else if (isUnknown == true) {
      return PageConfiguration.unknown();
    } else if (selectedStory == null) {
      return PageConfiguration.home();
    } else if (selectedStory != null && isStoryMap) {
      return PageConfiguration.storyMap(selectedStory!);
    } else if (isAddStoryPage && isStoryMap) {
      return PageConfiguration.storyMap('');
    } else if (selectedStory != null) {
      return PageConfiguration.detailStory(selectedStory!);
    } else if (isAddStoryPage) {
      return PageConfiguration.addStory();
    } else {
      return null;
    }
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) async {
    if (configuration.isUnknownPage) {
      isUnknown = true;
      isRegister = false;
    } else if (configuration.isRegisterPage) {
      isRegister = true;
    } else if (configuration.isAddStoryPage) {
      isUnknown = false;
      isRegister = false;
      selectedStory = null;
    } else if (configuration.isStoryMap) {
      isUnknown = false;
      isRegister = false;
      selectedStory = configuration.storyId.toString();
    } else if (configuration.isHomePage ||
        configuration.isLoginPage ||
        configuration.isSplashPage) {
      isUnknown = false;
      selectedStory = null;
      isRegister = false;
    } else if (configuration.isDetailPage) {
      isUnknown = false;
      isRegister = false;
      selectedStory = configuration.storyId.toString();
    } else {
      log('Could not set new route');
    }

    notifyListeners();
  }

  List<Page> get _unknownStack => const [
        MaterialPage(
          key: ValueKey("UnknownPage"),
          child: UnknownScreen(),
        ),
      ];

  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("SplashScreen"),
          child: SplashScreen(),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginScreen(
            onLogin: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterScreen(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("StoriesListPage"),
          child: StoriesListScreen(
            onTappedDetail:
                (String storyId, Map<String, dynamic> storyDataGet) {
              selectedStory = storyId;
              storyData = storyDataGet;
              notifyListeners();
            },
            onTappedAdd: (bool value) {
              isAddStoryPage = true;
              notifyListeners();
            },
            onLogout: () {
              isLoggedIn = false;
              notifyListeners();
            },
          ),
        ),
        if (selectedStory != null && isStoryMap)
          MaterialPage(
            key: const ValueKey("StoryMap"),
            child: MapScreen(
              latLon: latLon,
              onSelectedLocation: (latLon) {
                isStoryMap = false;
                notifyListeners();
              },
            ),
          ),
        if (selectedStory != null && !isStoryMap)
          MaterialPage(
            key: ValueKey(selectedStory),
            child: StoryDetailsScreen(
              storyId: selectedStory!,
              storyData: storyData!,
              onCheckLocation: (latLon) {
                isStoryMap = true;
                this.latLon = latLon;
                notifyListeners();
              },
            ),
          ),
        if (isAddStoryPage && isStoryMap)
          MaterialPage(
            key: const ValueKey("StoryMap"),
            child: MapScreen(
              latLon: latLon,
              onSelectedLocation: (latLon) {
                isStoryMap = false;
                this.latLon = latLon;
                notifyListeners();
              },
            ),
          ),
        if (isAddStoryPage && !isStoryMap)
          MaterialPage(
            key: const ValueKey("AddStoryPage"),
            child: AddStoryScreen(
              latLon: latLon,
              onGetLocation: () {
                isStoryMap = true;
                notifyListeners();
              },
              onStoryAdded: () {
                isAddStoryPage = false;
                notifyListeners();
              },
            ),
          ),
      ];
}
