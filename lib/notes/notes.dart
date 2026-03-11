import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/component/textformfield.dart';
import 'package:flutter_firebase_mastery_2023/core/utils/app_logger.dart';
import 'package:flutter_firebase_mastery_2023/notes/addnote.dart';
import 'package:flutter_firebase_mastery_2023/notes/viewnote.dart';

class Notes extends StatefulWidget {
  final String categoryId;
  const Notes({super.key, required this.categoryId});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editContentController = TextEditingController();
  List<QueryDocumentSnapshot> _notes = [];
  int _currentIndex = 0;

  @override
  void dispose() {
    _editTitleController.dispose();
    _editContentController.dispose();
    super.dispose();
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('notes')
          .doc(noteId)
          .delete();
      AppLogger.i('Note deleted: $noteId');
    } catch (e, st) {
      AppLogger.e('Failed to delete note', e, st);
    }
  }

  Future<void> _editNote(QueryDocumentSnapshot note) async {
    _editTitleController.text = note['title'] as String? ?? '';
    _editContentController.text = note['content'] as String? ?? '';
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Note', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            FormInput(
              label: 'Title',
              hintText: 'Enter note title',
              controller: _editTitleController,
            ),
            FormInput(
              label: 'Content',
              hintText: 'Enter note content',
              controller: _editContentController,
              maxLines: 6,
            ),
          ],
        ),
      ),
      btnOkText: 'Save',
      btnOkOnPress: () async {
        final title = _editTitleController.text.trim();
        final content = _editContentController.text.trim();
        if (title.isEmpty) return;
        try {
          await FirebaseFirestore.instance
              .collection('categories')
              .doc(widget.categoryId)
              .collection('notes')
              .doc(note.id)
              .update({'title': title, 'content': content});
          AppLogger.i('Note updated: ${note.id}');
        } catch (e, st) {
          AppLogger.e('Failed to update note', e, st);
        }
      },
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: 'Search notes',
            onPressed: () => showSearch(
              context: context,
              delegate: NoteSearchDelegate(notes: _notes, categoryId: widget.categoryId),
            ),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addNoteFab',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddNoteScreen(categoryId: widget.categoryId)),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (val) => setState(() => _currentIndex = val),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('notes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            AppLogger.e('Notes stream error', snapshot.error);
            return Center(
              child: Text('Failed to load notes.', style: theme.textTheme.bodyLarge),
            );
          }

          _notes = snapshot.data?.docs ?? [];

          if (_notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text('No notes yet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first note.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _NoteCard(
                  title: note['title'] as String? ?? 'Untitled',
                  content: note['content'] as String? ?? '',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewNote(
                        categoryId: widget.categoryId,
                        noteId: note.id,
                      ),
                    ),
                  ),
                  onDelete: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: 'Delete Note',
                      desc: 'Are you sure you want to delete this note?',
                      btnOkText: 'Delete',
                      btnOkOnPress: () => _deleteNote(note.id),
                      btnCancelOnPress: () {},
                    ).show();
                  },
                  onEdit: () => _editNote(note),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Note Card ──────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _NoteCard({
    required this.title,
    required this.content,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onEdit,
                    child: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  content,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Note Search Delegate ───────────────────────────────────────────────────────

class NoteSearchDelegate extends SearchDelegate {
  final List<QueryDocumentSnapshot> notes;
  final String categoryId;

  NoteSearchDelegate({required this.notes, required this.categoryId});

  List<QueryDocumentSnapshot> get _filtered => notes
      .where((n) => (n['title'] as String? ?? '').toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(onPressed: () => query = '', icon: const Icon(Icons.close)),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty ? 'Search for a note' : 'No results found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final note = _filtered[index];
        return ListTile(
          leading: const Icon(Icons.sticky_note_2_outlined),
          title: Text(note['title'] as String? ?? 'Untitled'),
          subtitle: Text(
            note['content'] as String? ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, null);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ViewNote(categoryId: categoryId, noteId: note.id),
            ));
          },
        );
      },
    );
  }
}
