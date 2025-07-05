import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note.dart';
import '../repositories/notes_repository.dart';

// Events
abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final String title;
  final String content;

  AddNote({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class UpdateNote extends NotesEvent {
  final String id;
  final String title;
  final String content;

  UpdateNote({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class DeleteNote extends NotesEvent {
  final String id;

  DeleteNote({required this.id});

  @override
  List<Object?> get props => [id];
}

// States
abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;

  NotesLoaded({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class NotesError extends NotesState {
  final String message;

  NotesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoteOperationLoading extends NotesState {
  final List<Note> notes;

  NoteOperationLoading({required this.notes});

  @override
  List<Object?> get props => [notes];
}

// BLoC
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _notesRepository;

  NotesBloc({required NotesRepository notesRepository})
      : _notesRepository = notesRepository,
        super(NotesInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _notesRepository.fetchNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(NoteOperationLoading(notes: currentState.notes));
      try {
        final newNote = Note.create(
          title: event.title,
          content: event.content,
        );
        await _notesRepository.addNote(newNote);
        final updatedNotes = await _notesRepository.fetchNotes();
        emit(NotesLoaded(notes: updatedNotes));
      } catch (e) {
        emit(NotesError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(NoteOperationLoading(notes: currentState.notes));
      try {
        await _notesRepository.updateNote(event.id, event.title, event.content);
        final updatedNotes = await _notesRepository.fetchNotes();
        emit(NotesLoaded(notes: updatedNotes));
      } catch (e) {
        emit(NotesError(message: e.toString()));
      }
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(NoteOperationLoading(notes: currentState.notes));
      try {
        print('Deleting note with ID: ${event.id}');
        await _notesRepository.deleteNote(event.id);
        print('Note deleted successfully');
        final updatedNotes = await _notesRepository.fetchNotes();
        print('Fetched ${updatedNotes.length} notes after deletion');
        emit(NotesLoaded(notes: updatedNotes));
      } catch (e) {
        print('Error deleting note: $e');
        emit(NotesError(message: e.toString()));
      }
    } else {
      print('Current state is not NotesLoaded: ${currentState.runtimeType}');
    }
  }
} 