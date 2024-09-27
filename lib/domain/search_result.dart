import 'package:supervisor_app/domain/topic.dart';

class SearchResult {
  final List<Topic> exactMatches;
  final List<Topic> recommendations;

  SearchResult({required this.exactMatches, required this.recommendations});
}
