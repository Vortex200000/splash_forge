import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/helpers/color_helper.dart';
import '../state_management/splash_cubit.dart';
import '../state_management/splash_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SplashCubit>(),
      child: BlocConsumer<SplashCubit, SplashState>(
        listenWhen: (a, b) => b.message != null,
        listener: (context, s) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.message!))),
        builder: (context, s) {
          final cubit = context.read<SplashCubit>();
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.appName)),
            body: ListView(padding: const EdgeInsets.all(16), children: [
              FilledButton.tonal(
                onPressed: () async {
                  final res = await FilePicker.platform
                      .pickFiles(type: FileType.image, withData: true);
                  final bytes = res?.files.single.bytes;
                  if (bytes != null) cubit.setLogo(bytes);
                },
                child: const Text(AppStrings.pickLogo),
              ),
              const SizedBox(height: 16),
              _ColorTile(AppStrings.splashColor, s.splashColor, cubit.setSplashColor),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(AppStrings.useIconBg),
                value: s.useIconBg,
                onChanged: cubit.setUseIconBg,
              ),
              if (s.useIconBg)
                _ColorTile(AppStrings.iconBgColor, s.iconBgColor, cubit.setIconBgColor),
              const Text(AppStrings.roundness),
              Slider(
                value: s.k,
                max: 0.5,
                onChanged: cubit.setK,
                onChangeEnd: (_) => cubit.regenerate(),
              ),
              const Text(AppStrings.logoRadius),
              Slider(
                value: s.radius,
                max: 0.5,
                onChanged: cubit.setRadius,
                onChangeEnd: (_) => cubit.regenerate(),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _Phone(AppStrings.android12, s.splashColor, s.android12,
                    circle: s.useIconBg ? s.iconBgColor : null, useCircle: true),
                _Phone(AppStrings.legacy, s.splashColor, s.legacy),
              ]),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: s.busy ? null : cubit.export,
                child: s.busy
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(AppStrings.export),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onPick;
  const _ColorTile(this.label, this.color, this.onPick);

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(color.hex),
        trailing: CircleAvatar(backgroundColor: color),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(pickerColor: color, onColorChanged: onPick),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        ),
      );
}

class _Phone extends StatelessWidget {
  final String label;
  final Color bg;
  final Uint8List? image;
  final Color? circle;
  final bool useCircle;
  const _Phone(this.label, this.bg, this.image, {this.circle, this.useCircle = false});

  @override
  Widget build(BuildContext context) {
    // phone is 150px wide for a 360dp screen (x0.4167)
    // Android 12 icon area: 240dp with bg, 288dp without -> circle mask
    final area = circle != null ? 100.0 : 120.0;
    Widget content = const SizedBox();
    if (image != null) {
      content = useCircle
          ? ClipOval(
              child: Container(
                width: area, height: area, color: circle,
                child: Image.memory(image!, fit: BoxFit.contain),
              ),
            )
          : SizedBox(width: 100, height: 100, child: Image.memory(image!, fit: BoxFit.contain));
    }
    return Column(children: [
      Container(
        width: 150, height: 300, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF27272A), width: 5),
        ),
        child: content,
      ),
      const SizedBox(height: 8),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ]);
  }
}
