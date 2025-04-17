import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;    // Unique identifier of the post document in Firestore
  final String title;
  final String content; // Main content of the post
  final String imageUrl;
  final String userProfileImage;
  final String username;
  final String userHandle;
  final DateTime timestamp;  // Timestamp of when the post was created
  final List<Map<String, dynamic>> replies;
  final String userId; // UID of the user who created the post


  // Constructor for creating a new Post instance
  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.userProfileImage,
    required this.username,
    required this.userHandle,
    required this.timestamp,
    required this.replies,
    required this.userId

  });

  // Factory method for converting Firestore document data into a Post object
  factory Post.fromFirestore(Map<String, dynamic> data, String id){
    return Post(
                id: id,
                title: data['title'] ?? '',
                content: data['content'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                userProfileImage: data['userProfileImage'] ?? '',
                username: data['username'] ?? 'مستخدم مجهول',
                userHandle: data['userHandle'] ?? '@unknown',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                replies: (data['replies'] as List?)?.map<Map<String, dynamic>>((reply) {
                  if (reply is Map<String, dynamic>) {
                    return reply;
                  } else {
                    // Fallback: if reply is stored as plain text, convert it to a structured map
                         return {
                              'text': reply.toString(),
                              'timestamp': Timestamp.now(),
                              'userId': '',
                              'username': 'مجهول',
                              'name': 'مجهول',
                              'userProfileImage': '',
                            };
                        }
                }).toList() ?? [],
                userId: data['userId'] ?? '',
     );
  }

  // Converts a Post object into a Map that can be saved to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'userProfileImage': userProfileImage,
      'username': username,
      'userHandle': userHandle,
     'timestamp': Timestamp.fromDate(timestamp),
      'replies': replies,
    };
  }
}
