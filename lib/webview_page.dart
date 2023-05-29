// ignore_for_file: unused_field, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:samo/splash_screen.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  double _progress = 0;
  bool _isLoading = true;
  late InAppWebViewController inAppWebViewController;
  late GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  DateTime? currentBackPressTime;

  Future<bool> _handleBackButton() async {
    final canGoBack = await inAppWebViewController.canGoBack();
    if (canGoBack) {
      await inAppWebViewController.goBack();
      return false;
    } else {
      final now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Press back again to exit')),
        );
        return false;
      }
      return true;
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
      _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    });
    await inAppWebViewController.reload();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.white,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse('https://samoschool.ru/'),
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform:
                        InAppWebViewOptions(transparentBackground: true),
                    android: AndroidInAppWebViewOptions(
                      domStorageEnabled: true,
                      databaseEnabled: true,
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    inAppWebViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      _isLoading = false;
                    });
                    _refreshIndicatorKey.currentState?.deactivate();
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      _progress = progress / 100;
                    });
                  },
                  pullToRefreshController: PullToRefreshController(
                    onRefresh: _handleRefresh,
                    options: PullToRefreshOptions(
                      enabled: true,
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_isLoading,
                    child: AnimatedOpacity(
                      opacity: _isLoading ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: splashScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
