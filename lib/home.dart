import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_firebase_mastery_2023/core/utils/app_logger.dart';
import 'package:flutter_firebase_mastery_2023/notes/notes.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _editController = TextEditingController();
  List<QueryDocumentSnapshot> _categories = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        AppLogger.i('User signed out — redirecting to login');
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    AppLogger.d('Home page disposed');
    super.dispose();
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .delete();
      AppLogger.i('Category deleted: $categoryId');
    } catch (e, st) {
      AppLogger.e('Failed to delete category', e, st);
    }
  }

  Future<void> _renameCategory(String categoryId, String currentName) async {
    _editController.text = currentName;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rename Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _editController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'New name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      btnOkText: 'Save',
      btnOkOnPress: () async {
        final newName = _editController.text.trim();
        if (newName.isEmpty) return;
        try {
          await FirebaseFirestore.instance
              .collection('categories')
              .doc(categoryId)
              .update({'name': newName});
          AppLogger.i('Category renamed: $categoryId → "$newName"');
        } catch (e, st) {
          AppLogger.e('Failed to rename category', e, st);
        }
      },
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                context: context,
                delegate: CategorySearchDelegate(categories: _categories),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addCategoryFab',
        onPressed: () => Navigator.pushNamed(context, 'addCategory'),
        icon: const Icon(Icons.create_new_folder_rounded),
        label: const Text('New Category'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (val) => setState(() => _currentIndex = val),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('id', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            AppLogger.e('Categories stream error', snapshot.error);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Something went wrong', style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          _categories = snapshot.data?.docs ?? [];

          if (_categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text('No categories yet', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to create your first category.',
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
                crossAxisCount: 3,
                childAspectRatio: 0.95,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final name = category['name'] as String? ?? 'Unnamed';
                return _CategoryCard(
                  name: name,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Notes(categoryId: category.id),
                    ));
                  },
                  onDelete: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: 'Delete Category',
                      desc: 'Are you sure you want to delete "$name"?',
                      btnOkText: 'Delete',
                      btnOkOnPress: () => _deleteCategory(category.id),
                      btnCancelOnPress: () {},
                    ).show();
                  },
                  onRename: () => _renameCategory(category.id, name),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Category Card ──────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _CategoryCard({
    required this.name,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onRename,
                    child: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Image.asset('images/folder.png', width: 44, height: 44, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search Delegate ────────────────────────────────────────────────────────────

class CategorySearchDelegate extends SearchDelegate {
  final List<QueryDocumentSnapshot> categories;
  CategorySearchDelegate({required this.categories});

  List<QueryDocumentSnapshot> get _filtered => categories
      .where((c) => (c['name'] as String).toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close),
        ),
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
          query.isEmpty ? 'Search for a category' : 'No results found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final item = _filtered[index];
        return ListTile(
          leading: const Icon(Icons.folder_rounded),
          title: Text(item['name'] as String),
          onTap: () {
            close(context, null);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => Notes(categoryId: item.id)),
            );
          },
        );
      },
    );
  }
}
