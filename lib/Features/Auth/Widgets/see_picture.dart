import 'package:flutter/material.dart';
class ViewImage extends StatelessWidget {
  const ViewImage({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl,fit: BoxFit.fitWidth,))),
      ),

    );
  }
}
