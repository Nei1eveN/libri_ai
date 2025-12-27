import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:libri_ai/src/features/books/data/book_repository_provider.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();
  final _genreController = TextEditingController();
  final _pagesController = TextEditingController();
  final _yearController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _publisherController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    _genreController.dispose();
    _pagesController.dispose();
    _yearController.dispose();
    _coverUrlController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Call the Repository (which calls the Edge Function)
      await ref.read(bookRepositoryProvider).addNewBook(
            title: _titleController.text.trim(),
            authors: [
              _authorController.text.trim(),
            ], // Simple single author for now
            description: _descController.text.trim(),
            genre: _genreController.text.trim(),
            pageCount: int.tryParse(_pagesController.text) ?? 0,
            publishedDate: _yearController.text.isNotEmpty
                ? "${_yearController.text}-01-01"
                : null,
            thumbnailUrl: _coverUrlController.text.isNotEmpty
                ? _coverUrlController.text.trim()
                : null,
            publisher: _publisherController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added with AI Embeddings! 🚀')),
        );
        context.pop(); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Book")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Contribute to the Library",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "The AI will automatically generate vectors for this book.",
                style: TextStyle(color: Colors.grey),
              ),
              const Gap(24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("Book Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const Gap(16),

              // Author
              TextFormField(
                controller: _authorController,
                decoration: _inputDecoration("Author"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const Gap(16),

              // Row for Genre & Pages, Year
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _genreController,
                      decoration: _inputDecoration("Genre (e.g. Sci-Fi)"),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: TextFormField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Page Count"),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Year"),
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Publisher
              TextFormField(
                controller: _publisherController,
                decoration: _inputDecoration("Publisher"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const Gap(16),

              TextFormField(
                controller: _coverUrlController,
                decoration:
                    _inputDecoration("Cover Image URL (Optional)").copyWith(
                  suffixIcon: const Icon(Icons.link, color: Colors.grey),
                  helperText:
                      "Paste a link to an image (e.g. from Amazon/Goodreads)",
                ),
              ),
              const Gap(16),

              // Description (Crucial for AI)
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: _inputDecoration("Description").copyWith(
                  alignLabelWithHint: true,
                  hintText:
                      "Enter a detailed description so the AI can match vibes accurately...",
                ),
                validator: (v) =>
                    v!.length < 20 ? "Description too short for AI" : null,
              ),
              const Gap(32),

              // Submit Button
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.all(16),
                ),
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label:
                    Text(_isSubmitting ? "Generating Vectors..." : "Add Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
