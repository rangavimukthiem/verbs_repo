import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  BannerAdWidgetState createState() => BannerAdWidgetState();
}

// banner ad class begin------------------------------------------------------------------------------
class BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Replace with your Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
            print("Banner ad loaded >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print(
              "Banner ad failed to load >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$error");
        },
      ),
    )..load();
    print(" >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>exited from banner ad class  ");
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

// banner ad class end

class InterstitialAdHandler extends StatefulWidget {
  const InterstitialAdHandler({
    super.key,
  });

  @override
  State<InterstitialAdHandler> createState() => InterstitialAdHandlerState();
}

class InterstitialAdHandlerState extends State<InterstitialAdHandler> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox());
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              loadInterstitialAd(); // Load a new ad after dismissal
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              loadInterstitialAd(); // Load a new ad if showing fails
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Interstitial ad is not ready yet');
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
