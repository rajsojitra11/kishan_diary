import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/localization.dart';
import '../../widgets/text_input_config.dart';
import '../../widgets/app_widgets.dart';

class AgroManageBillsTab extends StatelessWidget {
  const AgroManageBillsTab({
    super.key,
    required this.language,
    required this.editingBillId,
    required this.selectedFarmerName,
    required this.farmers,
    required this.bills,
    required this.dateCtrl,
    required this.amountCtrl,
    required this.noteCtrl,
    required this.paymentStatus,
    required this.savingBill,
    required this.billPhotoName,
    required this.billPhotoBytes,
    required this.billPhotoPath,
    required this.onOpenFarmerPicker,
    required this.onPickDate,
    required this.onPaymentStatusChanged,
    required this.onPickBillPhoto,
    required this.onClearBillPhoto,
    required this.onSaveBill,
    required this.onResetBillForm,
    required this.onStartEditBill,
    required this.onDeleteBill,
    required this.toDisplayDate,
  });

  final AppLanguage language;
  final int? editingBillId;
  final String selectedFarmerName;
  final List<Map<String, dynamic>> farmers;
  final List<Map<String, dynamic>> bills;
  final TextEditingController dateCtrl;
  final TextEditingController amountCtrl;
  final TextEditingController noteCtrl;
  final String paymentStatus;
  final bool savingBill;
  final String? billPhotoName;
  final Uint8List? billPhotoBytes;
  final String? billPhotoPath;
  final VoidCallback onOpenFarmerPicker;
  final VoidCallback onPickDate;
  final ValueChanged<String?> onPaymentStatusChanged;
  final VoidCallback onPickBillPhoto;
  final VoidCallback onClearBillPhoto;
  final VoidCallback onSaveBill;
  final VoidCallback onResetBillForm;
  final void Function(Map<String, dynamic> bill) onStartEditBill;
  final void Function(int billId) onDeleteBill;
  final String Function(String? serverDate) toDisplayDate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editingBillId == null
                      ? t(language, 'agroAddBill')
                      : t(language, 'agroEditBill'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: farmers.isEmpty ? null : onOpenFarmerPicker,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: t(language, 'agroFarmer'),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      selectedFarmerName.isNotEmpty
                          ? selectedFarmerName
                          : t(language, 'agroSelectFarmer'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedFarmerName.isNotEmpty
                            ? null
                            : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                buildInput(
                  TextInputConfig(
                    dateCtrl,
                    t(language, 'agroBillDate'),
                    Icons.calendar_today,
                    readOnly: true,
                    onTap: onPickDate,
                  ),
                ),
                const SizedBox(height: 10),
                buildInput(
                  TextInputConfig(
                    amountCtrl,
                    t(language, 'agroBillAmount'),
                    Icons.currency_rupee,
                    number: true,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: paymentStatus,
                  decoration: InputDecoration(
                    labelText: t(language, 'agroPaymentStatus'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text(t(language, 'agroPending')),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text(t(language, 'agroCompleted')),
                    ),
                  ],
                  onChanged: onPaymentStatusChanged,
                ),
                const SizedBox(height: 10),
                buildInput(
                  TextInputConfig(
                    noteCtrl,
                    t(language, 'agroBillNote'),
                    Icons.notes,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onPickBillPhoto,
                      icon: const Icon(Icons.photo_library),
                      label: Text(t(language, 'agroPickBillPhoto')),
                    ),
                    if (billPhotoName != null) Chip(label: Text(billPhotoName!)),
                    if (billPhotoName != null ||
                        billPhotoBytes != null ||
                        billPhotoPath != null)
                      TextButton(
                        onPressed: onClearBillPhoto,
                        child: Text(t(language, 'agroRemoveBillPhoto')),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: savingBill ? null : onSaveBill,
                        child: Text(
                          editingBillId == null
                              ? t(language, 'agroSaveBill')
                              : t(language, 'agroUpdateBill'),
                        ),
                      ),
                    ),
                    if (editingBillId != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onResetBillForm,
                        child: Text(t(language, 'cancelButton')),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
