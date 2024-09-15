import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/model/api_state.dart';
import 'package:story_app/provider/auth_provider.dart';
import 'package:story_app/provider/api_provider.dart';
import 'package:story_app/screen/story_detail/story_detail_info.dart';

class StoryDetailsScreen extends StatefulWidget {
  final String storyId;
  final Map<String, dynamic> storyData;
  final Function(LatLng) onCheckLocation;

  const StoryDetailsScreen({
    super.key,
    required this.storyId,
    required this.storyData,
    required this.onCheckLocation,
  });

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchStoryDetail();
  }

  Future<void> _fetchStoryDetail() async {
    final authProvider = context.read<AuthProvider>();
    final apiProvider = context.read<ApiProvider>();
    final token = await authProvider.getToken();

    if (token != null) {
      await apiProvider.getStoryDetail(widget.storyId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kembali"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Hero(
                tag: 'story_${widget.storyId}',
                child: Image.network(
                  widget.storyData['photoUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 48.0, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Consumer<ApiProvider>(
                builder: (context, apiProvider, child) {
                  final state = apiProvider.storyDetailState;

                  if (state == ApiState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state == ApiState.noConnection) {
                    return hasError(
                        Icons.wifi_off, apiProvider.storyDetailMessage);
                  } else if (state == ApiState.noData) {
                    return hasError(
                        Icons.question_mark, apiProvider.storyDetailMessage);
                  } else if (state == ApiState.error) {
                    return hasError(
                        Icons.error, apiProvider.storyDetailMessage);
                  } else if (state == ApiState.loaded) {
                    final story = apiProvider.storyDetail!.story;

                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StoryDetailInfo(
                              story: story,
                              tinggiLayar: tinggiLayar,
                              onCheckLocation: widget.onCheckLocation),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget hasError(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48.0),
          const SizedBox(height: 16.0),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
