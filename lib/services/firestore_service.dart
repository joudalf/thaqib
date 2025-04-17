import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/category.dart';
import '../model/posts.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _db.collection('community_categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Category.fromFirestore(data, doc.id);
        } else {
          print("⚠️ Warning: Skipping category ${doc.id} due to null data.");
          return null;
        }
      }).whereType<Category>().toList();
    } catch (e) {
      print("❌ Error fetching categories: $e");
      return [];
    }
  }








  // ✅ Fetch posts from a specific category
  Future<List<Post>> getPosts(String categoryId) async {
    try {
      print("📡 Querying Firestore for posts in category: $categoryId");
      QuerySnapshot snapshot = await _db
          .collection('community_categories')
          .doc(categoryId)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      print("📂 Found ${snapshot.docs.length} posts in Firestore");




      // ✅ Print fetched documents
      print("🔥 Fetched ${snapshot.docs.length} posts from Firestore");


      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // Extract Firestore data safely
        if (data != null) {
          return Post.fromFirestore(data, doc.id); // ✅ Pass both data and doc ID
        } else {
          print("⚠️ Warning: Skipping post ${doc.id} due to null data.");
          return null;
        }
      }).whereType<Post>().toList();
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }









  // ✅ Add a new post to a category
  Future<void> addPost(String categoryId, Post post) async {
    try {
      await _db
          .collection('community_categories')
          .doc(categoryId)
          .collection('posts')
          .add(post.toMap());
    } catch (e) {
      print("❌ Error adding post: $e");
    }
  }


  Future<void> addCategory(String title, String imageUrl) async {
    await FirebaseFirestore.instance.collection('community_categories').add({
      'name': title,
      'imageUrl': imageUrl,
    });
  }


  Future<void> deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('community_categories')
          .doc(categoryId)
          .delete();
      print("✅ Category deleted: $categoryId");
    } catch (e) {
      print("❌ Error deleting category: $e");
      rethrow;
    }
  }

  Future<void> addEduCategory(String name, String imageUrl) async {
    await FirebaseFirestore.instance.collection('edu_category').add({
      'name': name,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });

  }





}
