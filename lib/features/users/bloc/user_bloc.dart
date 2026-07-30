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
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    List<UserModel>? loaded = await LocalPersistenceService.loadUsers();

    if (loaded == null || loaded.isEmpty) {
      final emadAdmin = const UserModel(
        id: 'USR-001',
        name: 'Eng. Emad',
        email: 'emad@imh-solutions.com',
        entityCode: 'EM',
        password: 'Imh@2026!Secured',
        permissions: UserPermission.adminPermissions,
      );

      final mostafaAdmin = const UserModel(
        id: 'USR-002',
        name: 'Eng. Mostafa',
        email: 'mostafa@imh-solutions.com',
        entityCode: 'MO',
        password: 'Imh@2026!Secured',
        permissions: UserPermission.adminPermissions,
      );

      final badawyAdmin = const UserModel(
        id: 'USR-003',
        name: 'Eng. Badawy',
        email: 'badawy@imh-solutions.com',
        entityCode: 'BD',
        password: 'Imh@2026!Secured',
        permissions: UserPermission.adminPermissions,
      );

      final hanafyUser = const UserModel(
        id: 'USR-004',
        name: 'Hanafy',
        email: 'hanafy@imh-solutions.com',
        entityCode: 'HN',
        password: 'Imh@2026!Secured',
        permissions: UserPermission.standardUserPermissions,
      );

      loaded = [emadAdmin, mostafaAdmin, badawyAdmin, hanafyUser];
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

      emit(currentState.copyWith(
        users: updatedUsers,
        activeUser: updatedActive,
      ));

      LocalPersistenceService.saveUsers(updatedUsers);
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
    }
  }
}
