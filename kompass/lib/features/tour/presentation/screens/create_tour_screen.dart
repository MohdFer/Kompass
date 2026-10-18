import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';

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
  bool _isPublic = true;
  bool _requireJoinApproval = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      AppToast.showWarning(
        'Please select both a Start Date and an End Date.',
        context: context,
      );
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      AppToast.showError(
        'User profile not loaded. Please try again.',
        context: context,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final newTour = TourModel(
      tourId: '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      guideId: user.userId,
      status: 'Active',
      isPublic: _isPublic,
      requireJoinApproval: _requireJoinApproval,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(tourControllerProvider.notifier).createTour(newTour);
      AppToast.showSuccess(
        '${_isPublic ? 'Public' : 'Private'} tour "${newTour.name}" created successfully!',
      );
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          'Failed to create tour: $e',
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_isPublic ? 'Public Tour' : 'Private Tour'),
                subtitle: Text(
                  _isPublic
                      ? 'Listed in Join Tour for anyone to discover'
                      : 'Hidden from public list — join only using Tour Code',
                ),
                secondary: Icon(
                  _isPublic ? Icons.public : Icons.lock_outline,
                  color: AppColors.primaryGold,
                ),
                value: _isPublic,
                activeColor: AppColors.primaryGold,
                onChanged: (val) => setState(() => _isPublic = val),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _requireJoinApproval
                      ? 'Require Guide Approval to Join'
                      : 'Auto-Admit Joinees Using Code',
                ),
                subtitle: Text(
                  _requireJoinApproval
                      ? 'Joinees using the Tour Code send a request that you must Accept or Decline'
                      : 'All joinees entering a valid Tour Code are admitted automatically',
                ),
                secondary: Icon(
                  _requireJoinApproval
                      ? Icons.how_to_reg_outlined
                      : Icons.bolt_outlined,
                  color: AppColors.primaryGold,
                ),
                value: _requireJoinApproval,
                activeColor: AppColors.primaryGold,
                onChanged: (val) =>
                    setState(() => _requireJoinApproval = val),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start: ${_startDate!.toString().split(' ')[0]}',
                ),
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
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End: ${_endDate!.toString().split(' ')[0]}',
                ),
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
                label: 'Create Tour',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
