enum AppLanguage { english, gujarati }

const Map<AppLanguage, String> appLanguageNames = {
  AppLanguage.english: 'English',
  AppLanguage.gujarati: 'ગુજરાતી',
};

const Map<String, Map<AppLanguage, String>> translations = {
  'appTitle': {
    AppLanguage.english: 'Kishan Diary',
    AppLanguage.gujarati: 'કિસાન ડાયરી',
  },
  'addNewLand': {
    AppLanguage.english: 'Add New Land',
    AppLanguage.gujarati: 'નવી જમીન ઉમેરો',
  },
  'landName': {
    AppLanguage.english: 'Land Name',
    AppLanguage.gujarati: 'જમીનનું નામ',
  },
  'landSize': {
    AppLanguage.english: 'Land Size (acre)',
    AppLanguage.gujarati: 'જમીનનું કદ (એકર)',
  },
  'location': {AppLanguage.english: 'Location', AppLanguage.gujarati: 'સ્થળ'},
  'addLandButton': {
    AppLanguage.english: 'Add Land',
    AppLanguage.gujarati: 'જમીન ઉમેરો',
  },
  'selectLandHeading': {
    AppLanguage.english: 'Select Land',
    AppLanguage.gujarati: 'જમીન પસંદ કરો',
  },
  'selectLandLabel': {
    AppLanguage.english: 'Choose Land',
    AppLanguage.gujarati: 'જમીન પસંદ કરો',
  },
  'landDashboard': {
    AppLanguage.english: 'Land Dashboard',
    AppLanguage.gujarati: 'જમીન ડેશબોર્ડ',
  },
  'laborHoursLabel': {
    AppLanguage.english: 'Labor Rupees (₹)',
    AppLanguage.gujarati: 'મજૂરી રૂપિયા (₹)',
  },
  'fertilizerLabel': {
    AppLanguage.english: 'Fertilizer',
    AppLanguage.gujarati: 'દવા-બિયારણ (₹)',
  },
  'incomeLabel': {
    AppLanguage.english: 'Income (₹)',
    AppLanguage.gujarati: 'આવક (₹)',
  },
  'expensesLabel': {
    AppLanguage.english: 'Expenses (₹)',
    AppLanguage.gujarati: 'ખર્ચ (₹)',
  },
  'cropProductionLabel': {
    AppLanguage.english: 'Crop Production (kg)',
    AppLanguage.gujarati: 'ફસલ ઉત્પાદન (કિગ્રા)',
  },
  'saveMetricsButton': {
    AppLanguage.english: 'Save Metrics',
    AppLanguage.gujarati: 'મેટ્રિક્સ સાચવો',
  },
  'noLandSelected': {
    AppLanguage.english:
        'No land selected. Add a land and choose from dropdown.',
    AppLanguage.gujarati:
        'કોઈ જમીન પસંદ કરવામાં આવી નથી. કૃપા કરીને જમીન ઉમેરો અને ડ્રોપડાઉનમાંથી પસંદ કરો.',
  },
  'enterValidLand': {
    AppLanguage.english: 'Enter valid name, size (>0) and location',
    AppLanguage.gujarati: 'માન્ય નામ, કદ (>0) અને સ્થાન દાખલ કરો',
  },
  'selectLandFirst': {
    AppLanguage.english: 'Select a land first',
    AppLanguage.gujarati: 'સૌપ્રથમ જમીન પસંદ કરો',
  },
  'updateMetricsHeading': {
    AppLanguage.english: 'Update Land Metrics',
    AppLanguage.gujarati: 'જમીન મેટ્રિક્સ અપડેટ કરો',
  },
  'languageLabel': {
    AppLanguage.english: 'Language',
    AppLanguage.gujarati: 'ભાષા',
  },
  'drawerHeader': {
    AppLanguage.english: 'Kishan Diary Menu',
    AppLanguage.gujarati: 'કિસાન ડાયરી મેનુ',
  },
  'drawerLanguage': {
    AppLanguage.english: 'Change Language',
    AppLanguage.gujarati: 'ભાષા ફેરવો',
  },
  'drawerAbout': {
    AppLanguage.english: 'About App',
    AppLanguage.gujarati: 'એપ વિશે',
  },
  'drawerClear': {
    AppLanguage.english: 'Clear All Fields',
    AppLanguage.gujarati: 'બધા ક્ષેત્ર સાફ કરો',
  },
  'drawerAddLand': {
    AppLanguage.english: 'Add Land',
    AppLanguage.gujarati: 'જમીન ઉમેરો',
  },
  'navHome': {AppLanguage.english: 'Home', AppLanguage.gujarati: 'હોમ'},
  'navIncome': {AppLanguage.english: 'Income', AppLanguage.gujarati: 'આવક'},
  'navExpense': {AppLanguage.english: 'Expense', AppLanguage.gujarati: 'ખર્ચ'},
  'navCrop': {AppLanguage.english: 'Crop', AppLanguage.gujarati: 'ફસલ'},
  'navLabor': {AppLanguage.english: 'Labor', AppLanguage.gujarati: 'મજૂર'},
  'navAnimal': {AppLanguage.english: 'Animal', AppLanguage.gujarati: 'પશુ'},
  'animalIncomeLabel': {
    AppLanguage.english: 'Animal Income (₹)',
    AppLanguage.gujarati: 'પશુ આવક (₹)',
  },
  'laborName': {
    AppLanguage.english: 'Labor Name',
    AppLanguage.gujarati: 'મજૂરના નામ',
  },
  'laborMobile': {
    AppLanguage.english: 'Mobile',
    AppLanguage.gujarati: 'મોબાઇલ',
  },
  'laborDay': {
    AppLanguage.english: 'Labor Days',
    AppLanguage.gujarati: 'મજૂરીના દિવસો',
  },
  'laborDailyWage': {
    AppLanguage.english: 'Daily Wage (₹)',
    AppLanguage.gujarati: 'એક દિવસની મજૂરી (₹)',
  },
  'laborTotalWage': {
    AppLanguage.english: 'Total Wage (₹)',
    AppLanguage.gujarati: 'કુલ મજૂરી (₹)',
  },
  'laborPaid': {
    AppLanguage.english: 'Total Paid (₹)',
    AppLanguage.gujarati: 'કુલ ચૂકવણી (₹)',
  },
  'laborBalance': {
    AppLanguage.english: 'Total Pending (₹)',
    AppLanguage.gujarati: 'બાકી ચૂકવણી (₹)',
  },
  'upadSectionTitle': {
    AppLanguage.english: 'Upad Records for',
    AppLanguage.gujarati: 'ઉપાડ વિગતો',
  },
  'upadFormButton': {
    AppLanguage.english: 'Upad Form',
    AppLanguage.gujarati: 'ઉપાડ ફોર્મ',
  },
  'upadAmount': {
    AppLanguage.english: 'Upad Amount (₹)',
    AppLanguage.gujarati: 'ઉપાડ રકમ (₹)',
  },
  'upadNote': {
    AppLanguage.english: 'Detail (Note)',
    AppLanguage.gujarati: 'વિવરણ',
  },
  'upadDate': {
    AppLanguage.english: 'Upad Date',
    AppLanguage.gujarati: 'ઉપાડ તારીખ',
  },
  'upadAddButton': {
    AppLanguage.english: 'Add Upad',
    AppLanguage.gujarati: 'ઉપાડ ઉમેરો',
  },
  'upadUpdateButton': {
    AppLanguage.english: 'Update Upad',
    AppLanguage.gujarati: 'ઉપાડ અપડેટ કરો',
  },
  'upadNoRecords': {
    AppLanguage.english: 'No Upad records',
    AppLanguage.gujarati: 'કોઈ ઉપાડ નોંધાયેલ નથી',
  },
  'enterValidUpad': {
    AppLanguage.english: 'Enter valid upad amount, date and labor',
    AppLanguage.gujarati: 'માન્ય ઉપાડ રકમ, તારીખ અને મજૂર દાખલ કરો',
  },
  'actions': {AppLanguage.english: 'Actions', AppLanguage.gujarati: 'ક્રિયાઓ'},
  'noDateSelected': {
    AppLanguage.english: 'No Date',
    AppLanguage.gujarati: 'કોઈ તારીખ નથી',
  },
  'laborAddButton': {
    AppLanguage.english: 'Add Labor',
    AppLanguage.gujarati: 'મજૂર ઉમેરો',
  },
  'laborUpdateButton': {
    AppLanguage.english: 'Update Labor',
    AppLanguage.gujarati: 'મજૂર અપડેટ કરો',
  },
  'cancelButton': {
    AppLanguage.english: 'Cancel',
    AppLanguage.gujarati: 'રદ કરો',
  },
  'deleteButton': {
    AppLanguage.english: 'Delete',
    AppLanguage.gujarati: 'કાઢી નાખો',
  },
  'deleteLaborTitle': {
    AppLanguage.english: 'Delete Labor',
    AppLanguage.gujarati: 'મજૂર કાઢી નાખો',
  },
  'deleteLaborConfirm': {
    AppLanguage.english:
        'Are you sure you want to delete this labor and all upad records?',
    AppLanguage.gujarati:
        'શું તમે આ મજૂર અને તેની તમામ ઉપાડ નોંધો કાઢી નાખવા માંગો છો?',
  },
  'laborTotalPaid': {
    AppLanguage.english: 'Total Paid:',
    AppLanguage.gujarati: 'કુલ ચુકવેલ:',
  },
  'laborTotalPending': {
    AppLanguage.english: 'Total Pending:',
    AppLanguage.gujarati: 'કુલ બાકી:',
  },
  'laborFormButton': {
    AppLanguage.english: 'Add Labor',
    AppLanguage.gujarati: 'મજૂર ઉમેરો',
  },
  'enterValidLabor': {
    AppLanguage.english: 'Enter valid labor details',
    AppLanguage.gujarati: 'માન્ય મજૂર વિગતો દાખલ કરો',
  },
  'editLand': {
    AppLanguage.english: 'Edit Land Details',
    AppLanguage.gujarati: 'જમીનની વિગત સુધારો',
  },
};

String t(AppLanguage language, String key) {
  return translations[key]?[language] ?? key;
}
