
import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';

class GlobalColours {

  BuildContext context;

  GlobalColours(this.context);

  static const Color primaryColor = Color(0xFF007AFF);
  static const Color secondaryColor = Color(0xFF0056B3);
  static const Color backgroundColor = Color(0xFFF7FAFC);
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE5E5E5);
  static const Color errorColor = Color(0xFFD9534F);
  static const Color successColor = Color(0xFF5CB85C);
  static const Color warningColor = Color(0xFFF0AD4E);
  static const Color infoColor = Color(0xFF5BC0DE);

  bool get _isDarkMode => MediaQuery.of(context).platformBrightness == Brightness.dark;


  Color get containerColor {
    return _isDarkMode ? Colors.grey[900]! : Colors.white;
  }

  Color get textColorForContainer {
    return _isDarkMode ? Colors.white : Colors.black;
  }

  Color get iconColorForContainer {
    return _isDarkMode ? Colors.white : Colors.black;
  }

  Color? get aboutContainer {
    return _isDarkMode ? Colors.grey[900] : const Color(0xffedeff3);
  }

  Color? get onAboutContainer {
    return _isDarkMode ?  Colors.blueGrey.withOpacity(.1) : Colors.white;
  }

  Color? get aboutText {
    return _isDarkMode ? primaryBlue : const Color(0xff4b5563);
  }

  Color? get chooseCodeContainer {
    return _isDarkMode ? Colors.blueGrey : const Color(0xff1e40af);
  }

  Color get buttonColor {
    return _isDarkMode ? Colors.lightGreen : Colors.lightBlue;
  }

  Color? get buttonTextColor {
    return _isDarkMode ? Colors.green[900]: primaryBlue;
  }

  Color? get codeTextColor {
    return _isDarkMode ? const Color(0xff069383) : primaryBlue;
  }

  BoxShadow get containerShadow {
    final _color = _isDarkMode ? Colors.transparent : Colors.grey.withOpacity(.1);
    return BoxShadow(
      color: _color,
      spreadRadius: 2,
      blurRadius: 4,
      offset: const Offset(0, 2),
    );
  }
}