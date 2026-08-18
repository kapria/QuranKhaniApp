import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';

class KhaniListScreen extends StatelessWidget {
  const KhaniListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Khanis'),
      ),
      body: RefreshIndicator(
        onRefresh: () => khaniProvider.fetchKhanis(),
        child: khaniProvider.isLoading && khaniProvider.khanis.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : khaniProvider.khanis.isEmpty
                ? const Center(child: Text('No Khanis available'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: khaniProvider.khanis.length,
                    itemBuilder: (context, index) {
                      final khani = khaniProvider.khanis[index];
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
                                        color: khani.isActive
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        khani.isActive ? 'Active' : 'Ended',
                                        style: TextStyle(
                                          color: khani.isActive
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                          fontSize: 12,
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
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        khani.location ?? 'No location',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Chip(
                                  label: Text(
                                    'After ${_formatPrayer(khani.prayerAfter)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.blue[50],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Duration: ${khani.durationDays} days',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
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

  String _formatPrayer(String prayer) {
    switch (prayer) {
      case 'fajar':
        return 'Fajar';
      case 'zohar':
        return 'Zohar';
      case 'asar':
        return 'Asar';
      case 'magrib':
        return 'Magrib';
      case 'isa':
        return 'Isha';
      default:
        return prayer;
    }
  }

  void _showCreateKhaniDialog(BuildContext context) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPrayer = 'fajar';
    int durationDays = 30;
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
                  'duration_days': durationDays,
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
