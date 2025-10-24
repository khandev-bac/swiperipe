import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';
import 'package:swiperipe/screens/HomeScreen/HomeScreen.dart';
import 'package:swiperipe/screens/Settings/settings.dart';
import 'package:swiperipe/screens/StatesScreen/StateScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MonthlyPhotoGroup> monthlyGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePhotos();
  }

  Future<void> _initializePhotos() async {
    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      debugPrint('Permission state: ${permission.name}');

      if (!permission.isAuth && permission.name != 'limited') {
        if (mounted) {
          setState(() => isLoading = false);
          _showMessage('Please enable photo permission in settings');
          await Future.delayed(const Duration(seconds: 1));
          PhotoManager.openSetting();
        }
        return;
      }

      if (mounted) {
        await _loadPhotosFromGallery();
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showMessage('Error requesting permission: $e');
      }
    }
  }

  Future<void> _loadPhotosFromGallery() async {
    try {
      List<AssetPathEntity> paths = [];
      int retries = 3;

      while (paths.isEmpty && retries > 0) {
        paths = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          hasAll: true,
        );
        if (paths.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 200));
          retries--;
        }
      }

      if (paths.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        _showMessage('No photo albums found.');
        return;
      }

      final Map<String, List<AssetEntity>> groupedByMonth = {};

      for (var path in paths) {
        final int assetCount = await path.assetCountAsync;
        if (assetCount == 0) continue;

        final assets = await path.getAssetListRange(start: 0, end: assetCount);

        for (var asset in assets) {
          // Prevent duplicates
          bool alreadyAdded = groupedByMonth.values.any(
            (list) => list.any((a) => a.id == asset.id),
          );
          if (!alreadyAdded) {
            final monthKey = _getMonthKey(
              asset.createDateTime ?? DateTime.now(),
            );
            groupedByMonth.putIfAbsent(monthKey, () => []).add(asset);
          }
        }
      }

      if (groupedByMonth.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        _showMessage('No photos found.');
        return;
      }

      final List<MonthlyPhotoGroup> groups = groupedByMonth.entries
          .map(
            (e) => MonthlyPhotoGroup(
              month: e.key,
              assets: e.value,
              count: e.value.length,
            ),
          )
          .toList();

      // Sort descending by month
      groups.sort(
        (a, b) => _parseMonthKey(b.month).compareTo(_parseMonthKey(a.month)),
      );

      if (mounted) {
        setState(() {
          monthlyGroups = groups;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showMessage('Error loading photos: $e');
      }
    }
  }

  String _getMonthKey(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  DateTime _parseMonthKey(String monthKey) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parts = monthKey.split(' ');
    if (parts.length == 2) {
      final monthIndex = months.indexOf(parts[0]) + 1;
      final year = int.tryParse(parts[1]) ?? DateTime.now().year;
      return DateTime(year, monthIndex);
    }
    return DateTime.now();
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Live deletion callback
  void _handleDeletedPhoto(AssetEntity deletedAsset) {
    setState(() {
      for (var group in monthlyGroups) {
        group.assets.removeWhere((a) => a.id == deletedAsset.id);
        group.count = group.assets.length;
      }
      monthlyGroups.removeWhere((g) => g.assets.isEmpty);
    });
  }

  // Random Clean
  void _navigateToRandomClean() {
    final allPhotos = monthlyGroups.expand((g) => g.assets).toList();
    if (allPhotos.isEmpty) {
      _showMessage('No photos available');
      return;
    }

    allPhotos.shuffle();
    final randomPhotos = allPhotos.take(50).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeablePhotoCard(
          assets: randomPhotos,
          title: 'Random Clean',
          onBack: () => Navigator.pop(context),
          onDelete: _handleDeletedPhoto,
        ),
      ),
    );
  }

  // Screenshots
  void _navigateToScreenshots() {
    final allPhotos = monthlyGroups.expand((g) => g.assets).toList();
    final screenshots = allPhotos.where((asset) {
      final lowerPath = (asset.title ?? '').toLowerCase();
      return asset.type == AssetType.image &&
          (lowerPath.contains('screenshot') ||
              (asset.relativePath ?? '').toLowerCase().contains('screenshot'));
    }).toList();

    if (screenshots.isEmpty) {
      _showMessage('No screenshots found');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeablePhotoCard(
          assets: screenshots,
          title: 'Screenshots',
          onBack: () => Navigator.pop(context),
          onDelete: _handleDeletedPhoto,
        ),
      ),
    );
  }

  // Videos
  void _navigateToVideos() {
    final allPhotos = monthlyGroups.expand((g) => g.assets).toList();
    final videos = allPhotos
        .where((asset) => asset.type == AssetType.video)
        .toList();

    if (videos.isEmpty) {
      _showMessage('No videos found');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeablePhotoCard(
          assets: videos,
          title: 'Videos',
          onBack: () => Navigator.pop(context),
          onDelete: _handleDeletedPhoto,
        ),
      ),
    );
  }

  // Month View
  void _navigateToMonth(String month) {
    final group = monthlyGroups.firstWhere(
      (g) => g.month == month,
      orElse: () => MonthlyPhotoGroup(month: month, assets: [], count: 0),
    );

    if (group.assets.isEmpty) {
      _showMessage('No photos in this month');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SwipeablePhotoCard(
          assets: group.assets,
          title: month,
          onBack: () => Navigator.pop(context),
          onDelete: _handleDeletedPhoto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Customcolors.primary,
      appBar: AppBar(
        title: Text("Swipester", style: Customfonts.swiss),
        backgroundColor: Customcolors.primary,
        elevation: 0,
        actions: [
          _buildCircleIcon(
            svgPath: "assets/vectors/state.svg",
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatesScren()),
              );
            },
          ),
          _buildCircleIcon(
            svgPath: "assets/vectors/settings.svg",
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScren()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : monthlyGroups.isEmpty
          ? _buildEmptyState()
          : DynamicPhotoCards(
              photoGroups: monthlyGroups,
              onRandomClean: _navigateToRandomClean,
              onScreenshots: _navigateToScreenshots,
              onDuplicates: () => _showMessage('Duplicates coming soon'),
              onVideos: _navigateToVideos,
              onMonthTap: _navigateToMonth,
            ),
    );
  }

  Widget _buildCircleIcon({
    required String svgPath,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Customcolors.customDarkBlue,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            svgPath,
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No photos found in gallery",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => isLoading = true);
              _initializePhotos();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
