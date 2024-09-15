import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/model/api_state.dart';
import 'package:story_app/provider/api_provider.dart';
import 'package:story_app/widgets/expandable_fab.dart';

import '../provider/auth_provider.dart';

class StoriesListScreen extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onTappedDetail;
  final Function(bool) onTappedAdd;
  final Function() onLogout;

  const StoriesListScreen({
    super.key,
    required this.onTappedDetail,
    required this.onTappedAdd,
    required this.onLogout,
  });

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final ScrollController scrollController = ScrollController();
  String? token;

  @override
  void initState() {
    super.initState();
    _getTokenAndFetchStories();
  }

  Future<void> _getTokenAndFetchStories() async {
    final authProvider = context.read<AuthProvider>();
    final apiProvider = context.read<ApiProvider>();
    token = await authProvider.getToken();

    if (token != null) {
      apiProvider.getStories(token!);
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (apiProvider.pageItems != null) {
          apiProvider.getStories(token!);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authWatch = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Story App"),
      ),
      body: Consumer<ApiProvider>(
        builder: (context, value, child) {
          final state = value.storiesState;

          if (state == ApiState.loading && value.pageItems == 1) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == ApiState.noConnection) {
            return hasError(Icons.wifi_off, value.storiesMessage);
          } else if (state == ApiState.noData) {
            return hasError(Icons.question_mark, value.storiesMessage);
          } else if (state == ApiState.error) {
            return hasError(Icons.error, value.storiesMessage);
          } else if (state == ApiState.loaded) {
            final stories = value.stories;

            return GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1),
              itemCount: stories.length + (value.pageItems != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == stories.length && value.pageItems != null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final story = stories[index];
                return InkWell(
                  onTap: () {
                    final apiProvider = context.read<ApiProvider>();
                    apiProvider.resetStoryDetail();
                    widget
                        .onTappedDetail(story.id, {'photoUrl': story.photoUrl});
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: 'story_${story.id}',
                            child: SizedBox(
                              width: 100,
                              child: Image.network(
                                story.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image,
                                            size: 48.0, color: Colors.grey),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            story.name,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format(story.createdAt),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () async {
              widget.onTappedAdd(true);
            },
            icon: const Icon(Icons.add),
          ),
          ActionButton(
            onPressed: () async {
              final authRead = context.read<AuthProvider>();
              final result = await authRead.logout();
              if (result) widget.onLogout();
            },
            icon: authWatch.isLoadingLogout
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.logout),
          ),
        ],
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
