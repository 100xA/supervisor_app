import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

void sendTestData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Random random = Random();

  // Fetch student IDs from Firestore (assuming they are already in the students collection)
  QuerySnapshot studentSnapshot = await firestore.collection('students').get();
  List<String> studentIds = studentSnapshot.docs.map((doc) => doc.id).toList();
  // Generate and push 10 students
  for (int i = 0; i < 10; i++) {
    DocumentReference studentRef = await firestore.collection('students').add({
      'name': 'Student ${i + 1}',
      'email': 'student${i + 1}@example.com',
      'proposedTopic': [
        'AI-Powered Diagnostics in Healthcare',
        'Blockchain for Secure Supply Chains',
        'Augmented Reality in Education',
        'Quantum Computing for Cryptography',
        'Sustainable Urban Development',
        'Machine Learning for Climate Change Prediction',
        'Ethical Implications of AI in Law',
        'IoT for Smart Agriculture',
        'Cybersecurity in Autonomous Vehicles',
        'Big Data in Retail Analytics'
      ][i],
      'thesisStatus': [
        "written out",
        "started",
        "handed in",
        "invoiced",
        "paid",
      ][random.nextInt(4)],
      'proposalSubmissionDate': Timestamp.now(),
    });

    // Store student Document ID for cross-referencing
    studentIds.add(studentRef.id);
  }

  // Ensure there are enough students
  if (studentIds.length < 10) {
    dev.log('Not enough students in the database.');
    return;
  }

  // Supervisor names and distinct announced topics
  List<Map<String, dynamic>> supervisorsData = [
    {
      'name': 'Dr. Alice Johnson',
      'announcedTopics': [
        {
          'title': 'AI for Predictive Healthcare',
          'description':
              'Leveraging AI for early detection and prediction of diseases.'
        },
        {
          'title': 'Robotics in Surgical Procedures',
          'description':
              'Exploring the role of robotic assistance in minimally invasive surgeries.'
        }
      ]
    },
    {
      'name': 'Dr. Michael Brown',
      'announcedTopics': [
        {
          'title': 'Blockchain for Financial Transparency',
          'description':
              'Investigating how blockchain can promote transparency in global financial systems.'
        },
        {
          'title': 'Decentralized Identity Management',
          'description':
              'Using blockchain to create secure, decentralized identity solutions.'
        }
      ]
    },
    {
      'name': 'Dr. Sarah Lee',
      'announcedTopics': [
        {
          'title': 'Quantum Cryptography for Data Security',
          'description':
              'Exploring quantum encryption techniques for securing sensitive data.'
        },
        {
          'title': 'Quantum Computing for Drug Discovery',
          'description':
              'Leveraging quantum computing to speed up drug discovery and development processes.'
        }
      ]
    }

    // Other supervisors...
  ];

  // Shuffle studentIds to ensure randomness in assignment
  studentIds.shuffle(random);

  // Generate and push 10 supervisors
  for (var supervisorData in supervisorsData) {
    // First, add the supervisor document to Firestore
    DocumentReference supervisorRef =
        await firestore.collection('supervisors').add({
      'name': supervisorData['name'],
      'email': supervisorData['name'].toLowerCase().replaceAll(' ', '.') +
          '@example.com',
      'researchInterests': [
        'AI',
        'Blockchain',
        'Quantum Computing',
        'Cybersecurity',
        'Data Science'
      ].sublist(0, 3), // Pick first 3 interests
      'announcedTopics': List.generate(
        supervisorData['announcedTopics'].length,
        (index) => {
          'id': 'topic_${supervisorData['name']}_$index',
          'title': supervisorData['announcedTopics'][index]['title'],
          'description': supervisorData['announcedTopics'][index]
              ['description'],
        },
      ),
    });

    // Then, update the supervisor document with the theses
    List<Map<String, dynamic>> supervisedTheses = [];

    // Assign between 0-4 theses to this supervisor, ensuring unique student IDs
    int numTheses = random.nextInt(5); // Between 0 and 4 theses

    for (int i = 0; i < numTheses; i++) {
      if (studentIds.isEmpty) {
        dev.log('No more students left to assign.');
        break;
      }

      // Remove studentId from the list to ensure uniqueness
      String studentId = studentIds.removeLast();

      supervisedTheses.add({
        'studentId': studentId,
        'topic': [
          'AI-Powered Diagnostics in Healthcare',
          'Blockchain for Secure Supply Chains',
          'Augmented Reality in Education',
          'Quantum Computing for Cryptography',
          'Sustainable Urban Development',
          'Machine Learning for Climate Change Prediction',
          'Ethical Implications of AI in Law',
          'IoT for Smart Agriculture',
          'Cybersecurity in Autonomous Vehicles',
          'Big Data in Retail Analytics'
        ][random.nextInt(10)],
        'status': [
          'in discussion',
          'registered',
          'submitted',
          'colloquium held'
        ][random.nextInt(4)],
        // Assign supervisorRef.id to firstReviewer
        'firstReviewer': supervisorRef.id,
        // Add empty fields for secondReviewer and secondReviewerId
        'secondReviewer': '',
        'secondReviewerId': '',
        'invoiceStatus': [
          'not submitted',
          'submitted',
          'paid'
        ][random.nextInt(3)],
      });
    }

    // Now update the supervisor document with the supervised theses
    await supervisorRef.update({
      'supervisedTheses': supervisedTheses,
    });
  }

  dev.log(
      'Supervisors with unique student theses have been added to the database.');
}
