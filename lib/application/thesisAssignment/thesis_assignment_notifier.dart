import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/domain/supervisor.dart';
import 'package:supervisor_app/domain/thesis.dart';

class ThesisAssignmentState {
  final List<Thesis> theses;
  final List<Supervisor> reviewers;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  ThesisAssignmentState({
    required this.theses,
    required this.reviewers,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ThesisAssignmentState copyWith({
    List<Thesis>? theses,
    List<Supervisor>? reviewers,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ThesisAssignmentState(
      theses: theses ?? this.theses,
      reviewers: reviewers ?? this.reviewers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Search supervisors by name or email, case-insensitive
  List<Supervisor> get filteredReviewers {
    final query = searchQuery.toLowerCase();
    return reviewers
        .where((reviewer) =>
            reviewer.name.toLowerCase().contains(query) ||
            reviewer.email.toLowerCase().contains(query))
        .toList();
  }

  // Get only theses without a second reviewer assigned
  List<Thesis> get unassignedTheses {
    return theses.where((thesis) => thesis.secondReviewer.isEmpty).toList();
  }
}

// StateNotifier for managing thesis assignment state
class ThesisAssignmentNotifier extends StateNotifier<ThesisAssignmentState> {
  final FirebaseFirestore _firestore;

  ThesisAssignmentNotifier(this._firestore)
      : super(ThesisAssignmentState(theses: [], reviewers: [])) {
    _initializeData();
  }

  // Initialize supervisors and their supervised theses
  void _initializeData() async {
    state = state.copyWith(isLoading: true);
    try {
      final reviewersSnapshot =
          await _firestore.collection('supervisors').get();

      List<Thesis> allTheses = [];

      // Fetch supervisors and their supervised theses
      for (QueryDocumentSnapshot supervisorDoc in reviewersSnapshot.docs) {
        // Extract and convert supervisedTheses into Thesis objects
        List<Thesis> supervisedTheses =
            (supervisorDoc['supervisedTheses'] as List)
                .map((thesisData) => Thesis.fromMap(thesisData))
                .toList();

        allTheses.addAll(supervisedTheses);
      }

      // Fetch all reviewers (supervisors)
      final reviewers = reviewersSnapshot.docs
          .map((doc) => Supervisor.fromFirestore(doc))
          .toList();

      // Update the state with theses and reviewers
      state = state.copyWith(
        theses: allTheses,
        reviewers: reviewers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Set the search query for filtering reviewers
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Assign a second reviewer to the thesis
  Future<void> assignReviewer(Thesis thesis, Supervisor reviewer) async {
    state = state.copyWith(isLoading: true);
    try {
      // Fetch all supervisors
      final supervisorsSnapshot =
          await _firestore.collection('supervisors').get();

      DocumentSnapshot? supervisorDoc;
      List supervisedTheses = [];
      int thesisIndex = -1;

      // Find the specific supervisor who has this thesis in their supervisedTheses array
      for (var doc in supervisorsSnapshot.docs) {
        List thesesArray = doc['supervisedTheses'];

        // Look for the thesis with the matching studentId
        thesisIndex =
            thesesArray.indexWhere((t) => t['studentId'] == thesis.studentId);
        if (thesisIndex != -1) {
          supervisorDoc = doc;
          supervisedTheses = thesesArray;
          break;
        }
      }

      if (supervisorDoc == null) {
        throw Exception('No supervisor found with the provided thesis.');
      }

      // Update the thesis in the array with the second reviewer information
      supervisedTheses[thesisIndex]['secondReviewerId'] = reviewer.id;
      supervisedTheses[thesisIndex]['secondReviewer'] = reviewer.name;

      // Update the supervisor document with the modified supervisedTheses array
      await _firestore
          .collection('supervisors')
          .doc(supervisorDoc.id)
          .update({'supervisedTheses': supervisedTheses});

      // Update the local state with the new reviewer assignment
      final updatedTheses = state.theses.map((t) {
        if (t.studentId == thesis.studentId) {
          return t.copyWith(
            secondReviewer: reviewer.name,
            secondReviewerId: reviewer.id,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(theses: updatedTheses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Method to search for supervised theses by supervisor, case-insensitive
  List<Thesis> searchSupervisedTheses(String supervisorName) {
    final query = supervisorName.toLowerCase();
    return state.unassignedTheses
        .where((thesis) => thesis.firstReviewer.toLowerCase().contains(query))
        .toList();
  }
}
