import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';

class LiveDuaHomeScreen extends StatelessWidget {
  const LiveDuaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Dua'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.live_tv, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Live Quran Khani Dua',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use the same Khani join code to start or join a live dua session',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/start-live-dua'),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Start Live Dua (Host)'),
              style: ElevatedButton(
                style: ElevatedButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/join-live-dua'),
              icon: const Icon(Icons.join_inner),
              label: const Text('Join with Khani Code'),
              style: OutlinedButton(
                style: OutlinedButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
