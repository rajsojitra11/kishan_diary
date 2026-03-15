import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/animal.dart';
import '../models/land.dart';
import '../screens/animal_screen.dart';
import '../screens/crop_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/home_tab.dart';
import '../screens/income_screen.dart';
import '../screens/labour_screen.dart';
import '../utils/localization.dart';
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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLanguage _language = AppLanguage.gujarati;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Land> _lands = [];
  final List<Animal> _animals = [];
  Land? _selectedLand;
  int _navIndex = 0;
  final List<int> _tabHistory = [0];

  double get _animalIncomeGlobal {
    return _animals.fold(0, (sum, animal) => sum + animal.totalAmount);
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
          child: Column(
            children: [
              // Header
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(t(_language, 'drawerHeader')),
                accountEmail: const Text('v1.0'),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.agriculture, color: Colors.green, size: 32),
                ),
              ),

              // Language picker
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
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                        title: Text('${land.name} (${land.location})'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
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
                  _clearAll();
                  Navigator.pop(context);
                },
              ),

              // About
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: Text(t(_language, 'drawerAbout')),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(t(_language, 'drawerAbout')),
                      content: Text(t(_language, 'aboutAppDescription')),
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
            child: _currentTab(),
          ),
        ),

        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }
}
