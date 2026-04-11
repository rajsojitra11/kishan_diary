import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_providers.dart';
import '../utils/api_service.dart';
import '../utils/app_session.dart';
import '../utils/image_cache.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/text_input_config.dart';
import 'agro/agro_dashboard_tab.dart';
import 'agro/agro_farmer_bills_screen.dart';
import 'agro/agro_farmers_tab.dart';
import 'agro/agro_manage_bills_tab.dart';
import 'agro/agro_report_tab.dart';
import 'about_app_screen.dart';
import 'contact_us_screen.dart';
import 'login_screen.dart';
import 'rules_regulation_screen.dart';

class AgroOwnerScreen extends ConsumerStatefulWidget {
  const AgroOwnerScreen({
    super.key,
    this.initialUserName,
    this.initialUserEmail,
    this.initialUserBirthdate,
  });

  final String? initialUserName;
  final String? initialUserEmail;
  final String? initialUserBirthdate;

  @override
  ConsumerState<AgroOwnerScreen> createState() => _AgroOwnerScreenState();
}

class _AgroOwnerScreenState extends ConsumerState<AgroOwnerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();
  static const String _defaultProfileImagePath =
      'lib/assets/images/register.png';
  static const String _whatsAppGroupUrl =
      'https://chat.whatsapp.com/GIw3SmtRce46176ibwomjy?mode=gi_t';

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _farmerNameCtrl = TextEditingController();
  final TextEditingController _farmerMobileCtrl = TextEditingController();

  AppLanguage _language = AppLanguage.gujarati;
  bool _loading = true;
  bool _savingBill = false;
  bool _savingFarmer = false;
  int _navIndex = 0;
  String _farmerSearchQuery = '';

  String _paymentStatus = 'pending';
  int? _selectedFarmerId;
  int? _editingBillId;
  Uint8List? _billPhotoBytes;
  String? _billPhotoPath;
  String? _billPhotoName;

  String _profileName = '';
  String _profileEmail = '';
  String _profileBirthdate = '';
  String _profilePassword = '';
  Uint8List? _profileImageBytes;
  String? _profileImageUrl;

  Map<String, dynamic> _dashboard = {};
  Map<String, dynamic> _report = {};
  final List<Map<String, dynamic>> _farmers = [];
  final List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _profileName = widget.initialUserName ?? '';
    _profileEmail = widget.initialUserEmail ?? '';
    _profileBirthdate = widget.initialUserBirthdate ?? '';
    _dateCtrl.text = _formatDate(DateTime.now());
    _bootstrap();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _noteCtrl.dispose();
    _farmerNameCtrl.dispose();
    _farmerMobileCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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

  Future<void> _bootstrap() async {
    try {
      final profileData = await ref.read(apiServiceProvider).me();
      final profile = profileData['user'] is Map
          ? (profileData['user'] as Map).cast<String, dynamic>()
          : profileData;

      final preferredLanguage = profile['preferred_language']?.toString();
      _language = preferredLanguage == 'en'
          ? AppLanguage.english
          : AppLanguage.gujarati;
      _profileName = profile['name']?.toString() ?? _profileName;
      _profileEmail = profile['email']?.toString() ?? _profileEmail;
        _profileBirthdate = _toDisplayDate(profile['birth_date']?.toString());
        _profileImageUrl = profile['profile_image_url']?.toString();

      await _reloadAll();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroLoadError'))),
      );
    }
  }

  Future<void> _reloadAll() async {
    final dashboard = await ref.read(apiServiceProvider).getAgroDashboardSummary();
    final farmers = await ref.read(apiServiceProvider).getAgroFarmers();
    final billsData = await ref.read(apiServiceProvider).getAgroBills();
    final report = await ref.read(apiServiceProvider).getAgroReport();

    if (!mounted) {
      return;
    }

    setState(() {
      _dashboard = dashboard;
      _farmers
        ..clear()
        ..addAll(farmers);
      _bills
        ..clear()
        ..addAll(
          (((billsData['bills'] as List?) ?? [])
              .map((item) => (item as Map).cast<String, dynamic>())),
        );
      _report = report;
      _loading = false;

      final selectedStillExists = _selectedFarmerId != null &&
          _farmers.any((farmer) => farmer['id'] == _selectedFarmerId);

      if (!selectedStillExists) {
        if (_farmers.isNotEmpty) {
          final firstId = _farmers.first['id'];
          _selectedFarmerId = firstId is int ? firstId : null;
        } else {
          _selectedFarmerId = null;
        }
      }
    });
  }

  Future<void> _logout() async {
    try {
      await ref.read(apiServiceProvider).logout();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateCtrl.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickBillPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      setState(() {
        _billPhotoBytes = bytes;
        _billPhotoPath = null;
        _billPhotoName = file.name;
      });
      return;
    }

    setState(() {
      _billPhotoPath = file.path;
      _billPhotoBytes = null;
      _billPhotoName = file.name;
    });
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t(_language, 'validationRequiredField');
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
    return _picker.pickImage(source: source, imageQuality: 85, maxWidth: 900);
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

  Future<void> _showUpdateProfileDialog() async {
    final nameCtrl = TextEditingController(text: _profileName);
    final emailCtrl = TextEditingController(text: _profileEmail);
    final birthdateCtrl = TextEditingController(text: _profileBirthdate);
    final passwordCtrl = TextEditingController(text: _profilePassword);
    final formKey = GlobalKey<FormState>();

    if (birthdateCtrl.text.trim().isEmpty) {
      final today = DateTime.now();
      birthdateCtrl.text =
          '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    }

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
                      : ((tempProfileImageUrl?.trim().isNotEmpty ?? false)
                          ? CachedNetworkImageProvider(
                              tempProfileImageUrl!,
                              cacheManager: AppImageCache.manager,
                            )
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
                        initialDate: DateTime(now.year - 18, now.month, now.day),
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
                  final updated = await ref.read(apiServiceProvider).updateProfile(
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
                    final imagePayload = await ref.read(apiServiceProvider)
                        .updateProfileImage(
                          imagePath: tempProfileImagePath,
                          imageBytes: tempProfileImageBytes,
                          fileName: tempProfileImagePath!.split('/').last,
                        );
                    updatedProfileImageUrl = imagePayload['profile_image_url']
                        ?.toString();
                  } else if (tempProfileImageBytes != null) {
                    final imagePayload = await ref.read(apiServiceProvider)
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
                    SnackBar(content: Text(t(_language, 'profileUpdatedMessage'))),
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

  String _selectedFarmerName() {
    if (_selectedFarmerId == null) {
      return '';
    }

    for (final farmer in _farmers) {
      if (farmer['id'] == _selectedFarmerId) {
        return farmer['name']?.toString() ?? '';
      }
    }

    return '';
  }

  Future<void> _openFarmerPickerDialog() async {
    String query = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredFarmers = _farmers.where((farmer) {
              final name = farmer['name']?.toString().toLowerCase() ?? '';
              return name.contains(query.toLowerCase());
            }).toList();

            return AlertDialog(
              title: Text(t(_language, 'agroFarmer')),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: t(_language, 'agroSearchFarmerHint'),
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() => query = value.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filteredFarmers.isEmpty
                          ? Center(child: Text(t(_language, 'agroNoFarmers')))
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredFarmers.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, index) {
                                final farmer = filteredFarmers[index];
                                final farmerId = farmer['id'];

                                return ListTile(
                                  title: Text(farmer['name']?.toString() ?? '-'),
                                  selected: farmerId == _selectedFarmerId,
                                  onTap: () {
                                    if (farmerId is int) {
                                      setState(() => _selectedFarmerId = farmerId);
                                      Navigator.of(dialogContext).pop();
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(t(_language, 'cancelButton')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetBillForm() {
    setState(() {
      _editingBillId = null;
      _paymentStatus = 'pending';
      _amountCtrl.clear();
      _noteCtrl.clear();
      _dateCtrl.text = _formatDate(DateTime.now());
      _billPhotoBytes = null;
      _billPhotoPath = null;
      _billPhotoName = null;
    });
  }

  void _startEditBill(Map<String, dynamic> bill) {
    setState(() {
      _editingBillId = bill['id'] as int?;
      _selectedFarmerId = bill['farmer_id'] as int?;
      _paymentStatus = bill['payment_status']?.toString() ?? 'pending';
      _amountCtrl.text = (bill['amount'] ?? 0).toString();
      _dateCtrl.text = _toDisplayDate(bill['bill_date']?.toString());
      _noteCtrl.text = bill['note']?.toString() ?? '';
      _billPhotoBytes = null;
      _billPhotoPath = null;
      _billPhotoName = null;
    });
  }

  Future<void> _saveBill() async {
    if (_savingBill) {
      return;
    }

    if (_selectedFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroSelectFarmer'))),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'validationEnterValidNumber'))),
      );
      return;
    }

    if (_dateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'validationSelectDate'))),
      );
      return;
    }

    if (_editingBillId == null && _billPhotoPath == null && _billPhotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroBillPhotoRequired'))),
      );
      return;
    }

    try {
      setState(() => _savingBill = true);

      if (_editingBillId == null) {
        await ref.read(apiServiceProvider).createAgroBill(
          farmerId: _selectedFarmerId!,
          billDate: _dateCtrl.text.trim(),
          paymentStatus: _paymentStatus,
          amount: amount,
          note: _noteCtrl.text.trim(),
          billPhotoPath: _billPhotoPath,
          billPhotoBytes: _billPhotoBytes,
          billPhotoFileName: _billPhotoName,
        );
      } else {
        await ref.read(apiServiceProvider).updateAgroBill(
          billId: _editingBillId!,
          farmerId: _selectedFarmerId!,
          billDate: _dateCtrl.text.trim(),
          paymentStatus: _paymentStatus,
          amount: amount,
          note: _noteCtrl.text.trim(),
          billPhotoPath: _billPhotoPath,
          billPhotoBytes: _billPhotoBytes,
          billPhotoFileName: _billPhotoName,
        );
      }

      await _reloadAll();
      _resetBillForm();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroBillSaved'))),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _savingBill = false);
      }
    }
  }

  Future<void> _deleteBill(int billId) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t(_language, 'deleteButton')),
            content: Text(t(_language, 'agroBillDeleteConfirm')),
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

    if (!shouldDelete) {
      return;
    }

    try {
      await ref.read(apiServiceProvider).deleteAgroBill(billId);
      await _reloadAll();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroBillDeleted'))),
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

  Future<bool> _saveFarmer() async {
    if (_savingFarmer) {
      return false;
    }

    final name = _farmerNameCtrl.text.trim();
    final mobile = _farmerMobileCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroEnterFarmerName'))),
      );
      return false;
    }

      if (!RegExp('^\\d{10}\$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'validationEnterValidMobile'))),
      );
        return false;
    }

    try {
      setState(() => _savingFarmer = true);

      final response = await ref.read(apiServiceProvider).createAgroFarmer(
        name: name,
        mobile: mobile,
      );

      final farmer = response['farmer'];
      final farmerId = farmer is Map ? farmer['id'] : null;

      await _reloadAll();

      if (!mounted) {
        return false;
      }

      setState(() {
        _farmerNameCtrl.clear();
        _farmerMobileCtrl.clear();
        if (farmerId is int) {
          _selectedFarmerId = farmerId;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroFarmerAdded'))),
      );
      return true;
    } on ApiException catch (error) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return false;
    } finally {
      if (mounted) {
        setState(() => _savingFarmer = false);
      }
    }
  }

  Future<void> _openEditFarmerDialog(Map<String, dynamic> farmer) async {
    final farmerId = farmer['id'];
    if (farmerId is! int) {
      return;
    }

    final nameCtrl = TextEditingController(text: farmer['name']?.toString() ?? '');
    final mobileCtrl = TextEditingController(text: farmer['mobile']?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t(_language, 'agroEditFarmerTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: t(_language, 'agroFarmerNameLabel'),
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                counterText: '',
                labelText: t(_language, 'agroFarmerMobileLabel'),
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t(_language, 'cancelButton')),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final mobile = mobileCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t(_language, 'agroEnterFarmerName'))),
                );
                return;
              }

              if (!RegExp('^\\d{10}\$').hasMatch(mobile)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t(_language, 'validationEnterValidMobile'))),
                );
                return;
              }

              try {
                await ref.read(apiServiceProvider).updateAgroFarmer(
                  farmerId: farmerId,
                  name: name,
                  mobile: mobile,
                );
                await _reloadAll();

                if (!dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();

                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t(_language, 'agroFarmerUpdated'))),
                );
              } on ApiException catch (error) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
            child: Text(t(_language, 'saveButton')),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFarmer(Map<String, dynamic> farmer) async {
    final farmerId = farmer['id'];
    if (farmerId is! int) {
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t(_language, 'deleteButton')),
            content: Text(t(_language, 'agroFarmerDeleteConfirm')),
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

    if (!shouldDelete) {
      return;
    }

    try {
      await ref.read(apiServiceProvider).deleteAgroFarmer(farmerId);
      await _reloadAll();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(_language, 'agroFarmerDeleted'))),
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

  Future<void> _openAddFarmerDialog() async {
    _farmerNameCtrl.clear();
    _farmerMobileCtrl.clear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(_language, 'agroAddFarmerButton')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _farmerNameCtrl,
                decoration: InputDecoration(
                  labelText: t(_language, 'agroFarmerNameLabel'),
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _farmerMobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: t(_language, 'agroFarmerMobileLabel'),
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _savingFarmer
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: Text(t(_language, 'cancelButton')),
            ),
            ElevatedButton(
              onPressed: _savingFarmer
                  ? null
                  : () async {
                      final saved = await _saveFarmer();
                      if (!dialogContext.mounted) {
                        return;
                      }
                      if (saved) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: Text(t(_language, 'agroAddFarmerButton')),
            ),
          ],
        );
      },
    );
  }

  Widget _dashboardTab() {
    return AgroDashboardTab(
      language: _language,
      dashboard: _dashboard,
    );
  }

  Widget _manageBillsTab() {
    return AgroManageBillsTab(
      language: _language,
      editingBillId: _editingBillId,
      selectedFarmerName: _selectedFarmerName(),
      farmers: _farmers,
      bills: _bills,
      dateCtrl: _dateCtrl,
      amountCtrl: _amountCtrl,
      noteCtrl: _noteCtrl,
      paymentStatus: _paymentStatus,
      savingBill: _savingBill,
      billPhotoName: _billPhotoName,
      billPhotoBytes: _billPhotoBytes,
      billPhotoPath: _billPhotoPath,
      onOpenFarmerPicker: _openFarmerPickerDialog,
      onPickDate: _pickDate,
      onPaymentStatusChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() => _paymentStatus = value);
      },
      onPickBillPhoto: _pickBillPhoto,
      onClearBillPhoto: () {
        setState(() {
          _billPhotoName = null;
          _billPhotoBytes = null;
          _billPhotoPath = null;
        });
      },
      onSaveBill: _saveBill,
      onResetBillForm: _resetBillForm,
      onStartEditBill: _startEditBill,
      onDeleteBill: _deleteBill,
      toDisplayDate: _toDisplayDate,
    );
  }

  Widget _farmersTab() {
    final query = _farmerSearchQuery.trim().toLowerCase();
    final filteredFarmers = query.isEmpty
        ? _farmers
        : _farmers.where((farmer) {
            final name = farmer['name']?.toString().toLowerCase() ?? '';
            final mobile = farmer['mobile']?.toString().toLowerCase() ?? '';
            return name.contains(query) || mobile.contains(query);
          }).toList();

    return AgroFarmersTab(
      language: _language,
      farmers: filteredFarmers,
      searchQuery: _farmerSearchQuery,
      onSearchChanged: (value) {
        setState(() => _farmerSearchQuery = value);
      },
      onAddFarmer: _openAddFarmerDialog,
      onEditFarmer: _openEditFarmerDialog,
      onDeleteFarmer: _deleteFarmer,
      onOpenFarmerBills: (farmer) {
        final farmerId = farmer['id'];
        if (farmerId is! int) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AgroFarmerBillsScreen(
              language: _language,
              farmerId: farmerId,
              farmerName: farmer['name']?.toString() ?? '-',
              farmerMobile: farmer['mobile']?.toString() ?? '-',
            ),
          ),
        );
      },
    );
  }

  Widget _reportTab() {
    return AgroReportTab(
      language: _language,
      report: _report,
      toDisplayDate: _toDisplayDate,
    );
  }

  Widget _currentTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_navIndex) {
      case 1:
        return _manageBillsTab();
      case 2:
        return _farmersTab();
      case 3:
        return _reportTab();
      default:
        return _dashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildKishanAppBar(
        context: context,
        language: _language,
        title: t(_language, 'agroCenterTitle'),
        titleIcon: Icons.storefront_rounded,
        showMenu: true,
        extraActions: [
          IconButton(
            onPressed: _reloadAll,
            icon: const Icon(Icons.refresh),
            tooltip: t(_language, 'agroRefresh'),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [Color(0xFF14532D), Color(0xFF166534)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            backgroundImage: _profileImageBytes != null
                                ? MemoryImage(_profileImageBytes!)
                                : (_profileImageUrl != null &&
                                          _profileImageUrl!.trim().isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          _profileImageUrl!,
                                          cacheManager: AppImageCache.manager,
                                        )
                                      : const AssetImage(_defaultProfileImagePath)
                                            as ImageProvider),
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
                            _profileEmail.isNotEmpty
                                ? _profileEmail
                                : t(_language, 'drawerHeader'),
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
                        Future.delayed(Duration.zero, _showUpdateProfileDialog);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.green),
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
                                    if (v == null) {
                                      return;
                                    }
                                    ref.read(apiServiceProvider)
                                        .updateLanguage(
                                          v == AppLanguage.english
                                              ? 'en'
                                              : 'gu',
                                        )
                                        .then(
                                          (_) => AppSession.saveUserProfile(
                                            preferredLanguage:
                                                v == AppLanguage.english
                                                ? 'en'
                                                : 'gu',
                                          ),
                                        )
                                        .catchError((_) {});
                                    setState(() => _language = v);
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.blue),
                      title: Text(t(_language, 'drawerAbout')),
                      onTap: () {
                        _openDrawerInfoPage(AboutAppScreen(language: _language));
                      },
                    ),
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
                    ListTile(
                      leading: const Icon(Icons.contact_mail, color: Colors.teal),
                      title: Text(t(_language, 'drawerContactUs')),
                      onTap: () {
                        _openDrawerInfoPage(ContactUsScreen(language: _language));
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
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(t(_language, 'drawerLogout')),
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, _logout);
                },
              ),
            ],
          ),
        ),
      ),
      body: _currentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (value) => setState(() => _navIndex = value),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: t(_language, 'agroDashboardTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: t(_language, 'agroManageBillsTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: t(_language, 'agroFarmersTab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.summarize),
            label: t(_language, 'agroReportsTab'),
          ),
        ],
      ),
    );
  }
}
