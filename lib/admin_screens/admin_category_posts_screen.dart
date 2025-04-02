import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/posts.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminCategoryPostsScreen extends StatefulWidget {
  final String categoryId;

  const AdminCategoryPostsScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _AdminCategoryPostsScreenState createState() => _AdminCategoryPostsScreenState();
}

class _AdminCategoryPostsScreenState extends State<AdminCategoryPostsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    List<Post> fetchedPosts = await _firestoreService.getPosts(widget.categoryId);
    setState(() {
      posts = fetchedPosts;
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      timestamp = timestamp.toDate();
    }

    if (timestamp is DateTime) {
      Duration difference = DateTime.now().difference(timestamp);
      if (difference.inMinutes < 60) return "${difference.inMinutes} د";
      if (difference.inHours < 24) return "${difference.inHours} س";
      return "${difference.inDays} يوم";
    }

    return "غير معروف";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/gradient 1.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // الهيدر
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "إدارة المشاركات",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: posts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _buildPostCard(post);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المستخدم + زر الحذف
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.userProfileImage)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("@${post.userHandle}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeletePost(post),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(post.content),
            if (post.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(post.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
    GestureDetector(
    onTap: () => _showReplyBottomSheet(context, post),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
    const Icon(Icons.chat_bubble_outline, color: Colors.grey),
    const SizedBox(width: 5),
    Text(post.replies.length.toString()),
            const SizedBox(height: 10),

          ],
        ),
      ),
    ],
    ),
    ),
    );
  }

  void _confirmDeletePost(Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد الحذف"),
        content: Text("هل تريد حذف هذه المشاركة؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('community_categories')
                  .doc(widget.categoryId)
                  .collection('posts')
                  .doc(post.id)
                  .delete();
              loadPosts();
            },
            child: Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReply(Post post, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد حذف الرد"),
        content: Text("هل تريد حذف هذا الرد؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              post.replies.removeAt(index);
              await FirebaseFirestore.instance
                  .collection('community_categories')
                  .doc(widget.categoryId)
                  .collection('posts')
                  .doc(post.id)
                  .update({'replies': post.replies});
              loadPosts();
            },
            child: Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

    void _showReplyBottomSheet(BuildContext context, Post post) {
      TextEditingController _replyController = TextEditingController();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: MediaQuery
                .of(context)
                .viewInsets,
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("الردود", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: post.replies.length,
                      itemBuilder: (context, index) {
                        final reply = post.replies[index];

                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    reply['userProfileImage'] ?? ''),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          reply['name'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '@${reply['username'] ?? ''}',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(reply['text'] ?? ''),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  post.replies.removeAt(index);
                                  await FirebaseFirestore.instance
                                      .collection('community_categories')
                                      .doc(widget.categoryId)
                                      .collection('posts')
                                      .doc(post.id)
                                      .update({'replies': post.replies});
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: "أضف ردًا...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null || _replyController.text.isEmpty) return;

                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();

                      final reply = {
                        'text': _replyController.text,
                        'timestamp': Timestamp.now(),
                        'userId': user.uid,
                        'username': userDoc.data()?['username'] ?? 'unknown',
                        'name': userDoc.data()?['name'] ?? 'مستخدم',
                        'userProfileImage': userDoc
                            .data()?['profileImageUrl'] ?? '',
                      };

                      post.replies.add(reply);
                      await FirebaseFirestore.instance
                          .collection('community_categories')
                          .doc(widget.categoryId)
                          .collection('posts')
                          .doc(post.id)
                          .update({'replies': post.replies});
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text("إرسال"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }


