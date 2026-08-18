import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';
import '../providers/auth_provider.dart';

class LiveDuaSessionScreen extends StatefulWidget {
  const LiveDuaSessionScreen({super.key});

  @override
  State<LiveDuaSessionScreen> createState() => _LiveDuaSessionScreenState();
}

class _LiveDuaSessionScreenState extends State<LiveDuaSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSession();
    });
  }

  Future<void> _loadSession() async {
    final code = ModalRoute.of(context)!.settings.arguments as String;
    final khaniProvider = Provider.of<KhaniProvider>(context, listen: false);
    await khaniProvider.getLiveSession(code);
  }

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final session = khaniProvider.liveSession;
    final khani = khaniProvider.selectedKhani;
    final joinCode = session?.joinCode ?? khani?.joinCode ?? '';
    final isHost = khani != null && 
                   (khani.hostId == authProvider.user?.id || khani.createdBy == authProvider.user?.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(joinCode.isNotEmpty ? joinCode : 'Live Dua'),
        actions: [
          if (isHost && session?.status == 'waiting')
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _showStartStreamDialog(context, joinCode),
              tooltip: 'Start Stream',
            ),
          if (isHost && session?.status == 'live')
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () async {
                final success = await khaniProvider.endLiveDua(joinCode);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live dua ended')),
                  );
                  Navigator.pop(context);
                }
              },
              tooltip: 'End Session',
            ),
        ],
      ),
      body: khaniProvider.isLoading && session == null
          ? const Center(child: CircularProgressIndicator())
          : session == null
              ? const Center(child: Text('Session not found'))
              : RefreshIndicator(
                  onRefresh: () async {
                    final code = ModalRoute.of(context)!.settings.arguments as String;
                    await khaniProvider.getLiveSession(code);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSessionCard(context, session, isHost),
                        const SizedBox(height: 24),
                        _buildParticipantsList(context, session),
                        const SizedBox(height: 24),
                        _buildStreamActions(context, session, isHost),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSessionCard(BuildContext context, session, bool isHost) {
    final khani = khaniProvider.selectedKhani;
    
    return Card(
      color: session.status == 'live' ? Colors.red[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  session.status == 'live' ? Icons.live_tv : Icons.schedule,
                  color: session.status == 'live' ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  session.status == 'live' ? 'LIVE' : 'WAITING',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: session.status == 'live' ? Colors.red : Colors.orange,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.joinCode ?? khani?.joinCode ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Khani: ${session.khaniTitle ?? khani?.title ?? 'N/A'}'),
            const SizedBox(height: 4),
            if (khani != null && khani.hostName != null)
              Text('Host: ${khani.hostName}'),
            const SizedBox(height: 4),
            Text('Type: ${session.streamType == 'video' ? 'Video + Audio' : 'Audio Only'}'),
            if (isHost) ...[
              const SizedBox(height: 8),
              const Text(
                'Share this code with participants',
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsList(BuildContext context, session) {
    final khani = khaniProvider.selectedKhani;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (khani?.hostName != null)
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.mic, color: Colors.white, size: 18),
                ),
                title: Text(khani!.hostName!),
                subtitle: Text(khani.hostId ?? ''),
                trailing: const Text(
                  'HOST',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Others joined with the same code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamActions(BuildContext context, session, bool isHost) {
    if (session.status == 'ended') {
      return const Card(
        color: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This live dua session has ended',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    }

    if (session.status == 'waiting') {
      return Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.hourglass_empty, size: 40, color: Colors.orange),
              const SizedBox(height: 8),
              const Text(
                'Waiting for host to start the stream...',
                textAlign: TextAlign.center,
              ),
              if (!isHost) ...[
                const SizedBox(height: 16),
                const Text(
                  'You can listen once the host starts the stream',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ]
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (session.streamType == 'audio')
          Card(
            child: ListTile(
              leading: const Icon(Icons.headphones, color: Colors.green),
              title: const Text('Listen to Dua'),
              subtitle: const Text('Audio stream is live'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Audio playback would start here')),
                  );
                },
                child: const Text('Listen'),
              ),
            ),
          )
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('Watch Live'),
              subtitle: Text(session.streamUrl ?? 'Stream URL not set'),
              trailing: ElevatedButton(
                onPressed: session.streamUrl != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Video player would open here')),
                        );
                      }
                    : null,
                child: const Text('Watch'),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: const Text('Share Join Code'),
            subtitle: Text('Code: ${session.joinCode ?? ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied: ${session.joinCode ?? ''}')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showStartStreamDialog(BuildContext context, String joinCode) {
    final streamUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Stream'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your stream URL (RTMP/WebRTC)'),
            const SizedBox(height: 12),
            TextField(
              controller: streamUrlController,
              decoration: const InputDecoration(
                labelText: 'Stream URL',
                border: OutlineInputBorder(),
                hintText: 'rtmp://... or https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final khaniProvider = Provider.of<KhaniProvider>(context, listen: false);
              final success = await khaniProvider.startStream(
                joinCode,
                streamUrlController.text.trim().isEmpty
                    ? null
                    : streamUrlController.text.trim(),
                'audio',
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stream started!'),
                    backgroundColor: Colors.green,
                  ),
                );
                await _loadSession();
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
