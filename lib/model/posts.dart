import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String userProfileImage; // ✅ Add user profile image
  final String username; // ✅ Add username
  final String userHandle; // ✅ Add user handle (@username)
  final DateTime timestamp; // ✅ Keep DateTime for correct Firestore conversion
  final List<Map<String, dynamic>> replies;// ✅ Add replies as a list
  final String userId;


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

  // ✅ Convert Firestore Document to Post object
  factory Post.fromFirestore(Map<String, dynamic> data, String id){
    return Post(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      userProfileImage: data['userProfileImage'] ?? '', // ✅ Get user image
      username: data['username'] ?? 'مستخدم مجهول', // ✅ Get username
      userHandle: data['userHandle'] ?? '@unknown', // ✅ Get user handle (@)
      timestamp: (data['timestamp'] as Timestamp).toDate(), // ✅ Fix DateTime issue
      replies: (data['replies'] as List?)?.map<Map<String, dynamic>>((reply) {
        if (reply is Map<String, dynamic>) {
          return reply;
        } else {
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

  // ✅ Convert Post object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'userProfileImage': userProfileImage, // ✅ Save user image
      'username': username, // ✅ Save username
      'userHandle': userHandle, // ✅ Save user handle (@)
     'timestamp': Timestamp.fromDate(timestamp),// ✅ Fix DateTime issue
      'replies': replies, // ✅ Save replies
    };
  }
}
