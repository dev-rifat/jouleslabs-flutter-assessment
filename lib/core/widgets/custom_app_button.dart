import 'package:flutter/material.dart';

class CustomAppButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color btnBorderColor;
  final double buttonRadius;
  final double buttonHeight;
  final double? buttonWidth;
  final Widget? widget;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final double borderWidth;
  final Function? onPressed;
  final TextStyle? btnTextStyle;

  const CustomAppButton(
      {super.key,
        this.text = "",
        this.widget,
        this.btnBorderColor = Colors.transparent,
        this.borderWidth = 1.0,
        this.buttonHeight = 48,
        this.buttonWidth,
        this.prefixWidget,
        this.suffixWidget,
        this.btnTextStyle,
        this.buttonColor = Colors.blue,
        this.buttonTextColor = Colors.white,
        this.onPressed,
        this.buttonRadius = 30});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///Button click action
      onTap: () => onPressed == null ? null : onPressed!(),
      child: Container(
        height: buttonHeight,
        width: buttonWidth ?? MediaQuery.of(context).size.width,

        ///Button style
        decoration: _buttonStyle(),
        child: Center(
          child: widget ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Prefix widget
                  prefixWidget ?? Container(),
                  _spacer(),
                  Expanded(
                    child: Text(

                      text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,

                      ///Button text style
                      style: _textStyle(),
                    ),
                  ),
                  _spacer(),

                  /// Suffix widget
                  suffixWidget ?? Container()
                ],
              ),
        ),
      ),
    );
  }

  _buttonStyle() {
    return BoxDecoration(
        border: Border.all(width: borderWidth, color: btnBorderColor),
        color: buttonColor,
        borderRadius: BorderRadius.circular(buttonRadius));
  }

  _textStyle() {
    return btnTextStyle ?? TextStyle(color: buttonTextColor, fontSize: 17);
  }

  _spacer() {
    return const SizedBox(
      width: 12,
    );
  }
}