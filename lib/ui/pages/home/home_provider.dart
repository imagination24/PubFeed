import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:linkify/linkify.dart';
import 'package:pub_feed/common/common.dart';
import 'package:pub_feed/models/radar.dart';
import 'package:pub_feed/radar/radar.dart';
import 'package:pub_feed/utils/LogUtil.dart';


class HomeProvider extends ChangeNotifier {
  static const String feedSite = "https://rsshub.rssforever.com/twitter/user/gigadein1119";
  static const String pubDev = "https://weibo.com/u/5984336074";
  static const String weiboSearch = "https://s.weibo.com/weibo?q=";
  List source = [pubDev];
  late HeadlessInAppWebView headlessWebView;
  late InAppWebViewController webViewController;
  String weiboCookie = "";
  TextEditingController textEditingController = TextEditingController();

  HomeProvider() {
    InAppWebViewGroupOptions inAppWebViewGroupOptions =
        InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(userAgent: "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36")
        );
    headlessWebView = HeadlessInAppWebView(
      onConsoleMessage: (controller, consoleMessage) => LogUtil.commonLog("CONSOLE MESSAGE: ${consoleMessage.message}", StackTrace.current),
      initialOptions: inAppWebViewGroupOptions,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
    );
  }

  getWeiboCookie()async{
    headlessWebView.run();
    await webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(weiboSearch), method: 'GET'));
    var cookies = await CookieManager.instance().getCookies(url: (await webViewController.getUrl())!);
    for (var element in cookies) {
    weiboCookie += "${element.name}=${element.value};";
    }
  }

  String? getHref(var ele)=>ele[0].children[0].children[0].attributes["href"];

  Future<Radar?> detectWeibo() async {
    String word = textEditingController.text;
    word = "$weiboSearch$word";
    if(weiboCookie.isEmpty)getWeiboCookie();
    Map<String,String> headers = {
      "Accept": "application/json, text/plain, */*",
      "accept-encoding": "gzip, deflate, br",
      "accept-language": "zh-CN,zh;q=0.9",
      "cookie":weiboCookie
    };
    var response = await get(Uri.parse(word),headers: headers);
    var parser = parse(response.body);
    var ele = parser.getElementsByClassName("card card-user-b s-brt1 card-user-b-padding");
    String ? encodePath = getHref(ele);
    if(encodePath==null) return null;
    int commonId = int.parse(encodePath.replaceAll("//weibo.com/u/", ""),onError: (e)=>-1);
    if(commonId==-1){
      String? uidOfBtn = ele[0].children[2].children[0].attributes["uid"];
      if(uidOfBtn==null||uidOfBtn.isEmpty)return null;
      encodePath = "//weibo.com/u/$uidOfBtn";
    }
    return Radar.fromJson({"title": "微博博主", "path": encodePath, "isRssHub": true});
  }

  String? _verifyLink(String? url) {
    var links = linkify(url!.trim(),
            options: const LinkifyOptions(humanize: false),
            linkifiers: [const UrlLinkifier()])
        .where((element) => element is LinkableElement);
    if (links.isEmpty) {
      return null;
    }
    return links.first.text;
  }

  _callRadar(String url) async {
    List<Radar> result = await _detectUrl(url);
    result.forEach((element) => LogUtil.commonLog("${element.path}  ${element.title}", StackTrace.current));
  }

  Future<List<Radar>> _detectUrl(String url,{Map<String, String> ? header}) async {
    await headlessWebView.run();
    await webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(url), method: 'GET',headers: header));
    await headlessWebView.webViewController.injectJavascriptFileFromAsset(
        assetFilePath: 'assets/js/radar-rules.js');
    await headlessWebView.webViewController
        .injectJavascriptFileFromAsset(assetFilePath: 'assets/js/url.min.js');
    await headlessWebView.webViewController
        .injectJavascriptFileFromAsset(assetFilePath: 'assets/js/psl.min.js');
    await headlessWebView.webViewController.injectJavascriptFileFromAsset(
        assetFilePath: 'assets/js/route-recognizer.min.js');
    await headlessWebView.webViewController
        .injectJavascriptFileFromAsset(assetFilePath: 'assets/js/utils.js');
    String rules = await Common.getRules();
    await headlessWebView.webViewController
        .evaluateJavascript(source: 'var rules=$rules');
    var html = await webViewController.getHtml();
    LogUtil.commonLog(html!, StackTrace.current);
    var uri = Uri.parse(url);
    String expression = """
      getPageRSSHub({
                            url: "$url",
                            host: "${uri.host}",
                            path: "${uri.path}",
                            html: `$html`,
                            rules: rules
                        });
      """;
    var res = await headlessWebView.webViewController
        .evaluateJavascript(source: expression);
    LogUtil.commonLog(res??"没有", StackTrace.current);
    var radarList = [];
    if (res != null) {
      radarList = Radar.listFromJson(json.decode(res));
    }
    return [...radarList, ...await RssPlus.detecting(url)];
  }
}
