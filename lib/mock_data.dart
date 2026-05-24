class Vehicle {
  final String id;
  final String name;
  final String plate;
  final String fuelType;
  final int tankCapacity;
  final double currentMileage;
  final double bestMileage;
  final int odo;
  final String image;

  const Vehicle({
    required this.id,
    required this.name,
    required this.plate,
    required this.fuelType,
    required this.tankCapacity,
    required this.currentMileage,
    required this.bestMileage,
    required this.odo,
    required this.image,
  });
}

class Alert {
  final String id;
  final String title;
  final String subtitle;
  final String severity;

  const Alert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.severity,
  });
}

class RecentActivity {
  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final String type;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class ExpenseBreakdown {
  final String name;
  final double value;

  const ExpenseBreakdown({required this.name, required this.value});
}

const List<Vehicle> mockVehicles = [
  Vehicle(
    id: "v1",
    name: "Toyota Innova",
    plate: "MH 12 AB 4521",
    fuelType: "Diesel",
    tankCapacity: 55,
    currentMileage: 18,
    bestMileage: 22,
    odo: 45220,
    image: "🚙",
  ),
  Vehicle(
    id: "v2",
    name: "Honda Activa",
    plate: "MH 14 XY 9087",
    fuelType: "Petrol",
    tankCapacity: 6,
    currentMileage: 48,
    bestMileage: 52,
    odo: 18430,
    image: "🛵",
  ),
];

const List<Alert> mockAlerts = [
  Alert(id: "n1", title: "Oil Change Due", subtitle: "In 320 KM", severity: "warning"),
  Alert(id: "n2", title: "Insurance Expiry", subtitle: "12 days left", severity: "danger"),
  Alert(id: "n3", title: "PUC Reminder", subtitle: "Due next month", severity: "info"),
  Alert(id: "n4", title: "Fuel Price Drop", subtitle: "Diesel ↓ ₹0.40/L near you", severity: "info"),
];

const List<RecentActivity> mockRecentActivity = [
  RecentActivity(id: "a1", title: "Fuel Added", subtitle: "Indian Oil • 22L", amount: "₹2,350", date: "Yesterday", type: "fuel"),
  RecentActivity(id: "a2", title: "Oil Change", subtitle: "Service Center", amount: "₹1,800", date: "2 days ago", type: "service"),
  RecentActivity(id: "a3", title: "Trip Completed", subtitle: "Mumbai → Pune (148 KM)", amount: "₹980", date: "3 days ago", type: "trip"),
  RecentActivity(id: "a4", title: "Toll Paid", subtitle: "Expressway", amount: "₹320", date: "4 days ago", type: "toll"),
];

const List<ExpenseBreakdown> mockExpenseBreakdown = [
  ExpenseBreakdown(name: "Fuel", value: 11925),
  ExpenseBreakdown(name: "Insurance", value: 7950),
  ExpenseBreakdown(name: "Toll", value: 2650),
  ExpenseBreakdown(name: "Parking", value: 1855),
  ExpenseBreakdown(name: "Washing", value: 1325),
  ExpenseBreakdown(name: "Tires", value: 795),
];

const List<Map<String, dynamic>> mockMonthlyFuelUsage = [
  {"month": "Dec", "liters": 88, "cost": 9300},
  {"month": "Jan", "liters": 92, "cost": 9750},
  {"month": "Feb", "liters": 78, "cost": 8200},
  {"month": "Mar", "liters": 96, "cost": 10180},
  {"month": "Apr", "liters": 91, "cost": 9850},
  {"month": "May", "liters": 65, "cost": 6920},
];

const List<Map<String, dynamic>> mockMileageTrend = [
  {"month": "Dec", "mileage": 17.2},
  {"month": "Jan", "mileage": 17.8},
  {"month": "Feb", "mileage": 18.5},
  {"month": "Mar", "mileage": 18.1},
  {"month": "Apr", "mileage": 18.4},
  {"month": "May", "mileage": 17.9},
];

const List<Map<String, dynamic>> mockFuelLogs = [
  {"id": "f1", "date": "2026-05-15", "station": "Indian Oil", "odo": 45220, "liters": 22, "amount": 2350, "mileage": 18, "pricePerL": 106.8, "paymentMethod": "UPI", "fullTank": true},
  {"id": "f2", "date": "2026-05-08", "station": "HP Petrol", "odo": 44850, "liters": 18, "amount": 1920, "mileage": 17.5, "pricePerL": 106.6, "paymentMethod": "Card", "fullTank": true},
  {"id": "f3", "date": "2026-04-29", "station": "Bharat Petroleum", "odo": 44515, "liters": 25, "amount": 2680, "mileage": 18.2, "pricePerL": 107.2, "paymentMethod": "Cash", "fullTank": true},
  {"id": "f4", "date": "2026-04-20", "station": "Indian Oil", "odo": 44060, "liters": 20, "amount": 2140, "mileage": 19.1, "pricePerL": 107.0, "paymentMethod": "UPI", "fullTank": true},
  {"id": "f5", "date": "2026-04-10", "station": "Shell", "odo": 43680, "liters": 24, "amount": 2640, "mileage": 17.8, "pricePerL": 110.0, "paymentMethod": "Card", "fullTank": true},
  {"id": "f6", "date": "2026-04-01", "station": "Indian Oil", "odo": 43260, "liters": 22, "amount": 2330, "mileage": 18.5, "pricePerL": 105.9, "paymentMethod": "UPI", "fullTank": true},
];
