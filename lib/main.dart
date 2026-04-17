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
  bool _hasError = false; // ایرر چیک کرنے کے لیے

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
            setState(() {
              _isLoading = true;
              _hasError = false; // نیا پیج شروع ہوتے ہی ایرر سٹیٹ ختم
            });
          },
          onPageFinished: (String url) {
            // اگر ایرر نہیں آیا تبھی لوڈنگ ختم کریں
            if (!_hasError) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = true; // انٹرنیٹ نہ ہونے پر بھی سرکل گھومتا رہے گا
            });
            // تھوڑی دیر بعد دوبارہ لوڈ کرنے کی کوشش کریں
            Future.delayed(const Duration(seconds: 5), () {
              _controller.reload();
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://lavenderblush-eagle-882875.hostingersite.com/chat_group.php'));

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
            // اگر ایرر ہو تو ویب ویو کو چھپا دیں تاکہ سسٹم کا ڈیفالٹ ایرر پیج نظر نہ آئے
            Opacity(
              opacity: _hasError ? 0 : 1,
              child: WebViewWidget(controller: _controller),
            ),
            
            // لوڈنگ سرکل - جب پیج لوڈ ہو رہا ہو یا انٹرنیٹ کا مسئلہ ہو
            if (_isLoading || _hasError)
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
