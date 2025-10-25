import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:swiperipe/contants/CustomColors.dart';
import 'package:swiperipe/contants/CustomFonts.dart';
import 'package:swiperipe/screens/HomeScreen/HomeScreen.dart';
import 'package:swiperipe/screens/Settings/settings.dart';

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

// ------------------- HomeScreen -------------------
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

  // ------------------- Permission & Load Photos -------------------
  Future<void> _initializePhotos() async {
    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();

      debugPrint('Initial Permission state: ${permission.name}');
      debugPrint('Is Auth: ${permission.isAuth}');

      if (!mounted) return;

      bool isAuthorized = permission.isAuth;

      if (!isAuthorized && permission.name == 'limited') {
        debugPrint('Permission is limited, proceeding...');
        isAuthorized = true;
      }

      if (!isAuthorized) {
        await Future.delayed(const Duration(milliseconds: 500));
        final PermissionState retryPermission =
            await PhotoManager.requestPermissionExtend();
        debugPrint('Retry Permission state: ${retryPermission.name}');
        isAuthorized =
            retryPermission.isAuth || retryPermission.name == 'limited';
      }

      if (!isAuthorized) {
        if (mounted) {
          _showMessage('Please enable photo permission in settings');
          setState(() => isLoading = false);
          await Future.delayed(const Duration(seconds: 1));
          PhotoManager.openSetting();
        }
        return;
      }

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _loadPhotosFromGallery();
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showMessage('Error requesting permission: ${e.toString()}');
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
          debugPrint(
            'No albums found, retrying... (${retries - 1} attempts left)',
          );
          await Future.delayed(const Duration(milliseconds: 200));
          retries--;
        }
      }

      final Map<String, List<AssetEntity>> groupedByMonth = {};

      for (var pathEntity in paths) {
        final int assetCount = await pathEntity.assetCountAsync;
        if (assetCount == 0) continue;

        final List<AssetEntity> assets = await pathEntity.getAssetListRange(
          start: 0,
          end: assetCount,
        );

        for (var asset in assets) {
          final bool alreadyAdded = groupedByMonth.values.any(
            (list) => list.any((a) => a.id == asset.id),
          );

          if (!alreadyAdded) {
            final DateTime createTime = asset.createDateTime ?? DateTime.now();
            final String monthKey = _getMonthKey(createTime);

            groupedByMonth.putIfAbsent(monthKey, () => []).add(asset);
          }
        }
      }

      final List<MonthlyPhotoGroup> groups = groupedByMonth.entries
          .map(
            (entry) => MonthlyPhotoGroup(
              month: entry.key,
              assets: entry.value,
              count: entry.value.length,
            ),
          )
          .toList();

      groups.sort((a, b) {
        final aDate = _parseMonthKey(a.month);
        final bDate = _parseMonthKey(b.month);
        return bDate.compareTo(aDate);
      });

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
        _showMessage('Error loading photos: ${e.toString()}');
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

  // ------------------- Functions for DynamicPhotoCards -------------------

  void _onDeletePhoto(AssetEntity asset) {
    setState(() {
      for (var group in monthlyGroups) {
        group.assets.remove(asset);
        group.count = group.assets.length;
      }
    });
  }

  void _navigateToRandomClean() {
    if (monthlyGroups.isEmpty) {
      _showMessage('No photos available');
      return;
    }

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
        builder: (context) => SwipeablePhotoCard(
          assets: randomPhotos,
          title: 'Random Clean',
          onBack: () => Navigator.pop(context),
          onKeep: (AssetEntity asset) {},
          onDelete: _onDeletePhoto,
        ),
      ),
    );
  }

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
        builder: (context) => SwipeablePhotoCard(
          assets: group.assets,
          title: month,
          onBack: () => Navigator.pop(context),
          onKeep: (AssetEntity asset) {},
          onDelete: _onDeletePhoto,
        ),
      ),
    );
  }

  void _onScreenshots() async {
    setState(() => isLoading = true);

    try {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      List<AssetEntity> screenshots = [];

      for (var path in paths) {
        final int count = await path.assetCountAsync;
        if (count == 0) continue;

        final assets = await path.getAssetListRange(start: 0, end: count);
        for (var asset in assets) {
          if (asset.title != null &&
              asset.title!.toLowerCase().contains('screenshot')) {
            screenshots.add(asset);
          }
        }
      }

      if (screenshots.isEmpty) {
        _showMessage("No screenshots found");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SwipeablePhotoCard(
              assets: screenshots,
              title: "Screenshots",
              onBack: () => Navigator.pop(context),
              onKeep: (asset) {},
              onDelete: _onDeletePhoto,
            ),
          ),
        );
      }
    } catch (e) {
      _showMessage("Error loading screenshots: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ------------------- Build -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Customcolors.primary,
      appBar: AppBar(
        title: Text("Swipester", style: Customfonts.swiss),
        backgroundColor: Customcolors.primary,
        elevation: 0,
        // actions: [
        //   // Stats icon

        //   // Settings icon
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 10),
        //     child: GestureDetector(
        //       onTap: () {
        //         HapticFeedback.mediumImpact();
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const SettingsScren(),
        //           ),
        //         );
        //       },
        //       child: Container(
        //         padding: const EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: Customcolors.customDarkBlue,
        //           shape: BoxShape.circle,
        //         ),
        //         child: SvgPicture.asset(
        //           "assets/vectors/settings.svg",
        //           width: 24,
        //           height: 24,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : monthlyGroups.isEmpty
          ? Center(
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
            )
          : DynamicPhotoCards(
              photoGroups: monthlyGroups,
              onRandomClean: _navigateToRandomClean,
              onScreenshots: _onScreenshots,
              onDuplicates: () {
                _showMessage('Duplicates feature coming soon');
              },
              onVideos: () {
                _showMessage('Videos feature coming soon');
              },
              onMonthTap: _navigateToMonth,
              onDelete: _onDeletePhoto,
            ),
    );
  }
}
