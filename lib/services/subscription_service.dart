import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static const _googleApiKey = 'goog_vgzdwHZfhgFqwwiaqLKfRoCHbKs';
  static const _appleApiKey = 'appl_YOUR_API_KEY_HERE';

  static Future<void> init() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else {
        return; // Unsupported platform
      }
      
      await Purchases.configure(configuration);
    } catch (e) {
      print('Error initializing RevenueCat: $e');
    }
  }

  static final ValueNotifier<int> currentPlanNotifier = ValueNotifier<int>(0);

  static Future<void> login(String appUserId) async {
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      print('RevenueCat login error: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      print('RevenueCat logout error: $e');
    }
  }

  // 0: Free, 1: Remove Ads, 2: Plus, 3: Pro
  static Future<int> getCurrentPlan() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      int plan = 0;
      if (customerInfo.entitlements.all['pro']?.isActive == true) {
        plan = 3;
      } else if (customerInfo.entitlements.all['plus']?.isActive == true) {
        plan = 2;
      } else if (customerInfo.entitlements.all['remove_ads']?.isActive == true) {
        plan = 1;
      }
      currentPlanNotifier.value = plan;
      return plan;
    } catch (e) {
      return 0;
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      GoogleProductChangeInfo? changeInfo;
      if (Platform.isAndroid) {
        final customerInfo = await Purchases.getCustomerInfo();
        if (customerInfo.activeSubscriptions.isNotEmpty) {
          final oldProductIdentifier = customerInfo.activeSubscriptions.first;
          changeInfo = GoogleProductChangeInfo(
            oldProductIdentifier,
            prorationMode: GoogleProrationMode.immediateWithTimeProration,
          );
        }
      }

      final purchaseResult = await Purchases.purchasePackage(
        package,
        googleProductChangeInfo: changeInfo,
      );
      return purchaseResult.customerInfo.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Purchase error: $e");
      }
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      print("Restore error: $e");
      return false;
    }
  }

  static String getPlanName(int index) {
    switch (index) {
      case 1:
        return 'Remove Ads';
      case 2:
        return 'Fuel Log Plus';
      case 3:
        return 'Fuel Log Pro';
      case 0:
      default:
        return 'Free Plan';
    }
  }

  static int getMaxVehicles(int index) {
    switch (index) {
      case 1:
        return 5;
      case 2:
        return 15;
      case 3:
        return 35;
      case 0:
      default:
        return 3; // Default free limit
    }
  }

  static int getMaxReminders(int index) {
    switch (index) {
      case 1:
        return 15;
      case 2:
        return 35;
      case 3:
        return 50;
      case 0:
      default:
        return 5;
    }
  }
}
