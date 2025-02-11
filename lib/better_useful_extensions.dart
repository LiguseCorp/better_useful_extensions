import 'dart:math';

import 'package:flutter/material.dart';

extension BetterStringExtensions on String {
  Color toColor() {
    final hexColor = toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6 || hexColor.length == 8) {
      final hexCode = hexColor.length == 6 ? "FF$hexColor" : hexColor;
      try {
        return Color(int.parse(hexCode, radix: 16));
      } catch (e) {
        throw Exception('Error parsing color string: $this, error: $e');
      }
    } else {
      throw Exception('Error parsing color string: $this, error: $e');
    }
  }

  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}

extension BetterColorExtensions on Color {
  String get toHex {
    return '#${value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
  }

  String get toHexStringWithAlpha {
    return '#${value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
  }

  Color blendWithBackground(double alpha, Color backgroundColor) {
    alpha = min(1, max(0, alpha));

    final red = ((this.red * alpha) + (backgroundColor.red * (1 - alpha))).toInt();
    final green = ((this.green * alpha) + (backgroundColor.green * (1 - alpha))).toInt();
    final blue = ((this.blue * alpha) + (backgroundColor.blue * (1 - alpha))).toInt();

    return Color.fromARGB(255, red, green, blue);
  }
}

extension BetterDateTimeExtensions on DateTime {
  DateTime onlyDay() {
    return DateTime(year, month, day);
  }
}

extension BetterBrightnessExtensions on Brightness {
  Brightness get reversed => this == Brightness.light ? Brightness.dark : Brightness.light;
}

extension BetterWidgetExtensions on Widget {
  Widget interact({
    Function()? onTap,
    Function()? onLongPress,
    void Function()? onSecondaryTap,
    void Function()? onDoubleTap,
    String tooltipMessage = "",
    bool disabled = false,
    MouseCursor? mouseCursor,
    bool useScale = false,
  }) {
    final isPressed = ValueNotifier<bool>(false);
    final opacity = ValueNotifier<double>(1.0);

    void setOpacity(double value) {
      if (!disabled && onTap != null) {
        opacity.value = value;
      }
    }

    return MouseRegion(
      cursor: mouseCursor ?? (onTap != null && !disabled ? SystemMouseCursors.click : MouseCursor.defer),
      hitTestBehavior: HitTestBehavior.translucent,
      onEnter: (v) => setOpacity(0.6),
      onExit: (v) => setOpacity(1.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: disabled ? null : onTap,
        onLongPress: disabled ? null : onLongPress,
        onSecondaryTap: disabled ? null : onSecondaryTap,
        onDoubleTap: disabled ? null : onDoubleTap,
        onTapDown: disabled || onTap == null
            ? null
            : (details) {
          isPressed.value = true;
          setOpacity(0.4);
        },
        onTapUp: disabled || onTap == null
            ? null
            : (details) {
          isPressed.value = false;
          setOpacity(1.0);
        },
        onTapCancel: disabled || onTap == null
            ? null
            : ( ) {
          isPressed.value = false;
          opacity.value = 1.0;
        },
        child: ValueListenableBuilder<double>(
          valueListenable: opacity,
          builder: (context, currentOpacity, child) => AnimatedOpacity(
            opacity: disabled ? 0.4 + currentOpacity * 0 : currentOpacity,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn,
            child: ValueListenableBuilder<bool>(
              valueListenable: isPressed,
              builder: (context, currentIsPressed, child) => AnimatedScale(
                scale: useScale ? (currentIsPressed ? 0.9 : 1) : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                child: tooltipMessage.isNotEmpty
                    ? Tooltip(message: tooltipMessage, child: this)
                    : this,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget marginOnly({double top = 0, double bottom = 0, double left = 0, double right = 0}) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      child: this,
    );
  }

  Widget marginAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }
}

extension BetterNumExtensions on num {
  Duration get microseconds => Duration(microseconds: round());

  Duration get milliseconds => Duration(milliseconds: round());

  Duration get seconds => Duration(seconds: round());

  Duration get minutes => Duration(minutes: round());

  Duration get hours => Duration(hours: round());

  Duration get days => Duration(days: round());
}