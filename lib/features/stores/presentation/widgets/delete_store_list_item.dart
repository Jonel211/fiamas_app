import 'package:flutter/material.dart';

class DeleteStoreListItem extends StatelessWidget {
  const DeleteStoreListItem({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}