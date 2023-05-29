// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:samo/splash_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final url = 'https://samoschool.store/';
  late final WebViewController controller;
  double _progress = 0;
  bool _isLoading = true;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  DateTime? currentBackPressTime;

  Future<bool> _handleBackButton() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
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
    await controller.reload();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
    controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url.startsWith(url)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) {
          setState(() {
            _progress = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            _progress = 100 / progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            _progress = 100;
          });
        },
      ))
      ..loadRequest(
        Uri.parse(url),
      )
      ..canGoBack();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handleBackButton(),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.white,
            child: Stack(
              children: [
                WebViewWidget(
                  controller: controller,
                  gestureRecognizers: Set()
                    ..add(
                      Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer()
                            ..onDown = (DragDownDetails dragDownDetails) {
                              controller.getScrollPosition().then((value) {
                                if (value == 0 &&
                                    dragDownDetails.globalPosition.direction <
                                        1) {
                                  controller.reload();
                                }
                              });
                            }),
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
