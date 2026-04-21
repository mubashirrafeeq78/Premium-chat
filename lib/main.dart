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
  bool _isFirstLoadDone = false; 

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initController();
  }

  // کیمرہ، مائیکروفون اور میڈیا فائلز بھیجنے کے لیے بنیادی پرمیشنز
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.photos, // میڈیا فائلز سلیکٹ کرنے کے لیے
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
            if (!_isFirstLoadDone) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _isFirstLoadDone = true; 
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Web Resource Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse('https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php'));

    // اینڈرائیڈ کے لیے مخصوص سیٹنگز (کیمرہ اور وائس ریکارڈنگ کی اجازت)
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);

      // یہ وہ حصہ ہے جو ویب سائٹ کو ہارڈویئر استعمال کرنے کی اجازت دیتا ہے
      (controller.platform as AndroidWebViewController).setOnPermissionRequest(
        (AndroidPermissionRequest request) async {
          await request.grant();
        },
      );
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
