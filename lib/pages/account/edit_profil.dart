import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apple_leaf/configs/theme.dart';
import 'package:apple_leaf/widgets/custom_appbar.dart';
import 'package:apple_leaf/widgets/custom_button.dart';
import 'package:apple_leaf/widgets/custom_textfield.dart';
import '../../provider/auth_provider.dart';

class EditProfil extends ConsumerStatefulWidget {
  const EditProfil({super.key});

  @override
  ConsumerState<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends ConsumerState<EditProfil> {
  late TextEditingController namaController;
  late TextEditingController emailController;
  String? profilePicturePath;

  Uint8List? _imageBytes;
  XFile? _pickedFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    final userData = authState.userData;

    namaController = TextEditingController(text: userData?['name'] ?? '');
    emailController = TextEditingController(text: userData?['email'] ?? '');
    profilePicturePath = userData?['profile_picture'];
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> handleSave() async {
    final name = namaController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Email tidak boleh kosong.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authNotifier = ref.read(authProvider.notifier);

    // Update nama dan email
    final errorMessage = await authNotifier.updateProfile(
      name: name,
      email: email,
    );

    if (errorMessage != null) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      return;
    }

    // Tampilkan pesan sukses untuk update profil
    if (mounted && _pickedFile == null) { // Hanya tampilkan jika tidak ada foto yang diupload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }

    // Jika ada gambar yang dipilih, upload gambarnya
    if (_pickedFile != null) {
      final uploadError = await authNotifier.uploadPhotoProfile(
        _imageBytes!,
        _pickedFile!.name,
      );
      if (uploadError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(uploadError)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final baseImageUrl = authNotifier.baseImageUrl;

    return Scaffold(
      appBar: customAppBar(context, title: 'Ubah Profil'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: neutral100,
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : (profilePicturePath != null
                              ? NetworkImage(
                                  '$baseImageUrl/storage/$profilePicturePath')
                              : const AssetImage('assets/images/icon.jpg'))
                          as ImageProvider,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: green700,
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Input untuk Nama
          CustomForm(
            title: 'Nama',
            hint: 'John Doe',
            controller: namaController,
          ),

          const SizedBox(height: 16),

          // Input untuk Email
          CustomForm(
            title: 'Email',
            hint: 'johndoe@gmail.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 24),

          // Tombol Simpan
          CustomButton(
            text: isLoading ? 'Menyimpan...' : 'Simpan',
            onTap: isLoading ? null : handleSave,
          ),

          // Show error message if any
          if (authState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                authState.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
