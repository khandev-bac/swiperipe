import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:swiperipe/contants/CustomColors.dart';

// Model for grouped photos
class MonthlyPhotoGroup {
  final String month;
  List<AssetEntity> assets; // make mutable
  int count; // make mutable

  MonthlyPhotoGroup({
    required this.month,
    required this.assets,
    required this.count,
  });
}

// ------------------- DynamicPhotoCards -------------------
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
            // Random Clean
            _buildActionCard(
              title: "Random Clean",
              subtitle: "50 random photos to review",
              emoji: "🎲",
              colors: const [
                Customcolors.customBlue,
                Customcolors.customDarkBlue,
              ],
              onTap: widget.onRandomClean,
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Screenshots
            _buildActionCard(
              title: "Screenshots",
              subtitle: "Review screenshots",
              emoji: "📷",
              colors: const [Color(0xFFA855F7), Color(0xFF9333EA)],
              onTap: widget.onScreenshots,
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Duplicates
            _buildActionCard(
              title: "Duplicates",
              subtitle: "Review duplicates",
              emoji: "😊",
              colors: const [Color(0xFFFF6B6B), Color(0xFFFF6B9D)],
              onTap: widget.onDuplicates,
            ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.2),
            const SizedBox(height: 12),

            // Videos
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
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

// ------------------- SwipeablePhotoCard -------------------
class SwipeablePhotoCard extends StatefulWidget {
  final List<AssetEntity> assets;
  final String title;
  final VoidCallback onBack;
  final Function(AssetEntity)? onDelete; // <-- NEW

  const SwipeablePhotoCard({
    Key? key,
    required this.assets,
    required this.title,
    required this.onBack,
    this.onDelete, // <-- NEW
  }) : super(key: key);

  @override
  State<SwipeablePhotoCard> createState() => _SwipeablePhotoCardState();
}

class _SwipeablePhotoCardState extends State<SwipeablePhotoCard> {
  late SwipableStackController _controller;
  late List<AssetEntity> assets;
  late List<Uint8List?> thumbnails;
  int _keptCount = 0;
  int _deletedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
    assets = List.from(widget.assets);
    _preloadThumbnails();
  }

  Future<void> _preloadThumbnails() async {
    thumbnails = await Future.wait(
      assets.map(
        (asset) => asset.thumbnailDataWithSize(const ThumbnailSize.square(400)),
      ),
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePhoto(AssetEntity asset) async {
    try {
      await PhotoManager.editor.deleteWithIds([asset.id]);
      if (widget.onDelete != null) widget.onDelete!(asset); // <-- UPDATE HOME
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isComplete = _keptCount + _deletedCount >= assets.length;

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
            "${_keptCount + _deletedCount}/${assets.length}",
            style: const TextStyle(
              color: Customcolors.customBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: isComplete
          ? _buildCompletionScreen()
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SwipableStack(
                      controller: _controller,
                      itemCount: assets.length,
                      onSwipeCompleted: (index, direction) async {
                        final asset = assets[index];
                        if (direction == SwipeDirection.left) {
                          await _deletePhoto(asset);
                          _deletedCount++;
                        } else if (direction == SwipeDirection.right) {
                          _keptCount++;
                        }
                        setState(() {}); // update stats
                      },
                      builder: (context, properties) {
                        final cardIndex = properties.index;
                        final thumbnail = thumbnails[cardIndex];
                        return _buildPhotoCard(thumbnail);
                      },
                    ),
                  ),
                ),
                _buildStats(),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildPhotoCard(Uint8List? thumbnail) {
    if (thumbnail == null) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Customcolors.customBlue,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Customcolors.customDarkBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 3,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.memory(
            thumbnail,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
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

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Customcolors.customBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn(assets.length, "Total", Colors.white),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildStatColumn(_keptCount, "Kept", const Color(0xFF4CAF50)),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildStatColumn(_deletedCount, "Deleted", const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(int count, String label, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  _controller.next(swipeDirection: SwipeDirection.left),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  _controller.next(swipeDirection: SwipeDirection.right),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "Keep",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
