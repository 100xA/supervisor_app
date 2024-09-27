import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

void sendTestData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Random random = Random();

  List<String> studentIds = [];

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
        'in discussion',
        'registered',
        'submitted',
        'colloquium held'
      ][random.nextInt(4)],
      'proposalSubmissionDate': Timestamp.now(),
    });

    // Store student Document ID for cross-referencing
    studentIds.add(studentRef.id);
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
    },
    {
      'name': 'Dr. David Garcia',
      'announcedTopics': [
        {
          'title': 'Sustainable Architecture for Urban Areas',
          'description':
              'Exploring green building technologies for sustainable urban infrastructure.'
        },
        {
          'title': 'AI in Smart City Planning',
          'description':
              'Using artificial intelligence to optimize resource allocation in smart cities.'
        }
      ]
    },
    {
      'name': 'Dr. Emily Zhang',
      'announcedTopics': [
        {
          'title': 'IoT for Precision Agriculture',
          'description':
              'Utilizing IoT technologies for optimizing agricultural practices and crop monitoring.'
        },
        {
          'title': 'AI in Climate Change Mitigation',
          'description':
              'Investigating the role of AI in tracking and mitigating climate change.'
        }
      ]
    },
    {
      'name': 'Dr. John Carter',
      'announcedTopics': [
        {
          'title': 'Machine Learning for Autonomous Vehicles',
          'description':
              'Developing machine learning algorithms for safe navigation in autonomous vehicles.'
        },
        {
          'title': 'Cybersecurity in Automotive Networks',
          'description':
              'Ensuring security and privacy in connected vehicle systems.'
        }
      ]
    },
    {
      'name': 'Dr. Olivia Miller',
      'announcedTopics': [
        {
          'title': 'Data Analytics for Retail Optimization',
          'description':
              'Leveraging big data to optimize supply chain and customer behavior analysis in retail.'
        },
        {
          'title': 'AI in E-commerce Personalization',
          'description':
              'Exploring the use of AI to enhance personalized shopping experiences in e-commerce.'
        }
      ]
    },
    {
      'name': 'Dr. Robert Evans',
      'announcedTopics': [
        {
          'title': 'AI for Real-time Financial Analytics',
          'description':
              'Using AI to provide real-time insights into financial markets and transactions.'
        },
        {
          'title': 'Blockchain for Secure Voting Systems',
          'description':
              'Designing secure and transparent voting systems using blockchain technology.'
        }
      ]
    },
    {
      'name': 'Dr. Sophie Turner',
      'announcedTopics': [
        {
          'title': 'AI in Personalized Learning Platforms',
          'description':
              'Developing AI-driven systems to provide personalized learning experiences in education.'
        },
        {
          'title': 'Augmented Reality for Education',
          'description':
              'Using AR to enhance interactive learning environments in classrooms.'
        }
      ]
    },
    {
      'name': 'Dr. James Anderson',
      'announcedTopics': [
        {
          'title': 'Cybersecurity in Cloud Computing',
          'description':
              'Exploring advanced security measures to protect data in cloud-based systems.'
        },
        {
          'title': 'AI for Malware Detection',
          'description':
              'Leveraging artificial intelligence to detect and mitigate malicious software attacks.'
        }
      ]
    }
  ];

  // Generate and push 10 supervisors
  for (var supervisorData in supervisorsData) {
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
      'supervisedTheses': List.generate(
        random.nextInt(5), // Supervises 0-4 theses
        (index) => {
          'studentId': studentIds[random.nextInt(studentIds.length)],
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
          'secondReviewer': 'supervisor_${random.nextInt(10)}',
          'invoiceStatus': [
            'not submitted',
            'submitted',
            'paid'
          ][random.nextInt(3)],
        },
      ),
    });
  }

  dev.log(
      '10 students and 10 supervisors with unique announced topics have been added to the database.');
}
