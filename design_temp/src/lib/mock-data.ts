export const vehicles = [
  {
    id: "v1",
    name: "Toyota Innova",
    plate: "MH 12 AB 4521",
    fuelType: "Diesel",
    tankCapacity: 55,
    currentMileage: 18,
    bestMileage: 22,
    odo: 45220,
    image: "🚙",
  },
  {
    id: "v2",
    name: "Honda Activa",
    plate: "MH 14 XY 9087",
    fuelType: "Petrol",
    tankCapacity: 6,
    currentMileage: 48,
    bestMileage: 52,
    odo: 18430,
    image: "🛵",
  },
];

export const fuelLogs = [
  { id: "f1", date: "2026-05-15", station: "Indian Oil", odo: 45220, liters: 22, amount: 2350, mileage: 18, pricePerL: 106.8, paymentMethod: "UPI", fullTank: true },
  { id: "f2", date: "2026-05-08", station: "HP Petrol", odo: 44850, liters: 18, amount: 1920, mileage: 17.5, pricePerL: 106.6, paymentMethod: "Card", fullTank: true },
  { id: "f3", date: "2026-04-29", station: "Bharat Petroleum", odo: 44515, liters: 25, amount: 2680, mileage: 18.2, pricePerL: 107.2, paymentMethod: "Cash", fullTank: true },
  { id: "f4", date: "2026-04-20", station: "Indian Oil", odo: 44060, liters: 20, amount: 2140, mileage: 19.1, pricePerL: 107.0, paymentMethod: "UPI", fullTank: true },
  { id: "f5", date: "2026-04-10", station: "Shell", odo: 43680, liters: 24, amount: 2640, mileage: 17.8, pricePerL: 110.0, paymentMethod: "Card", fullTank: true },
  { id: "f6", date: "2026-04-01", station: "Indian Oil", odo: 43260, liters: 22, amount: 2330, mileage: 18.5, pricePerL: 105.9, paymentMethod: "UPI", fullTank: true },
];

export const expenses = [
  { id: "e1", category: "Fuel", title: "Indian Oil refill", amount: 2350, date: "2026-05-15" },
  { id: "e2", category: "Service", title: "Oil Change", amount: 1800, date: "2026-05-13" },
  { id: "e3", category: "Toll", title: "Mumbai-Pune Expressway", amount: 320, date: "2026-05-11" },
  { id: "e4", category: "Parking", title: "Phoenix Mall", amount: 80, date: "2026-05-10" },
  { id: "e5", category: "Insurance", title: "Renewal Premium", amount: 12400, date: "2026-04-28" },
  { id: "e6", category: "Washing", title: "Premium wash", amount: 250, date: "2026-04-22" },
  { id: "e7", category: "Tires", title: "Rotation", amount: 400, date: "2026-04-15" },
];

export const monthlyFuelUsage = [
  { month: "Dec", liters: 88, cost: 9300 },
  { month: "Jan", liters: 92, cost: 9750 },
  { month: "Feb", liters: 78, cost: 8200 },
  { month: "Mar", liters: 96, cost: 10180 },
  { month: "Apr", liters: 91, cost: 9850 },
  { month: "May", liters: 65, cost: 6920 },
];

export const mileageTrend = [
  { month: "Dec", mileage: 17.2 },
  { month: "Jan", mileage: 17.8 },
  { month: "Feb", mileage: 18.5 },
  { month: "Mar", mileage: 18.1 },
  { month: "Apr", mileage: 18.4 },
  { month: "May", mileage: 17.9 },
];

export const fuelPriceTrend = [
  { d: "Mon", petrol: 106.2, diesel: 94.1 },
  { d: "Tue", petrol: 106.4, diesel: 94.2 },
  { d: "Wed", petrol: 106.5, diesel: 94.0 },
  { d: "Thu", petrol: 106.8, diesel: 94.3 },
  { d: "Fri", petrol: 107.0, diesel: 94.5 },
  { d: "Sat", petrol: 106.9, diesel: 94.4 },
  { d: "Sun", petrol: 106.7, diesel: 94.3 },
];

export const expenseBreakdown = [
  { name: "Fuel", value: 6200 },
  { name: "Service", value: 2000 },
  { name: "Toll", value: 420 },
  { name: "Parking", value: 180 },
  { name: "Repairs", value: 600 },
];

export const recentActivity = [
  { id: "a1", title: "Fuel Added", subtitle: "Indian Oil • 22L", amount: "₹2,350", date: "Yesterday", type: "fuel" },
  { id: "a2", title: "Oil Change", subtitle: "Service Center", amount: "₹1,800", date: "2 days ago", type: "service" },
  { id: "a3", title: "Trip Completed", subtitle: "Mumbai → Pune (148 KM)", amount: "₹980", date: "3 days ago", type: "trip" },
  { id: "a4", title: "Toll Paid", subtitle: "Expressway", amount: "₹320", date: "4 days ago", type: "toll" },
];

export const alerts = [
  { id: "n1", title: "Oil Change Due", subtitle: "In 320 KM", severity: "warning" },
  { id: "n2", title: "Insurance Expiry", subtitle: "12 days left", severity: "danger" },
  { id: "n3", title: "PUC Reminder", subtitle: "Due next month", severity: "info" },
  { id: "n4", title: "Fuel Price Drop", subtitle: "Diesel ↓ ₹0.40/L near you", severity: "info" },
];

export const trips = [
  { id: "t1", from: "Home", to: "Office", distance: 28, fuel: 1.6, cost: 170, date: "Today" },
  { id: "t2", from: "Mumbai", to: "Pune", distance: 148, fuel: 8.2, cost: 880, date: "3 days ago" },
  { id: "t3", from: "Pune", to: "Lonavala", distance: 65, fuel: 3.7, cost: 395, date: "Last week" },
];
