import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId) 
        .order('created_at', ascending: false);


    setState(() {
      notifications = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔔 Notifications"),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications yet."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(notif['title'] ?? ''),
                    subtitle: Text(notif['message'] ?? ''),
                    trailing: Text(
                      DateTime.parse(notif['created_at']).toLocal().toString().split('.')[0],
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
  