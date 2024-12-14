import 'package:apple_leaf/configs/theme.dart';
import 'package:apple_leaf/provider/apple_service.dart';
import 'package:apple_leaf/provider/history_service.dart';
import 'package:apple_leaf/widgets/custom_appbar.dart';
import 'package:apple_leaf/widgets/custom_button.dart';
import 'package:apple_leaf/widgets/custom_dialog.dart';
import 'package:apple_leaf/widgets/custom_textfield.dart';
import 'package:apple_leaf/widgets/history/list_penyakit_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_leaf/provider/auth_provider.dart';

class ListPenyakitPage extends ConsumerWidget {
  final String label;
  final String appleId;

  const ListPenyakitPage({
    super.key,
    required this.label,
    required this.appleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    final historyState = ref.watch(appleHistoryProvider(appleId));

    return Scaffold(
      backgroundColor: neutralWhite,
      appBar: customAppBar(
        context,
        title: label,
        actions: [
          IconButton(
            onPressed: () => handleDeleteApel(context, ref),
            icon: const Icon(IconsaxPlusLinear.trash),
            color: redBase,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: CustomTextField(
              prefixIcon: IconsaxPlusLinear.search_normal_1,
              hint: 'Cari riwayat',
              controller: searchController,
            ),
          ),
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyState.error != null
                    ? Center(child: Text(historyState.error!))
                    : historyState.histories.isEmpty
                        ? const Center(child: Text('Belum ada riwayat'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: historyState.histories.length,
                            itemBuilder: (context, index) {
                              final history = historyState.histories[index];
                              final historyData =
                                  history['history'] as Map<String, dynamic>;
                              final diseaseInfo = historyData['disease_info']
                                  as Map<String, dynamic>;

                              return ListPenyakitCard(
                                image: historyData['scan_image_path'] ??
                                    'assets/images/daun_article.png',
                                title: diseaseInfo['category'] ??
                                    'Unknown Disease',
                                date: historyData['scan_date'] ?? '-',
                                description: diseaseInfo['description'] ?? '-',
                                symptom: diseaseInfo['symptoms'] ?? '-',
                                solution: diseaseInfo['treatment'] ?? '-',
                              );
                            },
                          ),
          )
        ],
      ),
    );
  }

  Future<void> handleDeleteApel(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Hapus riwayat ini?',
        subtitle:
            'Semua informasi yang terkait dengan diagnosis ini akan hilang.',
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  isDialogButton: true,
                  text: 'Hapus',
                  backgroundColor: redBase,
                  onTap: () async {
                    final appleService = ref.read(appleServiceProvider);
                    final userId = ref.read(authProvider).userData?['id'].toString();
                    
                    await appleService.deleteApple(appleId);
                    
                    // Refresh apple list after deletion
                    if (userId != null) {
                      ref.read(appleProvider(userId).notifier).fetchApples();
                    }
                    
                    // Close dialog
                    Navigator.of(context).pop();
                    // Go back to previous page
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: CustomButton(
                  isDialogButton: true,
                  text: 'Batal',
                  backgroundColor: neutralWhite,
                  borderColor: neutral100,
                  textColor: neutralBlack,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
