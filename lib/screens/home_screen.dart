import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/animal.dart';
import '../models/land.dart';
import '../screens/animal_screen.dart';
import '../screens/crop_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/home_tab.dart';
import '../screens/income_screen.dart';
import '../screens/labour_screen.dart';
import '../screens/login_screen.dart';
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
/// - [_animals]           — animal-wise milk and amount records
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

class _HomeScreenState extends State<HomeScreen> {
  AppLanguage _language = AppLanguage.gujarati;
  static const String _defaultProfileImagePath =
      'lib/assets/images/register.png';
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Land> _lands = [];
  final List<Animal> _animals = [];
  Land? _selectedLand;
  int _navIndex = 0;
  final List<int> _tabHistory = [0];
  late String _profileName;
  late String _profileEmail;
  late String _profileBirthdate;
  late String _profilePassword;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    final initialName = widget.initialUserName?.trim() ?? '';
    _profileName = initialName.isNotEmpty
        ? initialName
        : t(_language, 'loggedUserDefaultName');
    _profileEmail = widget.initialUserEmail?.trim() ?? '';
    _profileBirthdate = widget.initialUserBirthdate?.trim() ?? '';
    _profilePassword = widget.initialUserPassword ?? '';
  }

  ImageProvider get _profileImageProvider {
    if (_profileImageBytes != null) {
      return MemoryImage(_profileImageBytes!);
    }
    return const AssetImage(_defaultProfileImagePath);
  }

  double get _animalIncomeGlobal {
    return _animals.fold(0.0, (sum, animal) => sum + animal.totalAmount);
  }

  // ── Land Operations ────────────────────────────────────────────────────────

  void _addLandFromValues(String name, double size, String location) {
    final land = Land(name: name, size: size, location: location);
    setState(() {
      _lands.add(land);
      _selectedLand = land;
      _navIndex = 0;
      _tabHistory
        ..remove(0)
        ..add(0);
    });
  }

  void _selectLand(Land land) {
    setState(() {
      _selectedLand = land;
      _navIndex = 0;
      _tabHistory
        ..remove(0)
        ..add(0);
    });
  }

  void _clearAll() {
    setState(() {
      _lands.clear();
      _animals.clear();
      _selectedLand = null;
      _navIndex = 0;
      _tabHistory
        ..clear()
        ..add(0);
    });
  }

  Future<void> _confirmClearAll() async {
    final shouldClear =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t(_language, 'deleteAllDataTitle')),
            content: Text(t(_language, 'deleteAllDataConfirm')),
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

    _clearAll();
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

  Future<Uint8List?> _pickProfileImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 900,
    );

    if (pickedFile == null) {
      return null;
    }

    return pickedFile.readAsBytes();
  }

  Future<Uint8List?> _showProfileImagePickerOptions() async {
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

    return _pickProfileImage(source);
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
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final name = nameCtrl.text.trim();
              final size = double.parse(sizeCtrl.text.trim());
              final location = locCtrl.text.trim();

              setState(() {
                land.name = name;
                land.size = size;
                land.location = location;
              });
              Navigator.pop(context);
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
    passwordCtrl.text = _profilePassword;
    Uint8List? tempProfileImageBytes = _profileImageBytes;

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
                        : const AssetImage(_defaultProfileImagePath)
                              as ImageProvider,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final pickedBytes =
                          await _showProfileImagePickerOptions();
                      if (pickedBytes == null) {
                        return;
                      }
                      dialogSetState(() {
                        tempProfileImageBytes = pickedBytes;
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
                    validator: _requiredValidator,
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
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                setState(() {
                  _profileName = nameCtrl.text.trim();
                  _profileEmail = emailCtrl.text.trim();
                  _profileBirthdate = birthdateCtrl.text.trim();
                  _profilePassword = passwordCtrl.text;
                  _profileImageBytes = tempProfileImageBytes;
                });

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t(_language, 'profileUpdatedMessage')),
                  ),
                );
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
      animals: _animals,
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

  // ── Nav Bar ────────────────────────────────────────────────────────────────

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
          icon: const Icon(Icons.home),
          label: t(_language, 'navHome'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.currency_rupee),
          label: t(_language, 'navIncome'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long),
          label: t(_language, 'navExpense'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.eco),
          label: t(_language, 'navCrop'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.group),
          label: t(_language, 'navLabor'),
        ),
        BottomNavigationBarItem(
          icon: const FaIcon(FontAwesomeIcons.cow),
          label: t(_language, 'navAnimal'),
        ),
      ],
    );
  }

  // ── Current Tab ────────────────────────────────────────────────────────────

  Widget _currentTab() {
    switch (_navIndex) {
      case 1:
        return IncomeScreen(
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      case 2:
        return ExpenseScreen(
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      case 3:
        return CropScreen(
          selectedLand: _selectedLand,
          language: _language,
          onSaved: () => setState(() {}),
        );
      case 4:
        return LabourScreen(selectedLand: _selectedLand, language: _language);
      case 5:
        return AnimalScreen(
          language: _language,
          animals: _animals,
          onAnimalsChanged: (updatedAnimals) {
            setState(() {
              _animals
                ..clear()
                ..addAll(updatedAnimals);
            });
          },
        );
      default:
        return HomeTab(
          lands: _lands,
          selectedLand: _selectedLand,
          language: _language,
          animalIncomeGlobal: _animalIncomeGlobal,
          onAddLand: _addLandFromValues,
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
                                trailing: IconButton(
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
                                onTap: () {
                                  _selectLand(land);
                                  Navigator.pop(context);
                                },
                              );
                            }),
                        ],
                      ),

                      // Clear all
                      ListTile(
                        leading: const Icon(Icons.clear_all, color: Colors.red),
                        title: Text(t(_language, 'drawerClear')),
                        onTap: () {
                          Navigator.pop(context);
                          _confirmClearAll();
                        },
                      ),

                      // About
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        title: Text(t(_language, 'drawerAbout')),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(t(_language, 'drawerAbout')),
                              content: Text(
                                t(_language, 'aboutAppDescription'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(t(_language, 'okButton')),
                                ),
                              ],
                            ),
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
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                t(_language, 'drawerTermsConditions'),
                              ),
                              content: Text(
                                t(_language, 'termsConditionsDescription'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(t(_language, 'okButton')),
                                ),
                              ],
                            ),
                          );
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
