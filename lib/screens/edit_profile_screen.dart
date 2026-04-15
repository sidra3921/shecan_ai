import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';
import '../services/supabase_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  final _authService = SupabaseAuthService();
  final _dbService = SupabaseDatabaseService();
  final _storageService = SupabaseStorageService();

  bool _isLoading = true;
  bool _isSaving = false;

  File? _pickedImageFile;
  Uint8List? _pickedImageBytes;
  String _currentPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await _dbService.getUser(userId);
      if (user != null) {
        _fillControllers(user);
      } else {
        final authUser = _authService.currentUser;
        _nameController.text = authUser?.userMetadata?['display_name'] as String? ??
            authUser?.email?.split('@').first ??
            '';
        _phoneController.text = authUser?.phone ?? '';
      }
    } catch (_) {
      // Keep defaults if fetch fails.
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fillControllers(UserModel user) {
    _nameController.text = user.displayName;
    _phoneController.text = user.phone;
    _bioController.text = user.bio;
    _skillsController.text = user.skills.join(', ');
    _hourlyRateController.text = user.hourlyRate > 0 ? user.hourlyRate.toStringAsFixed(0) : '';
    _currentPhotoUrl = user.photoURL;
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageFile = null;
      });
      return;
    }

    setState(() {
      _pickedImageFile = File(picked.path);
      _pickedImageBytes = null;
    });
  }

  List<String> _parseSkills(String rawSkills) {
    return rawSkills
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String photoUrl = _currentPhotoUrl;
      String? uploadWarning;
      if (_pickedImageBytes != null) {
        try {
          photoUrl = await _storageService.uploadProfilePhotoBytes(
            userId: userId,
            bytes: _pickedImageBytes!,
          );
        } catch (e) {
          uploadWarning = 'Profile photo upload failed. Other changes were saved.';
          debugPrint('Profile photo upload failed: $e');
        }
      } else if (_pickedImageFile != null) {
        try {
          photoUrl = await _storageService.uploadProfilePhoto(
            userId: userId,
            imageFile: _pickedImageFile!,
          );
        } catch (e) {
          uploadWarning = 'Profile photo upload failed. Other changes were saved.';
          debugPrint('Profile photo upload failed: $e');
        }
      }

      final hourlyRate = double.tryParse(_hourlyRateController.text.trim()) ?? 0.0;
      final skills = _parseSkills(_skillsController.text);

      await _dbService.updateUser(userId, {
        'display_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'skills': skills,
        'hourly_rate': hourlyRate,
        'photo_url': photoUrl,
      });

      await _authService.updateUserProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        photoURL: photoUrl,
      );

      if (!mounted) {
        return;
      }
      final message = uploadWarning ?? 'Profile saved successfully.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: AppColors.pinkBackground,
                              backgroundImage: _pickedImageBytes != null
                                  ? MemoryImage(_pickedImageBytes!) as ImageProvider
                                  : _pickedImageFile != null
                                      ? FileImage(_pickedImageFile!)
                                      : _currentPhotoUrl.isNotEmpty
                                          ? NetworkImage(_currentPhotoUrl)
                                          : null,
                              child: _pickedImageBytes == null &&
                                      _pickedImageFile == null &&
                                      _currentPhotoUrl.isEmpty
                                  ? const Icon(Icons.person, size: 56, color: AppColors.primary)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.short_text),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          labelText: 'Skills (comma-separated)',
                          prefixIcon: Icon(Icons.auto_awesome_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hourlyRateController,
                        decoration: const InputDecoration(
                          labelText: 'Hourly rate (PKR)',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
