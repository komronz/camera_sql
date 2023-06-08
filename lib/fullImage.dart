import 'dart:io';

import 'package:flutter/material.dart';


class FullImage extends StatelessWidget {
  final File image;
  final String title;
  FullImage({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(title.toUpperCase(), style: const TextStyle(color: Colors.black54),),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black54,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Center(
          child: Image(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: FileImage(image),
          ),
        ),
      ),
    );
  }
}