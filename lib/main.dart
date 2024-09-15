import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/db/auth_repository.dart';
import 'package:story_app/provider/api_provider.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/provider/add_story_provider.dart';
import 'package:story_app/provider/upload_provider.dart';
import 'package:story_app/routes/router_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/url_strategy.dart';
import 'routes/route_information_parser.dart';

void main() {
  usePathUrlStrategy();
  runApp(const StoryApp());
}

class StoryApp extends StatefulWidget {
  const StoryApp({super.key});

  @override
  State<StoryApp> createState() => _StoryAppState();
}

class _StoryAppState extends State<StoryApp> {
  late MyRouterDelegate myRouterDelegate;
  late MyRouteInformationParser myRouteInformationParser;
  late AuthProvider authProvider;
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepository();

    apiService = ApiService();
    authProvider = AuthProvider(authRepository, apiService);
    myRouterDelegate = MyRouterDelegate(authRepository);
    myRouteInformationParser = MyRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authProvider),
        ChangeNotifierProvider(create: (context) => AddStoryProvider()),
        ChangeNotifierProvider(create: (context) => UploadProvider(apiService)),
        ChangeNotifierProvider(
          create: (context) => ApiProvider(ApiService()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Story App',
        routerDelegate: myRouterDelegate,
        routeInformationParser: myRouteInformationParser,
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}
