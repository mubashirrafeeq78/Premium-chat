import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PremiumWebView(),
  ));
}

class PremiumWebView extends StatefulWidget {
  const PremiumWebView({super.key});

  @override
  State<PremiumWebView> createState() => _PremiumWebViewState();
}

class _PremiumWebViewState extends State<PremiumWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFirstLoadDone = false; // یہ چیک کرے گا کہ کیا پہلی بار لوڈنگ مکمل ہو گئی ہے

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initController();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  void _initController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // صرف تب لوڈنگ دکھائیں اگر پہلی بار لوڈ ہو رہا ہو
            if (!_isFirstLoadDone) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            // جب ایک بار پیج لوڈ ہو جائے تو سب ختم
            setState(() {
              _isLoading = false;
              _isFirstLoadDone = true; // اب دوبارہ کبھی لوڈنگ نہیں دکھائے گا
            });
          },
          onWebResourceError: (WebResourceError error) {
            // یہاں سے ہم نے 'setState' اور 'reload' والا لاجک ہٹا دیا ہے
            // تاکہ انٹرنیٹ جانے پر یوزر کو تنگ نہ کیا جائے اور سرکل نہ آئے
            debugPrint("Web Resource Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse('https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            // لوڈنگ سرکل صرف تب نظر آئے گا جب پہلی بار فائل لوڈ ہو رہی ہو
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
