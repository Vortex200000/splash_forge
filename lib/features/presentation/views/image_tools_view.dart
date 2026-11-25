import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/tools_strings.dart';
import '../../../core/di/service_locator.dart';
import '../state_management/image_tools_cubit.dart';

class ImageToolsView extends StatefulWidget {
  const ImageToolsView({super.key});
  @override
  State<ImageToolsView> createState() => _ImageToolsViewState();
}

class _ImageToolsViewState extends State<ImageToolsView> {
  final _w = TextEditingController(text: '960');
  final _h = TextEditingController(text: '960');

  @override
  void dispose() {
    _w.dispose();
    _h.dispose();
    super.dispose();
  }

  void _applySize(ImageToolsCubit cubit) {
    final w = int.tryParse(_w.text) ?? 960;
    final h = int.tryParse(_h.text) ?? 960;
    cubit.setSize(w, h);
    _w.text = cubit.state.width.toString();
    _h.text = cubit.state.height.toString();
  }

  void _preset(ImageToolsCubit cubit, int side) {
    _w.text = '$side';
    _h.text = '$side';
    cubit.setSize(side, side);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ImageToolsCubit>(),
      child: BlocConsumer<ImageToolsCubit, ImageToolsState>(
        listenWhen: (a, b) => b.message != null,
        listener: (context, s) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.message!))),
        builder: (context, s) {
          final cubit = context.read<ImageToolsCubit>();
          return Scaffold(
            appBar: AppBar(title: const Text(ToolsStrings.title)),
            body: ListView(padding: const EdgeInsets.all(16), children: [
              FilledButton.tonal(
                onPressed: () async {
                  final res = await FilePicker.platform
                      .pickFiles(type: FileType.image, withData: true);
                  final bytes = res?.files.single.bytes;
                  if (bytes != null) cubit.setImage(bytes);
                },
                child: const Text(ToolsStrings.chooseImage),
              ),
              if (s.source != null) ...[
                const SizedBox(height: 16),
                const Text(ToolsStrings.original),
                if (s.removeBg)
                  Text(ToolsStrings.tapToPick,
                      style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Builder(
                      builder: (ctx) => GestureDetector(
                        onTapDown: (d) {
                          if (!s.removeBg) return;
                          final box = ctx.findRenderObject() as RenderBox;
                          cubit.setPick(d.localPosition.dx / box.size.width,
                              d.localPosition.dy / box.size.height);
                        },
                        child: Stack(children: [
                          Image.memory(s.source!),
                          if (s.removeBg)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment(s.pickDx * 2 - 1, s.pickDy * 2 - 1),
                                child: const Icon(Icons.add_circle_outline,
                                    size: 22, color: Colors.redAccent),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(ToolsStrings.removeBg),
                  value: s.removeBg,
                  onChanged: cubit.setRemoveBg,
                ),
                if (s.removeBg) ...[
                  const Text(ToolsStrings.tolerance),
                  Slider(
                    value: s.tolerance,
                    max: 0.6,
                    onChanged: cubit.setTolerance,
                    onChangeEnd: (_) => cubit.process(),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(ToolsStrings.connectedOnly),
                    subtitle: const Text(ToolsStrings.connectedHelp),
                    value: s.contiguous,
                    onChanged: cubit.setContiguous,
                  ),
                ],
                const SizedBox(height: 8),
                const Text(ToolsStrings.size),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _w,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: ToolsStrings.width, border: OutlineInputBorder()),
                      onSubmitted: (_) => _applySize(cubit),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('×'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _h,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: ToolsStrings.height, border: OutlineInputBorder()),
                      onSubmitted: (_) => _applySize(cubit),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Apply',
                    icon: const Icon(Icons.check),
                    onPressed: () => _applySize(cubit),
                  ),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  for (final side in const [192, 512, 960, 1024, 1152])
                    ActionChip(
                      label: Text('$side'),
                      onPressed: () => _preset(cubit, side),
                    ),
                ]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(ToolsStrings.keepRatio),
                  subtitle: const Text(ToolsStrings.keepRatioHelp),
                  value: s.keepRatio,
                  onChanged: cubit.setKeepRatio,
                ),
                const SizedBox(height: 8),
                Text('${ToolsStrings.result} (${s.width} × ${s.height})'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    child: Stack(fit: StackFit.expand, children: [
                      CustomPaint(painter: _CheckerPainter()),
                      if (s.result != null)
                        Image.memory(s.result!, fit: BoxFit.contain),
                      if (s.busy)
                        const Center(child: CircularProgressIndicator()),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: s.busy ? null : cubit.save,
                  child: const Text(ToolsStrings.savePng),
                ),
              ],
            ]),
          );
        },
      ),
    );
  }
}

/// Grey squares so transparent areas are visible.
class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 12.0;
    final light = Paint()..color = const Color(0xFFF5F5F5);
    final dark = Paint()..color = const Color(0xFFDADADA);
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = 0; x * cell < size.width; x++) {
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          (x + y).isEven ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
