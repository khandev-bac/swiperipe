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

      debugPrint('Initial Permission state: ${permission.name}');
      debugPrint('Is Auth: ${permission.isAuth}');

      if (!mounted) return;

      bool isAuthorized = permission.isAuth;

      if (!isAuthorized && permission.name == 'limited') {
        debugPrint('Permission is limited, but proceeding to load photos...');
        isAuthorized = true;
      }

      if (!isAuthorized) {
        debugPrint('Permission denied, requesting again...');
        await Future.delayed(const Duration(milliseconds: 500));

        final PermissionState retryPermission =
            await PhotoManager.requestPermissionExtend();
        debugPrint('Retry Permission state: ${retryPermission.name}');

        isAuthorized = retryPermission.isAuth;
        if (!isAuthorized && retryPermission.name == 'limited') {
          isAuthorized = true;
        }
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
        debugPrint('Permission state is valid, loading photos...');
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
      debugPrint('Starting to load photos...');

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

      debugPrint('Total albums found: ${paths.length}');

      if (paths.isEmpty) {
        if (mounted) {
          setState(() => isLoading = false);
          _showMessage(
            'No photo albums found. Check if you have photos in gallery.',
          );
        }
        return;
      }

      final Map<String, List<AssetEntity>> groupedByMonth = {};

      for (var pathEntity in paths) {
        debugPrint('Loading from album: ${pathEntity.name}');

        final int assetCount = await pathEntity.assetCountAsync;
        debugPrint('Photos in ${pathEntity.name}: $assetCount');

        if (assetCount == 0) continue;

        final List<AssetEntity> assets = await pathEntity.getAssetListRange(
          start: 0,
          end: assetCount,
        );

        debugPrint(
          'Successfully loaded ${assets.length} assets from ${pathEntity.name}',
        );

        for (var asset in assets) {
          // Only add if we haven't seen this asset before
          final bool alreadyAdded = groupedByMonth.values.any(
            (list) => list.any((a) => a.id == asset.id),
          );

          if (!alreadyAdded) {
            final DateTime createTime = asset.createDateTime ?? DateTime.now();
            final String monthKey = _getMonthKey(createTime);

            if (!groupedByMonth.containsKey(monthKey)) {
              groupedByMonth[monthKey] = [];
            }
            groupedByMonth[monthKey]!.add(asset);
          }
        }
      }

      debugPrint('Total photos grouped: ${groupedByMonth.length} months');
      debugPrint(
        'Total photos: ${groupedByMonth.values.fold<int>(0, (sum, list) => sum + list.length)}',
      );

      if (groupedByMonth.isEmpty) {
        if (mounted) {
          setState(() => isLoading = false);
          _showMessage('No photos found. Try opening gallery first.');
        }
        return;
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
        try {
          final aDate = _parseMonthKey(a.month);
          final bDate = _parseMonthKey(b.month);
          return bDate.compareTo(aDate);
        } catch (e) {
          debugPrint('Sort error: $e');
          return 0;
        }
      });

      debugPrint('Successfully loaded ${groups.length} month groups');

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

  void _navigateToRandomClean() {
    if (monthlyGroups.isEmpty) {
      _showMessage('No photos available');
      return;
    }

    final List<AssetEntity> allPhotos = [];
    for (var group in monthlyGroups) {
      allPhotos.addAll(group.assets);
    }

    if (allPhotos.isEmpty) {
      _showMessage('No photos available');
      return;
    }

    allPhotos.shuffle();
    final randomPhotos = allPhotos.take(50).toList();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SwipeablePhotoCard(
          assets: randomPhotos,
          title: 'Random Clean',
          onBack: () => Navigator.pop(context),
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

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SwipeablePhotoCard(
          assets: group.assets,
          title: month,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Customcolors.primary,
      appBar: AppBar(
        title: Text("Swiperipe", style: Customfonts.swiss),
        backgroundColor: Customcolors.primary,
        elevation: 0,
        actions: [
          // Stats icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatesScren()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Customcolors.customDarkBlue,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/vectors/state.svg",
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Settings icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScren(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Customcolors.customDarkBlue,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/vectors/settings.svg",
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
              onScreenshots: () {
                _showMessage('Screenshots feature coming soon');
              },
              onDuplicates: () {
                _showMessage('Duplicates feature coming soon');
              },
              onVideos: () {
                _showMessage('Videos feature coming soon');
              },
              onMonthTap: _navigateToMonth,
            ),
    );
  }
}
