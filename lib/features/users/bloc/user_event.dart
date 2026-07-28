import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {}

class SwitchActiveUser extends UserEvent {
  final String userId;
  const SwitchActiveUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddUser extends UserEvent {
  final UserModel user;
  const AddUser(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUserPermissions extends UserEvent {
  final String userId;
  final UserPermission permissions;

  const UpdateUserPermissions({
    required this.userId,
    required this.permissions,
  });

  @override
  List<Object?> get props => [userId, permissions];
}

class DeleteUser extends UserEvent {
  final String userId;
  const DeleteUser(this.userId);

  @override
  List<Object?> get props => [userId];
}
