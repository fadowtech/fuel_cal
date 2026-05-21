import 'package:flutter/material.dart';
import 'package:fuel_cal/services/currency_service.dart';

class CurrencySelectionPage extends StatefulWidget {
  final VoidCallback onCurrencySelected;

  const CurrencySelectionPage({super.key, required this.onCurrencySelected});

  @override
  State<CurrencySelectionPage> createState() => _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends State<CurrencySelectionPage> {
  String? _selectedCurrency;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    String? currency = await CurrencyService.getCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _saveAndNavigate() async {
    if (_selectedCurrency != null) {
      await CurrencyService.saveCurrency(_selectedCurrency!);
      widget.onCurrencySelected();
    } else {
      setState(() {
        _errorMessage = 'Please select a currency to proceed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background deep dark gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF07090C),
                  Color(0xFF0D1117),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Wave drawings in the background
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141921),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF00FF88),
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Header Title
                  const Text(
                    'Select Your Currency',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Choose the currency you want to use for your transactions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8E92A2),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // App Icon Badge centered
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF11141B),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Selection Card Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E121A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Choose your preferred currency',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...CurrencyService.supportedCurrencies.entries.map((entry) {
                          String code = entry.key;
                          String name = entry.value;
                          String symbol = CurrencyService.getCurrencySymbol(code);
                          return _buildCurrencyOption(
                            code: code,
                            name: name,
                            symbol: symbol,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Select & Continue Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF109246), Color(0xFF00FF88)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveAndNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF109246),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Select & Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Security lock / shield icon and text
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00FF88).withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.security_outlined,
                            color: Color(0xFF00FF88),
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your preference is secure with us.',
                          style: TextStyle(
                            color: Color(0xFF6E7282),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption({
    required String code,
    required String name,
    required String symbol,
  }) {
    final isSelected = _selectedCurrency == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrency = code;
          _errorMessage = '';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10141D) : const Color(0xFF0A0C10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00FF88).withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00FF88)
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00FF88),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Currency symbol badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF00FF88).withOpacity(0.12)
                    : const Color(0xFF121620),
              ),
              alignment: Alignment.center,
              child: Text(
                symbol,
                style: const TextStyle(
                  color: Color(0xFF00FF88),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8E92A2),
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // Chevron indicator
            Icon(
              Icons.chevron_right_rounded,
              color: isSelected ? const Color(0xFF00FF88) : Colors.white.withOpacity(0.2),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Background Wave Painter to match top waves
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Wave 1 (Upper/Left)
    final Paint paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00FF88).withOpacity(0.12),
          const Color(0xFF00FF88).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path1 = Path();
    path1.moveTo(0, size.height * 0.22);
    path1.cubicTo(
      size.width * 0.25,
      size.height * 0.16,
      size.width * 0.45,
      size.height * 0.32,
      size.width,
      size.height * 0.26,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Stroke 1
    final Paint strokePaint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00FF88).withOpacity(0.6),
          const Color(0xFF00D99A).withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Path strokePath1 = Path();
    strokePath1.moveTo(0, size.height * 0.22);
    strokePath1.cubicTo(
      size.width * 0.25,
      size.height * 0.16,
      size.width * 0.45,
      size.height * 0.32,
      size.width,
      size.height * 0.26,
    );
    canvas.drawPath(strokePath1, strokePaint1);

    // Wave 2 (Lower/Right)
    final Paint paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00D99A).withOpacity(0.08),
          const Color(0xFF00D99A).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path2 = Path();
    path2.moveTo(0, size.height * 0.28);
    path2.cubicTo(
      size.width * 0.35,
      size.height * 0.35,
      size.width * 0.70,
      size.height * 0.20,
      size.width,
      size.height * 0.24,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Stroke 2
    final Paint strokePaint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00FF88).withOpacity(0.08),
          const Color(0xFF00D99A).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.25))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path strokePath2 = Path();
    strokePath2.moveTo(0, size.height * 0.28);
    strokePath2.cubicTo(
      size.width * 0.35,
      size.height * 0.35,
      size.width * 0.70,
      size.height * 0.20,
      size.width,
      size.height * 0.24,
    );
    canvas.drawPath(strokePath2, strokePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}