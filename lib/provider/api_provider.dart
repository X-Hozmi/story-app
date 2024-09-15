import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/api_state.dart';
import 'package:story_app/data/model/serialization/asset_detail_response.dart';
import 'package:story_app/data/model/serialization/story.dart';

class ApiProvider extends ChangeNotifier {
  final ApiService apiService;
  ApiProvider(this.apiService);

  ApiState storiesState = ApiState.initial;
  String storiesMessage = "";
  bool storiesError = false;
  List<Story> stories = [];

  DetailResponse? storyDetail;
  ApiState storyDetailState = ApiState.initial;
  String storyDetailMessage = "";

  int? pageItems = 1;
  int sizeItems = 4;

  void resetStories() {
    stories = [];
    pageItems = 1;
    storiesState = ApiState.initial;
    notifyListeners();
  }

  void resetStoryDetail() {
    storyDetail = null;
    storyDetailState = ApiState.initial;
    notifyListeners();
  }

  Future<void> getStories(String? token) async {
    try {
      if (pageItems == 1) {
        storiesState = ApiState.loading;
        notifyListeners();
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        storiesState = ApiState.noConnection;
        storiesError = true;
        storiesMessage =
            "Sepertinya kamu belum terhubung ke internet. Silakan hidupkan koneksi internet lalu coba lagi";
        notifyListeners();
        return;
      }

      final result = await apiService.getStories(pageItems!, sizeItems, token);

      if (result.listStory.isEmpty) {
        storiesState = ApiState.noData;
        storiesError = true;
        storiesMessage = "Belum ada data yang dapat ditampilkan";
        notifyListeners();
        return;
      }

      stories.addAll(result.listStory);
      storiesMessage = "Success";
      storiesError = false;
      storiesState = ApiState.loaded;

      if (result.listStory.length < sizeItems) {
        pageItems = null;
      } else {
        pageItems = pageItems! + 1;
      }

      notifyListeners();
    } catch (e) {
      storiesState = ApiState.error;
      storiesError = true;
      storiesMessage = 'Galat';
      notifyListeners();
    }
  }

  Future<void> getStoryDetail(String storyId, String token) async {
    try {
      storyDetailState = ApiState.loading;
      notifyListeners();

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        storyDetailState = ApiState.noConnection;
        storyDetailMessage =
            "Sepertinya kamu belum terhubung ke internet. Silakan hidupkan koneksi internet lalu coba lagi";
        notifyListeners();
        return;
      }

      final result = await apiService.httpRequestDetail(
        endpoints: 'stories/$storyId',
        headers: {'Authorization': 'Bearer $token'},
      );

      storyDetail = result;
      storyDetailState = ApiState.loaded;
      notifyListeners();
    } catch (e) {
      storyDetailState = ApiState.error;
      storyDetailMessage = 'Galat';
      notifyListeners();
    }
  }
}
