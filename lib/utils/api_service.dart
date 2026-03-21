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
  static const String _androidDefaultApiBase = 'http://192.168.1.8:8000/api/v1';

  static String get _baseUrl {
    final configured = const String.fromEnvironment('API_BASE_URL');
    if (configured.trim().isNotEmpty) {
      return configured.endsWith('/api/v1')
          ? configured
          : '${configured.replaceAll(RegExp(r'/$'), '')}/api/v1';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }

    if (Platform.isAndroid) {
      return _androidDefaultApiBase;
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: query);
  }

  String _backendUnavailableMessage() {
    final apiBase = _baseUrl.replaceAll(RegExp(r'/api/v1$'), '');
    return 'Backend server not running or not reachable. '
        'Start Laravel with: php artisan serve --host=0.0.0.0 --port=8000 '
        'and run app with API_BASE_URL=$apiBase';
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
    Map<String, dynamic> payload;

    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Invalid server response',
        statusCode: response.statusCode,
      );
    }

    final success = payload['success'] == true;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return payload['data'];
    }

    throw ApiException(
      payload['message']?.toString() ?? 'Request failed',
      statusCode: response.statusCode,
      errors: payload['errors'] as Map<String, dynamic>?,
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

    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on http.ClientException {
      throw ApiException(_backendUnavailableMessage());
    } on SocketException {
      throw ApiException(_backendUnavailableMessage());
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
      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } on http.ClientException {
      throw ApiException(_backendUnavailableMessage());
    } on SocketException {
      throw ApiException(_backendUnavailableMessage());
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
    required String email,
    required String mobile,
    required String birthDate,
    required String password,
    required String passwordConfirmation,
    String preferredLanguage = 'gu',
  }) async {
    final data = await _request(
      'POST',
      '/auth/register',
      auth: false,
      body: {
        'name': name,
        'email': email,
        'mobile': mobile,
        'birth_date': birthDate,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'preferred_language': preferredLanguage,
      },
    );

    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      auth: false,
      body: {'mobile': mobile, 'password': password},
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

  Future<Map<String, dynamic>> getAnimals() async {
    final data = await _request('GET', '/animals');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createAnimal(String animalName) async {
    final data = await _request(
      'POST',
      '/animals',
      body: {'animal_name': animalName},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateAnimal(
    int animalId,
    String animalName,
  ) async {
    final data = await _request(
      'PUT',
      '/animals/$animalId',
      body: {'animal_name': animalName},
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteAnimal(int animalId) async {
    final data = await _request('DELETE', '/animals/$animalId');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getAnimalRecords(int animalId) async {
    final data = await _request('GET', '/animals/$animalId/records');
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createAnimalRecord({
    required int animalId,
    required double amount,
    required double milkLiter,
    required String recordDate,
  }) async {
    final data = await _request(
      'POST',
      '/animals/$animalId/records',
      body: {
        'amount': amount,
        'milk_liter': milkLiter,
        'record_date': recordDate,
      },
    );
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteAnimalRecord(int animalRecordId) async {
    final data = await _request('DELETE', '/animal-records/$animalRecordId');
    return (data as Map).cast<String, dynamic>();
  }
}
