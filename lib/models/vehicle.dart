class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final double efficiency; // KM/L
  final String iconEmoji;
  final String fuelType;
  final String? logoUrl;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.efficiency,
    required this.iconEmoji,
    this.fuelType = 'Petrol',
    this.logoUrl,
  });

  String get displayName => '$make $model';
}

final List<Vehicle> defaultVehicles = [
  const Vehicle(id: '1', make: 'Tata', model: 'Nexon', year: 2024, efficiency: 17.5, iconEmoji: '🚗', fuelType: 'Petrol', logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Tata_logo.svg/512px-Tata_logo.svg.png'),
  const Vehicle(id: '2', make: 'Hyundai', model: 'Creta', year: 2023, efficiency: 16.8, iconEmoji: '🚘', fuelType: 'Diesel', logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Hyundai_Motor_Company_logo.svg/120px-Hyundai_Motor_Company_logo.svg.png'),
  const Vehicle(id: '3', make: 'Kia', model: 'Seltos', year: 2022, efficiency: 16.5, iconEmoji: '🚙', fuelType: 'Petrol', logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/KIA_logo2.svg/120px-KIA_logo2.svg.png'),
  const Vehicle(id: '4', make: 'Maruti Suzuki', model: 'Brezza', year: 2023, efficiency: 19.8, iconEmoji: '🏎️', fuelType: 'Petrol', logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Suzuki_logo_2.svg/120px-Suzuki_logo_2.svg.png'),
  const Vehicle(id: '5', make: 'Toyota', model: 'Innova Hycross', year: 2023, efficiency: 21.1, iconEmoji: '🚐', fuelType: 'Petrol', logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Toyota_carlogo.svg/120px-Toyota_carlogo.svg.png'),
];
