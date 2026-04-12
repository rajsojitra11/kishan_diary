import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'app_session.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();
  static final ValueNotifier<int> billsRefreshNotifier = ValueNotifier<int>(0);
  static int? cachedBillsTotalCount;
  static const String _androidDefaultApiBase =
      'https://kishan-diary.onrender.com/api/v1';

  void _notifyBillsChanged() {
    billsRefreshNotifier.value = billsRefreshNotifier.value + 1;
  }

  void _increaseCachedBillsTotal() {
    if (cachedBillsTotalCount != null) {
      cachedBillsTotalCount = cachedBillsTotalCount! + 1;
    }
  }

  void _decreaseCachedBillsTotal() {
    if (cachedBillsTotalCount != null) {
      cachedBillsTotalCount = (cachedBillsTotalCount! - 1).clamp(0, 1 << 30);
    }
  }

  static String get _baseUrl {
    var configured = const String.fromEnvironment('API_BASE_URL');
    if (configured.trim().isNotEmpty) {
      configured = configured.trim().replaceAll(RegExp(r'/$'), '');

      // Keep HTTP for localhost/private network during local development.
      final isLocalHttp =
          configured.startsWith('http://localhost') ||
          configured.startsWith('http://127.0.0.1') ||
          configured.startsWith('http://10.') ||
          configured.startsWith('http://192.168.') ||
          configured.startsWith('http://172.16.') ||
          configured.startsWith('http://172.17.') ||
          configured.startsWith('http://172.18.') ||
          configured.startsWith('http://172.19.') ||
          configured.startsWith('http://172.2');

      // Force HTTPS for non-local hosts because many production hosts redirect
      // http->https and some POST/DELETE payloads can be lost on redirect.
      if (configured.startsWith('http://') && !isLocalHttp) {
        configured = configured.replaceFirst('http://', 'https://');
      }

      if (configured.endsWith('/api/v1')) {
        return configured;
      }

      if (configured.endsWith('/api')) {
        return '$configured/v1';
      }

      if (configured.endsWith('/v1')) {
        return configured.replaceFirst(RegExp(r'/v1$'), '/api/v1');
      }

      return '$configured/api/v1';
    }

    if (kIsWeb) {
      return 'https://kishan-diary.onrender.com/api/v1';
    }

    if (Platform.isAndroid) {
      return _androidDefaultApiBase;
    }

    return 'https://kishan-diary.onrender.com/api/v1';
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({
    bool auth = true,
    bool json = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (json) {
      headers['Content-Type'] = 'application/json';
    }

    if (auth) {
      final token = await AppSession.getToken();
      if (token == null || token.isEmpty) {
        throw ApiException('Please login again');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> _decodeResponse(http.Response response) async {
    // Log every response for developer debugging
    debugPrint('[API] ${response.statusCode} — ${response.request?.url}');

    Map<String, dynamic> payload;

    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Server returned non-JSON (HTML error page, nginx page, redirect, etc.)
      final preview = response.body.length > 300
          ? '${response.body.substring(0, 300)}...'
          : response.body;
      debugPrint('[API] Non-JSON body: $preview');
      throw ApiException(
        'Server error (HTTP ${response.statusCode}). Please try again.',
        statusCode: response.statusCode,
      );
    }

    debugPrint('[API] Response body: $payload');

    final success = payload['success'] == true;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return payload['data'];
    }

    // Build a readable error from Laravel's response
    final serverMessage = payload['message']?.toString();
    final errors = payload['errors'] as Map<String, dynamic>?;

    String displayMessage;
    if (errors != null && errors.isNotEmpty) {
      // Combine all validation field errors into one readable string
      final errorLines = errors.entries.map((e) {
        final msgs =
            (e.value as List?)?.map((m) => m.toString()).join(', ') ??
            e.value.toString();
        return msgs;
      }).toList();
      displayMessage = errorLines.join('\n');
    } else {
      displayMessage =
          serverMessage ?? 'Request failed (HTTP ${response.statusCode})';
    }

    debugPrint('[API] Error $displayMessage');

    throw ApiException(
      displayMessage,
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  Future<dynamic> _request(
    String method,
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, query: query);
    final headers = await _headers(
      auth: auth,
      json: method != 'GET' && method != 'DELETE',
    );

    debugPrint('[API] $method $uri');

    late http.Response response;

    try {
      final Future<http.Response> call;
      switch (method) {
        case 'GET':
          call = http.get(uri, headers: headers);
          break;
        case 'POST':
          call = http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PUT':
          call = http.put(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PATCH':
          call = http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'DELETE':
          call = http.delete(uri, headers: headers);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
      // 30s timeout — Render free tier can take ~30s on cold start
      response = await call.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException(
          'Server is starting up, please wait a moment and try again.',
        ),
      );
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('[API] ClientException: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on SocketException catch (e) {
      debugPrint('[API] SocketException: $e');
      throw ApiException('Cannot reach server. Please check your internet.');
    }

    return _decodeResponse(response);
  }

  Future<dynamic> _multipart(
    String method,
    String path, {
    bool auth = true,
    Map<String, String>? fields,
    String? fileField,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(await _headers(auth: auth, json: false));

    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }

    if (fileField != null) {
      if (fileBytes != null && fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: (fileName != null && fileName.trim().isNotEmpty)
                ? fileName
                : 'upload.jpg',
          ),
        );
      } else if (filePath != null && filePath.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );
      }
    }

    late http.Response response;

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException(
          'Server is starting up, please wait a moment and try again.',
        ),
      );
      response = await http.Response.fromStream(streamedResponse);
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('[API] Multipart ClientException: $e');
      throw ApiException('No internet connection. Please check your network.');
    } on SocketException catch (e) {
      debugPrint('[API] Multipart SocketException: $e');
      throw ApiException('Cannot reach server. Please check your internet.');
    }

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> mobileCheck(String mobile) async {
    final data = await _request(
      'POST',
      '/auth/mobile-check',
      auth: false,
      body: {'mobile': mobile},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? email,
    required String mobile,
    required String birthDate,
    required String password,
    required String passwordConfirmation,
    String preferredLanguage = 'gu',
    String userRole = 'farmer',
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'mobile': mobile,
      'birth_date': birthDate,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'preferred_language': preferredLanguage,
      'user_role': userRole,
    };
    if (email != null && email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }

    final data = await _request(
      'POST',
      '/auth/register',
      auth: false,
      body: body,
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
    required String userRole,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      auth: false,
      body: {'mobile': mobile, 'password': password, 'user_role': userRole},
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> resetForgotPassword({
    required String mobile,
    required String birthDate,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final data = await _request(
      'POST',
      '/auth/forgot-password/reset',
      auth: false,
      body: {
        'mobile': mobile,
        'birth_date': birthDate,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<void> logout() async {
    await _request('POST', '/auth/logout');
  }

  Future<Map<String, dynamic>> me() async {
    final data = await _request('GET', '/me');
    return (data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> getMyBills({String? source}) async {
    final query = <String, String>{};
    if (source != null && source.trim().isNotEmpty) {
      query['source'] = source.trim();
    }

    final data = await _request(
      'GET',
      '/me/bills',
      query: query.isEmpty ? null : query,
    );
    final rows = ((data as Map)['bills'] as List?) ?? [];
    final parsed = rows
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();

    final requestedSource = source?.trim().toLowerCase() ?? 'all';
    if (requestedSource == 'all') {
      cachedBillsTotalCount = parsed.length;
    }

    return parsed;
  }

  Future<Map<String, dynamic>> createFarmerBill({
    required String billDate,
    required String paymentStatus,
    required double amount,
    String? note,
  }) async {
    final data = await _request(
      'POST',
      '/me/farmer-bills',
      body: {
        'bill_date': billDate,
        'payment_status': paymentStatus,
        'amount': amount,
        'note': note,
      },
    );

    _increaseCachedBillsTotal();
    _notifyBillsChanged();

    return ((data as Map)['bill'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateFarmerBill({
    required int billId,
    required String billDate,
    required String paymentStatus,
    required double amount,
    String? note,
  }) async {
    final data = await _request(
      'PUT',
      '/me/farmer-bills/$billId',
      body: {
        'bill_date': billDate,
        'payment_status': paymentStatus,
        'amount': amount,
        'note': note,
      },
    );

    _notifyBillsChanged();

    return ((data as Map)['bill'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteFarmerBill(int billId) async {
    final data = await _request('DELETE', '/me/farmer-bills/$billId');
    _decreaseCachedBillsTotal();
    _notifyBillsChanged();
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String birthDate,
    String? password,
    String? passwordConfirmation,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'birth_date': birthDate,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      body['password_confirmation'] = passwordConfirmation ?? password;
    }

    final data = await _request('PUT', '/me', body: body);
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateProfileImage({
    String? imagePath,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/me/profile-image',
      fileField: 'profile_image',
      filePath: imagePath,
      fileBytes: imageBytes,
      fileName: fileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateLanguage(String preferredLanguage) async {
    final data = await _request(
      'PATCH',
      '/me/language',
      body: {'preferred_language': preferredLanguage},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> clearAllData() async {
    await _request('DELETE', '/me/all-data');
  }

  Future<Map<String, dynamic>> submitSuggestion(String message) async {
    final data = await _request(
      'POST',
      '/me/suggestions',
      body: {'message': message},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> dashboardSummary() async {
    final data = await _request('GET', '/dashboard/summary');
    return (data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> getLands() async {
    final data = await _request('GET', '/lands');
    final list = ((data as Map)['lands'] as List?) ?? [];
    return list.map((item) => (item as Map).cast<String, dynamic>()).toList();
  }

  Future<Map<String, dynamic>> createLand({
    required String name,
    required double size,
    required String location,
  }) async {
    final data = await _request(
      'POST',
      '/lands',
      body: {'land_name': name, 'land_size': size, 'location': location},
    );

    return ((data as Map)['land'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateLand({
    required int landId,
    required String name,
    required double size,
    required String location,
  }) async {
    final data = await _request(
      'PUT',
      '/lands/$landId',
      body: {'land_name': name, 'land_size': size, 'location': location},
    );

    return ((data as Map)['land'] as Map).cast<String, dynamic>();
  }

  Future<void> deleteLand(int landId) async {
    await _request('DELETE', '/lands/$landId');
  }

  Future<Map<String, dynamic>> getLandSummary(int landId) async {
    final data = await _request('GET', '/lands/$landId/summary');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getIncomeEntries(int landId) async {
    final data = await _request('GET', '/lands/$landId/income-entries');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createIncomeEntry({
    required int landId,
    required String incomeType,
    required double amount,
    required String entryDate,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    String? billPhotoFileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/lands/$landId/income-entries',
      fields: {
        'income_type': incomeType,
        'amount': amount.toString(),
        'entry_date': entryDate,
        'note': note ?? '',
      },
      fileField: 'bill_photo',
      filePath: billPhotoPath,
      fileBytes: billPhotoBytes,
      fileName: billPhotoFileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateIncomeEntry({
    required int incomeEntryId,
    required String incomeType,
    required double amount,
    required String entryDate,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    String? billPhotoFileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/income-entries/$incomeEntryId?_method=PUT',
      fields: {
        '_method': 'PUT',
        'income_type': incomeType,
        'amount': amount.toString(),
        'entry_date': entryDate,
        'note': note ?? '',
      },
      fileField: 'bill_photo',
      filePath: billPhotoPath,
      fileBytes: billPhotoBytes,
      fileName: billPhotoFileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteIncomeEntry(int incomeEntryId) async {
    final data = await _request('DELETE', '/income-entries/$incomeEntryId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getExpenseEntries(int landId) async {
    final data = await _request('GET', '/lands/$landId/expense-entries');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createExpenseEntry({
    required int landId,
    required String expenseType,
    required double amount,
    required String entryDate,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    String? billPhotoFileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/lands/$landId/expense-entries',
      fields: {
        'expense_type': expenseType,
        'amount': amount.toString(),
        'entry_date': entryDate,
        'note': note ?? '',
      },
      fileField: 'bill_photo',
      filePath: billPhotoPath,
      fileBytes: billPhotoBytes,
      fileName: billPhotoFileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateExpenseEntry({
    required int expenseEntryId,
    required String expenseType,
    required double amount,
    required String entryDate,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    String? billPhotoFileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/expense-entries/$expenseEntryId?_method=PUT',
      fields: {
        '_method': 'PUT',
        'expense_type': expenseType,
        'amount': amount.toString(),
        'entry_date': entryDate,
        'note': note ?? '',
      },
      fileField: 'bill_photo',
      filePath: billPhotoPath,
      fileBytes: billPhotoBytes,
      fileName: billPhotoFileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteExpenseEntry(int expenseEntryId) async {
    final data = await _request('DELETE', '/expense-entries/$expenseEntryId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getCropEntries(int landId) async {
    final data = await _request('GET', '/lands/$landId/crop-entries');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createCropEntry({
    required int landId,
    required String cropType,
    required double landSize,
    required double cropWeight,
    required String weightUnit,
  }) async {
    final data = await _request(
      'POST',
      '/lands/$landId/crop-entries',
      body: {
        'crop_type': cropType,
        'land_size': landSize,
        'crop_weight': cropWeight,
        'weight_unit': weightUnit,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateCropEntry({
    required int cropEntryId,
    required String cropType,
    required double landSize,
    required double cropWeight,
    required String weightUnit,
  }) async {
    final data = await _request(
      'PUT',
      '/crop-entries/$cropEntryId',
      body: {
        'crop_type': cropType,
        'land_size': landSize,
        'crop_weight': cropWeight,
        'weight_unit': weightUnit,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteCropEntry(int cropEntryId) async {
    final data = await _request('DELETE', '/crop-entries/$cropEntryId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getLaborEntries(int landId) async {
    final data = await _request('GET', '/lands/$landId/labor-entries');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createLaborEntry({
    required int landId,
    required String laborName,
    required String mobile,
    double totalDays = 0,
    double dailyRate = 0,
  }) async {
    final data = await _request(
      'POST',
      '/lands/$landId/labor-entries',
      body: {
        'labor_name': laborName,
        'mobile': mobile,
        'total_days': totalDays,
        'daily_rate': dailyRate,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateLaborEntry({
    required int laborEntryId,
    required String laborName,
    required String mobile,
    required double totalDays,
    required double dailyRate,
  }) async {
    final data = await _request(
      'PUT',
      '/labor-entries/$laborEntryId',
      body: {
        'labor_name': laborName,
        'mobile': mobile,
        'total_days': totalDays,
        'daily_rate': dailyRate,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteLaborEntry(int laborEntryId) async {
    final data = await _request('DELETE', '/labor-entries/$laborEntryId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getUpadEntries(int laborEntryId) async {
    final data = await _request(
      'GET',
      '/labor-entries/$laborEntryId/upad-entries',
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createUpadEntry({
    required int laborEntryId,
    required double amount,
    required String paymentDate,
    String? note,
    String? laborNameSnapshot,
  }) async {
    final data = await _request(
      'POST',
      '/labor-entries/$laborEntryId/upad-entries',
      body: {
        'amount': amount,
        'payment_date': paymentDate,
        'note': note,
        'labor_name_snapshot': laborNameSnapshot,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateUpadEntry({
    required int upadEntryId,
    required double amount,
    required String paymentDate,
    String? note,
    String? laborNameSnapshot,
  }) async {
    final data = await _request(
      'PUT',
      '/upad-entries/$upadEntryId',
      body: {
        'amount': amount,
        'payment_date': paymentDate,
        'note': note,
        'labor_name_snapshot': laborNameSnapshot,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteUpadEntry(int upadEntryId) async {
    final data = await _request('DELETE', '/upad-entries/$upadEntryId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getAgroDashboardSummary() async {
    final data = await _request('GET', '/agro-center/dashboard');
    return (data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> getAgroFarmers() async {
    final data = await _request('GET', '/agro-center/farmers');
    final rows = ((data as Map)['farmers'] as List?) ?? [];
    return rows.map((item) => (item as Map).cast<String, dynamic>()).toList();
  }

  Future<Map<String, dynamic>> createAgroFarmer({
    required String name,
    required String mobile,
  }) async {
    final data = await _request(
      'POST',
      '/agro-center/farmers',
      body: {'name': name, 'mobile': mobile},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateAgroFarmer({
    required int farmerId,
    required String name,
    required String mobile,
  }) async {
    final data = await _request(
      'PUT',
      '/agro-center/farmers/$farmerId',
      body: {'name': name, 'mobile': mobile},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteAgroFarmer(int farmerId) async {
    final data = await _request('DELETE', '/agro-center/farmers/$farmerId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getAgroBills({
    int? farmerId,
    String? paymentStatus,
    String? fromDate,
    String? toDate,
  }) async {
    final query = <String, String>{};
    if (farmerId != null) {
      query['farmer_id'] = farmerId.toString();
    }
    if (paymentStatus != null && paymentStatus.trim().isNotEmpty) {
      query['payment_status'] = paymentStatus;
    }
    if (fromDate != null && fromDate.trim().isNotEmpty) {
      query['from_date'] = fromDate;
    }
    if (toDate != null && toDate.trim().isNotEmpty) {
      query['to_date'] = toDate;
    }

    final data = await _request('GET', '/agro-center/bills', query: query);
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createAgroBill({
    required int farmerId,
    required String billDate,
    required String paymentStatus,
    required double amount,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    String? billPhotoFileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/agro-center/bills',
      fields: {
        'farmer_id': farmerId.toString(),
        'bill_date': billDate,
        'payment_status': paymentStatus,
        'amount': amount.toString(),
        'note': note ?? '',
      },
      fileField: 'bill_photo',
      filePath: billPhotoPath,
      fileBytes: billPhotoBytes,
      fileName: billPhotoFileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateAgroBill({
    required int billId,
    required int farmerId,
    required String billDate,
    required String paymentStatus,
    required double amount,
    String? note,
    String? billPhotoPath,
    Uint8List? billPhotoBytes,
    String? billPhotoFileName,
  }) async {
    final data = await _multipart(
      'POST',
      '/agro-center/bills/$billId?_method=PUT',
      fields: {
        '_method': 'PUT',
        'farmer_id': farmerId.toString(),
        'bill_date': billDate,
        'payment_status': paymentStatus,
        'amount': amount.toString(),
        'note': note ?? '',
      },
      fileField: 'bill_photo',
      filePath: billPhotoPath,
      fileBytes: billPhotoBytes,
      fileName: billPhotoFileName,
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteAgroBill(int billId) async {
    final data = await _request('DELETE', '/agro-center/bills/$billId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getAgroReport({
    String? fromDate,
    String? toDate,
  }) async {
    final query = <String, String>{};
    if (fromDate != null && fromDate.trim().isNotEmpty) {
      query['from_date'] = fromDate;
    }
    if (toDate != null && toDate.trim().isNotEmpty) {
      query['to_date'] = toDate;
    }

    final data = await _request('GET', '/agro-center/reports', query: query);
    return (data as Map).cast<String, dynamic>();
  }
}
