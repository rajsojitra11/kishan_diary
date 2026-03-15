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
    AppLanguage.english: 'Labor Cost',
    AppLanguage.gujarati: 'મજૂરી ખર્ચ',
  },
  'fertilizerLabel': {
    AppLanguage.english: 'Fertilizer & Seeds',
    AppLanguage.gujarati: 'દવા-બિયારણ',
  },
  'incomeLabel': {AppLanguage.english: 'Income', AppLanguage.gujarati: 'આવક'},
  'incomeAddButton': {
    AppLanguage.english: 'Add Income',
    AppLanguage.gujarati: 'આવક ઉમેરો',
  },
  'incomeUpdateButton': {
    AppLanguage.english: 'Update Income',
    AppLanguage.gujarati: 'આવક અપડેટ કરો',
  },
  'incomeTypeLabel': {
    AppLanguage.english: 'Income Type',
    AppLanguage.gujarati: 'આવક પ્રકાર',
  },
  'incomeAmountLabel': {
    AppLanguage.english: 'Amount',
    AppLanguage.gujarati: 'રકમ',
  },
  'incomeDateLabel': {
    AppLanguage.english: 'Date',
    AppLanguage.gujarati: 'તારીખ',
  },
  'incomeNoteLabel': {
    AppLanguage.english: 'Note (Optional)',
    AppLanguage.gujarati: 'નોંધ (વૈકલ્પિક)',
  },
  'incomeNoteListLabel': {
    AppLanguage.english: 'Note',
    AppLanguage.gujarati: 'નોંધ',
  },
  'incomeBillPhotoLabel': {
    AppLanguage.english: 'Bill Photo (Optional)',
    AppLanguage.gujarati: 'બિલ ફોટો (વૈકલ્પિક)',
  },
  'incomePickPhotoButton': {
    AppLanguage.english: 'Pick Photo',
    AppLanguage.gujarati: 'ફોટો પસંદ કરો',
  },
  'incomeChangePhotoButton': {
    AppLanguage.english: 'Change Photo',
    AppLanguage.gujarati: 'ફોટો બદલો',
  },
  'incomeRemovePhotoButton': {
    AppLanguage.english: 'Remove Photo',
    AppLanguage.gujarati: 'ફોટો દૂર કરો',
  },
  'incomeNoRecords': {
    AppLanguage.english: 'No income records',
    AppLanguage.gujarati: 'કોઈ આવક નોંધ નથી',
  },
  'incomeNoBillPhoto': {
    AppLanguage.english: 'No bill photo attached',
    AppLanguage.gujarati: 'બિલ ફોટો જોડાયેલ નથી',
  },
  'viewIncomeBillTitle': {
    AppLanguage.english: 'View Bill Photo',
    AppLanguage.gujarati: 'બિલ ફોટો જુઓ',
  },
  'enterValidIncome': {
    AppLanguage.english: 'Please enter amount and select date',
    AppLanguage.gujarati: 'કૃપા કરીને રકમ દાખલ કરો અને તારીખ પસંદ કરો',
  },
  'deleteIncomeTitle': {
    AppLanguage.english: 'Delete Income',
    AppLanguage.gujarati: 'આવક કાઢી નાખો',
  },
  'deleteIncomeConfirm': {
    AppLanguage.english: 'Are you sure you want to delete this income record?',
    AppLanguage.gujarati: 'શું તમે આ આવક નોંધ કાઢી નાખવા માંગો છો?',
  },
  'deleteAnimalRecordTitle': {
    AppLanguage.english: 'Delete Animal Record',
    AppLanguage.gujarati: 'પશુ નોંધ કાઢી નાખો',
  },
  'deleteAnimalRecordConfirm': {
    AppLanguage.english: 'Are you sure you want to delete this animal record?',
    AppLanguage.gujarati: 'શું તમે આ પશુ નોંધ કાઢી નાખવા માંગો છો?',
  },
  'incomeTypeCropSale': {
    AppLanguage.english: 'Crop Sale',
    AppLanguage.gujarati: 'ફસલ વેચાણ',
  },
  'incomeTypeTractorHarvester': {
    AppLanguage.english: 'Tractor/Harvester',
    AppLanguage.gujarati: 'ટ્રેક્ટર/હાર્વેસ્ટર',
  },
  'incomeTypeVegetables': {
    AppLanguage.english: 'Vegetable Sale',
    AppLanguage.gujarati: 'શાકભાજી વેચાણ',
  },
  'incomeTypeMilkSale': {
    AppLanguage.english: 'Milk Sale',
    AppLanguage.gujarati: 'દૂધ વેચાણ',
  },
  'incomeTypeSubsidy': {
    AppLanguage.english: 'Subsidy',
    AppLanguage.gujarati: 'સબસિડી',
  },
  'incomeTypeOther': {
    AppLanguage.english: 'Other',
    AppLanguage.gujarati: 'અન્ય',
  },
  'expensesLabel': {
    AppLanguage.english: 'Expenses',
    AppLanguage.gujarati: 'ખર્ચ',
  },
  'expenseRecordsLabel': {
    AppLanguage.english: 'Expense Records',
    AppLanguage.gujarati: 'ખર્ચ નોંધો',
  },
  'expenseAddButton': {
    AppLanguage.english: 'Add Expense',
    AppLanguage.gujarati: 'ખર્ચ ઉમેરો',
  },
  'expenseUpdateButton': {
    AppLanguage.english: 'Update Expense',
    AppLanguage.gujarati: 'ખર્ચ અપડેટ કરો',
  },
  'expenseTypeLabel': {
    AppLanguage.english: 'Expense Type',
    AppLanguage.gujarati: 'ખર્ચ પ્રકાર',
  },
  'expenseAmountLabel': {
    AppLanguage.english: 'Amount',
    AppLanguage.gujarati: 'રકમ',
  },
  'expenseDateLabel': {
    AppLanguage.english: 'Date',
    AppLanguage.gujarati: 'તારીખ',
  },
  'expenseNoteLabel': {
    AppLanguage.english: 'Note (Optional)',
    AppLanguage.gujarati: 'નોંધ (વૈકલ્પિક)',
  },
  'expenseNoteListLabel': {
    AppLanguage.english: 'Note',
    AppLanguage.gujarati: 'નોંધ',
  },
  'expenseBillPhotoLabel': {
    AppLanguage.english: 'Bill Photo (Optional)',
    AppLanguage.gujarati: 'બિલ ફોટો (વૈકલ્પિક)',
  },
  'expensePickPhotoButton': {
    AppLanguage.english: 'Pick Photo',
    AppLanguage.gujarati: 'ફોટો પસંદ કરો',
  },
  'expenseChangePhotoButton': {
    AppLanguage.english: 'Change Photo',
    AppLanguage.gujarati: 'ફોટો બદલો',
  },
  'expenseRemovePhotoButton': {
    AppLanguage.english: 'Remove Photo',
    AppLanguage.gujarati: 'ફોટો દૂર કરો',
  },
  'expenseNoRecords': {
    AppLanguage.english: 'No expense records',
    AppLanguage.gujarati: 'કોઈ ખર્ચ નોંધ નથી',
  },
  'expenseNoBillPhoto': {
    AppLanguage.english: 'No bill photo attached',
    AppLanguage.gujarati: 'બિલ ફોટો જોડાયેલ નથી',
  },
  'viewBillTitle': {
    AppLanguage.english: 'View Bill Photo',
    AppLanguage.gujarati: 'બિલ ફોટો જુઓ',
  },
  'enterValidExpense': {
    AppLanguage.english: 'Please enter amount and select date',
    AppLanguage.gujarati: 'કૃપા કરીને રકમ દાખલ કરો અને તારીખ પસંદ કરો',
  },
  'deleteExpenseTitle': {
    AppLanguage.english: 'Delete Expense',
    AppLanguage.gujarati: 'ખર્ચ કાઢી નાખો',
  },
  'deleteExpenseConfirm': {
    AppLanguage.english: 'Are you sure you want to delete this expense record?',
    AppLanguage.gujarati: 'શું તમે આ ખર્ચ નોંધ કાઢી નાખવા માંગો છો?',
  },
  'expenseTypeMedicine': {
    AppLanguage.english: 'Medicine',
    AppLanguage.gujarati: 'દવા',
  },
  'expenseTypeSeeds': {
    AppLanguage.english: 'Seeds',
    AppLanguage.gujarati: 'બિયારણ',
  },
  'expenseTypeTractor': {
    AppLanguage.english: 'Tractor',
    AppLanguage.gujarati: 'ટ્રેક્ટર',
  },
  'expenseTypeLightBill': {
    AppLanguage.english: 'Light Bill',
    AppLanguage.gujarati: 'લાઇટ બિલ',
  },
  'expenseTypeOther': {
    AppLanguage.english: 'Other',
    AppLanguage.gujarati: 'અન્ય',
  },
  'cropProductionLabel': {
    AppLanguage.english: 'Crop Production (kg)',
    AppLanguage.gujarati: 'ફસલ ઉત્પાદન (કિગ્રા)',
  },
  'addCropButton': {
    AppLanguage.english: 'Add Crop',
    AppLanguage.gujarati: 'ફસલ ઉમેરો',
  },
  'updateCropButton': {
    AppLanguage.english: 'Update Crop',
    AppLanguage.gujarati: 'ફસલ અપડેટ કરો',
  },
  'cropType': {
    AppLanguage.english: 'Crop Type',
    AppLanguage.gujarati: 'ફસલનો પ્રકાર',
  },
  'cropTypeWheat': {AppLanguage.english: 'Wheat', AppLanguage.gujarati: 'ઘઉં'},
  'cropTypeCotton': {
    AppLanguage.english: 'Cotton',
    AppLanguage.gujarati: 'કપાસ',
  },
  'cropTypeGroundnut': {
    AppLanguage.english: 'Groundnut',
    AppLanguage.gujarati: 'મગફળી',
  },
  'cropTypeBajra': {
    AppLanguage.english: 'Bajra',
    AppLanguage.gujarati: 'બાજરી',
  },
  'cropTypeMaize': {AppLanguage.english: 'Maize', AppLanguage.gujarati: 'મકાઈ'},
  'cropTypeRice': {AppLanguage.english: 'Rice', AppLanguage.gujarati: 'ચોખા'},
  'cropTypeJiru': {AppLanguage.english: 'Cumin', AppLanguage.gujarati: 'જીરૂં'},
  'cropTypeLasan': {AppLanguage.english: 'Garlic', AppLanguage.gujarati: 'લસણ'},
  'cropTypeChana': {
    AppLanguage.english: 'Chickpea',
    AppLanguage.gujarati: 'ચણા',
  },
  'cropTypeTal': {AppLanguage.english: 'Sesame', AppLanguage.gujarati: 'તલ'},
  'cropTypeAnyOther': {
    AppLanguage.english: 'Other',
    AppLanguage.gujarati: 'અન્ય',
  },
  'cropWeight': {
    AppLanguage.english: 'Crop Weight',
    AppLanguage.gujarati: 'ફસલ વજન',
  },
  'weightUnit': {
    AppLanguage.english: 'Weight Unit',
    AppLanguage.gujarati: 'વજન એકમ',
  },
  'weightUnitKg': {AppLanguage.english: 'kg', AppLanguage.gujarati: 'કિગ્રા'},
  'weightUnitMan': {
    AppLanguage.english: 'Maund (20 kg)',
    AppLanguage.gujarati: 'મણ (20 કિગ્રા)',
  },
  'noCropRecords': {
    AppLanguage.english: 'No crop records',
    AppLanguage.gujarati: 'કોઈ ફસલ રેકોર્ડ નથી',
  },
  'enterValidCrop': {
    AppLanguage.english: 'Enter valid land size and crop weight',
    AppLanguage.gujarati: 'માન્ય જમીન કદ અને ફસલ વજન દાખલ કરો',
  },
  'saveMetricsButton': {
    AppLanguage.english: 'Save Metrics',
    AppLanguage.gujarati: 'મેટ્રિક્સ સાચવો',
  },
  'noLandSelected': {
    AppLanguage.english:
        'No land selected. Add a land and choose it from the list.',
    AppLanguage.gujarati:
        'કોઈ જમીન પસંદ કરવામાં આવી નથી. કૃપા કરીને જમીન ઉમેરો અને ડ્રોપડાઉનમાંથી પસંદ કરો.',
  },
  'enterValidLand': {
    AppLanguage.english: 'Enter valid name, size (>0) and location',
    AppLanguage.gujarati: 'માન્ય નામ, કદ (>0) અને સ્થાન દાખલ કરો',
  },
  'validationRequiredField': {
    AppLanguage.english: 'This field is required',
    AppLanguage.gujarati: 'આ માહિતી ફરજિયાત છે',
  },
  'validationEnterValidNumber': {
    AppLanguage.english: 'Enter a valid number',
    AppLanguage.gujarati: 'માન્ય સંખ્યા દાખલ કરો',
  },
  'validationEnterPositiveNumber': {
    AppLanguage.english: 'Enter a value greater than 0',
    AppLanguage.gujarati: '0 કરતાં મોટી કિંમત દાખલ કરો',
  },
  'validationSelectDate': {
    AppLanguage.english: 'Please select a date',
    AppLanguage.gujarati: 'કૃપા કરીને તારીખ પસંદ કરો',
  },
  'validationEnterValidMobile': {
    AppLanguage.english: 'Enter a valid 10-digit mobile number',
    AppLanguage.gujarati: 'માન્ય 10 અંકનો મોબાઇલ નંબર દાખલ કરો',
  },
  'validationEnterValidEmail': {
    AppLanguage.english: 'Enter a valid email address',
    AppLanguage.gujarati: 'માન્ય ઇમેઇલ સરનામું દાખલ કરો',
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
    AppLanguage.gujarati: 'કિસાન ડાયરી મેનૂ',
  },
  'loggedUserDefaultName': {
    AppLanguage.english: 'Farmer',
    AppLanguage.gujarati: 'ખેડૂત',
  },
  'drawerLanguage': {
    AppLanguage.english: 'Change Language',
    AppLanguage.gujarati: 'ભાષા બદલો',
  },
  'drawerAbout': {
    AppLanguage.english: 'About App',
    AppLanguage.gujarati: 'એપ વિશે',
  },
  'drawerTermsConditions': {
    AppLanguage.english: 'Terms & Conditions',
    AppLanguage.gujarati: 'નિયમો અને શરતો',
  },
  'termsConditionsDescription': {
    AppLanguage.english:
        'Use this app responsibly. Keep your records accurate and do not share private farm data with unknown users.',
    AppLanguage.gujarati:
        'આ એપનો જવાબદારીપૂર્વક ઉપયોગ કરો. તમારી વિગતો સાચી રાખો અને અજાણી વ્યક્તિઓ સાથે ખાનગી ખેતીનો ડેટા શેર ન કરો.',
  },
  'drawerClear': {
    AppLanguage.english: 'Clear All Data',
    AppLanguage.gujarati: 'બધો ડેટા સાફ કરો',
  },
  'drawerUpdateProfile': {
    AppLanguage.english: 'Update Profile',
    AppLanguage.gujarati: 'પ્રોફાઇલ અપડેટ કરો',
  },
  'drawerLogout': {
    AppLanguage.english: 'Logout',
    AppLanguage.gujarati: 'લોગઆઉટ',
  },
  'logoutConfirmTitle': {
    AppLanguage.english: 'Logout',
    AppLanguage.gujarati: 'લોગઆઉટ',
  },
  'logoutConfirmMessage': {
    AppLanguage.english: 'Are you sure you want to logout?',
    AppLanguage.gujarati: 'શું તમે ખાતરી કરો છો કે તમે લોગઆઉટ કરવા માંગો છો?',
  },
  'updateProfileTitle': {
    AppLanguage.english: 'Update Profile',
    AppLanguage.gujarati: 'પ્રોફાઇલ અપડેટ કરો',
  },
  'updateProfileName': {
    AppLanguage.english: 'Name',
    AppLanguage.gujarati: 'નામ',
  },
  'updateProfileEmail': {
    AppLanguage.english: 'Email',
    AppLanguage.gujarati: 'ઇમેઇલ',
  },
  'updateProfileBirthdate': {
    AppLanguage.english: 'Birthdate',
    AppLanguage.gujarati: 'જન્મ તારીખ',
  },
  'updateProfilePassword': {
    AppLanguage.english: 'Password',
    AppLanguage.gujarati: 'પાસવર્ડ',
  },
  'updateProfileImage': {
    AppLanguage.english: 'Update Profile Image',
    AppLanguage.gujarati: 'પ્રોફાઇલ ફોટો અપડેટ કરો',
  },
  'profileImageCameraOption': {
    AppLanguage.english: 'Take Photo',
    AppLanguage.gujarati: 'ફોટો ખેંચો',
  },
  'profileImageGalleryOption': {
    AppLanguage.english: 'Choose from Gallery',
    AppLanguage.gujarati: 'ગેલેરીમાંથી પસંદ કરો',
  },
  'profileUpdatedMessage': {
    AppLanguage.english: 'Profile updated successfully',
    AppLanguage.gujarati: 'પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ',
  },
  'deleteAllDataTitle': {
    AppLanguage.english: 'Delete All Data',
    AppLanguage.gujarati: 'બધો ડેટા કાઢી નાખો',
  },
  'deleteAllDataConfirm': {
    AppLanguage.english:
        'Are you sure you want to delete all data? This action cannot be undone.',
    AppLanguage.gujarati:
        'શું તમે ખરેખર બધી માહિતી કાઢી નાખવા માંગો છો? આ ક્રિયા પાછી કરી શકાશે નહીં.',
  },
  'drawerAddLand': {
    AppLanguage.english: 'Add Land',
    AppLanguage.gujarati: 'જમીન ઉમેરો',
  },
  'shareAppTooltip': {
    AppLanguage.english: 'Share App',
    AppLanguage.gujarati: 'એપ શેર કરો',
  },
  'shareAppText': {
    AppLanguage.english:
        'Try the Kishan Diary app to manage farm income, expenses, crop, and labor records.',
    AppLanguage.gujarati:
        'ખેતીની આવક, ખર્ચ, પાક અને મજૂરી રેકોર્ડ માટે કિસાન ડાયરી એપ જરૂર અજમાવો.',
  },
  'editLandTooltip': {
    AppLanguage.english: 'Edit Land',
    AppLanguage.gujarati: 'જમીન સંપાદિત કરો',
  },
  'aboutAppDescription': {
    AppLanguage.english:
        'Kishan Diary — land tracking and expense management app.',
    AppLanguage.gujarati:
        'કિસાન ડાયરી — જમીન ટ્રેકિંગ અને ખર્ચ વ્યવસ્થાપન માટેની એપ.',
  },
  'okButton': {AppLanguage.english: 'OK', AppLanguage.gujarati: 'બરાબર'},
  'navHome': {AppLanguage.english: 'Home', AppLanguage.gujarati: 'હોમ'},
  'navIncome': {AppLanguage.english: 'Income', AppLanguage.gujarati: 'આવક'},
  'navExpense': {AppLanguage.english: 'Expense', AppLanguage.gujarati: 'ખર્ચ'},
  'navCrop': {AppLanguage.english: 'Crop', AppLanguage.gujarati: 'ફસલ'},
  'navLabor': {AppLanguage.english: 'Labor', AppLanguage.gujarati: 'મજૂર'},
  'navAnimal': {AppLanguage.english: 'Animal', AppLanguage.gujarati: 'પશુ'},
  'animalIncomeLabel': {
    AppLanguage.english: 'Animal Income',
    AppLanguage.gujarati: 'પશુ આવક',
  },
  'addAnimalButton': {
    AppLanguage.english: 'Add Animal',
    AppLanguage.gujarati: 'પશુ ઉમેરો',
  },
  'animalNameLabel': {
    AppLanguage.english: 'Animal Name',
    AppLanguage.gujarati: 'પશુનું નામ',
  },
  'animalListLabel': {
    AppLanguage.english: 'Animals',
    AppLanguage.gujarati: 'પશુઓ',
  },
  'animalNoAnimals': {
    AppLanguage.english: 'No animals added',
    AppLanguage.gujarati: 'કોઈ પશુ ઉમેરાયેલ નથી',
  },
  'animalExists': {
    AppLanguage.english: 'Animal name already exists',
    AppLanguage.gujarati: 'આ પશુનું નામ પહેલેથી જ છે',
  },
  'enterValidAnimalName': {
    AppLanguage.english: 'Please enter animal name',
    AppLanguage.gujarati: 'કૃપા કરીને પશુનું નામ દાખલ કરો',
  },
  'animalAmountLabel': {
    AppLanguage.english: 'Amount',
    AppLanguage.gujarati: 'રકમ',
  },
  'animalMilkLabel': {
    AppLanguage.english: 'Milk (L)',
    AppLanguage.gujarati: 'દૂધ (લિટર)',
  },
  'animalDateLabel': {
    AppLanguage.english: 'Date',
    AppLanguage.gujarati: 'તારીખ',
  },
  'addAnimalRecordButton': {
    AppLanguage.english: 'Add Record',
    AppLanguage.gujarati: 'નોંધ ઉમેરો',
  },
  'animalRecordsLabel': {
    AppLanguage.english: 'Records',
    AppLanguage.gujarati: 'નોંધો',
  },
  'animalNoRecords': {
    AppLanguage.english: 'No records for this animal',
    AppLanguage.gujarati: 'આ પશુ માટે કોઈ નોંધ નથી',
  },
  'animalTotalAmountLabel': {
    AppLanguage.english: 'Total Amount',
    AppLanguage.gujarati: 'કુલ રકમ',
  },
  'animalTotalMilkLabel': {
    AppLanguage.english: 'Total Milk (L)',
    AppLanguage.gujarati: 'કુલ દૂધ (લિટર)',
  },
  'enterValidAnimalRecord': {
    AppLanguage.english: 'Please enter valid amount, milk and date',
    AppLanguage.gujarati: 'કૃપા કરીને માન્ય રકમ, દૂધ અને તારીખ દાખલ કરો',
  },
  'saveButton': {AppLanguage.english: 'Save', AppLanguage.gujarati: 'સાચવો'},
  'laborName': {
    AppLanguage.english: 'Labor Name',
    AppLanguage.gujarati: 'મજૂરનું નામ',
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
    AppLanguage.english: 'Daily Wage',
    AppLanguage.gujarati: 'એક દિવસની મજૂરી',
  },
  'laborTotalWage': {
    AppLanguage.english: 'Total Wage',
    AppLanguage.gujarati: 'કુલ મજૂરી',
  },
  'laborPaid': {
    AppLanguage.english: 'Total Paid',
    AppLanguage.gujarati: 'કુલ ચૂકવણી',
  },
  'laborBalance': {
    AppLanguage.english: 'Total Pending',
    AppLanguage.gujarati: 'બાકી ચૂકવણી',
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
    AppLanguage.english: 'Upad Amount',
    AppLanguage.gujarati: 'ઉપાડ રકમ',
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
    AppLanguage.english: 'Enter a valid upad amount and date',
    AppLanguage.gujarati: 'માન્ય ઉપાડ રકમ અને તારીખ દાખલ કરો',
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
  'deleteCropTitle': {
    AppLanguage.english: 'Delete Crop',
    AppLanguage.gujarati: 'ફસલ કાઢી નાખો',
  },
  'deleteCropConfirm': {
    AppLanguage.english: 'Are you sure you want to delete this crop record?',
    AppLanguage.gujarati: 'શું તમે આ ફસલ રેકોર્ડ કાઢી નાખવા માંગો છો?',
  },
  'deleteUpadTitle': {
    AppLanguage.english: 'Delete Upad',
    AppLanguage.gujarati: 'ઉપાડ કાઢી નાખો',
  },
  'deleteUpadConfirm': {
    AppLanguage.english: 'Are you sure you want to delete this upad record?',
    AppLanguage.gujarati: 'શું તમે આ ઉપાડ રેકોર્ડ કાઢી નાખવા માંગો છો?',
  },
  'laborTotalPaid': {
    AppLanguage.english: 'Total Paid',
    AppLanguage.gujarati: 'કુલ ચૂકવેલ',
  },
  'laborTotalPending': {
    AppLanguage.english: 'Total Pending',
    AppLanguage.gujarati: 'કુલ બાકી',
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
