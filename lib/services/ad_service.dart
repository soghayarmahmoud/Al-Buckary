import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to manage Google Mobile Ads
class AdService {
  static bool _initialized = false;

  /// Initialize Google Mobile Ads SDK
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('✅ Google Mobile Ads initialized');
    } catch (e) {
      debugPrint('❌ Error initializing ads: $e');
    }
  }

  /// Get Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3053984425671049/2537718058'; // Real Banner ID
    } else if (Platform.isIOS) {
      // TODO: Replace with your AdMob Banner Ad Unit ID
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  /// Get Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Replace with your AdMob Interstitial Ad Unit ID
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      // TODO: Replace with your AdMob Interstitial Ad Unit ID
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    return '';
  }

  /// Create and load a Banner Ad
  static BannerAd createBannerAd({
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    required void Function(Ad ad) onAdLoaded,
  }) {
    debugPrint('📢 Creating banner ad with ID: $bannerAdUnitId');
    
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded successfully');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: ${error.message} (Code: ${error.code})');
          onAdFailedToLoad(ad, error);
        },
        onAdOpened: (ad) {
          debugPrint('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('📴 Banner ad closed');
        },
      ),
    );
  }

  /// Load an Interstitial Ad
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          debugPrint('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial ad failed to load: $error');
        },
      ),
    );
    
    return interstitialAd;
  }
}
