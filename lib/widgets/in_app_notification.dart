import 'package:flutter/material.dart';

class InAppNotification extends StatelessWidget {
  final String time;
  final String vehicleName;
  final String title;
  final String category;
  final String dueStatus;
  final String odometer;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const InAppNotification({
    Key? key,
    required this.time,
    required this.vehicleName,
    required this.title,
    required this.category,
    required this.dueStatus,
    required this.odometer,
    required this.onDismiss,
    required this.onTap,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String time,
    required String vehicleName,
    required String title,
    required String category,
    required String dueStatus,
    required String odometer,
    required VoidCallback onTap,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: InAppNotification(
                time: time,
                vehicleName: vehicleName,
                title: title,
                category: category,
                dueStatus: dueStatus,
                odometer: odometer,
                onDismiss: () => Navigator.pop(context),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24), // Dark grey
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Icon Placeholder
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_gas_station, color: Color(0xFF10B981), size: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(time, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            GestureDetector(
                              onTap: onDismiss,
                              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.directions_car, color: Colors.blueAccent, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                vehicleName,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.08), height: 1, thickness: 1),
            
            // Middle Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  const Icon(Icons.oil_barrel, color: Color(0xFFFFB020), size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.08), height: 1, thickness: 1),
            
            // Bottom Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFFFF4A4A), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    dueStatus,
                    style: const TextStyle(color: Color(0xFFFF4A4A), fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 18)),
                  ),
                  const Icon(Icons.speed, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    odometer,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
