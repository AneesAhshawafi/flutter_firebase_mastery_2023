import 'package:flutter/material.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Screen for adding a new note to a category.
class AddNoteScreen extends StatefulWidget {
  final String categoryId;
  const AddNoteScreen({super.key, required this.categoryId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _imageFile = File(image.path));
      }
    } catch (e, st) {
      AppLogger.w('Image picker failed', e, st);
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('notes')
          .add({
            'title': _titleController.text.trim(),
            'content': _contentController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      AppLogger.i('Note added to category ${widget.categoryId}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      AppLogger.e('Failed to add note', e, st);
      if (mounted) {
        AwesomeDialog(
          context: context,
          title: 'Error',
          body: const Text('Failed to save your note. Please try again.'),
          dialogType: DialogType.error,
        ).show();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                FormInput(
                  label: 'Note Title',
                  hintText: 'Enter note title',
                  controller: _titleController,
                ),
                const SizedBox(height: 12),
                FormInput(
                  label: 'Note Content',
                  hintText: 'Write your note here...',
                  controller: _contentController,
                  maxLines: 12,
                  minLines: 6,
                ),
                const SizedBox(height: 16),
                // Image picker section
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, height: 160, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_imageFile == null ? 'Attach image' : 'Change image'),
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      title: 'Choose Source',
                      dialogType: DialogType.noHeader,
                      animType: AnimType.bottomSlide,
                      btnOkOnPress: () {},
                      body: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt_outlined),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library_outlined),
                            title: const Text('Gallery'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ).show();
                  },
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ElevatedButton(
                  onPressed: _loading ? null : _saveNote,
                  child: Text(
                    'Save Note',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
