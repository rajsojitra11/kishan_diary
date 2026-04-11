import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});
