class EngineeringProject {
  final String id;
  final String name;
  final String client;
  final String location;
  final String status; // 'Active', 'Completed', 'On-Hold'

  const EngineeringProject({
    required this.id,
    required this.name,
    required this.client,
    required this.location,
    required this.status,
  });
}

class AppProjects {
  static const List<EngineeringProject> defaultProjects = [
    EngineeringProject(id: 'PRJ-001', name: 'Siemens UAE Automation', client: 'Siemens Middle East', location: 'UAE', status: 'Active'),
    EngineeringProject(id: 'PRJ-002', name: 'FCB Senegal Cement Plant', client: 'FCB Fives', location: 'Senegal', status: 'Active'),
    EngineeringProject(id: 'PRJ-003', name: 'SCC - ABB Contactor Upgrade', client: 'Suez Cement Co.', location: 'Egypt', status: 'Active'),
    EngineeringProject(id: 'PRJ-004', name: 'EWEKORO PCS Upgrade', client: 'Lafarge Africa', location: 'Nigeria', status: 'Active'),
    EngineeringProject(id: 'PRJ-005', name: 'Jubail PCS Upgrade', client: 'Marafiq / SABIC', location: 'Saudi Arabia', status: 'Active'),
    EngineeringProject(id: 'PRJ-006', name: 'Sinai Engineering Expansion', client: 'Sinai Cement', location: 'Egypt', status: 'Completed'),
    EngineeringProject(id: 'PRJ-007', name: 'Slag Mill KSA Drive Integration', client: 'Yamama Cement', location: 'Saudi Arabia', status: 'Active'),
    EngineeringProject(id: 'PRJ-008', name: 'Silo Arabian Cement Commissioning', client: 'Arabian Cement Co.', location: 'Egypt', status: 'Completed'),
    EngineeringProject(id: 'PRJ-000', name: 'General HQ / Internal Overhead', client: 'IMH Internal', location: 'Main Office', status: 'Active'),
  ];

  static List<String> getProjectNames() {
    return defaultProjects.map((e) => e.name).toList();
  }
}
