import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _firestore.collection('users').doc(_userId).collection('notes');

  // Fetch all notes for the current user
  Future<List<Note>> fetchNotes() async {
    try {
      final querySnapshot = await _notesCollection
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Note.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Add a new note
  Future<Note> addNote(Note note) async {
    try {
      final docRef = await _notesCollection.add(note.toMap());
      final doc = await docRef.get();
      return Note.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // Update an existing note
  Future<Note> updateNote(String id, String title, String content) async {
    try {
      final updatedNote = {
        'title': title,
        'content': content,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _notesCollection.doc(id).update(updatedNote);
      
      final doc = await _notesCollection.doc(id).get();
      return Note.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await _notesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
} 