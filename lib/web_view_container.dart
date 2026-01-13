import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './constants/utils.dart';

class WebViewContainer extends StatefulWidget {
  final String url;

  const WebViewContainer(this.url, {super.key});

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final WebViewController _controller;
  final WebViewCookieManager _cookieManager = WebViewCookieManager();

  bool _codeReturned = false;

  @override
  void initState() {
    super.initState();
    Utils.sendAnalyticsEvent('azure_login_page');
    _initWebView();
  }

  Future<void> _initWebView() async {
    // CRITICAL FIX — clear SSO session
    await _cookieManager.clearCookies();

    final PlatformWebViewControllerCreationParams params =
    const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('Page started: $url');
          },
          onPageFinished: (url) async {
            debugPrint('Page finished: $url');

            // 🔑 Capture Azure redirect with auth code
            if (!_codeReturned && url.contains('code=')) {
              _codeReturned = true;

              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];

              if (code != null && mounted) {
                Navigator.of(context).pop({'code': code});
              }
            }
          },
          onWebResourceError: (error) {
            debugPrint(
              'WebView error: ${error.errorCode} - ${error.description}',
            );
          },
          onNavigationRequest: (request) {
            debugPrint('Navigating to: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (message) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );

    // CLEAR CACHE EVERY TIME
    await _controller.clearCache();
    // FORCE LOGIN SCREEN EVERY TIME
    final forcedLoginUrl = widget.url.contains('prompt=')
        ? widget.url
        : '${widget.url}&prompt=login';
    await _controller.loadRequest(Uri.parse(forcedLoginUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Connect2SolveAppBar(
          title: 'Login',
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
