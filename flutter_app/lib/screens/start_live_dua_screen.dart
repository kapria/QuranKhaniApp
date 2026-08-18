import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';
import '../providers/auth_provider.dart';

class StartLiveDuaScreen extends StatefulWidget {
  const StartLiveDuaScreen({super.key});

  @override
  State<StartLiveDuaScreen> createState() => _StartLiveDuaScreenState();
}

class _StartLiveDuaScreenState extends State<StartLiveDuaScreen> {
  String? _selectedKhaniId;
  String _streamType = 'audio';
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String && _selectedKhaniId == null) {
      _selectedKhaniId = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);
    final activeKhanis = khaniProvider.khanis.where((k) => k.isActive).toList();

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
              'Select Quran Khani',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (activeKhanis.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No active Khanis available'),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedKhaniId,
                decoration: const InputDecoration(
                  labelText: 'Quran Khani',
                  border: OutlineInputBorder(),
                ),
                items: activeKhanis
                    .map((khani) => DropdownMenuItem(
                          value: khani.id,
                          child: Text(khani.title),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedKhaniId = value);
                },
              ),
            const SizedBox(height: 16),
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
              onPressed: _isLoading || _selectedKhaniId == null
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final session = await khaniProvider.startLiveDua(
                        _selectedKhaniId!,
                        _streamType,
                      );
                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (session != null) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/live-dua-session',
                            arguments: session.uniqueCode,
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
