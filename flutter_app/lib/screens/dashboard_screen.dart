import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/khani_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final khaniProvider = Provider.of<KhaniProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await khaniProvider.fetchNotifications();
              if (context.mounted) {
                Navigator.pushNamed(context, '/notifications');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => khaniProvider.fetchKhanis(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserCard(context, authProvider.user!),
              const SizedBox(height: 24),
              const Text(
                'My Assignments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (khaniProvider.assignments.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No assignments yet'),
                  ),
                )
              else
                ...khaniProvider.assignments.map((assignment) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text('${assignment.paraNumber}'),
                        ),
                        title: Text('Para ${assignment.paraNumber}'),
                        subtitle: Text(
                          assignment.status == 'completed'
                              ? 'Completed'
                              : 'Assigned - ${assignment.khaniId.substring(0, 8)}...',
                        ),
                        trailing: Icon(
                          assignment.status == 'completed'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: assignment.status == 'completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/khanis'),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('View Khanis'),
                      style: ElevatedButton(
                        style: ElevatedButton(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/para-selection'),
                      icon: const Icon(Icons.checklist),
                      label: const Text('Select Para'),
                      style: ElevatedButton(
                        style: ElevatedButton(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/live-dua'),
                icon: const Icon(Icons.live_tv, color: Colors.red),
                label: const Text('Live Dua'),
                style: ElevatedButton(
                  style: ElevatedButton(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Code: ${user.memberCode}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
