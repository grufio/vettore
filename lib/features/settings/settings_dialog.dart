import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/services/settings_service.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('API Settings'),
                    selected: true, // For now, it's the only option
                    onTap: () {
                      // In a future version, this would switch the view
                    },
                  ),
                ],
              ),
            ),
            const VerticalDivider(),
            const Expanded(child: _ApiSettingsView()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ApiSettingsView extends ConsumerStatefulWidget {
  const _ApiSettingsView();

  @override
  ConsumerState<_ApiSettingsView> createState() => __ApiSettingsViewState();
}

class __ApiSettingsViewState extends ConsumerState<_ApiSettingsView> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final settingsService = ref.read(settingsServiceProvider);
    _apiKeyController = TextEditingController(
      text: settingsService.geminiApiKey ?? '',
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = ref.watch(settingsServiceProvider);
    final isApiEnabled = settingsService.isGeminiApiEnabled;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('API Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable Google API'),
            value: isApiEnabled,
            onChanged: (value) {
              settingsService.setGeminiApiEnabled(value);
              setState(() {}); // Rebuild to update the UI
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'Google API Key',
              border: OutlineInputBorder(),
              hintText: 'Enter your API key here',
            ),
            enabled: isApiEnabled,
            onChanged: (value) {
              settingsService.setGeminiApiKey(value);
            },
          ),
        ],
      ),
    );
  }
}
