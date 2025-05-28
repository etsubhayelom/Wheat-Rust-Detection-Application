import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheat_rust_detection_application/services/api_services.dart';
import 'package:wheat_rust_detection_application/controllers/post_controllers.dart';
import 'package:wheat_rust_detection_application/views/home_page_widgets/post_card.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<dynamic> _results = [];
  bool _loading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => _loading = true);

    try {
      final results = await apiService.searchPosts(widget.query);
      debugPrint('results: $results');

      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _results = [];
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final postController = Provider.of<PostController>(context, listen: false);
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Search:"${widget.query}"'),
        ),
        body: _results.isEmpty
            ? const Center(child: Text('No results found.'))
            : ListView(
                children: _results.map((post) {
                  return PostCard(
                    post: post,
                    postController: postController,
                    apiService: apiService,
                  );
                }).toList(),
              ));
  }
}
