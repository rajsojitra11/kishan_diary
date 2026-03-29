import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/crop_entry.dart';
import '../models/expense_entry.dart';
import '../models/income_entry.dart';
import '../models/land.dart';
import '../models/labor_entry.dart';
import '../models/upad_entry.dart';
import '../screens/about_app_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/crop_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/home_tab.dart';
import '../screens/income_screen.dart';
import '../screens/labour_screen.dart';
import '../screens/login_screen.dart';
import '../screens/rules_regulation_screen.dart';
import '../utils/api_service.dart';
import '../utils/app_session.dart';
import '../utils/localization.dart';
import '../utils/pdf_export.dart';
import '../widgets/app_widgets.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/text_input_config.dart';

/// Root scaffold of the app.
///
/// Holds cross-cutting state:
/// - [_language]          — current app language
/// - [_lands]             — list of all lands
/// - [_selectedLand]      — currently active land
///
/// Each tab is a separate widget defined in its own screen file.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialUserName,
    this.initialUserEmail,
    this.initialUserBirthdate,
    this.initialUserPassword,
  });

  final String? initialUserName;
  final String? initialUserEmail;
  final String? initialUserBirthdate;
  final String? initialUserPassword;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppLanguage _language = AppLanguage.gujarati;
  static const String _defaultProfileImagePath =
      'lib/assets/images/register.png';
  static const String _whatsAppGroupUrl =
      'https://chat.whatsapp.com/GIw3SmtRce46176ibwomjy?mode=gi_t';
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Land> _lands = [];
  Land? _selectedLand;
  int _navIndex = 0;
  final List<int> _tabHistory = [0];
  late String _profileName;
  late String _profileEmail;
  late String _profileBirthdate;
  late String _profilePassword;
  Uint8List? _profileImageBytes;
  String? _profileImageUrl;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initialName = widget.initialUserName?.trim() ?? '';
    _profileName = initialName.isNotEmpty
        ? initialName
        : t(_language, 'loggedUserDefaultName');
    _profileEmail = widget.initialUserEmail?.trim() ?? '';
    _profileBirthdate = widget.initialUserBirthdate?.trim() ?? '';
    _profilePassword = widget.initialUserPassword ?? '';
    _bootstrapData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _persistSelectedLand();
    }
  }

  Future<void> _bootstrapData() async {
    try {
      final token = await AppSession.getToken();
      if (token == null || token.isEmpty) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      final profileData = await ApiService.instance.me();
      _applyProfileFromPayload(profileData);
      final savedSelectedLandId = await AppSession.getSelectedLandId();
      final savedSelectedLandName = await AppSession.getSelectedLandName();

      final landsPayload = await ApiService.instance.getLands();

      final mappedLands = landsPayload.map(_landFromApi).toList();
      Land? selectedLand;
      if (savedSelectedLandId != null) {
        for (final land in mappedLands) {
          if (land.id == savedSelectedLandId) {
            selectedLand = land;
            break;
          }
        }
      }
      if (selectedLand == null &&
          savedSelectedLandName != null &&
          savedSelectedLandName.trim().isNotEmpty) {
        final normalizedSavedName = savedSelectedLandName.trim().toLowerCase();
        for (final land in mappedLands) {
          if (land.name.trim().toLowerCase() == normalizedSavedName) {
            selectedLand = land;
            break;
          }
        }
      }
      selectedLand ??= mappedLands.isNotEmpty ? mappedLands.first : null;

      if (!mounted) {
        return;
      }

      setState(() {
        _lands
          ..clear()
          ..addAll(mappedLands);
        _selectedLand = selectedLand;
        _initialLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _initialLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _initialLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load app data.')));
    }
  }

  void _applyProfileFromPayload(Map<String, dynamic> payload) {
    final profile = payload['user'] is Map
        ? (payload['user'] as Map).cast<String, dynamic>()
        : payload;

    final preferredLanguage = profile['preferred_language']?.toString();

    _profileName = profile['name']?.toString().trim().isNotEmpty == true
        ? profile['name'].toString().trim()
        : t(_language, 'loggedUserDefaultName');
    _profileEmail = profile['email']?.toString() ?? '';
    _profileBirthdate = _toDisplayDate(profile['birth_date']?.toString());
    _profileImageUrl = profile['profile_image_url']?.toString();
    _language = _languageFromApiCode(preferredLanguage);
  }

  AppLanguage _languageFromApiCode(String? code) {
    if (code == 'en') {
      return AppLanguage.english;
    }
    return AppLanguage.gujarati;
  }

  String _languageToApiCode(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.gujarati:
        return 'gu';
    }
  }

  String _toDisplayDate(String? serverDate) {
    if (serverDate == null || serverDate.trim().isEmpty) {
      return '';
    }
    final parts = serverDate.split('-');
    if (parts.length != 3) {
      return serverDate;
    }
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  Land _landFromApi(Map<String, dynamic> item) {
    return Land(
      id: _toInt(item['id']),
      name: item['land_name']?.toString() ?? '',
      size: _toDouble(item['land_size']),
      location: item['location']?.toString() ?? '',
      laborRupees: _toDouble(item['labor_rupees']),
      fertilizerKg: _toDouble(item['fertilizer_kg']),
      income: _toDouble(item['income_total']),
      expenses: _toDouble(item['expense_total']),
      cropProductionKg: _toDouble(item['crop_production_kg']),
    );
  }

  IncomeEntry _incomeEntryFromApi(Map<String, dynamic> item) {
    return IncomeEntry(
      id: _toInt(item['id']),
      type: item['income_type']?.toString() ?? 'incomeTypeCropSale',
      amount: _toDouble(item['amount']),
      date: _toDisplayDate(item['entry_date']?.toString()),
      note: item['note']?.toString() ?? '',
      billPhotoPath: item['bill_photo_path']?.toString(),
      billPhotoUrl: item['bill_photo_url']?.toString(),
    );
  }

  ExpenseEntry _expenseEntryFromApi(Map<String, dynamic> item) {
    return ExpenseEntry(
      id: _toInt(item['id']),
      type: item['expense_type']?.toString() ?? 'expenseTypeMedicine',
      amount: _toDouble(item['amount']),
      date: _toDisplayDate(item['entry_date']?.toString()),
      note: item['note']?.toString() ?? '',
      billPhotoPath: item['bill_photo_path']?.toString(),
      billPhotoUrl: item['bill_photo_url']?.toString(),
    );
  }

  CropEntry _cropEntryFromApi(Map<String, dynamic> item) {
    return CropEntry(
      id: _toInt(item['id']),
      cropType: item['crop_type']?.toString() ?? 'cropTypeWheat',
      landSize: _toDouble(item['land_size']),
      cropWeight: _toDouble(item['crop_weight']),
      weightUnit: item['weight_unit']?.toString() == 'man' ? 'man' : 'kg',
    );
  }

  LaborEntry _laborEntryFromApi(Map<String, dynamic> item) {
    return LaborEntry(
      id: _toInt(item['id']),
      name: item['labor_name']?.toString() ?? '',
      mobile: item['mobile']?.toString() ?? '',
      days: _toDouble(item['total_days']),
      dailyRate: _toDouble(item['daily_rate']),
    );
  }

  UpadEntry _upadEntryFromApi(Map<String, dynamic> item, LaborEntry labor) {
    final snapshot = item['labor_name_snapshot']?.toString();
    return UpadEntry(
      id: _toInt(item['id']),
      laborEntryId: _toInt(item['labor_entry_id']) ?? labor.id,
      landId: _toInt(item['land_id']),
      laborName: snapshot == null || snapshot.trim().isEmpty
          ? labor.name
          : snapshot,
      amount: _toDouble(item['amount']),
      note: item['note']?.toString() ?? '',
      date: _toDisplayDate(item['payment_date']?.toString()),
    );
  }

  ImageProvider get _profileImageProvider {
    if (_profileImageBytes != null) {
      return MemoryImage(_profileImageBytes!);
    }
    if (_profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return const AssetImage(_defaultProfileImagePath);
  }

  // ── Land Operations ────────────────────────────────────────────────────────

  Future<void> _persistSelectedLand() async {
    final landName = _selectedLand?.name.trim();
    final landId = _selectedLand?.id;
    if (landName == null || landName.isEmpty) {
      await AppSession.clearSelectedLandName();
    } else {
      await AppSession.saveSelectedLandName(landName);
    }
    if (landId == null) {
      await AppSession.clearSelectedLandId();
      return;
    }
    await AppSession.saveSelectedLandId(landId);
  }

  void _setHomeTabAsActive() {
    _navIndex = 0;
    _tabHistory
      ..remove(0)
      ..add(0);
  }

  Future<bool> _addLandFromValues(
    String name,
    double size,
    String location,
  ) async {
    try {
      final payload = await ApiService.instance.createLand(
        name: name,
        size: size,
        location: location,
      );
      final land = _landFromApi(payload);

      if (!mounted) {
        return false;
      }

      setState(() {
        _lands.add(land);
        _selectedLand = land;
        _setHomeTabAsActive();
      });
      return true;
    } on ApiException catch (error) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return false;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add land. Please try again.'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _selectLand(Land land) async {
    if (_selectedLand?.id == land.id) {
      return;
    }

    setState(() {
      _selectedLand = land;
      _setHomeTabAsActive();
    });
    await _persistSelectedLand();
  }

  Future<void> _confirmClearAll() async {
    final shouldClear =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t(_language, 'deleteAllDataTitle')),
            content: Text(
              '${t(_language, 'deleteAllDataConfirm')}\n\n${t(_language, 'deleteAllDataNote')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t(_language, 'cancelButton')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t(_language, 'deleteButton')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldClear) {
      return;
    }

    try {
      await ApiService.instance.clearAllData();

      if (!mounted) {
        return;
      }

      setState(() {
        _lands.clear();
        _selectedLand = null;
        _setHomeTabAsActive();
      });

      await AppSession.clearSelectedLandId();
      await AppSession.clearSelectedLandName();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'disableAllDataDone'))),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _confirmDisableLand(Land land) async {
    final shouldDisable =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t(_language, 'disableLandTitle')),
            content: Text(t(_language, 'disableLandConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t(_language, 'cancelButton')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t(_language, 'deleteButton')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDisable) {
      return;
    }

    try {
      if (land.id != null) {
        await ApiService.instance.deleteLand(land.id!);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _lands.removeWhere((item) => item.id == land.id);
        if (_selectedLand?.id == land.id) {
          _selectedLand = _lands.isNotEmpty ? _lands.first : null;
          _setHomeTabAsActive();
        }
      });

      await _persistSelectedLand();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _navigateToTab(int index) {
    if (index == _navIndex) {
      return;
    }

    setState(() {
      _navIndex = index;
      _tabHistory
        ..remove(index)
        ..add(index);
    });
  }

  void _handleSystemBack() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      return;
    }

    if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        _navIndex = _tabHistory.last;
      });
      return;
    }

    SystemNavigator.pop();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t(_language, 'validationRequiredField');
    }
    return null;
  }

  String? _positiveNumberValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return t(_language, 'validationRequiredField');
    }
    final parsed = double.tryParse(raw);
    if (parsed == null) {
      return t(_language, 'validationEnterValidNumber');
    }
    if (parsed <= 0) {
      return t(_language, 'validationEnterPositiveNumber');
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return t(_language, 'validationRequiredField');
    }
    if (!RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$').hasMatch(email)) {
      return t(_language, 'validationEnterValidEmail');
    }
    return null;
  }

  Future<XFile?> _pickProfileImage(ImageSource source) async {
    return _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 900,
    );
  }

  Future<Map<String, dynamic>?> _showProfileImagePickerOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(t(_language, 'profileImageCameraOption')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t(_language, 'profileImageGalleryOption')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return null;
    }

    final pickedFile = await _pickProfileImage(source);
    if (pickedFile == null) {
      return null;
    }

    final bytes = await pickedFile.readAsBytes();
    return {'bytes': bytes, 'path': pickedFile.path};
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddLandDialog() {
    final nameCtrl = TextEditingController();
    final sizeCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t(_language, 'addNewLand')),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInput(
                  TextInputConfig(
                    nameCtrl,
                    t(_language, 'landName'),
                    Icons.landscape,
                    validator: _requiredValidator,
                  ),
                ),
                const SizedBox(height: 8),
                buildInput(
                  TextInputConfig(
                    sizeCtrl,
                    t(_language, 'landSize'),
                    Icons.straighten,
                    number: true,
                    validator: _positiveNumberValidator,
                  ),
                ),
                const SizedBox(height: 8),
                buildInput(
                  TextInputConfig(
                    locCtrl,
                    t(_language, 'location'),
                    Icons.location_on,
                    validator: _requiredValidator,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t(_language, 'cancelButton')),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final name = nameCtrl.text.trim();
              final size = double.parse(sizeCtrl.text.trim());
              final location = locCtrl.text.trim();

              _addLandFromValues(name, size, location);
              Navigator.pop(context);
            },
            child: Text(t(_language, 'addLandButton')),
          ),
        ],
      ),
    );
  }

  void _showEditLandDialog(Land land) {
    final nameCtrl = TextEditingController(text: land.name);
    final sizeCtrl = TextEditingController(text: land.size.toString());
    final locCtrl = TextEditingController(text: land.location);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t(_language, 'editLand')),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInput(
                  TextInputConfig(
                    nameCtrl,
                    t(_language, 'landName'),
                    Icons.landscape,
                    validator: _requiredValidator,
                  ),
                ),
                const SizedBox(height: 8),
                buildInput(
                  TextInputConfig(
                    sizeCtrl,
                    t(_language, 'landSize'),
                    Icons.straighten,
                    number: true,
                    validator: _positiveNumberValidator,
                  ),
                ),
                const SizedBox(height: 8),
                buildInput(
                  TextInputConfig(
                    locCtrl,
                    t(_language, 'location'),
                    Icons.location_on,
                    validator: _requiredValidator,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t(_language, 'cancelButton')),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(t(_language, 'saveMetricsButton')),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final name = nameCtrl.text.trim();
              final size = double.parse(sizeCtrl.text.trim());
              final location = locCtrl.text.trim();

              try {
                if (land.id != null) {
                  final payload = await ApiService.instance.updateLand(
                    landId: land.id!,
                    name: name,
                    size: size,
                    location: location,
                  );
                  final updated = _landFromApi(payload);
                  setState(() {
                    land.name = updated.name;
                    land.size = updated.size;
                    land.location = updated.location;
                  });
                } else {
                  setState(() {
                    land.name = name;
                    land.size = size;
                    land.location = location;
                  });
                }

                if (!mounted) {
                  return;
                }

                Navigator.pop(context);
              } on ApiException catch (error) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateProfileDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final birthdateCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    nameCtrl.text = _profileName;
    emailCtrl.text = _profileEmail;
    birthdateCtrl.text = _profileBirthdate;
    if (birthdateCtrl.text.trim().isEmpty) {
      final today = DateTime.now();
      birthdateCtrl.text =
          '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    }
    passwordCtrl.text = _profilePassword;
    Uint8List? tempProfileImageBytes = _profileImageBytes;
    String? tempProfileImageUrl = _profileImageUrl;
    String? tempProfileImagePath;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: Text(t(_language, 'updateProfileTitle')),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: tempProfileImageBytes != null
                        ? MemoryImage(tempProfileImageBytes!)
                        : (tempProfileImageUrl != null &&
                                  tempProfileImageUrl!.trim().isNotEmpty
                              ? NetworkImage(tempProfileImageUrl!)
                              : const AssetImage(_defaultProfileImagePath)
                                    as ImageProvider),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final pickedResult =
                          await _showProfileImagePickerOptions();
                      if (pickedResult == null) {
                        return;
                      }
                      dialogSetState(() {
                        tempProfileImageBytes =
                            pickedResult['bytes'] as Uint8List?;
                        tempProfileImagePath = pickedResult['path']?.toString();
                        if (tempProfileImageBytes != null) {
                          tempProfileImageUrl = null;
                        }
                      });
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(t(_language, 'updateProfileImage')),
                  ),
                  const SizedBox(height: 8),
                  buildInput(
                    TextInputConfig(
                      nameCtrl,
                      t(_language, 'updateProfileName'),
                      Icons.person,
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildInput(
                    TextInputConfig(
                      emailCtrl,
                      t(_language, 'updateProfileEmail'),
                      Icons.email,
                      validator: _emailValidator,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: birthdateCtrl,
                    readOnly: true,
                    validator: _requiredValidator,
                    decoration: InputDecoration(
                      labelText: t(_language, 'updateProfileBirthdate'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(
                          now.year - 18,
                          now.month,
                          now.day,
                        ),
                        firstDate: DateTime(1900),
                        lastDate: now,
                      );

                      if (pickedDate == null) {
                        return;
                      }

                      birthdateCtrl.text =
                          '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: t(_language, 'updateProfilePassword'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t(_language, 'cancelButton')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                try {
                  final updated = await ApiService.instance.updateProfile(
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    birthDate: birthdateCtrl.text.trim(),
                    password: passwordCtrl.text.trim().isEmpty
                        ? null
                        : passwordCtrl.text,
                    passwordConfirmation: passwordCtrl.text.trim().isEmpty
                        ? null
                        : passwordCtrl.text,
                  );

                  String? updatedProfileImageUrl;

                  if (tempProfileImagePath != null &&
                      tempProfileImagePath!.isNotEmpty) {
                    final imagePayload = await ApiService.instance
                        .updateProfileImage(
                          imagePath: tempProfileImagePath,
                          imageBytes: tempProfileImageBytes,
                          fileName: tempProfileImagePath!.split('/').last,
                        );
                    updatedProfileImageUrl = imagePayload['profile_image_url']
                        ?.toString();
                  } else if (tempProfileImageBytes != null) {
                    final imagePayload = await ApiService.instance
                        .updateProfileImage(
                          imageBytes: tempProfileImageBytes,
                          fileName: 'profile_image.jpg',
                        );
                    updatedProfileImageUrl = imagePayload['profile_image_url']
                        ?.toString();
                  }

                  final user = ((updated['user'] as Map?) ?? {})
                      .cast<String, dynamic>();

                  await AppSession.saveUserProfile(
                    name: user['name']?.toString(),
                    email: user['email']?.toString(),
                    birthDate: birthdateCtrl.text.trim(),
                  );

                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _profileName =
                        user['name']?.toString() ?? nameCtrl.text.trim();
                    _profileEmail =
                        user['email']?.toString() ?? emailCtrl.text.trim();
                    _profileBirthdate = birthdateCtrl.text.trim();
                    if (passwordCtrl.text.trim().isNotEmpty) {
                      _profilePassword = passwordCtrl.text;
                    }
                    _profileImageBytes = tempProfileImageBytes;
                    _profileImageUrl =
                        updatedProfileImageUrl ??
                        user['profile_image_url']?.toString() ??
                        _profileImageUrl;
                  });

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t(_language, 'profileUpdatedMessage')),
                    ),
                  );
                } on ApiException catch (error) {
                  if (!dialogContext.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(error.message)));
                }
              },
              child: Text(t(_language, 'saveButton')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t(_language, 'logoutConfirmTitle')),
            content: Text(t(_language, 'logoutConfirmMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t(_language, 'cancelButton')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t(_language, 'drawerLogout')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout || !mounted) {
      return;
    }

    try {
      await ApiService.instance.logout();
    } catch (_) {}

    await AppSession.clearAll();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _downloadCurrentPageRecords() async {
    final exported = await exportCurrentPagePdf(
      language: _language,
      navIndex: _navIndex,
      lands: _lands,
      selectedLand: _selectedLand,
    );

    if (!mounted) {
      return;
    }

    if (!exported) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t(_language, 'downloadNoData'))));
    }
  }

  Future<void> _loadAllRecordsForPdf() async {
    for (final land in _lands) {
      if (land.id == null) {
        continue;
      }

      final incomePayload = await ApiService.instance.getIncomeEntries(
        land.id!,
      );
      final incomeEntries = ((incomePayload['income_entries'] as List?) ?? [])
          .map(
            (item) =>
                _incomeEntryFromApi((item as Map).cast<String, dynamic>()),
          )
          .toList();

      final expensePayload = await ApiService.instance.getExpenseEntries(
        land.id!,
      );
      final expenseEntries =
          ((expensePayload['expense_entries'] as List?) ?? [])
              .map(
                (item) =>
                    _expenseEntryFromApi((item as Map).cast<String, dynamic>()),
              )
              .toList();

      final cropPayload = await ApiService.instance.getCropEntries(land.id!);
      final cropEntries = ((cropPayload['crop_entries'] as List?) ?? [])
          .map(
            (item) => _cropEntryFromApi((item as Map).cast<String, dynamic>()),
          )
          .toList();

      final laborPayload = await ApiService.instance.getLaborEntries(land.id!);
      final laborEntries = ((laborPayload['labor_entries'] as List?) ?? [])
          .map(
            (item) => _laborEntryFromApi((item as Map).cast<String, dynamic>()),
          )
          .toList();

      final upadEntries = <UpadEntry>[];
      for (final labor in laborEntries) {
        if (labor.id == null) {
          continue;
        }
        final upadPayload = await ApiService.instance.getUpadEntries(labor.id!);
        final entries = ((upadPayload['upad_entries'] as List?) ?? [])
            .map(
              (item) => _upadEntryFromApi(
                (item as Map).cast<String, dynamic>(),
                labor,
              ),
            )
            .toList();
        upadEntries.addAll(entries);
      }

      land.incomeEntries
        ..clear()
        ..addAll(incomeEntries);
      land.expenseEntries
        ..clear()
        ..addAll(expenseEntries);
      land.cropEntries
        ..clear()
        ..addAll(cropEntries);
      land.laborEntries
        ..clear()
        ..addAll(laborEntries);
      land.upadEntries
        ..clear()
        ..addAll(upadEntries);

      land.income = _toDouble(incomePayload['total_income']);
      land.expenses = _toDouble(expensePayload['total_expense']);
      land.cropProductionKg = _toDouble(
        cropPayload['crop_production_kg_total'],
      );
      land.laborRupees = _toDouble(
        ((laborPayload['totals'] as Map?)?['total_wage']),
      );
    }

  }

  Future<void> _downloadAllDataRecords() async {
    try {
      await _loadAllRecordsForPdf();
      if (mounted) {
        setState(() {});
      }

      final exported = await exportAllDataPdf(
        language: _language,
        lands: _lands,
      );

      if (!mounted) {
        return;
      }

      if (!exported) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t(_language, 'downloadAllNoData'))),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download all data PDF.')),
      );
    }
  }

  Future<void> _openWhatsAppGroup() async {
    final uri = Uri.parse(_whatsAppGroupUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'whatsAppOpenError'))),
      );
    }
  }

  void _openDrawerInfoPage(Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => page)).then((_) {
      if (mounted) {
        _scaffoldKey.currentState?.openDrawer();
      }
    });
  }

  // ── Nav Bar ────────────────────────────────────────────────────────────────

  Widget _navIcon(Widget icon, {required bool selected}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected
            ? Colors.green.withAlpha(30)
            : Colors.grey.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? Colors.green.withAlpha(90)
              : Colors.grey.withAlpha(90),
          width: 1,
        ),
      ),
      child: icon,
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: _navigateToTab,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: _navIcon(const Icon(Icons.home), selected: false),
          activeIcon: _navIcon(const Icon(Icons.home), selected: true),
          label: t(_language, 'navHome'),
        ),
        BottomNavigationBarItem(
          icon: _navIcon(const Icon(Icons.currency_rupee), selected: false),
          activeIcon: _navIcon(
            const Icon(Icons.currency_rupee),
            selected: true,
          ),
          label: t(_language, 'navIncome'),
        ),
        BottomNavigationBarItem(
          icon: _navIcon(const Icon(Icons.receipt_long), selected: false),
          activeIcon: _navIcon(const Icon(Icons.receipt_long), selected: true),
          label: t(_language, 'navExpense'),
        ),
        BottomNavigationBarItem(
          icon: _navIcon(const Icon(Icons.eco), selected: false),
          activeIcon: _navIcon(const Icon(Icons.eco), selected: true),
          label: t(_language, 'navCrop'),
        ),
        BottomNavigationBarItem(
          icon: _navIcon(const Icon(Icons.group), selected: false),
          activeIcon: _navIcon(const Icon(Icons.group), selected: true),
          label: t(_language, 'navLabor'),
        ),
      ],
    );
  }

  // ── Current Tab ────────────────────────────────────────────────────────────

  Widget _currentTab() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_navIndex) {
      case 1:
        return IncomeScreen(
          key: ValueKey('income-${_selectedLand?.id ?? 'none'}'),
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      case 2:
        return ExpenseScreen(
          key: ValueKey('expense-${_selectedLand?.id ?? 'none'}'),
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      case 3:
        return CropScreen(
          key: ValueKey('crop-${_selectedLand?.id ?? 'none'}'),
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      case 4:
        return LabourScreen(
          key: ValueKey('labor-${_selectedLand?.id ?? 'none'}'),
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      default:
        return HomeTab(
          lands: _lands,
          selectedLand: _selectedLand,
          language: _language,
          onAddLand: _addLandFromValues,
          onChangeLand: _selectLand,
        );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleSystemBack();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: buildKishanAppBar(
          context: context,
          language: _language,
          title: t(_language, 'appTitle'),
          showMenu: true,
        ),

        // ── Drawer ─────────────────────────────────────────────────────────────
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade700,
                              Colors.green.shade300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white,
                              backgroundImage: _profileImageProvider,
                              onBackgroundImageError: (_, __) {},
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _profileName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t(_language, 'drawerHeader'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Colors.green,
                        ),
                        title: Text(t(_language, 'drawerUpdateProfile')),
                        onTap: () {
                          Navigator.pop(context);
                          Future.delayed(
                            Duration.zero,
                            _showUpdateProfileDialog,
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Language picker
                      ListTile(
                        leading: const Icon(
                          Icons.language,
                          color: Colors.green,
                        ),
                        title: Text(t(_language, 'drawerLanguage')),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: AppLanguage.values.map((lang) {
                                  return RadioListTile<AppLanguage>(
                                    title: Text(appLanguageNames[lang]!),
                                    value: lang,
                                    groupValue: _language,
                                    onChanged: (v) {
                                      if (v != null) {
                                        ApiService.instance
                                            .updateLanguage(
                                              _languageToApiCode(v),
                                            )
                                            .then(
                                              (_) => AppSession.saveUserProfile(
                                                preferredLanguage:
                                                    _languageToApiCode(v),
                                              ),
                                            )
                                            .catchError((_) {});
                                        setState(() => _language = v);
                                        Navigator.pop(context);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),

                      // Land selector
                      ExpansionTile(
                        leading: const Icon(Icons.map, color: Colors.green),
                        title: Text(t(_language, 'selectLandHeading')),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add, color: Colors.green),
                            title: Text(t(_language, 'drawerAddLand')),
                            onTap: () {
                              Navigator.pop(context);
                              _showAddLandDialog();
                            },
                          ),
                          if (_lands.isEmpty)
                            ListTile(
                              dense: true,
                              title: Text(t(_language, 'noLandSelected')),
                              onTap: () => Navigator.pop(context),
                            )
                          else
                            ..._lands.map((land) {
                              final isSelected = land == _selectedLand;
                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: Colors.green.shade50,
                                leading: Icon(
                                  Icons.landscape,
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                title: Text('${land.name} (${land.location})'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.green,
                                      ),
                                      tooltip: t(_language, 'editLandTooltip'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showEditLandDialog(land);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: t(
                                        _language,
                                        'disableLandTooltip',
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _confirmDisableLand(land);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await _selectLand(land);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.pop(context);
                                },
                              );
                            }),
                        ],
                      ),

                      // About
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        title: Text(t(_language, 'drawerAbout')),
                        onTap: () {
                          _openDrawerInfoPage(
                            AboutAppScreen(language: _language),
                          );
                        },
                      ),

                      // Terms & Conditions
                      ListTile(
                        leading: const Icon(
                          Icons.policy_outlined,
                          color: Colors.deepPurple,
                        ),
                        title: Text(t(_language, 'drawerTermsConditions')),
                        onTap: () {
                          _openDrawerInfoPage(
                            RulesRegulationScreen(language: _language),
                          );
                        },
                      ),

                      // Contact Us
                      ListTile(
                        leading: const Icon(
                          Icons.contact_mail,
                          color: Colors.teal,
                        ),
                        title: Text(t(_language, 'drawerContactUs')),
                        onTap: () {
                          _openDrawerInfoPage(
                            ContactUsScreen(language: _language),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.chat, color: Colors.green),
                        title: Text(t(_language, 'drawerWhatsAppGroup')),
                        onTap: () {
                          Navigator.pop(context);
                          _openWhatsAppGroup();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        title: Text(t(_language, 'drawerDownloadAllData')),
                        onTap: () {
                          Navigator.pop(context);
                          _downloadAllDataRecords();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.clear_all, color: Colors.red),
                  title: Text(t(_language, 'drawerClear')),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmClearAll();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(t(_language, 'drawerLogout')),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(Duration.zero, _confirmLogout);
                  },
                ),
              ],
            ),
          ),
        ),

        // ── Body ───────────────────────────────────────────────────────────────
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.lightGreen.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_navIndex != 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: t(_language, 'downloadPdfTooltip'),
                      icon: const Icon(Icons.download),
                      onPressed: _downloadCurrentPageRecords,
                    ),
                  ),
                _currentTab(),
              ],
            ),
          ),
        ),

        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }
}
