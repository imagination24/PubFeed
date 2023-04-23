/*
Warning:Release模式下此工具会阻碍程序运动-具体表现为运行到使用工具位置就停止继续往下运行,建议用完即弃，具体原因是混淆会导致StackTrace紊乱。
Time:2022/4/27
Description:log统一接口
Author:lai
*/

class LogUtil{
  static commonLog(Object message, StackTrace current) {
    MYCustomTrace programInfo = MYCustomTrace(current);
    print("file: ${programInfo.fileName}, line: ${programInfo.lineNumber}, Info: $message");
  }
}


class MYCustomTrace {
  final StackTrace _trace;
  String? fileName;
  int ?lineNumber;
  int ?columnNumber;

  MYCustomTrace(this._trace) {
    _parseTrace();
  }

  void _parseTrace() {
    var traceString = _trace.toString().split("\n")[0];
    var indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
    var fileInfo = traceString.substring(indexOfFileName);
    var listOfInfo = fileInfo.split(":");
    fileName = listOfInfo[0];
    lineNumber = int.parse(listOfInfo[1]);
    var columnStr = listOfInfo[2];
    columnStr = columnStr.replaceFirst(")", "");
    columnNumber = int.parse(columnStr);
  }
}