import 'dart:collection';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:pub_feed/common/common.dart';
import 'package:pub_feed/models/radar.dart';
import 'package:pub_feed/radar/rules.dart';
import 'package:pub_feed/utils/LogUtil.dart';



class RssPlus {
  static Future<List<Radar>> detecting(String url) async {
    var specialRadar = Rules.detectUrl(url);
    if (specialRadar != null) {
      return specialRadar;
    }
    return await detectByUrl(url);
  }

  static Future<List<Radar>> detectByUrl(String url) async {
    List<Radar> radarList = [];
    String? html = await Common.getContentByUrl(Uri.parse(url));
    if (html == null) {
      return radarList;
    }
    Document document = parse(html);
    LogUtil.commonLog(document, StackTrace.current);
    radarList = await parseKnownRss(document, url);
    radarList += await parseUnKnownRss(document, url);
    radarList = radarList.toSet().toList();
    return radarList;
  }

  /// 获取在<head>的<link>元素中，已经声明为RSS的链接
  static Future<List<Radar>> parseKnownRss(
      Document document, String url) async {
    List<Radar> radarList = [];
    List<Element> links = document.getElementsByTagName("link");
    for (var i = 0; i < links.length; i++) {
      LogUtil.commonLog(links, StackTrace.current);
      var link = links[i];
      LinkedHashMap attrs = link.attributes;
      LogUtil.commonLog(attrs, StackTrace.current);
      String? linkHref = attrs['href'];
      String? linkType = attrs['type'];
      String? linkTitle = attrs.containsKey("title")
          ? attrs['title']
          : getTitle(document);
      RegExp rssPattern = RegExp(r'.+\/(rss|rdf|atom)');
      RegExp xmlPattern = RegExp(r'^text\/xml$');
      if (linkType != null &&
          linkHref != null &&
          linkType.isNotEmpty &&
          (rssPattern.hasMatch(linkType) || xmlPattern.hasMatch(linkType))) {
        Uri uri = Uri.parse(url);
        if (!linkHref.startsWith("http") && !linkHref.contains(uri.host)) {
          linkHref = '${uri.scheme}://${uri.host}$linkHref';
        }
        Radar radar = Radar.fromJson(
            {"title": linkTitle, "path": linkHref, "isRssHub": false});
        radarList.add(radar);
      }
    }
    return radarList;
  }
  
  static String? getTitle(Document document){
    List<Element> elementList = document.getElementsByTagName("title");
    return elementList.isEmpty?null:elementList[0].text;
  }

  static Future<List<Radar>> parseUnKnownRss(
      Document document, String url) async {
    List<Element> links = document.getElementsByTagName("a");
    List<Radar> radarList = [];
    Uri uri = Uri.parse(url);

    for (var i = 0; i < links.length; i++) {
      var link = links[i];
      LinkedHashMap attrs = link.attributes;
      String? linkHref = attrs['href'];
      String linkTitle =
          attrs.containsKey("title") ? attrs['title'] : link.text;
      if (linkTitle.isEmpty) {
        linkTitle = document.getElementsByTagName("title")[0].text;
      }
      if (linkHref != null &&
          linkHref.isNotEmpty &&
          (RegExp(r'^(https|http|ftp|feed).*([\.\/]rss([\.\/]xml|\.aspx|\.jsp|\/)?$|\/node\/feed$|\/feed(\.xml|\/$|$)|\/rss\/[a-z0-9]+$|[?&;](rss|xml)=|[?&;]feed=rss[0-9.]*$|[?&;]action=rss_rc$|feeds\.feedburner\.com\/[\w\W]+$)')
                  .hasMatch(linkHref) ||
              RegExp(
                      r'^(https|http|ftp|feed).*\/atom(\.xml|\.aspx|\.jsp|\/)?$|[?&;]feed=atom[0-9.]*$')
                  .hasMatch(linkHref) ||
              RegExp(
                      r'^(https|http|ftp|feed).*(\/feeds?\/[^.\/]*\.xml$|.*\/index\.xml$|feed\/msgs\.xml(\?num=\d+)?$)')
                  .hasMatch(linkHref) ||
              RegExp(r'^(https|http|ftp|feed).*\.rdf$')
                  .hasMatch(linkHref) ||
              RegExp(r'^(rss|feed):\/\/').hasMatch(linkHref) ||
              RegExp(r'^(https|http):\/\/feed\.').hasMatch(linkHref))) {
        if (!linkHref.startsWith("http") && !linkHref.contains(uri.host)) {
          linkHref = '${uri.scheme}://${uri.host}$linkHref';
        }
        Radar radar = Radar.fromJson(
            {"title": linkTitle, "path": linkHref, "isRssHub": false});
        radarList.add(radar);
      }
    }
    return radarList;
  }
}
