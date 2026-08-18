import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class KhaniDetailsScreen extends StatefulWidget {
  const KhaniDetailsScreen({super.key});

  @override
  State<KhaniDetailsScreen> createState() => _KhaniDetailsScreenState();
}

class _KhaniDetailsScreenState extends State<KhaniDetailsScreen> {
  late TextEditingController _sawabController;

  @override
  void initState() {
    super.initState();
    _sawabController = TextEditingController();
  }

  @override
  void dispose() {
    _sawabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final khaniId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khani Details'),
        actions: [
          if (khaniProvider.selectedKhani?.isActive == true) ...[
            IconButton(
              icon: const Icon(Icons.live_tv, color: Colors.red),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/start-live-dua',
                  arguments: khaniProvider.selectedKhani!.id,
                );
              },
              tooltip: 'Start Live Dua',
            ),
            IconButton(
              icon: const Icon(Icons.stop_circle),
              onPressed: () => _showEndKhaniDialog(context, khaniId),
              tooltip: 'End Khani',
            ),
          ]
        ],
      ),
      body: khaniProvider.isLoading && khaniProvider.selectedKhani == null
          ? const Center(child: CircularProgressIndicator())
          : khaniProvider.selectedKhani == null
              ? const Center(child: Text('Khani not found'))
              : RefreshIndicator(
                  onRefresh: () => khaniProvider.fetchKhaniDetails(khaniId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKhaniInfoCard(context, khaniProvider.selectedKhani!),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text(
                              'Para Assignments',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Total: ${khaniProvider.khaniAssignments.length}/30',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDurationInfo(khaniProvider.selectedKhani!),
                        const SizedBox(height: 16),
                        if (khaniProvider.khaniAssignments.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No para assignments yet'),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: 30,
                            itemBuilder: (context, index) {
                              final paraNum = index + 1;
                              final assignment = khaniProvider.khaniAssignments
                                  .firstWhere(
                                (a) => a.paraNumber == paraNum,
                                orElse: () => ParaAssignment(
                                  id: '',
                                  khaniId: '',
                                  paraNumber: paraNum,
                                  userId: '',
                                  status: 'unassigned',
                                  createdAt: DateTime.now(),
                                ),
                              );
                              final isAssigned = assignment.id.isNotEmpty;
                              final isCompleted =
                                  assignment.status == 'completed';

                              return GestureDetector(
                                onTap: isAssigned && !isCompleted
                                    ? () => _completePara(context, assignment.id)
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green
                                        : isAssigned
                                            ? Colors.orange
                                            : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCompleted
                                          ? Colors.green
                                          : isAssigned
                                              ? Colors.orange
                                              : Colors.grey[400]!,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$paraNum',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isCompleted || isAssigned
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (isCompleted)
                                          const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        else if (isAssigned)
                                          Icon(
                                            Icons.pending,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                        const Text(
                          'Essalay Sawab Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _sawabController,
                          decoration: const InputDecoration(
                            labelText: 'Sawab Details',
                            border: OutlineInputBorder(),
                            hintText: 'Enter Essalay Sawab details...',
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (_sawabController.text.trim().isEmpty) return;
                            final success =
                                await khaniProvider.saveSawabDetails(
                              khaniId,
                              _sawabController.text.trim(),
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sawab details saved!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text('Save Sawab Details'),
                        ),
                        if (khaniProvider.sawabDetails != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Card(
                              color: Colors.amber[50],
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saved Details:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(khaniProvider.sawabDetails!.details),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildKhaniInfoCard(BuildContext context, Khani khani) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              khani.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text('Start: ${khani.startDate} at ${khani.startTime}'),
              ],
            ),
            const SizedBox(height: 8),
            if (khani.location != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(khani.location!)),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text('After ${_formatPrayer(khani.prayerAfter)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timelapse, size: 18),
                const SizedBox(width: 8),
                Text('${khani.durationDays} days'),
              ],
            ),
            if (khani.description != null) ...[
              const SizedBox(height: 8),
              Text(khani.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInfo(Khani khani) {
    final start = DateTime.parse(khani.startDate);
    final end = start.add(Duration(days: khani.durationDays));
    final remaining = end.difference(DateTime.now()).inDays;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                remaining > 0
                    ? '$remaining days remaining (ends ${end.toString().split(' ')[0]})'
                    : 'Duration completed',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
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

  void _completePara(BuildContext context, String assignmentId) async {
    final khaniProvider = Provider.of<KhaniProvider>(context, listen: false);
    final success = await khaniProvider.completePara(assignmentId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Para marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEndKhaniDialog(BuildContext context, String khaniId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Quran Khani'),
        content: const Text('Are you sure you want to end this Quran Khani?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final api = ApiService();
                await api.post('/khanis/$khaniId/end', {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quran Khani ended'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Provider.of<KhaniProvider>(context, listen: false)
                      .fetchKhaniDetails(khaniId);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton(
              style: ElevatedButton(backgroundColor: Colors.red),
            ),
            child: const Text('End'),
          ),
        ],
      ),
    );
  }
}
