// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/sizes.dart';

class CustomTextField2 extends StatefulWidget {
  final String hintText;
  final TextInputType keyboardType;
  final String textFieldImage;
  final ValueChanged<String>? onChanged;
  const CustomTextField2(
      {super.key,
      required this.hintText,
      required this.keyboardType,
      required this.textFieldImage,
      this.onChanged});

  @override
  State<CustomTextField2> createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField2> {
  List<dynamic> plants = [];
  String searchQuery = '';

  Future<void> fetchPlants() async {
    final response = searchQuery.isEmpty
        ? await ApiService.getPlants()
        : await ApiService.searchPlants(searchQuery);

    if (response.statusCode == 200) {
      setState(() {
        plants = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        onChanged: (val) {
          if (widget.onChanged != null) {
            widget.onChanged!(val);
          }
        },
        decoration: InputDecoration(
          fillColor: white,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: grey,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius:
                BorderRadius.all(Radius.circular(GSizes.borderRadiusLg)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(GSizes.borderRadiusLg)),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.network(
              widget.textFieldImage,
              width: 24,
              height: 24,
              color: black,
            ),
          ),
        ),
      ),
    );
  }
}
