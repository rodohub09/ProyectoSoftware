import 'package:flutter/material.dart';

PreferredSizeWidget barraPrincipal() {
  return AppBar(
    title: const Text(
      "Menú Login",
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: const Color(0xFFD48957),
    elevation: 4,
    centerTitle: true,
  );
}
