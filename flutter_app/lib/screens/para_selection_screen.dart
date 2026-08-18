import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';
import '../providers/auth_provider.dart';
import '../models/app_models.dart';

class ParaSelectionScreen extends StatelessWidget {
  const ParaSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final activeKhani = khaniProvider.khanis.firstWhere(
      (k) => k.status == 'scheduled' || k.status == 'live',
      orElse: () => khaniProvider.khanis.isNotEmpty
          ? khaniProvider.khanis.first
          : Khani(
              id: '',
              title: '',
              startDate: '',
              startTime: '',
              prayerAfter: '',
              durationMinutes: 60,
              status: 'scheduled',
              joinCode: '',
              createdBy: '',
              createdAt: DateTime.now(),
            ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Para'),
      ),
      body: activeKhani.id.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No active Quran Khani available',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await khaniProvider.fetchKhaniDetails(activeKhani.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeKhani.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Duration: ${activeKhani.durationMinutes} minutes'),
                            Text('Start: ${activeKhani.startDate} at ${activeKhani.startTime}'),
                            if (activeKhani.joinCode.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.vpn_key, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Code: ${activeKhani.joinCode}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          '30 Paras',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total Duration: ${activeKhani.durationMinutes} minutes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Member Code: ${authProvider.user?.memberCode ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1.2,
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
                        final isMyAssignment =
                            assignment.userId == authProvider.user?.id;

                        if (isAssigned && !isMyAssignment) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '$paraNum',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }

                        if (isCompleted) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$paraNum',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (isAssigned && isMyAssignment) {
                          return ElevatedButton(
                            onPressed: () => _showCompleteDialog(
                              context,
                              activeKhani.id,
                              paraNum,
                              assignment.id,
                            ),
                            style: ElevatedButton(
                              style: ElevatedButton(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                            child: Text(
                              '$paraNum',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return ElevatedButton(
                          onPressed: () =>
                              _assignPara(context, activeKhani.id, paraNum),
                          style: ElevatedButton(
                            style: ElevatedButton(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          child: Text(
                            '$paraNum',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _assignPara(
      BuildContext context, String khaniId, int paraNumber) async {
    final khaniProvider = Provider.of<KhaniProvider>(context, listen: false);
    final success = await khaniProvider.assignPara(khaniId, paraNumber);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Para $paraNumber assigned!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCompleteDialog(
      BuildContext context, String khaniId, int paraNumber, String assignmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Para $paraNumber?'),
        content: const Text(
          'Mark this para as completed? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final khaniProvider =
                  Provider.of<KhaniProvider>(context, listen: false);
              final success =
                  await khaniProvider.completePara(assignmentId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Para $paraNumber marked as completed!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton(backgroundColor: Colors.green),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
