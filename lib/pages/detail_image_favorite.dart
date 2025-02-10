import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:Wintar_Gallery/helpers/database_helper.dart';

class DetailImageFavoritePage extends StatelessWidget {
  final Uint8List imageBytes;
  final int imageId;
  final VoidCallback onRemoveFavorite; // Accept the callback function

  const DetailImageFavoritePage({
    Key? key,
    required this.imageBytes,
    required this.imageId,
    required this.onRemoveFavorite, // Initialize the callback function
  }) : super(key: key);

  Future<void> _removeFromFavorites(BuildContext context) async {
    try {
      await DatabaseHelper.instance.toggleFavoriteImage(imageId, false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image removed from favorites')),
      );

      // Call the callback function to refresh the favorites list
      onRemoveFavorite();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove image from favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Image Detail'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  gaplessPlayback: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _removeFromFavorites(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.black, // Set the background color to black
                  textStyle: TextStyle(
                      color: Colors.white), // Set the text color to white
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete, // You can choose any icon you prefer
                      color: Colors.white, // Set the icon color to white
                    ),
                    SizedBox(
                        width: 8), // Add some space between the icon and text
                    Text(
                      'Remove from Favorites',
                      style: TextStyle(
                          color: Colors.white), // Set the text color to white
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
