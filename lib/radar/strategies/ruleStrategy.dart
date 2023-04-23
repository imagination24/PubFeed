import 'package:pub_feed/models/radar.dart';

abstract class RuleStrategy {
  List<Radar> detect(String url);
}