import 'package:flutter/material.dart';

import '../models/land.dart';
import '../utils/localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLanguage _language = AppLanguage.gujarati;
  final List<Land> lands = [];
  Land? selectedLand;
  int _selectedNavIndex = 0;
  double _animalIncomeGlobal = 0;
  double _incomeGlobal = 0;
  double _expensesGlobal = 0;
  double _cropGlobal = 0;
  double _laborHoursGlobal = 0;
  bool _showLaborForm = false;
  int? _editingLaborIndex;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _laborController = TextEditingController();
  final TextEditingController _fertilizerController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _productionController = TextEditingController();
  final TextEditingController _animalController = TextEditingController();

  final TextEditingController _laborNameController = TextEditingController();
  final TextEditingController _laborMobileController = TextEditingController();
  final TextEditingController _laborDayController = TextEditingController();
  final TextEditingController _laborPaidController = TextEditingController();
  final TextEditingController _laborBalanceController = TextEditingController();

  final List<LaborEntry> _laborEntries = [];
  List<UpadEntry> _upadEntries = [];
  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _locationController.dispose();
    _laborController.dispose();
    _fertilizerController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    _productionController.dispose();
    _animalController.dispose();
    _laborNameController.dispose();
    _laborMobileController.dispose();
    _laborDayController.dispose();
    _laborPaidController.dispose();
    _laborBalanceController.dispose();
    super.dispose();
  }

  void _addLand() {
    final name = _nameController.text.trim();
    final size = double.tryParse(_sizeController.text.trim()) ?? 0;
    final location = _locationController.text.trim();

    if (name.isEmpty || size <= 0 || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t(_language, 'enterValidLand'))));
      return;
    }

    _addLandFromValues(name, size, location);

    _nameController.clear();
    _sizeController.clear();
    _locationController.clear();
  }

  void _addLandFromValues(String name, double size, String location) {
    final land = Land(name: name, size: size, location: location);

    setState(() {
      lands.add(land);
      selectedLand = land;
      _fillMetricFields(land);
      _selectedNavIndex = 0;
    });
  }

  void _showAddLandDialog() {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t(_language, 'addNewLand')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInput(
                  TextInputConfig(
                    nameController,
                    t(_language, 'landName'),
                    Icons.landscape,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInput(
                  TextInputConfig(
                    sizeController,
                    t(_language, 'landSize'),
                    Icons.straighten,
                    number: true,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInput(
                  TextInputConfig(
                    locationController,
                    t(_language, 'location'),
                    Icons.location_on,
                  ),
                ),
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
                final name = nameController.text.trim();
                final size = double.tryParse(sizeController.text.trim()) ?? 0;
                final location = locationController.text.trim();

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
        );
      },
    );
  }

  void _selectLand(Land? land) {
    setState(() {
      selectedLand = land;
      if (land != null) {
        _fillMetricFields(land);
      }
    });
  }

  void _fillMetricFields(Land land) {
    _laborController.text = land.laborHours.toString();
    _fertilizerController.text = land.fertilizerKg.toString();
    _incomeController.text = land.income.toString();
    _expensesController.text = land.expenses.toString();
    _productionController.text = land.cropProductionKg.toString();
    _animalController.text = _animalIncomeGlobal.toString();
  }

  void _saveMetrics() {
    final labor = int.tryParse(_laborController.text.trim()) ?? 0;
    final fertilizer = double.tryParse(_fertilizerController.text.trim()) ?? 0;
    final income = double.tryParse(_incomeController.text.trim()) ?? 0;
    final expenses = double.tryParse(_expensesController.text.trim()) ?? 0;
    final production = double.tryParse(_productionController.text.trim()) ?? 0;
    final animalIncome = double.tryParse(_animalController.text.trim()) ?? 0;

    setState(() {
      if (_selectedNavIndex == 1) {
        _incomeGlobal = income;
      } else if (_selectedNavIndex == 2) {
        _expensesGlobal = expenses;
      } else if (_selectedNavIndex == 3) {
        _cropGlobal = production;
      } else if (_selectedNavIndex == 4) {
        _laborHoursGlobal = labor.toDouble();
      } else if (_selectedNavIndex == 5) {
        _animalIncomeGlobal = animalIncome;
      } else {
        if (selectedLand == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(_language, 'selectLandFirst'))),
          );
          return;
        }
        selectedLand!.laborHours = labor;
        selectedLand!.fertilizerKg = fertilizer;
        selectedLand!.income = income;
        selectedLand!.expenses = expenses;
        selectedLand!.cropProductionKg = production;
      }
    });
  }

  void _clearFields() {
    setState(() {
      _nameController.clear();
      _sizeController.clear();
      _locationController.clear();
      _laborController.clear();
      _fertilizerController.clear();
      _incomeController.clear();
      _expensesController.clear();
      _productionController.clear();
      _animalController.clear();
      _laborNameController.clear();
      _laborMobileController.clear();
      _laborDayController.clear();
      _laborPaidController.clear();
      _laborBalanceController.clear();
      selectedLand = null;
      _laborEntries.clear();
      _upadEntries.clear();
    });
  }

  void _selectLanguage(AppLanguage language) {
    setState(() {
      _language = language;
    });
  }

  void _addLaborEntry() {
    final name = _laborNameController.text.trim();
    final mobile = _laborMobileController.text.trim();
    final day = int.tryParse(_laborDayController.text.trim()) ?? 0;
    final paid = double.tryParse(_laborPaidController.text.trim()) ?? 0;
    final pending = double.tryParse(_laborBalanceController.text.trim()) ?? 0;

    if (name.isEmpty || mobile.isEmpty || day <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t(_language, 'enterValidLabor'))));
      return;
    }

    setState(() {
      if (_editingLaborIndex != null) {
        _laborEntries[_editingLaborIndex!] = LaborEntry(
          name: name,
          mobile: mobile,
          days: day,
          paid: paid,
          pending: pending,
        );
      } else {
        _laborEntries.add(
          LaborEntry(
            name: name,
            mobile: mobile,
            days: day,
            paid: paid,
            pending: pending,
          ),
        );
      }

      _laborNameController.clear();
      _laborMobileController.clear();
      _laborDayController.clear();
      _laborPaidController.clear();
      _laborBalanceController.clear();
      _showLaborForm = false;
      _editingLaborIndex = null;
    });
  }

  double get _laborTotalPaid => _laborEntries.fold(0, (a, e) => a + e.paid);
  double get _laborTotalPending =>
      _laborEntries.fold(0, (a, e) => a + e.pending);

  void _openUpadPage(String laborName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpadScreen(
          laborName: laborName,
          upadEntries: _upadEntries,
          onEntriesChanged: (updatedEntries) {
            setState(() {
              _upadEntries = updatedEntries;
            });
          },
          language: _language,
        ),
      ),
    );
  }

  void _removeLaborEntry(int index) {
    setState(() {
      _laborEntries.removeAt(index);
    });
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      color: color.withAlpha(38),
      child: ListTile(
        leading: Icon(iconForStat(title), color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  IconData iconForStat(String title) {
    if (title.contains('Labor') || title.contains('મજુર')) return Icons.group;
    if (title.contains('Fertilizer') || title.contains('દવા-બિયારણ')) {
      return Icons.grass;
    }
    if (title.contains('Income') || title.contains('આવક')) {
      return Icons.currency_rupee;
    }
    if (title.contains('Expenses') || title.contains('ખર્ચ')) {
      return Icons.money_off;
    }
    if (title.contains('Crop') || title.contains('ફસલ')) {
      return Icons.agriculture;
    }
    if (title.contains('Animal') || title.contains('પશુ')) {
      return Icons.agriculture;
    }
    return Icons.info;
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) => setState(() => _selectedNavIndex = index),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey[700],
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
          icon: const Icon(Icons.money_off),
          label: t(_language, 'navExpense'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.agriculture),
          label: t(_language, 'navCrop'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.group),
          label: t(_language, 'navLabor'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.pets),
          label: t(_language, 'navAnimal'),
        ),
      ],
    );
  }

  Widget _buildPageContent() {
    switch (_selectedNavIndex) {
      case 1:
        return _buildMetricPage(
          'navIncome',
          _incomeController,
          'incomeLabel',
          Colors.teal,
          requireLand: true,
        );
      case 2:
        return _buildMetricPage(
          'navExpense',
          _expensesController,
          'expensesLabel',
          Colors.red,
          requireLand: true,
        );
      case 3:
        return _buildMetricPage(
          'navCrop',
          _productionController,
          'cropProductionLabel',
          Colors.orange,
          requireLand: true,
        );
      case 4:
        return _buildLaborPage();
      case 5:
        return _buildMetricPage(
          'navAnimal',
          _animalController,
          'animalIncomeLabel',
          Colors.purple,
          requireLand: false,
        );
      default:
        return _buildHomePage();
    }
  }

  Widget _buildMetricPage(
    String titleKey,
    TextEditingController controller,
    String metricKey,
    Color color, {
    bool requireLand = true,
  }) {
    if (requireLand && selectedLand == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text(t(_language, 'noLandSelected'))),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(_language, titleKey),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _statCard(
              t(_language, metricKey),
              _getSelectedStat(metricKey),
              color,
            ),
            const SizedBox(height: 10),
            _buildInput(
              TextInputConfig(
                controller,
                t(_language, metricKey),
                Icons.edit,
                number: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(t(_language, 'saveMetricsButton')),
                onPressed: _saveMetrics,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaborPage() {
    if (selectedLand == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(t(_language, 'selectLandFirst'))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showLaborForm)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_search),
                label: Text(t(_language, 'laborFormButton')),
                onPressed: () => setState(() => _showLaborForm = true),
              ),
            ),
          ),
        if (_showLaborForm)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(_language, 'navLabor'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _laborNameController,
                      t(_language, 'laborName'),
                      Icons.person,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _laborMobileController,
                      t(_language, 'laborMobile'),
                      Icons.phone,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _laborDayController,
                      t(_language, 'laborDay'),
                      Icons.calendar_today,
                      number: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _laborPaidController,
                      t(_language, 'laborPaid'),
                      Icons.money,
                      number: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _laborBalanceController,
                      t(_language, 'laborBalance'),
                      Icons.account_balance_wallet,
                      number: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        _editingLaborIndex != null ? Icons.update : Icons.add,
                      ),
                      label: Text(
                        _editingLaborIndex != null
                            ? t(_language, 'laborUpdateButton')
                            : t(_language, 'laborAddButton'),
                      ),
                      onPressed: _addLaborEntry,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${t(_language, 'laborTotalPaid')} ${_laborTotalPaid.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${t(_language, 'laborTotalPending')} ${_laborTotalPending.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        ..._laborEntries.asMap().entries.map((entry) {
          final idx = entry.key;
          final labor = entry.value;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                '${labor.name} (${labor.days} ${t(_language, 'laborDay')})',
              ),
              subtitle: Text(
                '${t(_language, 'laborPaid')}: ₹ ${labor.paid.toStringAsFixed(2)} | ${t(_language, 'laborBalance')}: ₹ ${labor.pending.toStringAsFixed(2)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.account_balance,
                      color: Colors.orange,
                    ),
                    tooltip: 'Upad',
                    onPressed: () {
                      _openUpadPage(labor.name);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _laborNameController.text = labor.name;
                        _laborMobileController.text = labor.mobile;
                        _laborDayController.text = labor.days.toString();
                        _laborPaidController.text = labor.paid.toString();
                        _laborBalanceController.text = labor.pending.toString();
                        _showLaborForm = true;
                        _editingLaborIndex = idx;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeLaborEntry(idx),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getSelectedStat(String metricKey) {
    switch (metricKey) {
      case 'incomeLabel':
        return selectedLand == null
            ? '₹ ${_incomeGlobal.toStringAsFixed(2)}'
            : '₹ ${selectedLand!.income.toStringAsFixed(2)}';
      case 'expensesLabel':
        return selectedLand == null
            ? '₹ ${_expensesGlobal.toStringAsFixed(2)}'
            : '₹ ${selectedLand!.expenses.toStringAsFixed(2)}';
      case 'cropProductionLabel':
        return selectedLand == null
            ? '${_cropGlobal.toStringAsFixed(2)} kg'
            : '${selectedLand!.cropProductionKg.toStringAsFixed(2)} kg';
      case 'laborHoursLabel':
        return selectedLand == null
            ? '${_laborHoursGlobal.toStringAsFixed(0)} hrs'
            : '${selectedLand!.laborHours} hrs';
      case 'animalIncomeLabel':
        return '₹ ${_animalIncomeGlobal.toStringAsFixed(2)}';
      case 'laborTotalPaidLabel':
        return '₹ ${_laborTotalPaid.toStringAsFixed(2)}';
      case 'laborTotalPendingLabel':
        return '₹ ${_laborTotalPending.toStringAsFixed(2)}';
      default:
        return '0';
    }
  }

  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lands.isEmpty) ...[
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(_language, 'addNewLand'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _nameController,
                      t(_language, 'landName'),
                      Icons.landscape,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _sizeController,
                      t(_language, 'landSize'),
                      Icons.straighten,
                      number: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInput(
                    TextInputConfig(
                      _locationController,
                      t(_language, 'location'),
                      Icons.location_on,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(t(_language, 'addLandButton')),
                      onPressed: _addLand,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (selectedLand == null)
          Center(child: Text(t(_language, 'noLandSelected')))
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(_language, 'landDashboard'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
                children: [
                  _statCard(
                    '${t(_language, 'incomeLabel')}:',
                    '₹ ${selectedLand!.income.toStringAsFixed(2)}',
                    Colors.teal,
                  ),
                  _statCard(
                    '${t(_language, 'expensesLabel')}:',
                    '₹ ${selectedLand!.expenses.toStringAsFixed(2)}',
                    Colors.red,
                  ),
                  _statCard(
                    '${t(_language, 'cropProductionLabel')}:',
                    '${selectedLand!.cropProductionKg.toStringAsFixed(2)} kg',
                    Colors.orange,
                  ),
                  _statCard(
                    '${t(_language, 'fertilizerLabel')}:',
                    '₹ ${selectedLand!.fertilizerKg.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  _statCard(
                    '${t(_language, 'laborHoursLabel')}:',
                    '₹ ${selectedLand!.laborHours.toStringAsFixed(0)}',
                    Colors.blue,
                  ),
                  _statCard(
                    '${t(_language, 'animalIncomeLabel')}:',
                    '₹ ${_animalIncomeGlobal.toStringAsFixed(2)}',
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(_language, 'appTitle')),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      drawer: Drawer(
        child: Column(
          children: [
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
                child: Icon(Icons.agriculture, color: Colors.green),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: Text(t(_language, 'drawerLanguage')),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: AppLanguage.values.map((lang) {
                          return RadioListTile<AppLanguage>(
                            title: Text(appLanguageNames[lang]!),
                            value: lang,
                            groupValue: _language,
                            onChanged: (value) {
                              if (value != null) {
                                _selectLanguage(value);
                                Navigator.pop(context);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
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
                if (lands.isEmpty) ...[
                  ListTile(
                    title: Text(t(_language, 'noLandSelected')),
                    dense: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ] else
                  ...lands.map((land) {
                    return ListTile(
                      title: Text('${land.name} (${land.location})'),
                      onTap: () {
                        _selectLand(land);
                        Navigator.pop(context);
                      },
                    );
                  }),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.red),
              title: Text(t(_language, 'drawerClear')),
              onTap: () {
                _clearFields();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: Text(t(_language, 'drawerAbout')),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(t(_language, 'drawerAbout')),
                      content: Text(
                        'Kishan Diary app for land tracking and expenses.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildPageContent()],
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildInput(TextInputConfig config) {
    return TextField(
      controller: config.controller,
      keyboardType: config.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: config.label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(config.icon),
      ),
    );
  }
}

class LaborEntry {
  final String name;
  final String mobile;
  final int days;
  final double paid;
  final double pending;

  LaborEntry({
    required this.name,
    required this.mobile,
    required this.days,
    required this.paid,
    required this.pending,
  });
}

class UpadEntry {
  final String laborName;
  final double amount;
  final String note;
  final String date;

  UpadEntry({
    required this.laborName,
    required this.amount,
    required this.note,
    required this.date,
  });
}

class UpadScreen extends StatefulWidget {
  final String laborName;
  final List<UpadEntry> upadEntries;
  final ValueChanged<List<UpadEntry>> onEntriesChanged;
  final AppLanguage language;

  const UpadScreen({
    super.key,
    required this.laborName,
    required this.upadEntries,
    required this.onEntriesChanged,
    required this.language,
  });

  @override
  State<UpadScreen> createState() => _UpadScreenState();
}

class _UpadScreenState extends State<UpadScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _saveUpad() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final note = _noteController.text.trim();
    final date = _dateController.text.trim();

    if (amount <= 0 || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(widget.language, 'enterValidUpad'))),
      );
      return;
    }

    final newEntry = UpadEntry(
      laborName: widget.laborName,
      amount: amount,
      note: note,
      date: date,
    );

    final updatedList = List<UpadEntry>.from(widget.upadEntries);
    if (_editingIndex != null) {
      updatedList[_editingIndex!] = newEntry;
    } else {
      updatedList.add(newEntry);
    }

    widget.onEntriesChanged(updatedList);

    setState(() {
      _amountController.clear();
      _noteController.clear();
      _dateController.clear();
      _editingIndex = null;
    });
  }

  Widget _buildInput(TextInputConfig config) {
    return TextField(
      controller: config.controller,
      keyboardType: config.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: config.label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(config.icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laborUpad = widget.upadEntries
        .where((entry) => entry.laborName == widget.laborName)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${t(widget.language, 'upadSectionTitle')} ${widget.laborName}',
        ),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput(
              TextInputConfig(
                _amountController,
                t(widget.language, 'upadAmount'),
                Icons.account_balance,
                number: true,
              ),
            ),
            const SizedBox(height: 10),
            _buildInput(
              TextInputConfig(
                _noteController,
                t(widget.language, 'upadNote'),
                Icons.notes,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: t(widget.language, 'upadDate'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(_dateController),
                ),
              ),
              onTap: () => _selectDate(_dateController),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_editingIndex != null ? Icons.update : Icons.add),
                label: Text(
                  _editingIndex != null
                      ? t(widget.language, 'upadUpdateButton')
                      : t(widget.language, 'upadAddButton'),
                ),
                onPressed: _saveUpad,
              ),
            ),
            const SizedBox(height: 20),
            Text(t(widget.language, 'upadNoRecords')),
            const SizedBox(height: 10),
            if (laborUpad.isEmpty)
              Text(t(widget.language, 'upadNoRecords'))
            else
              DataTable(
                columns: [
                  DataColumn(label: Text(t(widget.language, 'upadAmount'))),
                  DataColumn(label: Text(t(widget.language, 'upadNote'))),
                  DataColumn(label: Text(t(widget.language, 'upadDate'))),
                  DataColumn(label: Text(t(widget.language, 'actions'))),
                ],
                rows: laborUpad.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text('₹ ${record.amount.toStringAsFixed(2)}')),
                      DataCell(Text(record.note)),
                      DataCell(Text(record.date)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final globalIndex = widget.upadEntries.indexOf(
                                  record,
                                );
                                setState(() {
                                  _editingIndex = globalIndex;
                                  _amountController.text = record.amount
                                      .toString();
                                  _noteController.text = record.note;
                                  _dateController.text = record.date;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final updatedList = List<UpadEntry>.from(
                                  widget.upadEntries,
                                )..removeAt(widget.upadEntries.indexOf(record));
                                widget.onEntriesChanged(updatedList);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class TextInputConfig {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool number;
  final bool isInt;

  TextInputConfig(
    this.controller,
    this.label,
    this.icon, {
    this.number = false,
    this.isInt = false,
  });
}
