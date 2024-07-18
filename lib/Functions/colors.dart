import 'package:flutter/material.dart';

const Color MAIN_COLOR = Color(0xFFEE622D);
const Color SECONDARY_COLOR = Color(0xFFF38B44);
const Color LIGHT_SECONDARY_COLOR = Color(0xFFFFA769);
const Color ULTRA_LIGHT_SECONDARY_COLOR = Color(0xFFFDEBDF);
const Color DARK_BLUE_COLOR = Color(0xFF15295E);
const Color DARK_BLUE_GHOST = Color.fromARGB(150, 15, 41, 94);//Color(0xFF15295E);
const Color BLUE_GHOST = Color.fromARGB(180, 60, 150, 250);
const Color LIGHT_BLUE_GHOST = Color.fromARGB(220, 150, 200, 250);
const Color LIGHT_BLUE_COLOR = Color(0xFF386EFF);
const Color ALERTA = Color(0xFFE3F2FD);
const Color ULTRALIGHT_GREY_COLOR = Color(0xFFEFEFEF);
const Color GREY_COLOR = Color(0xFF7A7E7F);
const Color GREY_COLOR2 = Color(0xFF61615f);
const Color GHOST = Color.fromARGB(0, 255, 255, 255);
const Color LIGHT = Color(0xFFFFFFFF);

const Color NO_UPDATE = Colors.black26;
const Color UPDATE = Colors.cyan;
const Color ACTIVE = Colors.green;
const Color NOT_EXISTS = Colors.redAccent;
const Color ARROW_COLOR = Color(0xFFC7EFCF);
const Color ERROR_COLOR = Color(0xFF15A4ED);

const TextStyle DANGER_TEXT_STYLE = TextStyle(color: Colors.red);
const TextStyle TEXT_BUTTON_STYLE = TextStyle(color: Colors.white);
const TextStyle TEXT_BUTTON_DARK = TextStyle(color: DARK_BLUE_COLOR,);
const TextStyle TEXT_INPUT_STYLE = TextStyle(color: Colors.blue);
const TextStyle TEXT_CARD_STYLE = TextStyle(color: MAIN_COLOR);
const TextStyle TEXT_TITLE_STYLE = TextStyle(fontSize: 25.0);
const TextStyle TEXT_SUBTITLE_STYLE = TextStyle(fontSize: 18.0);
const TextStyle TEXT_FIELD = TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0);
const TextStyle TEXT_FIELD_PHANTOM = TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: GREY_COLOR);
const TextStyle TEXT_LABEL = TextStyle(fontSize: 15.0);
const TextStyle DARK_TEXT_LABEL = TextStyle(fontSize: 15.0, color: DARK_BLUE_COLOR);
const TextStyle TEXT_SUBTITLE_ERROR_STYLE = TextStyle(color: ULTRA_LIGHT_SECONDARY_COLOR, fontSize: 20.0);

ButtonStyle DARK_BUTTON_STYLE = ElevatedButton.styleFrom(
  backgroundColor: DARK_BLUE_COLOR,
  textStyle: TEXT_BUTTON_STYLE,
  side: BorderSide(color: LIGHT, width: 2),
  shadowColor: Colors.black,
  elevation: 6.5,
);
ButtonStyle LIGHT_BUTTON_STYLE = ElevatedButton.styleFrom(
  backgroundColor: LIGHT,
  textStyle: TEXT_BUTTON_STYLE,
  side: BorderSide(color: DARK_BLUE_COLOR, width: 2),
  shadowColor: Colors.black,
  elevation: 6.5,
);

OutlineInputBorder LIGHT_INPUT_STYLE = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  gapPadding: 10,
  borderSide: BorderSide(
    style: BorderStyle.solid,
    width: 2,
    color: DARK_BLUE_COLOR,),
);

