import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;
  final UserModel activeUser;

  const UserLoaded({
    required this.users,
    required this.activeUser,
  });

  UserLoaded copyWith({
    List<UserModel>? users,
    UserModel? activeUser,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      activeUser: activeUser ?? this.activeUser,
    );
  }

  @override
  List<Object?> get props => [users, activeUser];
}
