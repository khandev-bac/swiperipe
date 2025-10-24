import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:swiperipe/contants/CustomColors.dart';

// Model for grouped photos
class MonthlyPhotoGroup {
  final String month;
  final List<AssetEntity> assets;
  final int count;

  MonthlyPhotoGroup({
    required this.month,
    required this.assets,
    required this.count,
  });
}

// Component 1: Dynamic Cards for Home Screen
class DynamicPhotoCards extends StatefulWidget {
  final List<MonthlyPhotoGroup> photoGroups;
  final VoidCallback onRandomClean;
  final VoidCallback onScreenshots;
  final VoidCallback onDuplicates;
  final VoidCallback onVideos;
  final Function(String) onMonthTap;

  const DynamicPhotoCards({
    Key? key,
    required this.photoGroups,
    required this.onRandomClean,
    required this.onScreenshots,
    required this.onDuplicates,
    required this.onVideos,
    required this.onMonthTap,
  }) : super(key: key);

  @override
  State<DynamicPhotoCards> createState() => _DynamicPhotoCardsState();
}

class _DynamicPhotoCardsState extends State<DynamicPhotoCards> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Random Clean Card
            _buildActionCard(
              title: "Random Clean",
              subtitle: "pick random photos to review",
              emoji: "🎲",
              colors: const [
                Customcolors.customBlue,
                Customcolors.customDarkBlue,
              ],
              onTap: widget.onRandomClean,
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Screenshots Card
            _buildActionCard(
              title: "Screenshots",
              subtitle: "Review screenshots",
              emoji: "📷",
              colors: const [Color(0xFFA855F7), Color(0xFF9333EA)],
              onTap: widget.onScreenshots,
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Duplicates Card
            _buildActionCard(
              title: "Duplicates",
              subtitle: "Review duplicates",
              emoji: "😊",
              colors: const [Color(0xFFFF6B6B), Color(0xFFFF6B9D)],
              onTap: widget.onDuplicates,
            ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Videos Card
            _buildActionCard(
              title: "Videos",
              subtitle: "Review videos",
              emoji: "🎬",
              colors: const [Color(0xFF1FCECB), Color(0xFF0FB9B1)],
              onTap: widget.onVideos,
            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Monthly Photo Groups
            ...widget.photoGroups.asMap().entries.map((entry) {
              int index = entry.key;
              MonthlyPhotoGroup group = entry.value;
              return Column(
                children: [
                  _buildMonthCard(
                    month: group.month,
                    count: group.count,
                    onTap: () => widget.onMonthTap(group.month),
                    delay: Duration(milliseconds: 900 + (index * 100)),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnThisDayCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Customcolors.customBlue, Customcolors.customDarkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Customcolors.customDarkBlue.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "On This Day 📅",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "No photos from this day",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required String emoji,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title $emoji",
                  style: const TextStyle(
                    fontFamily: "Swiss",
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: "Swiss",
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard({
    required String month,
    required int count,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE5B9F5), Color(0xFFC89FE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC89FE8).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$count photos to clean",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 400.ms).slideX(begin: -0.2);
  }
}

// Component 2: Swipeable Photo Card
class SwipeablePhotoCard extends StatefulWidget {
  final List<AssetEntity> assets;
  final String title;
  final VoidCallback onBack;

  const SwipeablePhotoCard({
    Key? key,
    required this.assets,
    required this.title,
    required this.onBack,
  }) : super(key: key);

  @override
  State<SwipeablePhotoCard> createState() => _SwipeablePhotoCardState();
}

class _SwipeablePhotoCardState extends State<SwipeablePhotoCard> {
  late SwipableStackController _controller;
  late List<AssetEntity> remainingAssets;
  int _keptCount = 0;
  int _deletedCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
    remainingAssets = List.from(widget.assets);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deletePhoto(AssetEntity asset) async {
    try {
      await PhotoManager.editor.deleteWithIds([asset.id]);
      debugPrint('Photo deleted: ${asset.id}');
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }

  void _onSwipeLeft() {
    // Delete action (swipe left)
    if (remainingAssets.isNotEmpty) {
      final assetToDelete = remainingAssets[0];
      _deletePhoto(assetToDelete);
      remainingAssets.removeAt(0);
      _deletedCount++;
      setState(() {});
    }
  }

  void _onSwipeRight() {
    // Keep action (swipe right)
    if (remainingAssets.isNotEmpty) {
      remainingAssets.removeAt(0);
      _keptCount++;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = remainingAssets.isEmpty;

    return Scaffold(
      backgroundColor: Customcolors.primary,
      appBar: AppBar(
        backgroundColor: Customcolors.primary,
        elevation: 0,
        leading: GestureDetector(
          onTap: widget.onBack,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Customcolors.customBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${_keptCount + _deletedCount}/${widget.assets.length}",
            style: const TextStyle(
              color: Customcolors.customBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (_keptCount + _deletedCount > 0) {
                _keptCount = 0;
                _deletedCount = 0;
                remainingAssets = List.from(widget.assets);
                _controller.rewind();
                setState(() {});
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Customcolors.customBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.undo, color: Colors.white),
            ),
          ),
        ],
      ),
      body: remainingAssets.isEmpty
          ? _buildCompletionScreen()
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SwipableStack(
                      controller: _controller,
                      onSwipeCompleted: (index, direction) {
                        if (direction == SwipeDirection.left) {
                          _onSwipeLeft();
                        } else if (direction == SwipeDirection.right) {
                          _onSwipeRight();
                        }
                      },
                      stackClipBehaviour: Clip.none,
                      builder: (context, properties) {
                        if (remainingAssets.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final asset = remainingAssets[0];
                        return _buildPhotoCard(asset);
                      },
                      itemCount: remainingAssets.length,
                    ),
                  ),
                ),
                _buildStats(),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "All Done! 🎉",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Customcolors.customDarkBlue,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Customcolors.customDarkBlue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Kept: $_keptCount",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Deleted: $_deletedCount",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: Customcolors.customBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Back to Home",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(400)),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Customcolors.customDarkBlue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(snapshot.data!, fit: BoxFit.cover),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Customcolors.customBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "${widget.assets.length} photos",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$_keptCount photos kept",
            style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "$_deletedCount photos deleted",
            style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _onSwipeLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _onSwipeRight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Keep",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
