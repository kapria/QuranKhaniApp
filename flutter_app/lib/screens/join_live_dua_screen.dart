import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';

class JoinLiveDuaScreen extends StatefulWidget {
  const JoinLiveDuaScreen({super.key});

  @override
  State<JoinLiveDuaScreen> createState() => _JoinLiveDuaScreenState();
}

class _JoinLiveDuaScreenState extends State<JoinLiveDuaScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Live Dua'),
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
            const SizedBox(height: 24),
            const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Enter Join Code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: const InputDecoration(
                hintText: 'XXXX-XXXX',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final code = _codeController.text.trim().toUpperCase();
                      if (code.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a join code'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => _isLoading = true);
                      final session = await khaniProvider.joinLiveDua(code);
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
                              content: Text(khaniProvider.errorMessage ?? 'Invalid code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton(
                style: ElevatedButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
              child: const Text('Join', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
