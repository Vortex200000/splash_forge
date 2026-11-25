import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../core/constants/settings_strings.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/helpers/color_helper.dart';
import '../../domain/entities/app_settings.dart';
import '../state_management/settings_cubit.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _controller = TextEditingController();
  final SettingsCubit _cubit = getIt<SettingsCubit>();

  @override
  void initState() {
    super.initState();
    _controller.text = _cubit.state.settings.folderName;
    _cubit.load().then((_) {
      if (mounted) _controller.text = _cubit.state.settings.folderName;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(t, style: Theme.of(context).textTheme.titleSmall),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      bloc: _cubit,
      listenWhen: (a, b) => b.message != null,
      listener: (context, s) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.message!)));
        _controller.text = s.settings.folderName;
      },
      builder: (context, s) {
        final st = s.settings;
        return Scaffold(
          appBar: AppBar(title: const Text(SettingsStrings.settings)),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Text(SettingsStrings.storage, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: SettingsStrings.outputFolder,
                helperText: SettingsStrings.folderHelp,
                helperMaxLines: 3,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _cubit.saveFolder(_controller.text),
              child: const Text(SettingsStrings.save),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(SettingsStrings.autoSave),
              subtitle: const Text(SettingsStrings.autoSaveHelp),
              value: st.autoSave,
              onChanged: _cubit.setAutoSave,
            ),
            _title(SettingsStrings.appearance),
            SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(value: AppThemeMode.system, label: Text(SettingsStrings.themeSystem)),
                ButtonSegment(value: AppThemeMode.light, label: Text(SettingsStrings.themeLight)),
                ButtonSegment(value: AppThemeMode.dark, label: Text(SettingsStrings.themeDark)),
              ],
              selected: {st.themeMode},
              onSelectionChanged: (v) => _cubit.setThemeMode(v.first),
            ),
            _title(SettingsStrings.previewLayout),
            SegmentedButton<PreviewMode>(
              segments: const [
                ButtonSegment(value: PreviewMode.both, label: Text(SettingsStrings.previewBoth)),
                ButtonSegment(value: PreviewMode.toggle, label: Text(SettingsStrings.previewToggle)),
              ],
              selected: {st.previewMode},
              onSelectionChanged: (v) => _cubit.setPreviewMode(v.first),
            ),
            _title(SettingsStrings.defaults),
            _ColorRow(SettingsStrings.splashLight, st.splashColor,
                (c) => _cubit.preview(st.copyWith(splashColor: c.toARGB32())), _cubit.persist),
            _ColorRow(SettingsStrings.splashDark, st.splashColorDark,
                (c) => _cubit.preview(st.copyWith(splashColorDark: c.toARGB32())), _cubit.persist),
            _ColorRow(SettingsStrings.iconBg, st.iconBgColor,
                (c) => _cubit.preview(st.copyWith(iconBgColor: c.toARGB32())), _cubit.persist),
            const SizedBox(height: 8),
            const Text(SettingsStrings.originalRoundness),
            Slider(
              value: st.k,
              max: 0.5,
              onChanged: (v) => _cubit.preview(st.copyWith(k: v)),
              onChangeEnd: (_) => _cubit.persist(),
            ),
            const Text(SettingsStrings.logoRadius),
            Slider(
              value: st.radius,
              max: 0.5,
              onChanged: (v) => _cubit.preview(st.copyWith(radius: v)),
              onChangeEnd: (_) => _cubit.persist(),
            ),
          ]),
        );
      },
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<Color> onChanged;
  final Future<void> Function() onDone;
  const _ColorRow(this.label, this.value, this.onChanged, this.onDone);

  @override
  Widget build(BuildContext context) {
    final color = Color(value);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(color.hex),
      trailing: CircleAvatar(backgroundColor: color),
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: SingleChildScrollView(
            child: ColorPicker(pickerColor: color, onColorChanged: onChanged),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      ).then((_) => onDone()),
    );
  }
}
