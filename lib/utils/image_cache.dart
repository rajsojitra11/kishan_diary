import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCache {
  AppImageCache._();

  static final CacheManager manager = CacheManager(
    Config(
      'kishanDiaryImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 400,
    ),
  );
}
