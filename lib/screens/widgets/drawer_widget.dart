import 'package:flutter/material.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/screens/backup.dart';
import 'package:lit_reader/screens/log_screen.dart';
import 'package:lit_reader/screens/login.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 100,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Account'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Logs'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LogScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore),
                  title: const Text('Backup'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BackupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Text('V$versionString'),
                const SizedBox(width: 8),
                if (updateController.isUpdateAvailable)
                  Text(
                    'Update Available - V${updateController.latestVersion}',
                    style: const TextStyle(color: kRed, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            onTap: updateController.isUpdateAvailable
                ? () {
                    updateController.launchUpdateURL();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
