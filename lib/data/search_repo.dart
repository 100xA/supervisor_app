import 'package:supervisor_app/data/supervisor_repo.dart';

import 'package:supervisor_app/domain/topic.dart';

class SearchRepository {
  final SupervisorRepository supervisorRepository;

  SearchRepository(this.supervisorRepository);

  Future<List<Topic>> searchTopics(String query) async {
    return await supervisorRepository.searchTopics(query);
  }
}
