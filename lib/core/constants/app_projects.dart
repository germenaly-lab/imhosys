class EngineeringProject {
  final String id;
  final String name;
  final String client;
  final String location;
  final String status; // 'Active', 'Completed', 'On-Hold', 'Planned'
  final double estimatedCostEgp;
  final double estimatedCostEur;
  final double estimatedCostUsd;
  final double contractRevenueEgp;
  final double contractRevenueEur;
  final double contractRevenueUsd;
  final String notes;

  const EngineeringProject({
    required this.id,
    required this.name,
    required this.client,
    required this.location,
    required this.status,
    this.estimatedCostEgp = 0.0,
    this.estimatedCostEur = 0.0,
    this.estimatedCostUsd = 0.0,
    this.contractRevenueEgp = 0.0,
    this.contractRevenueEur = 0.0,
    this.contractRevenueUsd = 0.0,
    this.notes = '',
  });

  EngineeringProject copyWith({
    String? id,
    String? name,
    String? client,
    String? location,
    String? status,
    double? estimatedCostEgp,
    double? estimatedCostEur,
    double? estimatedCostUsd,
    double? contractRevenueEgp,
    double? contractRevenueEur,
    double? contractRevenueUsd,
    String? notes,
  }) {
    return EngineeringProject(
      id: id ?? this.id,
      name: name ?? this.name,
      client: client ?? this.client,
      location: location ?? this.location,
      status: status ?? this.status,
      estimatedCostEgp: estimatedCostEgp ?? this.estimatedCostEgp,
      estimatedCostEur: estimatedCostEur ?? this.estimatedCostEur,
      estimatedCostUsd: estimatedCostUsd ?? this.estimatedCostUsd,
      contractRevenueEgp: contractRevenueEgp ?? this.contractRevenueEgp,
      contractRevenueEur: contractRevenueEur ?? this.contractRevenueEur,
      contractRevenueUsd: contractRevenueUsd ?? this.contractRevenueUsd,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'client': client,
        'location': location,
        'status': status,
        'estimatedCostEgp': estimatedCostEgp,
        'estimatedCostEur': estimatedCostEur,
        'estimatedCostUsd': estimatedCostUsd,
        'contractRevenueEgp': contractRevenueEgp,
        'contractRevenueEur': contractRevenueEur,
        'contractRevenueUsd': contractRevenueUsd,
        'notes': notes,
      };

  factory EngineeringProject.fromJson(Map<String, dynamic> json) => EngineeringProject(
        id: json['id'] as String,
        name: json['name'] as String,
        client: json['client'] as String? ?? 'Client N/A',
        location: json['location'] as String? ?? 'Egypt',
        status: json['status'] as String? ?? 'Active',
        estimatedCostEgp: (json['estimatedCostEgp'] as num?)?.toDouble() ?? 0.0,
        estimatedCostEur: (json['estimatedCostEur'] as num?)?.toDouble() ?? 0.0,
        estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble() ?? 0.0,
        contractRevenueEgp: (json['contractRevenueEgp'] as num?)?.toDouble() ?? 0.0,
        contractRevenueEur: (json['contractRevenueEur'] as num?)?.toDouble() ?? 0.0,
        contractRevenueUsd: (json['contractRevenueUsd'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );
}

class AppProjects {
  static const List<EngineeringProject> defaultProjects = [
    EngineeringProject(id: 'PRJ-001', name: 'Siemens UAE Automation', client: 'Siemens Middle East', location: 'UAE', status: 'Active', contractRevenueEur: 450000.0, estimatedCostEur: 310000.0),
    EngineeringProject(id: 'PRJ-002', name: 'FCB Senegal Cement Plant', client: 'FCB Fives', location: 'Senegal', status: 'Active', contractRevenueEur: 890000.0, estimatedCostEur: 620000.0),
    EngineeringProject(id: 'PRJ-003', name: 'SCC - ABB Contactor Upgrade', client: 'Suez Cement Co.', location: 'Egypt', status: 'Active', contractRevenueEgp: 14500000.0, estimatedCostEgp: 9800000.0),
    EngineeringProject(id: 'PRJ-004', name: 'EWEKORO PCS Upgrade', client: 'Lafarge Africa', location: 'Nigeria', status: 'Active', contractRevenueUsd: 520000.0, estimatedCostUsd: 380000.0),
    EngineeringProject(id: 'PRJ-005', name: 'Jubail PCS Upgrade', client: 'Marafiq / SABIC', location: 'Saudi Arabia', status: 'Active', contractRevenueUsd: 780000.0, estimatedCostUsd: 510000.0),
    EngineeringProject(id: 'PRJ-006', name: 'Sinai Engineering Expansion', client: 'Sinai Cement', location: 'Egypt', status: 'Completed', contractRevenueEgp: 22000000.0, estimatedCostEgp: 17500000.0),
    EngineeringProject(id: 'PRJ-007', name: 'Slag Mill KSA Drive Integration', client: 'Yamama Cement', location: 'Saudi Arabia', status: 'Active', contractRevenueUsd: 340000.0, estimatedCostUsd: 220000.0),
    EngineeringProject(id: 'PRJ-008', name: 'Silo Arabian Cement Commissioning', client: 'Arabian Cement Co.', location: 'Egypt', status: 'Completed', contractRevenueEgp: 8500000.0, estimatedCostEgp: 6100000.0),
    EngineeringProject(id: 'PRJ-000', name: 'General HQ / Internal Overhead', client: 'IMH Internal', location: 'Main Office', status: 'Active'),
  ];

  static List<String> getProjectNames([List<EngineeringProject>? list]) {
    final target = list ?? defaultProjects;
    return target.map((e) => e.name).toList();
  }
}
