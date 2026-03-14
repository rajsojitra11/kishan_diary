import 'package:flutter/material.dart';

import '../models/land.dart';
import '../screens/animal_screen.dart';
import '../screens/crop_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/home_tab.dart';
import '../screens/income_screen.dart';
import '../screens/labour_screen.dart';
import '../utils/localization.dart';
import '../widgets/app_widgets.dart';
import '../widgets/text_input_config.dart';

/// Root scaffold of the app.
///
/// Holds cross-cutting state:
/// - [_language]          — current app language
/// - [_lands]             — list of all lands
/// - [_selectedLand]      — currently active land
/// - [_animalIncomeGlobal] — animal income (not tied to a specific land)
///
/// Each tab is a separate widget defined in its own screen file.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLanguage _language = AppLanguage.gujarati;
  final List<Land> _lands = [];
  Land? _selectedLand;
  int _navIndex = 0;
  double _animalIncomeGlobal = 0;

  // ── Land Operations ────────────────────────────────────────────────────────

  void _addLandFromValues(String name, double size, String location) {
    final land = Land(name: name, size: size, location: location);
    setState(() {
      _lands.add(land);
      _selectedLand = land;
      _navIndex = 0;
    });
  }

  void _selectLand(Land land) {
    setState(() {
      _selectedLand = land;
      _navIndex = 0;
    });
  }

  void _clearAll() {
    setState(() {
      _lands.clear();
      _selectedLand = null;
      _animalIncomeGlobal = 0;
      _navIndex = 0;
    });
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddLandDialog() {
    final nameCtrl = TextEditingController();
    final sizeCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t(_language, 'addNewLand')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInput(TextInputConfig(
                  nameCtrl, t(_language, 'landName'), Icons.landscape)),
              const SizedBox(height: 8),
              buildInput(TextInputConfig(
                  sizeCtrl, t(_language, 'landSize'), Icons.straighten,
                  number: true)),
              const SizedBox(height: 8),
              buildInput(TextInputConfig(
                  locCtrl, t(_language, 'location'), Icons.location_on)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final size = double.tryParse(sizeCtrl.text.trim()) ?? 0;
              final location = locCtrl.text.trim();
              if (name.isEmpty || size <= 0 || location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t(_language, 'enterValidLand'))),
                );
                return;
              }
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t(_language, 'editLand')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildInput(TextInputConfig(
                  nameCtrl, t(_language, 'landName'), Icons.landscape)),
              const SizedBox(height: 8),
              buildInput(TextInputConfig(
                  sizeCtrl, t(_language, 'landSize'), Icons.straighten,
                  number: true)),
              const SizedBox(height: 8),
              buildInput(TextInputConfig(
                  locCtrl, t(_language, 'location'), Icons.location_on)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(t(_language, 'saveMetricsButton')),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final size = double.tryParse(sizeCtrl.text.trim()) ?? 0;
              final location = locCtrl.text.trim();
              if (name.isEmpty || size <= 0 || location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t(_language, 'enterValidLand'))),
                );
                return;
              }
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
      onTap: (i) => setState(() => _navIndex = i),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.home), label: t(_language, 'navHome')),
        BottomNavigationBarItem(
            icon: const Icon(Icons.currency_rupee),
            label: t(_language, 'navIncome')),
        BottomNavigationBarItem(
            icon: const Icon(Icons.money_off),
            label: t(_language, 'navExpense')),
        BottomNavigationBarItem(
            icon: const Icon(Icons.agriculture),
            label: t(_language, 'navCrop')),
        BottomNavigationBarItem(
            icon: const Icon(Icons.group), label: t(_language, 'navLabor')),
        BottomNavigationBarItem(
            icon: const Icon(Icons.pets), label: t(_language, 'navAnimal')),
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
        return LabourScreen(
          selectedLand: _selectedLand,
          language: _language,
        );
      case 5:
        return AnimalScreen(
          language: _language,
          animalIncome: _animalIncomeGlobal,
          onSaved: (v) => setState(() => _animalIncomeGlobal = v),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(t(_language, 'appTitle')),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
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
                        tooltip: 'Edit Land',
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
                    content: const Text(
                        'Kishan Diary — land tracking & expense management app.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
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
    );
  }
}
