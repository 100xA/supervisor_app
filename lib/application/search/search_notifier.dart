import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/data/search_repo.dart';
import 'package:supervisor_app/domain/search_result.dart';

class SearchNotifier extends StateNotifier<AsyncValue<SearchResult>> {
  final SearchRepository _searchRepository;

  SearchNotifier(this._searchRepository)
      : super(AsyncValue.data(
            SearchResult(exactMatches: [], recommendations: [])));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state =
          AsyncValue.data(SearchResult(exactMatches: [], recommendations: []));
      return;
    }

    state = const AsyncValue.loading();

    try {
      final allResults = await _searchRepository.searchTopics(query);

      // Separate exact matches and recommendations
      final exactMatches = allResults
          .where((topic) =>
              topic.title
                  .toLowerCase()
                  .split(' ')
                  .contains(query.toLowerCase()) ||
              topic.description
                  .toLowerCase()
                  .split(' ')
                  .contains(query.toLowerCase()))
          .toList();

      final recommendations =
          allResults.where((topic) => !exactMatches.contains(topic)).toList();

      // Sort recommendations by similarity to query
      recommendations.sort((a, b) {
        int aScore = _calculateSimilarity(a.title, query) +
            _calculateSimilarity(a.description, query);
        int bScore = _calculateSimilarity(b.title, query) +
            _calculateSimilarity(b.description, query);
        return bScore.compareTo(aScore);
      });

      state = AsyncValue.data(SearchResult(
          exactMatches: exactMatches, recommendations: recommendations));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  int _calculateSimilarity(String text, String query) {
    final textWords = text.toLowerCase().split(' ');
    final queryWords = query.toLowerCase().split(' ');
    return queryWords.where((word) => textWords.contains(word)).length;
  }
}
