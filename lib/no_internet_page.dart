import 'package:flutter/material.dart';
import 'package:fuel_cal/services/theme_service.dart';

class NoInternetPage extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Container
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeService.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeService.neonColor.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: ThemeService.neonColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeService.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'It looks like you\'re offline. Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeService.mutedColor,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 56),

              // Retry Button
              Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: ThemeService.isDarkMode 
                        ? [const Color(0xFF109246), const Color(0xFF00FF88)]
                        : [const Color(0xFF00BFA5), const Color(0xFF00796B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeService.neonColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
