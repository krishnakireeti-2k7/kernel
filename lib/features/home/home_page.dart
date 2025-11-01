// features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Kernel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white70),
            onPressed: () {
              // TODO: Sync data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === QUICK START ===
            _sectionTitle("Quick Start"),
            const SizedBox(height: 12),
            _quickStartCard(context),

            const SizedBox(height: 32),

            // === ROUTINES HEADER ===
            Row(
              children: [
                _sectionTitle("Routines"),
                const Spacer(),
                _iconButton(Icons.add, () => context.push('/workout/template')),
                const SizedBox(width: 8),
                _iconButton(Icons.explore, () => context.push('/explore')),
              ],
            ),
            const SizedBox(height: 12),

            // === EXPLORE PLACEHOLDER ===
            _exploreCard(context),

            const SizedBox(height: 24),

            // === MY ROUTINES ===
            _myRoutinesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _quickStartCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/workout/session'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white70, size: 28),
            SizedBox(width: 12),
            Text(
              "Start Empty",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exploreCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/explore'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.explore, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              "Explore Community Routines",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _myRoutinesSection(BuildContext context) {
    return ExpansionTile(
      backgroundColor: const Color(0xFF1E1E1E),
      collapsedBackgroundColor: const Color(0xFF1E1E1E),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text(
        "My Routines",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: TextButton.icon(
              onPressed: () => context.push('/workouts'),
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text(
                "Create your first routine",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
