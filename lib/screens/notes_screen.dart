import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/notes_bloc.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';
import '../widgets/note_card.dart';
import '../widgets/note_dialog.dart';

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return BlocProvider(
      create: (context) => NotesBloc(
        notesRepository: NotesRepository(),
      )..add(FetchNotes()),
      child: _NotesScreenContent(user: user),
    );
  }
}

class _NotesScreenContent extends StatelessWidget {
  final User? user;

  const _NotesScreenContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded || state is NoteOperationLoading) {
            final notes = state is NotesLoaded ? state.notes : (state as NoteOperationLoading).notes;
            return _buildNotesList(context, notes);
          } else if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading notes'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NotesBloc>().add(FetchNotes()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Loading...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes) {
    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nothing here yet—tap ➕ to add a note.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onEdit: () => _showEditNoteDialog(context, note),
          onDelete: () => _showDeleteConfirmation(context, note),
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const NoteDialog(),
    );

    if (result != null) {
      context.read<NotesBloc>().add(
        AddNote(
          title: result['title']!,
          content: result['content']!,
        ),
      );
    }
  }

  void _showEditNoteDialog(BuildContext context, Note note) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => NoteDialog(note: note),
    );

    if (result != null) {
      context.read<NotesBloc>().add(
        UpdateNote(
          id: note.id,
          title: result['title']!,
          content: result['content']!,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${note.title.isEmpty ? 'Untitled' : note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('Delete button pressed for note: ${note.id}');
              Navigator.of(context).pop();
              context.read<NotesBloc>().add(DeleteNote(id: note.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 