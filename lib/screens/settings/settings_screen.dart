import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoPlay = true;
  bool _backgroundPlay = true;
  bool _locationPermission = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Auto Play'),
            subtitle: const Text('Enter area to play music automatically'),
            trailing: Switch(
              value: _autoPlay,
              onChanged: (value) {
                setState(() {
                  _autoPlay = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Background Play'),
            subtitle: const Text('Play music in background'),
            trailing: Switch(
              value: _backgroundPlay,
              onChanged: (value) {
                setState(() {
                  _backgroundPlay = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Location Permission'),
            subtitle: const Text('Allow app to access location'),
            trailing: Switch(
              value: _locationPermission,
              onChanged: (value) {
                setState(() {
                  _locationPermission = value;
                });
                // TODO: 位置情報の許可を要求
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Music Out v1.0.0'),
            onTap: () {
              // TODO: アプリ情報を表示
            },
          ),
        ],
      ),
    );
  }
} 