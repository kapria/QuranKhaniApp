import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';

class StartLiveDuaScreen extends StatefulWidget {
  const StartLiveDuaScreen({super.key});

  @override
  State<StartLiveDuaScreen> createState() => _StartLiveDuaScreenState();
}

class _StartLiveDuaScreenState extends State<StartLiveDuaScreen> {
  String _streamType = 'audio';
  bool _isLoading = false;
  String? _joinCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String && _joinCode == null) {
      _joinCode = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Live Dua'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              const LinearProgressIndicator()
            else
              const SizedBox(height: 4),
            const SizedBox(height: 16),
            const Text(
              'Join Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                _joinCode ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Stream Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'audio',
                  label: Text('Audio'),
                  icon: Icon(Icons.mic),
                ),
                ButtonSegment(
                  value: 'video',
                  label: Text('Video'),
                  icon: Icon(Icons.videocam),
                ),
              ],
              selected: {_streamType},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _streamType = selection.first);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading || _joinCode == null
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final session = await khaniProvider.startLiveDua(
                        _joinCode!,
                        _streamType,
                      );
                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (session != null) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/live-dua-session',
                            arguments: session.joinCode ?? _joinCode,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(khaniProvider.errorMessage ?? 'Failed to start'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton(
                style: ElevatedButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                ),
              ),
              child: const Text('Start Live Dua', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
