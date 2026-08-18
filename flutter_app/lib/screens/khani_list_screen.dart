import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';
import '../providers/auth_provider.dart';

class KhaniListScreen extends StatelessWidget {
  const KhaniListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Khanis'),
      ),
      body: RefreshIndicator(
        onRefresh: () => khaniProvider.fetchKhanis(),
        child: khaniProvider.isLoading && khaniProvider.khanis.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : khaniProvider.khanis.isEmpty
                ? const Center(child: Text('No active Khanis available'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: khaniProvider.khanis.length,
                    itemBuilder: (context, index) {
                      final khani = khaniProvider.khanis[index];
                      final isHost = khani.hostId == authProvider.user?.id || 
                                     khani.createdBy == authProvider.user?.id;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/khani-details',
                              arguments: khani.id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        khani.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: khani.status == 'live'
                                            ? Colors.red[100]
                                            : khani.status == 'ended'
                                                ? Colors.grey[200]
                                                : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        khani.status.toUpperCase(),
                                        style: TextStyle(
                                          color: khani.status == 'live'
                                              ? Colors.red[800]
                                              : khani.status == 'ended'
                                                  ? Colors.grey[800]
                                                  : Colors.orange[800],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 4),
                                    Text(khani.startDate),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(khani.startTime),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (khani.location != null) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          khani.location!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Row(
                                  children: [
                                    const Icon(Icons.timelapse, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${khani.durationMinutes} minutes'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (khani.joinCode.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.vpn_key, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        khani.joinCode,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 18),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Copied: ${khani.joinCode}')),
                                          );
                                        },
                                        tooltip: 'Copy code',
                                      ),
                                    ],
                                  ),
                                ],
                                if (isHost && khani.status == 'scheduled') ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final success = await khaniProvider.startKhani(khani.id);
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Quran Khani started! Share the code.'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Start Quran Khani'),
                                      style: ElevatedButton(
                                        style: ElevatedButton(
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (isHost && khani.status == 'live') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            final success = await khaniProvider.endKhani(khani.id);
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Quran Khani ended'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.stop),
                                          label: const Text('End Khani'),
                                          style: ElevatedButton(
                                            style: ElevatedButton(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/start-live-dua',
                                              arguments: khani.joinCode,
                                            );
                                          },
                                          icon: const Icon(Icons.live_tv),
                                          label: const Text('Live Dua'),
                                          style: ElevatedButton(
                                            style: ElevatedButton(
                                              backgroundColor: Colors.purple,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateKhaniDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Khani'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCreateKhaniDialog(BuildContext context) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPrayer = 'fajar';
    int durationMinutes = 60;
    final khaniProvider = Provider.of<KhaniProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Quran Khani'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Start Time (HH:MM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 60',
                  ),
                  onChanged: (value) {
                    final minutes = int.tryParse(value);
                    if (minutes != null && minutes > 0) {
                      setState(() => durationMinutes = minutes);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPrayer,
                  decoration: const InputDecoration(
                    labelText: 'Prayer Time',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'fajar', child: Text('After Fajar')),
                    DropdownMenuItem(value: 'zohar', child: Text('After Zohar')),
                    DropdownMenuItem(value: 'asar', child: Text('After Asar')),
                    DropdownMenuItem(value: 'magrib', child: Text('After Magrib')),
                    DropdownMenuItem(value: 'isa', child: Text('After Isha')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedPrayer = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    dateController.text.isEmpty ||
                    timeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final success = await khaniProvider.createKhani({
                  'title': titleController.text.trim(),
                  'start_date': dateController.text.trim(),
                  'start_time': timeController.text.trim(),
                  'location': locationController.text.trim().isEmpty
                      ? null
                      : locationController.text.trim(),
                  'prayer_after': selectedPrayer,
                  'duration_minutes': durationMinutes,
                  'description': descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                });
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Khani created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
