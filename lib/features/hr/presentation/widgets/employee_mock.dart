/// Temporary presentation-only mock until the Employee cubit is wired up.
class EmployeeMock {
  final String name;
  final String jobTitle;
  final String department;

  const EmployeeMock({
    required this.name,
    required this.jobTitle,
    required this.department,
  });
}

const List<EmployeeMock> mockEmployees = [
  EmployeeMock(
    name: 'Amro Handousa',
    jobTitle: 'Marketing Manger',
    department: 'Marketing',
  ),
  EmployeeMock(name: 'Sara Ahmed', jobTitle: 'HR Specialist', department: 'HR'),
  EmployeeMock(
    name: 'Omar Khaled',
    jobTitle: 'Software Engineer',
    department: 'Engineering',
  ),
  EmployeeMock(
    name: 'Mona Adel',
    jobTitle: 'Marketing Manger',
    department: 'Marketing',
  ),
  EmployeeMock(
    name: 'Youssef Hassan',
    jobTitle: 'Accountant',
    department: 'Finance',
  ),
  EmployeeMock(name: 'Laila Samir', jobTitle: 'HR Manager', department: 'HR'),
  EmployeeMock(
    name: 'Karim Nabil',
    jobTitle: 'Product Designer',
    department: 'Design',
  ),
  EmployeeMock(
    name: 'Nour Ibrahim',
    jobTitle: 'Marketing Manger',
    department: 'Marketing',
  ),
  EmployeeMock(name: 'Hassan Ali', jobTitle: 'Sales Lead', department: 'Sales'),
  EmployeeMock(
    name: 'Dina Mostafa',
    jobTitle: 'Software Engineer',
    department: 'Engineering',
  ),
  EmployeeMock(
    name: 'Tarek Fathy',
    jobTitle: 'Accountant',
    department: 'Finance',
  ),
  EmployeeMock(
    name: 'Amira Zaki',
    jobTitle: 'Marketing Manger',
    department: 'Marketing',
  ),
];

const List<String> mockJobTitles = [
  'Marketing Manger',
  'HR Specialist',
  'HR Manager',
  'Software Engineer',
  'Accountant',
  'Product Designer',
  'Sales Lead',
];

const List<String> mockDepartments = [
  'Marketing',
  'HR',
  'Engineering',
  'Finance',
  'Design',
  'Sales',
];
