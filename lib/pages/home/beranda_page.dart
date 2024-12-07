import 'package:apple_leaf/pages/history/scan_page.dart';
import 'package:apple_leaf/widgets/home/beranda_pindai_card.dart';
import 'package:apple_leaf/widgets/home/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:apple_leaf/configs/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../provider/auth_provider.dart';

class BerandaPage extends ConsumerWidget {
  final Function(int) updateIndex;
  const BerandaPage({super.key, required this.updateIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isEventEmpty = false;
    String? profilePicturePath;
    final authNotifier = ref.read(authProvider.notifier);
    final baseImageUrl = authNotifier.baseImageUrl;

    // Access the authentication state
    final authState = ref.watch(authProvider);
    final userData = authState.userData;

    // Get the user's name, or use a default if it's null
    final userName = userData?['name'] ?? 'Pengguna';
    profilePicturePath = userData?['profile_picture'];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => updateIndex(3),
              child: CircleAvatar(
                backgroundImage: profilePicturePath != null
                    ? NetworkImage('$baseImageUrl/storage/$profilePicturePath')
                    : const AssetImage('assets/images/icon.jpg'),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Halo,',
                  style: regularTS.copyWith(
                    fontSize: 14,
                    color: neutral400,
                  ),
                ),
                Text(
                  '$userName!',
                  style: mediumTS.copyWith(fontSize: 16, color: neutralBlack),
                ),
              ],
            )
          ],
        ),
      ),
      body: ListView(
        children: [
          // Pindai
          BerandaPindaiCard(
            // onScan: () {},
            onScan: () async {
              final image =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ScanPage(title: 'title', image: image);
                  },
                ));
              }
            },
          ),

          const SizedBox(height: 16),

          // Riwayat
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Riwayat terbaru',
              style: mediumTS.copyWith(fontSize: 20, color: neutralBlack),
            ),
          ),
          isEventEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(
                        'assets/icons/EmptyState.png',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Belum ada riwayat',
                      style: mediumTS.copyWith(fontSize: 14, color: neutral400),
                    )
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      CustomCard(
                        label: 'Scrab',
                        waktuScan: '1 hari yang lalu',
                        image: 'assets/images/daun_article.png',
                      ),
                      CustomCard(
                        label: 'Fire Blight',
                        waktuScan: '1 hari yang lalu',
                        image: 'assets/images/apple_card.png',
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
