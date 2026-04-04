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
    AppLanguage.english: 'Land Size (bigha)',
    AppLanguage.gujarati: 'જમીનનું કદ (વીઘા)',
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
    AppLanguage.english: 'Medicine & Seeds Expense',
    AppLanguage.gujarati: 'દવા-બિયારણ ખર્ચ',
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
  'incomeTypeAll': {AppLanguage.english: 'All', AppLanguage.gujarati: 'બધા'},
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
  'profitLabel': {AppLanguage.english: 'Profit', AppLanguage.gujarati: 'નફો'},
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
  'expenseTypeAll': {AppLanguage.english: 'All', AppLanguage.gujarati: 'બધા'},
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
  'drawerContactUs': {
    AppLanguage.english: 'Contact Us',
    AppLanguage.gujarati: 'સંપર્ક કરો',
  },
  'drawerWhatsAppGroup': {
    AppLanguage.english: 'Join WhatsApp Group',
    AppLanguage.gujarati: 'WhatsApp ગ્રુપ જોડાઓ',
  },
  'whatsAppOpenError': {
    AppLanguage.english: 'Unable to open WhatsApp group link.',
    AppLanguage.gujarati: 'WhatsApp ગ્રુપ લિંક ખોલવામાં અસમર્થ.',
  },
  'termsConditionsDescription': {
    AppLanguage.english:
        'Use this app responsibly. Keep your records accurate and do not share private farm data with unknown users.',
    AppLanguage.gujarati:
        'આ એપનો જવાબદારીપૂર્વક ઉપયોગ કરો. તમારી વિગતો સાચી રાખો અને અજાણી વ્યક્તિઓ સાથે ખાનગી ખેતીનો ડેટા શેર ન કરો.',
  },
  'drawerClear': {
    AppLanguage.english: 'Disable All Lands',
    AppLanguage.gujarati: 'બધી જમીન નિષ્ક્રિય કરો',
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
    AppLanguage.english: 'Disable All Lands',
    AppLanguage.gujarati: 'બધી જમીન નિષ્ક્રિય કરો',
  },
  'deleteAllDataConfirm': {
    AppLanguage.english:
        'Are you sure you want to disable all land records for this account?',
    AppLanguage.gujarati:
        'શું તમે ખાતરી કરો છો કે તમે આ એકાઉન્ટ માટે બધી જમીનના રેકોર્ડ નિષ્ક્રિય કરવા માંગો છો?',
  },
  'deleteAllDataNote': {
    AppLanguage.english:
        'After disabling, your land records will not be visible here.',
    AppLanguage.gujarati:
        'નિષ્ક્રિય કરવાથી તમારી બધી જમીનનો રેકોર્ડ અહીં દેખાશે નહીં.',
  },
  'disableAllDataDone': {
    AppLanguage.english: 'All land records disabled. You can add new lands.',
    AppLanguage.gujarati:
        'બધા જમીન રેકોર્ડ નિષ્ક્રિય થયા. તમે નવી જમીન ઉમેરી શકો છો.',
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
  'downloadPdfTooltip': {
    AppLanguage.english: 'Download PDF',
    AppLanguage.gujarati: 'PDF ડાઉનલોડ કરો',
  },
  'drawerDownloadAllData': {
    AppLanguage.english: 'Download All Data (PDF)',
    AppLanguage.gujarati: 'બધા ડેટાનો PDF ડાઉનલોડ કરો',
  },
  'pdfAllDataTitle': {
    AppLanguage.english: 'All Data Report (PDF)',
    AppLanguage.gujarati: 'તમામ ડેટાનો અહેવાલ (PDF)',
  },
  'pdfGeneratedOn': {
    AppLanguage.english: 'Generated on',
    AppLanguage.gujarati: 'તૈયાર થયેલ તારીખ',
  },
  'downloadNoData': {
    AppLanguage.english: 'No records available on this page',
    AppLanguage.gujarati: 'આ પેજમાં કોઈ રેકોર્ડ ઉપલબ્ધ નથી',
  },
  'downloadAllNoData': {
    AppLanguage.english: 'No records available to export',
    AppLanguage.gujarati: 'નિકાસ કરવા માટે કોઈ રેકોર્ડ ઉપલબ્ધ નથી',
  },
  'editLandTooltip': {
    AppLanguage.english: 'Edit Land',
    AppLanguage.gujarati: 'જમીન સંપાદિત કરો',
  },
  'disableLandTooltip': {
    AppLanguage.english: 'Disable Land',
    AppLanguage.gujarati: 'જમીન નિષ્ક્રિય કરો',
  },
  'disableLandTitle': {
    AppLanguage.english: 'Disable Land',
    AppLanguage.gujarati: 'જમીન નિષ્ક્રિય કરો',
  },
  'disableLandConfirm': {
    AppLanguage.english:
        'Are you sure you want to disable this land? Records will be kept but hidden.',
    AppLanguage.gujarati:
        'શું તમે આ જમીન નિષ્ક્રિય કરવા માંગો છો? રેકોર્ડ રહેશે, પરંતુ છુપાઈ જશે.',
  },
  'aboutAppDescription': {
    AppLanguage.english:
        'Kishan Diary — land tracking and expense management app.',
    AppLanguage.gujarati:
        'કિસાન ડાયરી — જમીન ટ્રેકિંગ અને ખર્ચ વ્યવસ્થાપન માટેની એપ.',
  },
  'aboutPageTitle': {
    AppLanguage.english: 'About Kishan Diary',
    AppLanguage.gujarati: 'કિસાન ડાયરી વિશે',
  },
  'aboutPageIntro': {
    AppLanguage.english:
        'Kishan Diary helps farmers manage land, income, expenses, crops, labor, and animal records in one place.',
    AppLanguage.gujarati:
        'કિસાન ડાયરી ખેડુતોને જમીન, આવક, ખર્ચ, પાક, મજૂરી અને પશુ રેકોર્ડ એક જ જગ્યાએ સંભાળવામાં મદદ કરે છે.',
  },
  'aboutPageFeaturesTitle': {
    AppLanguage.english: 'Main Features',
    AppLanguage.gujarati: 'મુખ્ય સુવિધાઓ',
  },
  'aboutFeature1': {
    AppLanguage.english: 'Land-wise financial tracking',
    AppLanguage.gujarati: 'જમીન મુજબ નાણાકીય ટ્રેકિંગ',
  },
  'aboutFeature2': {
    AppLanguage.english: 'Income, expense, and crop records',
    AppLanguage.gujarati: 'આવક, ખર્ચ અને પાક રેકોર્ડ',
  },
  'aboutFeature3': {
    AppLanguage.english: 'Labor and upad management',
    AppLanguage.gujarati: 'મજૂર અને ઉપાડ વ્યવસ્થાપન',
  },
  'aboutFeature4': {
    AppLanguage.english: 'Animal income and milk records',
    AppLanguage.gujarati: 'પશુ આવક અને દૂધ રેકોર્ડ',
  },
  'rulesPageTitle': {
    AppLanguage.english: 'Rules & Regulations',
    AppLanguage.gujarati: 'નિયમો અને નિયમન',
  },
  'rule1': {
    AppLanguage.english: 'Use correct and truthful farm data only.',
    AppLanguage.gujarati: 'માત્ર સાચો અને યથાર્થ ખેતી ડેટા જ દાખલ કરો.',
  },
  'rule2': {
    AppLanguage.english: 'Do not share your account token or password.',
    AppLanguage.gujarati: 'તમારો એકાઉન્ટ ટોકન અથવા પાસવર્ડ શેર ન કરો.',
  },
  'rule3': {
    AppLanguage.english: 'Review entries before saving or exporting reports.',
    AppLanguage.gujarati: 'સેવ અથવા રિપોર્ટ એક્સપોર્ટ કરતા પહેલા નોંધો ચકાસો.',
  },
  'rule4': {
    AppLanguage.english: 'Keep backup copies of important records.',
    AppLanguage.gujarati: 'મહત્વપૂર્ણ નોંધોની બેકઅપ નકલ રાખો.',
  },
  'rule5': {
    AppLanguage.english:
        'Respect local legal requirements for financial and labor records.',
    AppLanguage.gujarati:
        'નાણાકીય અને મજૂરી રેકોર્ડ માટે સ્થાનિક કાયદાકીય નિયમોનું પાલન કરો.',
  },
  'rule6': {
    AppLanguage.english:
        'Contact support for any wrong data, access issue, or app problem.',
    AppLanguage.gujarati:
        'ખોટા ડેટા, ઍક્સેસ સમસ્યા કે એપ સમસ્યા માટે સપોર્ટનો સંપર્ક કરો.',
  },
  'contactPageTitle': {
    AppLanguage.english: 'Contact Us',
    AppLanguage.gujarati: 'અમારો સંપર્ક કરો',
  },
  'contactPageIntro': {
    AppLanguage.english: 'For support, feedback, or issue reporting:',
    AppLanguage.gujarati: 'સપોર્ટ, પ્રતિસાદ અથવા સમસ્યા માટે સંપર્ક કરો:',
  },
  'contactHelpHeadline': {
    AppLanguage.english:
        'Do you have any questions or need help? We are here to support you!',
    AppLanguage.gujarati:
        'શું તમને કોઈ પ્રશ્નો છે કે મદદની જરૂર છે? અમે અહીં મદદ માટે છીએ!',
  },
  'contactHelpThankYou': {
    AppLanguage.english:
        'Feel free to contact us anytime. Thank you for using Kissan Yadi!',
    AppLanguage.gujarati:
        'કોઈ પણ સમયે અમારો સંપર્ક કરો. Kissan Yadi વાપરવા માટે તમારું આભાર!',
  },
  'contactMobileLabel': {
    AppLanguage.english: 'Mobile',
    AppLanguage.gujarati: 'મોબાઇલ',
  },
  'contactEmailLabel': {
    AppLanguage.english: 'Email',
    AppLanguage.gujarati: 'ઇમેઇલ',
  },
  'contactSuggestionTitle': {
    AppLanguage.english: 'Suggestion Box',
    AppLanguage.gujarati: 'સૂચન બોક્સ',
  },
  'contactSuggestionHint': {
    AppLanguage.english:
        'Write your suggestion to improve app functionality...',
    AppLanguage.gujarati: 'એપની સુવિધાઓ સુધારવા માટે તમારું સૂચન અહીં લખો...',
  },
  'contactSuggestionSubmit': {
    AppLanguage.english: 'Submit Suggestion',
    AppLanguage.gujarati: 'સૂચન મોકલો',
  },
  'contactSuggestionSuccess': {
    AppLanguage.english: 'Thank you! Your suggestion has been submitted.',
    AppLanguage.gujarati: 'આભાર! તમારું સૂચન સફળતાપૂર્વક મોકલાયું છે.',
  },
  'contactSuggestionError': {
    AppLanguage.english: 'Failed to submit suggestion. Please try again.',
    AppLanguage.gujarati: 'સૂચન મોકલી શકાયું નથી. કૃપા કરીને ફરી પ્રયાસ કરો.',
  },
  'okButton': {AppLanguage.english: 'OK', AppLanguage.gujarati: 'બરાબર'},
  'navHome': {AppLanguage.english: 'Home', AppLanguage.gujarati: 'હોમ'},
  'navIncome': {AppLanguage.english: 'Income', AppLanguage.gujarati: 'આવક'},
  'navExpense': {AppLanguage.english: 'Expense', AppLanguage.gujarati: 'ખર્ચ'},
  'navCrop': {AppLanguage.english: 'Crop', AppLanguage.gujarati: 'ફસલ'},
  'navLabor': {AppLanguage.english: 'Labor', AppLanguage.gujarati: 'મજૂર'},
  'navBills': {AppLanguage.english: 'Bills', AppLanguage.gujarati: 'બિલ'},
  'farmerNoBills': {
    AppLanguage.english: 'No bills found for your mobile number.',
    AppLanguage.gujarati: 'તમારા મોબાઇલ નંબર માટે કોઈ બિલ મળ્યું નથી.',
  },
  'farmerBillsLoadError': {
    AppLanguage.english: 'Failed to load bills. Please try again.',
    AppLanguage.gujarati: 'બિલ લોડ થઈ શક્યા નથી. કૃપા કરીને ફરી પ્રયાસ કરો.',
  },
  'farmerBillFromAgro': {
    AppLanguage.english: 'From Agro Center',
    AppLanguage.gujarati: 'એગ્રો સેન્ટર તરફથી',
  },
  'farmerBillSourceFarmer': {
    AppLanguage.english: 'Farmer Bill',
    AppLanguage.gujarati: 'ખેડૂત બિલ',
  },
  'farmerBillSourceAgro': {
    AppLanguage.english: 'Agro Bill',
    AppLanguage.gujarati: 'એગ્રો બિલ',
  },
  'farmerSelfBillLabel': {
    AppLanguage.english: 'Self Bill',
    AppLanguage.gujarati: 'મારું બિલ',
  },
  'farmerAddBillButton': {
    AppLanguage.english: 'Add Bill',
    AppLanguage.gujarati: 'બિલ ઉમેરો',
  },
  'farmerAddBillTitle': {
    AppLanguage.english: 'Add Farmer Bill',
    AppLanguage.gujarati: 'ખેડૂત બિલ ઉમેરો',
  },
  'farmerBillSaved': {
    AppLanguage.english: 'Farmer bill saved successfully.',
    AppLanguage.gujarati: 'ખેડૂત બિલ સફળતાપૂર્વક સાચવાયું.',
  },
  'farmerBillStatusUpdated': {
    AppLanguage.english: 'Bill status updated successfully.',
    AppLanguage.gujarati: 'બિલ સ્થિતિ સફળતાપૂર્વક અપડેટ થઈ.',
  },
  'farmerBillDeleteConfirm': {
    AppLanguage.english: 'Delete this farmer bill?',
    AppLanguage.gujarati: 'આ ખેડૂત બિલ કાઢી નાખવું છે?',
  },
  'farmerBillDeleted': {
    AppLanguage.english: 'Farmer bill deleted successfully.',
    AppLanguage.gujarati: 'ખેડૂત બિલ સફળતાપૂર્વક કાઢી નાખ્યું.',
  },
  'farmerBillInvalidAmount': {
    AppLanguage.english: 'Please enter a valid amount.',
    AppLanguage.gujarati: 'કૃપા કરીને માન્ય રકમ દાખલ કરો.',
  },
  'navAnimal': {AppLanguage.english: 'Animal', AppLanguage.gujarati: 'પશુ'},
  'animalIncomeLabel': {
    AppLanguage.english: 'Animal Income',
    AppLanguage.gujarati: 'પશુ આવક',
  },
  'addAnimalButton': {
    AppLanguage.english: 'Add Animal',
    AppLanguage.gujarati: 'પશુ ઉમેરો',
  },
  'editAnimalTitle': {
    AppLanguage.english: 'Edit Animal Name',
    AppLanguage.gujarati: 'પશુનું નામ સંપાદિત કરો',
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
  'laborSearchHint': {
    AppLanguage.english: 'Search labor by name or mobile',
    AppLanguage.gujarati: 'નામ અથવા મોબાઇલથી મજૂર શોધો',
  },
  'laborSearchNoResults': {
    AppLanguage.english: 'No labor found for this search',
    AppLanguage.gujarati: 'આ શોધ માટે કોઈ મજૂર મળ્યો નથી',
  },
  'laborMobile': {
    AppLanguage.english: 'Mobile',
    AppLanguage.gujarati: 'મોબાઇલ',
  },
  'laborDay': {
    AppLanguage.english: 'Labor Days',
    AppLanguage.gujarati: 'મજૂરીના દિવસો',
  },
  'laborWord': {AppLanguage.english: 'Labor', AppLanguage.gujarati: 'મજૂરી'},
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
  'agroCenterTitle': {
    AppLanguage.english: 'Agro Center',
    AppLanguage.gujarati: 'એગ્રો સેન્ટર',
  },
  'agroDashboardTab': {
    AppLanguage.english: 'Dashboard',
    AppLanguage.gujarati: 'ડેશબોર્ડ',
  },
  'agroManageBillsTab': {
    AppLanguage.english: 'Manage Bills',
    AppLanguage.gujarati: 'બિલ મેનેજ',
  },
  'agroFarmersTab': {
    AppLanguage.english: 'Farmers',
    AppLanguage.gujarati: 'ખેડૂતો',
  },
  'agroReportsTab': {
    AppLanguage.english: 'Reports',
    AppLanguage.gujarati: 'રિપોર્ટ',
  },
  'agroFarmersCount': {
    AppLanguage.english: 'Farmer Count',
    AppLanguage.gujarati: 'ખેડૂત સંખ્યા',
  },
  'agroBillsTotal': {
    AppLanguage.english: 'Total Bills',
    AppLanguage.gujarati: 'કુલ બિલ',
  },
  'agroBillsPending': {
    AppLanguage.english: 'Pending Bills',
    AppLanguage.gujarati: 'બાકી બિલ',
  },
  'agroBillsCompleted': {
    AppLanguage.english: 'Completed Bills',
    AppLanguage.gujarati: 'પૂર્ણ થયેલ બિલ',
  },
  'agroAmountTotal': {
    AppLanguage.english: 'Total Amount',
    AppLanguage.gujarati: 'કુલ રકમ',
  },
  'agroAddBill': {
    AppLanguage.english: 'Add Bill',
    AppLanguage.gujarati: 'બિલ ઉમેરો',
  },
  'agroEditBill': {
    AppLanguage.english: 'Edit Bill',
    AppLanguage.gujarati: 'બિલ સુધારો',
  },
  'agroFarmer': {AppLanguage.english: 'Farmer', AppLanguage.gujarati: 'ખેડૂત'},
  'agroSearchFarmerHint': {
    AppLanguage.english: 'Search farmer by name',
    AppLanguage.gujarati: 'નામ દ્વારા ખેડૂત શોધો',
  },
  'agroFarmerNameLabel': {
    AppLanguage.english: 'Farmer Name',
    AppLanguage.gujarati: 'ખેડૂતનું નામ',
  },
  'agroFarmerMobileLabel': {
    AppLanguage.english: 'Mobile Number',
    AppLanguage.gujarati: 'મોબાઇલ નંબર',
  },
  'agroAddFarmerButton': {
    AppLanguage.english: 'Add Farmer',
    AppLanguage.gujarati: 'ખેડૂત ઉમેરો',
  },
  'agroBillDate': {
    AppLanguage.english: 'Bill Date',
    AppLanguage.gujarati: 'બિલ તારીખ',
  },
  'agroBillAmount': {
    AppLanguage.english: 'Bill Amount',
    AppLanguage.gujarati: 'બિલ રકમ',
  },
  'agroPaymentStatus': {
    AppLanguage.english: 'Payment Status',
    AppLanguage.gujarati: 'ચુકવણી સ્થિતિ',
  },
  'agroPending': {AppLanguage.english: 'Pending', AppLanguage.gujarati: 'બાકી'},
  'agroCompleted': {
    AppLanguage.english: 'Completed',
    AppLanguage.gujarati: 'પૂર્ણ',
  },
  'agroBillNote': {
    AppLanguage.english: 'Bill Note',
    AppLanguage.gujarati: 'બિલ નોંધ',
  },
  'agroPickBillPhoto': {
    AppLanguage.english: 'Pick Bill Image',
    AppLanguage.gujarati: 'બિલ ફોટો પસંદ કરો',
  },
  'agroRemoveBillPhoto': {
    AppLanguage.english: 'Remove Bill Image',
    AppLanguage.gujarati: 'બિલ ફોટો દૂર કરો',
  },
  'agroSaveBill': {
    AppLanguage.english: 'Save Bill',
    AppLanguage.gujarati: 'બિલ સાચવો',
  },
  'agroUpdateBill': {
    AppLanguage.english: 'Update Bill',
    AppLanguage.gujarati: 'બિલ અપડેટ કરો',
  },
  'agroBillsList': {
    AppLanguage.english: 'Bill List',
    AppLanguage.gujarati: 'બિલ યાદી',
  },
  'agroNoBills': {
    AppLanguage.english: 'No bills found',
    AppLanguage.gujarati: 'કોઈ બિલ મળ્યું નથી',
  },
  'agroFarmersList': {
    AppLanguage.english: 'Farmer List',
    AppLanguage.gujarati: 'ખેડૂત યાદી',
  },
  'agroNoFarmers': {
    AppLanguage.english: 'No farmers found',
    AppLanguage.gujarati: 'કોઈ ખેડૂત મળ્યો નથી',
  },
  'agroNoSearchFarmers': {
    AppLanguage.english: 'No matching farmers found',
    AppLanguage.gujarati: 'મેળ ખાતા ખેડૂત મળ્યા નથી',
  },
  'agroReportRows': {
    AppLanguage.english: 'Report Rows',
    AppLanguage.gujarati: 'રિપોર્ટ પંક્તિઓ',
  },
  'agroNoReportData': {
    AppLanguage.english: 'No report data',
    AppLanguage.gujarati: 'રિપોર્ટ ડેટા નથી',
  },
  'agroRefresh': {
    AppLanguage.english: 'Refresh',
    AppLanguage.gujarati: 'રીફ્રેશ',
  },
  'agroLoadError': {
    AppLanguage.english: 'Failed to load agro center data.',
    AppLanguage.gujarati: 'એગ્રો સેન્ટર ડેટા લોડ થઈ શક્યો નથી.',
  },
  'agroSelectFarmer': {
    AppLanguage.english: 'Please select a farmer.',
    AppLanguage.gujarati: 'કૃપા કરીને ખેડૂત પસંદ કરો.',
  },
  'agroEnterFarmerName': {
    AppLanguage.english: 'Please enter farmer name.',
    AppLanguage.gujarati: 'કૃપા કરીને ખેડૂતનું નામ દાખલ કરો.',
  },
  'agroFarmerAdded': {
    AppLanguage.english: 'Farmer added successfully.',
    AppLanguage.gujarati: 'ખેડૂત સફળતાપૂર્વક ઉમેરાયો.',
  },
  'agroEditFarmerTitle': {
    AppLanguage.english: 'Edit Farmer',
    AppLanguage.gujarati: 'ખેડૂત સુધારો',
  },
  'agroFarmerUpdated': {
    AppLanguage.english: 'Farmer updated successfully.',
    AppLanguage.gujarati: 'ખેડૂત સફળતાપૂર્વક અપડેટ થયો.',
  },
  'agroFarmerDeleteConfirm': {
    AppLanguage.english:
        'Delete this farmer? Related bills will also be removed.',
    AppLanguage.gujarati: 'આ ખેડૂત કાઢી નાખવો? સંબંધિત બિલ પણ દૂર થશે.',
  },
  'agroFarmerDeleted': {
    AppLanguage.english: 'Farmer deleted successfully.',
    AppLanguage.gujarati: 'ખેડૂત સફળતાપૂર્વક કાઢી નાખ્યો.',
  },
  'agroBillDeleteConfirm': {
    AppLanguage.english: 'Delete this bill?',
    AppLanguage.gujarati: 'આ બિલ કાઢી નાખવું?',
  },
  'agroBillPhotoRequired': {
    AppLanguage.english: 'Bill image is required for new bill.',
    AppLanguage.gujarati: 'નવા બિલ માટે બિલ ફોટો જરૂરી છે.',
  },
  'agroBillSaved': {
    AppLanguage.english: 'Bill saved successfully.',
    AppLanguage.gujarati: 'બિલ સફળતાપૂર્વક સાચવાયું.',
  },
  'agroBillDeleted': {
    AppLanguage.english: 'Bill deleted successfully.',
    AppLanguage.gujarati: 'બિલ સફળતાપૂર્વક કાઢી નાખ્યું.',
  },
};

String t(AppLanguage language, String key) {
  return translations[key]?[language] ?? key;
}
