import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String id;
  final String name;
  final String client;
  final String location;
  final String status;
  final double budgetEgp;
  final double budgetEur;
  final double budgetUsd;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.client,
    required this.location,
    required this.status,
    this.budgetEgp = 0.0,
    this.budgetEur = 0.0,
    this.budgetUsd = 0.0,
  });

  @override
  List<Object?> get props => [id, name, client, location, status, budgetEgp, budgetEur, budgetUsd];
}
