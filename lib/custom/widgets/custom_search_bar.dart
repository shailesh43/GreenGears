import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          cursorColor: Colors.grey,
          decoration: InputDecoration(
            hintText: 'Search Requests',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              color: Color.fromARGB(255, 158, 158, 158),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromRGBO(202, 202, 202, 0.5411764705882353),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromRGBO(223, 223, 223, 1),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
