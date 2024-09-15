import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/db/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:story_app/data/model/serialization/token.dart';
import 'package:story_app/data/model/serialization/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final ApiService apiService;

  AuthProvider(this.authRepository, this.apiService);

  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;

  Future<bool> login(Map<String, dynamic> user) async {
    isLoadingLogin = true;
    notifyListeners();

    try {
      final userState = await apiService.httpRequest(
        endpoints: 'login',
        method: 'post',
        headers: null,
        bodyPost: user,
        query: '',
      );

      if (userState['error'] == false) {
        Map<String, dynamic> loginResultToken = userState['loginResult'];
        Token token = Token(
          userId: loginResultToken['userId'],
          name: loginResultToken['name'],
          token: loginResultToken['token'],
        );
        await authRepository.login();
        await authRepository.saveToken(token);
      }

      isLoggedIn = await authRepository.isLoggedIn();

      isLoadingLogin = false;
      notifyListeners();
      return isLoggedIn;
    } catch (e) {
      isLoadingLogin = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> getToken() async {
    final userState = await authRepository.getToken();
    return userState?.token;
  }

  Future<bool> logout() async {
    isLoadingLogout = true;
    notifyListeners();

    final logout = await authRepository.logout();
    if (logout) {
      await authRepository.deleteToken();
    }
    isLoggedIn = await authRepository.isLoggedIn();

    isLoadingLogout = false;
    notifyListeners();

    return !isLoggedIn;
  }

  Future<bool> saveUser(User user) async {
    isLoadingRegister = true;
    notifyListeners();

    final userState = await authRepository.saveUser(user);

    isLoadingRegister = false;
    notifyListeners();

    return userState;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> user) async {
    isLoadingRegister = true;
    notifyListeners();

    try {
      final userState = await apiService.httpRequest(
        endpoints: 'register',
        method: 'post',
        headers: null,
        bodyPost: user,
        query: '',
      );

      isLoadingRegister = false;
      notifyListeners();

      return userState;
    } catch (e) {
      isLoadingRegister = false;
      notifyListeners();
      return {'error': true, 'message': e};
    }
  }
}
