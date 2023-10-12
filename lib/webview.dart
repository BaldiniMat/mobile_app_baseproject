// ignore_for_file: avoid_print

import 'package:baseproject/pull_to_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStartPage extends StatefulWidget {
  const WebViewStartPage({super.key});

  @override
  State<WebViewStartPage> createState() => _WebViewStartPageState();
}

class _WebViewStartPageState extends State<WebViewStartPage>
    with WidgetsBindingObserver {
  final WebViewController controller = WebViewController();
  late DragGesturePullToRefresh dragGesturePullToRefresh;

  @override
  void initState() {
    super.initState();
    dragGesturePullToRefresh = DragGesturePullToRefresh();
    dragGesturePullToRefresh.setContext(context).setController(controller);

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(const Color(0x00000000));
    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
          debugPrint("Progress: $progress");
        },
        onPageStarted: (String url) {
          dragGesturePullToRefresh.started();
          debugPrint("onPageStarted: $url");
        },
        onPageFinished: (String url) {
          dragGesturePullToRefresh.finished();
          debugPrint("onPageFinished: $url");
        },
        onWebResourceError: (WebResourceError error) {
          dragGesturePullToRefresh.finished();
        },
        onNavigationRequest: (NavigationRequest request) {
          debugPrint("NavigationRequest: ${request.url}");
          if (request.url.startsWith('https://crowdplus.it/linkedin/')) {
            debugPrint('blocking navigation to ${request.url}');
            /*  ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Non puoi accedere a questa pagina, coglione")),
            ); */
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    controller.loadRequest(Uri.parse('https://crowdplus.it'));
    /* controller.loadRequest(Uri.parse('https://savonaeventi.com')); */

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // remove listener
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // on portrait / landscape or other change, recalculate height
    dragGesturePullToRefresh.setHeight(MediaQuery.of(context).size.height);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => dragGesturePullToRefresh.refresh(),
      child: Builder(
        builder: (context) => WebViewWidget(
          controller: controller,
          gestureRecognizers: {Factory(() => dragGesturePullToRefresh)},
          /* gestureRecognizers: Set()
          ..add(
            Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer()
                  ..onDown = (DragDownDetails dragDownDetails) {
                    controller.getScrollPosition().then((Offset value) {
                      if (value.dy == 0 &&
                          dragDownDetails.globalPosition.direction < 1) {
                        controller.reload();
                      }
                    });
                  }),
          ), */
        ),
      ),
    );
  }
}
