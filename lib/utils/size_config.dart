import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late Orientation _orientation;
  static late double _vw;
  static late double _vh;
  static late double _defaultSize;

  SizeConfig(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _orientation = _mediaQueryData.orientation;
    _vw = _mediaQueryData.size.width;
    _vh = _mediaQueryData.size.height;
    _defaultSize =
        _orientation == Orientation.landscape ? _vw * 0.024 : _vh * 0.024;
  }

  static init(BuildContext context) {
    SizeConfig(context);
  }

  static get orientation => _orientation;
  static get vw => _vw;
  static get vh => _vh;
  static get defaultSize => _defaultSize;
}
