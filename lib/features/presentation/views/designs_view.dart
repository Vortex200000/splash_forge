import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/settings_strings.dart';
import '../../../core/di/service_locator.dart';
import '../state_management/designs_cubit.dart';

class DesignsView extends StatefulWidget {
  const DesignsView({super.key});
  @override
  State<DesignsView> createState() => _DesignsViewState();
}

class _DesignsViewState extends State<DesignsView> {
  final DesignsCubit _cubit = getIt<DesignsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.myDesigns)),
      body: BlocConsumer<DesignsCubit, DesignsState>(
        bloc: _cubit,
        listenWhen: (a, b) => b.message != null,
        listener: (context, s) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.message!))),
        builder: (context, s) {
          if (s.loading && s.designs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.designs.isEmpty) {
            return const Center(child: Text(SettingsStrings.empty));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: s.designs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = s.designs[i];
              final thumb = d.thumbnail;
              return ListTile(
                leading: SizedBox(
                  width: 52,
                  height: 52,
                  child: thumb == null
                      ? const Icon(Icons.image_not_supported_outlined)
                      : Image.file(File(thumb), fit: BoxFit.contain),
                ),
                title: Text(d.name),
                subtitle: Text(d.createdAt.toString().substring(0, 16)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _cubit.delete(d.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
