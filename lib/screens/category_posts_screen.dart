import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/posts.dart';
import '../services/firestore_service.dart';
import 'add_post_screen.dart';

class CategoryPostsScreen extends StatefulWidget {
  final String categoryId;

  const CategoryPostsScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CategoryPostsScreenState createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    print("🔎 Fetching posts for category ID: ${widget.categoryId}");
    List<Post> fetchedPosts = await _firestoreService.getPosts(widget.categoryId);
    print("🔥 Posts Fetched: ${fetchedPosts.length}");
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

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} د";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} س";
      } else {
        return "${difference.inDays} يوم";
      }
    }

    return "غير معروف";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                        "المستكشفون",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "التصوير الفلكي",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: posts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: posts.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(categoryId: widget.categoryId),
            ),
          ).then((_) => loadPosts());
        },
        child: const Icon(Icons.add, color: Color(0xFF7A1E6C), size: 30),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7A1E6C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "مستكشفون"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "تعلم"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "التقويم"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "معلوماتي"),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.userProfileImage),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("@${post.userHandle}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(post.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 5),
                FirebaseAuth.instance.currentUser?.uid == post.userId
                    ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeletePostDialog(post);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 10),
                          Text('حذف المشاركة', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                )
                    : const Icon(Icons.more_horiz, color: Colors.grey),

              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(post.content, textAlign: TextAlign.right),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.imageUrl.isNotEmpty
                  ? Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text("❌ Failed to load image"));
                },
              )
                  : const SizedBox(),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _showReplyBottomSheet(context, post);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(post.replies.length.toString()),
                ],
              ),
            )
          ],
        ),
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
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("الردود", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: post.replies.length,
                    itemBuilder: (context, index) {
                      final reply = post.replies[index];
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final isCurrentUser = currentUser != null && reply['userId'] == currentUser.uid;

                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // صورة البروفايل
                            CircleAvatar(
                              backgroundImage: NetworkImage(reply['userProfileImage'] ?? ''),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),

                            // الاسم + @username + الرد
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        reply['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '@${reply['username'] ?? ''}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(reply['text'] ?? ''),
                                ],
                              ),
                            ),

                            // زر الحذف (إذا المستخدم نفسه)
                            if (isCurrentUser)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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
                    if (user == null || _replyController.text.isEmpty) {
                      print("❌ المستخدم مو مسجل دخول أو الرد فاضي");
                      return;
                    }
                    print("✅ المستخدم مسجل دخول وكتب رد");

                    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                    final reply = {
                      'text': _replyController.text,
                      'timestamp': Timestamp.now(),
                      'userId': user.uid,
                      'username': userDoc.data()?['username'] ?? 'unknown',
                      'name': userDoc.data()?['name'] ?? 'مستخدم',
                      'userProfileImage': userDoc.data()?['profileImageUrl'] ?? '',
                    };
                      post.replies.add(reply);

                      await FirebaseFirestore.instance
                          .collection('community_categories')
                          .doc(widget.categoryId)
                          .collection('posts')
                          .doc(post.id)
                          .update({'replies': post.replies});
                           print("✅ تم إرسال الرد إلى Firestore");


                      Navigator.pop(context);
                      setState(() {});
                    },

                  child: const Text("إرسال"),
                )
              ],
            ),
          ),
        );
      },
    );


  }

  void _showDeletePostDialog(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد أنك تريد حذف هذه المشاركة؟ لا يمكن التراجع."),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الدايالوج
              },
            ),
            TextButton(
              child: const Text("حذف", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // إغلاق الدايالوج

                await FirebaseFirestore.instance
                    .collection('community_categories')
                    .doc(widget.categoryId)
                    .collection('posts')
                    .doc(post.id)
                    .delete();

                setState(() {
                  posts.remove(post); // حذف البوست من الواجهة
                });
              },
            ),
          ],
        );
      },
    );
  }
}