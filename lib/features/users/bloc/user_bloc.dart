import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../models/user_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/local_persistence_service.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SwitchActiveUser>(_onSwitchActiveUser);
    on<AddUser>(_onAddUser);
    on<UpdateUserPermissions>(_onUpdateUserPermissions);
    on<DeleteUser>(_onDeleteUser);
    on<SyncUsersInternal>(_onSyncUsersInternal);
  }

  void _onSyncUsersInternal(SyncUsersInternal event, Emitter<UserState> emit) {
    emit(UserLoaded(users: event.users, activeUser: event.activeUser));
    LocalPersistenceService.saveUsers(event.users);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    List<UserModel>? loaded = await LocalPersistenceService.loadUsers();

    if (loaded == null || loaded.isEmpty) {
      final masterAdmin = const UserModel(
        id: 'USR-001',
        name: 'Eng. Emad',
        email: 'emad@imh-solutions.com',
        entityCode: 'EM',
        password: 'Imh@2026!Secured',
        permissions: UserPermission.adminPermissions,
      );

      loaded = [masterAdmin];
      await LocalPersistenceService.saveUsers(loaded);
    }

    final activeId = await LocalPersistenceService.loadActiveUserId();
    final activeUser = loaded.firstWhere(
      (u) => u.id == activeId,
      orElse: () => loaded!.first,
    );

    emit(UserLoaded(
      users: loaded,
      activeUser: activeUser,
    ));

    // Ensure all users are synced to Firebase Cloud Firestore
    for (final u in loaded) {
      FirebaseService.instance.saveUser(u);
    }

    // Listen to real-time Firebase users stream for multi-device sync
    FirebaseService.instance.getUsersStream().listen((remoteUsers) {
      if (remoteUsers.isNotEmpty && state is UserLoaded) {
        final currentState = state as UserLoaded;
        final mergedUsers = List<UserModel>.from(currentState.users);

        for (final remote in remoteUsers) {
          final idx = mergedUsers.indexWhere((u) => u.id == remote.id || u.email == remote.email);
          if (idx >= 0) {
            mergedUsers[idx] = remote;
          } else {
            mergedUsers.add(remote);
          }
        }

        final updatedActive = mergedUsers.firstWhere(
          (u) => u.id == currentState.activeUser.id,
          orElse: () => currentState.activeUser,
        );

        add(SyncUsersInternal(mergedUsers, updatedActive));
      }
    });
  }

  void _onSwitchActiveUser(SwitchActiveUser event, Emitter<UserState> emit) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final selected = currentState.users.firstWhere(
        (u) => u.id == event.userId,
        orElse: () => currentState.activeUser,
      );
      emit(currentState.copyWith(activeUser: selected));
      LocalPersistenceService.saveActiveUserId(selected.id);
    }
  }

  void _onAddUser(AddUser event, Emitter<UserState> emit) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final existingIndex = currentState.users.indexWhere((u) => u.id == event.user.id);

      List<UserModel> updatedUsers;
      if (existingIndex >= 0) {
        updatedUsers = List<UserModel>.from(currentState.users);
        updatedUsers[existingIndex] = event.user;
      } else {
        updatedUsers = List<UserModel>.from(currentState.users)..add(event.user);
      }

      final updatedActive = (currentState.activeUser.id == event.user.id)
          ? event.user
          : currentState.activeUser;

      emit(currentState.copyWith(
        users: updatedUsers,
        activeUser: updatedActive,
      ));

      // Local & Firebase sync
      LocalPersistenceService.saveUsers(updatedUsers);
      FirebaseService.instance.saveUser(event.user);
    }
  }

  void _onUpdateUserPermissions(UpdateUserPermissions event, Emitter<UserState> emit) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final updatedUsers = currentState.users.map((u) {
        if (u.id == event.userId) {
          return u.copyWith(
            permissions: event.permissions,
          );
        }
        return u;
      }).toList();

      final updatedActive = updatedUsers.firstWhere(
        (u) => u.id == currentState.activeUser.id,
        orElse: () => currentState.activeUser,
      );

      final targetUser = updatedUsers.firstWhere((u) => u.id == event.userId);

      emit(currentState.copyWith(
        users: updatedUsers,
        activeUser: updatedActive,
      ));

      LocalPersistenceService.saveUsers(updatedUsers);
      FirebaseService.instance.saveUser(targetUser);
    }
  }

  void _onDeleteUser(DeleteUser event, Emitter<UserState> emit) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      if (currentState.users.length <= 1) return; // Prevent deleting last user
      final updatedUsers = currentState.users.where((u) => u.id != event.userId).toList();
      final newActive = updatedUsers.contains(currentState.activeUser)
          ? currentState.activeUser
          : updatedUsers.first;

      emit(currentState.copyWith(
        users: updatedUsers,
        activeUser: newActive,
      ));

      LocalPersistenceService.saveUsers(updatedUsers);
      FirebaseService.instance.deleteUser(event.userId);
    }
  }
}
