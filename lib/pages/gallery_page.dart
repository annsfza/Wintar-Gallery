import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Wintar_Gallery/pages/detail_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../helpers/database_helper.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _imageFileList = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isSelectionMode = false;
  Set<int> _selectedImages = {};
  final Map<int, Size> _imageSizes = {};
  Set<int> _favoriteImages = {};

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

    void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleSelectionMode(int id) {
    setState(() {
      if (!_isSelectionMode) {
        _isSelectionMode = true;
        _selectedImages.add(id);
      } else {
        if (_selectedImages.contains(id)) {
          _selectedImages.remove(id);
          if (_selectedImages.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedImages.add(id);
        }
      }
    });
  }

  void _toggleFavoriteImages() async {
    setState(() {
      for (int id in _selectedImages) {
        if (_favoriteImages.contains(id)) {
          _favoriteImages.remove(id);
          DatabaseHelper.instance.toggleFavoriteImage(id, false);
        } else {
          _favoriteImages.add(id);
          DatabaseHelper.instance.toggleFavoriteImage(id, true);
        }
      }
      _selectedImages.clear();
      _isSelectionMode = false;
    });
    
    // Show success message
    _showSuccessSnackbar('Images added to favorites successfully');
  }

  Future<void> _deleteSelectedImages() async {
    if (_selectedImages.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final imagesToDelete = Set<int>.from(_selectedImages);

      for (int id in imagesToDelete) {
        await DatabaseHelper.instance.deleteImage(id);
      }

      setState(() {
        _imageFileList
            .removeWhere((image) => imagesToDelete.contains(image['id']));
        _selectedImages.clear();
        _isSelectionMode = false;
        _isLoading = false;
      });

      // Show success message
      _showSuccessSnackbar('Images deleted successfully');
    } catch (e) {
      print('Error deleting images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete images')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadImages() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final images = await DatabaseHelper.instance.getAllImages();
      if (mounted) {
        setState(() {
          _imageFileList = List.from(images)
            ..sort((a, b) => b['id'].compareTo(a['id']));
          _favoriteImages = _imageFileList
              .where((image) => image['isFavorite'] == 1)
              .map<int>((image) => image['id'] as int)
              .toSet();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load images')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<Map<String, dynamic>> newImages = [];

        for (var pickedFile in pickedFiles) {
          final imageFile = File(pickedFile.path);
          final date = DateTime.now();
          final id = await DatabaseHelper.instance.insertImage(imageFile, date);
          final bytes = await imageFile.readAsBytes();

          newImages.add({
            'id': id,
            'image': bytes,
            'date': date.toIso8601String(),
          });
        }

        setState(() {
          _imageFileList = [...newImages, ..._imageFileList];
          _isLoading = false;
        });

        // Show success message
        _showSuccessSnackbar('Images added successfully');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add images')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildImageItem(Map<String, dynamic> imageData) {
    final imageBytes = imageData['image'] as List<int>;
    final id = imageData['id'] as int;
    final isSelected = _selectedImages.contains(id);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (!_isSelectionMode) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailImagePage(
                    imageBytes: Uint8List.fromList(imageData['image'])),
              ),
            );
          } else {
            _toggleSelectionMode(id);
          }
        },
        onLongPress: () => _toggleSelectionMode(id),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? Colors.black.withOpacity(0.3)
                        : Colors.transparent,
                    BlendMode.darken,
                  ),
                  child: Image.memory(
                    Uint8List.fromList(imageBytes),
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    gaplessPlayback: true,
                    frameBuilder: (BuildContext context, Widget child,
                        int? frame, bool wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (_favoriteImages.contains(id))
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _isSelectionMode ? '${_selectedImages.length} Selected' : 'Home',
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: _isLoading ? null : _toggleFavoriteImages,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _isLoading ? null : _deleteSelectedImages,
                ),
              ]
            : null,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedImages.clear();
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  Text(
                    'My Image',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MasonryGridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: _imageFileList.length,
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemBuilder: (context, index) {
                  return _buildImageItem(_imageFileList[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: _pickImage,
              backgroundColor: _isLoading ? Colors.grey : Colors.black,
              shape: const CircleBorder(),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}