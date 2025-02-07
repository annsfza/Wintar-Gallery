import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frd_gallery/helpers/database_helper.dart';
import 'detail_image_favorite.dart';  // Import the Detail Image page

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  Future<List<Map<String, dynamic>>> _getFavoriteImages() async {
    return await DatabaseHelper.instance.getFavoriteImages();
  }

  void _refreshFavorites() {
    setState(() {});  // Trigger a rebuild of the page to reload the favorite images
  }

  Widget _buildFavoriteImageItem(Map<String, dynamic> imageData) {
    final imageBytes = imageData['image'] as List<int>;
    final int imageId = imageData['id'] as int;

    return GestureDetector(
      onTap: () {
        // Navigate to the detail page and pass the callback to refresh favorites
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailImageFavoritePage(
              imageBytes: Uint8List.fromList(imageBytes),
              imageId: imageId,
              onRemoveFavorite: _refreshFavorites,  // Pass the callback here
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          Uint8List.fromList(imageBytes),
          fit: BoxFit.cover,
          width: 150,
          height: 150,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0), // Added padding to create space between appbar and content
          child: FutureBuilder<List<Map<String, dynamic>>>( 
            future: _getFavoriteImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final favoriteImages = snapshot.data;

              if (favoriteImages == null || favoriteImages.isEmpty) {
                return const Center(
                  child: Text('No favorites yet!'),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: favoriteImages.length,
                itemBuilder: (context, index) {
                  return _buildFavoriteImageItem(favoriteImages[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
