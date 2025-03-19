import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/posts.dart';
import '../services/firestore_service.dart';
import 'add_post_screen.dart';

class CategoryPostsScreen extends StatefulWidget {
  final String categoryId;

  const CategoryPostsScreen({Key? key, required this.categoryId})
      : super(key: key);

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
    print("🔎 Fetching posts for category ID: ${widget.categoryId}"); // Debugging
    List<Post> fetchedPosts = await _firestoreService.getPosts(widget.categoryId);
    print("🔥 Posts Fetched: ${fetchedPosts.length}");
    setState(() {
      posts = fetchedPosts;
    });
  }

  // 🔹 Helper Function: Format Timestamp
  String _formatTimestamp(dynamic timestamp) {
    // ✅ Ensure it's a Firestore Timestamp before converting
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      Duration difference = DateTime.now().difference(date);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} د";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} س";
      } else {
        return "${difference.inDays} يوم";
      }
    } else {
      return "غير معروف"; // 🔹 Return "unknown" if timestamp is invalid
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Background Image
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
                // 🔹 App Bar
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
                      const SizedBox(width: 40), // Placeholder to balance back button
                    ],
                  ),
                ),

                // 🔹 Category Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "التصوير الفلكي", // Dynamically change this based on category
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 🔹 Posts List
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

      // 🔹 Floating Button for Adding New Post
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(categoryId: widget.categoryId),
            ),
          ).then((_) => loadPosts()); // Reload posts after adding a new one
        },
        child: const Icon(Icons.add, color: Color(0xFF7A1E6C), size: 30),
      ),



      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7A1E6C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // "المستكشفون" is the first tab
        onTap: (index) {
          // Handle navigation
        },
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

  // 🔹 Post Card Widget
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
            // User Info Row
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
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 10),

            // Post Content
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(post.content, textAlign: TextAlign.right),

            const SizedBox(height: 10),

            // Post Image
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

            // 🔹 Replies & Comments
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                const SizedBox(width: 5),
                Text(post.replies.length.toString()), // Number of replies
              ],
            ),
          ],
        ),
      ),
    );
  }


}


