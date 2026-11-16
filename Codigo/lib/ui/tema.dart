import 'package:flutter/material.dart';

/// Paleta de colores agrícolas y andinos inspirada en el centro poblado de Illpe
/// y la tierra fértil ("Allpa" en quechua).
class ColoresAllpa {
  static const verdeBosque = Color(0xFF1B4D3E);
  static const verdeOscuro = Color(0xFF11352A);
  static const verdeMedio = Color(0xFF2D6A4F);
  static const verdeClaro = Color(0xFF52B788);
  static const verdeMentaSuave = Color(0xFFD8EEDF);
  static const verdeSuperficie = Color(0xFFEBF6F0);

  static const doradoAndino = Color(0xFFC07A2B);
  static const doradoOscuro = Color(0xFFA5631E);
  static const doradoClaro = Color(0xFFFDE8C8);
  static const trigoSuave = Color(0xFFFAF0E1);

  static const tierraBarro = Color(0xFFA65034);
  static const tierraClara = Color(0xFFF8E7E1);

  static const fondoPapel = Color(0xFFF7F5EE);
  static const fondoTarjeta = Color(0xFFFFFFFF);
  static const bordeTarjeta = Color(0xFFE5DFD5);
  static const divisor = Color(0xFFEDE8DF);

  static const textoPrincipal = Color(0xFF1E2621);
  static const textoSecundario = Color(0xFF58665E);
  static const textoAtenuado = Color(0xFF8A9890);
}

ThemeData temaAllpa() {
  const verde = ColoresAllpa.verdeBosque;
  const papel = ColoresAllpa.fondoPapel;

  final esquema = ColorScheme.fromSeed(
    seedColor: verde,
    primary: verde,
    secondary: ColoresAllpa.doradoAndino,
    tertiary: ColoresAllpa.tierraBarro,
    surface: ColoresAllpa.fondoTarjeta,
    background: papel,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: papel,
    fontFamily: null, // Usa la tipografía predeterminada del sistema
    appBarTheme: const AppBarTheme(
      backgroundColor: verde,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    cardTheme: CardThemeData(
      color: ColoresAllpa.fondoTarjeta,
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresAllpa.bordeTarjeta, width: 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        elevation: 0.5,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: verde,
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: verde, width: 1.2),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: ColoresAllpa.textoSecundario, fontSize: 15),
      hintStyle: const TextStyle(color: ColoresAllpa.textoAtenuado, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColoresAllpa.bordeTarjeta, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColoresAllpa.bordeTarjeta, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: verde, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColoresAllpa.tierraBarro, width: 1.5),
      ),
    ),
  );
}

InputDecoration campo(
  String etiqueta, {
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? hintText,
  String? suffixText,
}) {
  return InputDecoration(
    labelText: etiqueta,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixText: suffixText,
  );
}
