import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../data/models/tour_model.dart';
import '../providers/tour_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class CreateTourScreen extends ConsumerStatefulWidget {
  const CreateTourScreen({super.key});

  @override
  ConsumerState<CreateTourScreen> createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends ConsumerState<CreateTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final newTour = TourModel(
        tourId: '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        guideId: user.userId,
        status: 'Draft',
        createdAt: DateTime.now(),
      );

      await ref.read(tourControllerProvider.notifier).createTour(newTour);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KompassAppBar(title: 'Create Tour'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tour Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_startDate == null ? 'Select Start Date' : _startDate!.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _startDate = date);
                },
              ),
              ListTile(
                title: Text(_endDate == null ? 'Select End Date' : _endDate!.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _endDate = date);
                },
              ),
              const SizedBox(height: 32),
              KompassButton(
                text: 'Create Tour',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
