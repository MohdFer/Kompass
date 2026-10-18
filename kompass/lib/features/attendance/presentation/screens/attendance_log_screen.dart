import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/attendance_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_app_bar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../tour/providers/tour_providers.dart';
import '../../data/models/attendance_model.dart';
import '../../providers/attendance_providers.dart';

final userNameProvider = FutureProvider.family<String, String>((ref, userId) async {
  final user = await ref.read(authRepositoryProvider).getUserData(userId);
  return user?.name ?? userId;
});

enum AttendanceTabFilter { all, present, absent, logs }

class AttendanceLogScreen extends ConsumerStatefulWidget {
  const AttendanceLogScreen({required this.tourId, super.key});
  final String tourId;

  @override
  ConsumerState<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends ConsumerState<AttendanceLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  AttendanceTabFilter _currentFilter = AttendanceTabFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(tourAttendanceProvider(widget.tourId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final tour = ref.watch(tourDetailProvider(widget.tourId)).valueOrNull;
    final allUsers = ref.watch(allUsersProvider).valueOrNull ?? [];

    final canManageAttendance = currentUser != null &&
        tour != null &&
        tour.guideId == currentUser.userId;

    final records = attendanceAsync.valueOrNull ?? [];

    // Map enrolled participants from all users
    final enrolledParticipantIds = tour?.participantIds ?? [];
    final enrolledUsers = allUsers
        .where((u) => enrolledParticipantIds.contains(u.userId))
        .toList();

    // Latest present record per user
    final Map<String, AttendanceModel> latestPresentMap = {};
    for (final r in records) {
      if (r.status == 'Present') {
        if (!latestPresentMap.containsKey(r.userId) ||
            (r.timestamp != null &&
                (latestPresentMap[r.userId]?.timestamp == null ||
                    r.timestamp!.isAfter(latestPresentMap[r.userId]!.timestamp!)))) {
          latestPresentMap[r.userId] = r;
        }
      }
    }

    final presentUsers = enrolledUsers
        .where((u) => latestPresentMap.containsKey(u.userId))
        .toList();

    final absentUsers = enrolledUsers
        .where((u) => !latestPresentMap.containsKey(u.userId))
        .toList();

    final totalCount = enrolledUsers.length;
    final presentCount = presentUsers.length;
    final absentCount = absentUsers.length;
    final checkInPercentage =
        totalCount > 0 ? (presentCount / totalCount) : 0.0;

    // Filter by search query
    bool matchesSearch(UserModel user) {
      if (_searchQuery.isEmpty) return true;
      return user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery);
    }

    final filteredAll = enrolledUsers.where(matchesSearch).toList();
    final filteredPresent = presentUsers.where(matchesSearch).toList();
    final filteredAbsent = absentUsers.where(matchesSearch).toList();

    return Scaffold(
      appBar: KompassAppBar(
        title: 'Roll Call & Attendance',
        actions: [
          if (!canManageAttendance)
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              tooltip: 'My QR Badge',
              onPressed: () => context.push('/tours/${widget.tourId}/qr'),
            ),
          if (canManageAttendance) ...[
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan Participant QR Code',
              onPressed: () => context.push('/tours/${widget.tourId}/scan'),
            ),
            if (records.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                tooltip: 'Clear All Attendance Logs',
                onPressed: () => _confirmClearLogs(context),
              ),
          ],
        ],
      ),
      body: Column(
        children: [
          // ── 1. Analytics & Summary Header ──
          _buildAnalyticsHeader(
            totalCount: totalCount,
            presentCount: presentCount,
            absentCount: absentCount,
            percentage: checkInPercentage,
          ),

          // ── 2. Participant Search Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search participants by name or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── 3. Category Filter Chips ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All ($totalCount)',
                  tab: AttendanceTabFilter.all,
                  icon: Icons.people_outline,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Present ($presentCount)',
                  tab: AttendanceTabFilter.present,
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Absent ($absentCount)',
                  tab: AttendanceTabFilter.absent,
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Raw Logs (${records.length})',
                  tab: AttendanceTabFilter.logs,
                  icon: Icons.history,
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── 4. Main Tab Content ──
          Expanded(
            child: attendanceAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) {
                if (enrolledUsers.isEmpty && _currentFilter != AttendanceTabFilter.logs) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.group_off_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'No participants enrolled in this tour yet.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Invite participants via email or share the Tour Code to begin roll call.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                switch (_currentFilter) {
                  case AttendanceTabFilter.all:
                    return _buildParticipantList(
                      users: filteredAll,
                      latestPresentMap: latestPresentMap,
                      canManage: canManageAttendance,
                      emptyMessage: _searchQuery.isNotEmpty
                          ? 'No participants match "$_searchQuery"'
                          : 'No participants enrolled.',
                    );
                  case AttendanceTabFilter.present:
                    return _buildParticipantList(
                      users: filteredPresent,
                      latestPresentMap: latestPresentMap,
                      canManage: canManageAttendance,
                      emptyMessage: _searchQuery.isNotEmpty
                          ? 'No present participants match "$_searchQuery"'
                          : 'No participants marked present yet.',
                    );
                  case AttendanceTabFilter.absent:
                    return _buildParticipantList(
                      users: filteredAbsent,
                      latestPresentMap: latestPresentMap,
                      canManage: canManageAttendance,
                      emptyMessage: _searchQuery.isNotEmpty
                          ? 'No absent participants match "$_searchQuery"'
                          : 'Awesome! All enrolled participants are checked in.',
                    );
                  case AttendanceTabFilter.logs:
                    return _buildRawLogsList(
                      records: records,
                      canManage: canManageAttendance,
                    );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canManageAttendance
          ? FloatingActionButton.extended(
              onPressed: () => _showManualAttendanceDialog(
                context,
                enrolledUsers.isNotEmpty ? enrolledUsers : allUsers,
              ),
              icon: const Icon(Icons.edit_note),
              label: const Text('Manual Check-In'),
            )
          : null,
    );
  }

  Widget _buildAnalyticsHeader({
    required int totalCount,
    required int presentCount,
    required int absentCount,
    required double percentage,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Roll Call Analytics',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${(percentage * 100).round()}% Checked In',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage == 1.0 ? AppColors.success : AppColors.primaryGold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Enrolled',
                  value: '$totalCount',
                  icon: Icons.groups_outlined,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Present',
                  value: '$presentCount',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Absent',
                  value: '$absentCount',
                  icon: Icons.cancel_outlined,
                  color: absentCount > 0 ? AppColors.error : AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required AttendanceTabFilter tab,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = _currentFilter == tab;
    final activeColor = color ?? AppColors.primaryGold;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _currentFilter = tab),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.black : (color ?? AppColors.textSecondary),
      ),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.black : AppColors.textPrimary,
      ),
      selectedColor: activeColor,
      backgroundColor: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildParticipantList({
    required List<UserModel> users,
    required Map<String, AttendanceModel> latestPresentMap,
    required bool canManage,
    required String emptyMessage,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final record = latestPresentMap[user.userId];
        final isPresent = record != null;

        final timeString = record?.timestamp != null
            ? DateFormat('hh:mm a').format(record!.timestamp!)
            : '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.15),
              child: Icon(
                isPresent ? Icons.check : Icons.close,
                color: isPresent ? AppColors.success : AppColors.error,
              ),
            ),
            title: Text(user.name, style: AppTextStyles.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: AppTextStyles.bodySmall),
                if (isPresent)
                  Text(
                    'Checked in via ${record.method}${timeString.isNotEmpty ? ' at $timeString' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Status: Not checked in (Absent)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
            trailing: canManage
                ? (isPresent
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 20, color: AppColors.error),
                        tooltip: 'Remove Attendance Check-In',
                        onPressed: () async {
                          try {
                            await ref
                                .read(attendanceControllerProvider.notifier)
                                .deleteRecord(widget.tourId, record.attendanceId);
                            AppToast.showInfo('Check-in removed for ${user.name}.');
                          } catch (e) {
                            AppToast.showError('Failed to remove check-in: $e');
                          }
                        },
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(100, 34),
                        ),
                        onPressed: () async {
                          try {
                            await ref
                                .read(attendanceControllerProvider.notifier)
                                .markAttendance(
                                  tourId: widget.tourId,
                                  userId: user.userId,
                                  method: 'Manual',
                                  status: 'Present',
                                );
                            AppToast.showSuccess('Marked ${user.name} as Present!');
                          } catch (e) {
                            AppToast.showError('Failed to mark attendance: $e');
                          }
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Mark Present', style: TextStyle(fontSize: 12)),
                      ))
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPresent
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPresent ? 'Present' : 'Absent',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isPresent ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRawLogsList({
    required List<AttendanceModel> records,
    required bool canManage,
  }) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No attendance history records logged yet.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final userNameAsync = ref.watch(userNameProvider(record.userId));

        final timeString = record.timestamp != null
            ? DateFormat('MMM dd, yyyy - hh:mm a').format(record.timestamp!)
            : 'Just now';

        final isPresent = record.status == 'Present';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent
                  ? AppColors.primaryGoldLight
                  : AppColors.warning,
              child: Icon(
                isPresent ? Icons.check : Icons.access_time,
                color: AppColors.textOnPrimary,
              ),
            ),
            title: userNameAsync.when(
              data: (name) => Text(name, style: AppTextStyles.titleMedium),
              loading: () => const Text('Loading...'),
              error: (_, __) => Text(record.userId),
            ),
            subtitle: Text(
              'Method: ${record.method} • Status: ${record.status}\nTime: $timeString',
              style: AppTextStyles.bodySmall,
            ),
            trailing: canManage
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    tooltip: 'Remove log entry',
                    onPressed: () async {
                      try {
                        await ref
                            .read(attendanceControllerProvider.notifier)
                            .deleteRecord(widget.tourId, record.attendanceId);
                        AppToast.showInfo('Log entry removed.');
                      } catch (e) {
                        AppToast.showError('Failed to remove record: $e');
                      }
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  void _confirmClearLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Roll Call Logs?'),
          content: const Text(
            'Are you sure you want to delete all attendance records for this tour? This will reset all check-ins.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await ref
                      .read(attendanceControllerProvider.notifier)
                      .clearAttendance(widget.tourId);
                  AppToast.showSuccess('All roll call logs cleared.');
                } catch (e) {
                  AppToast.showError('Failed to clear logs: $e');
                }
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showManualAttendanceDialog(
    BuildContext context,
    List<UserModel> selectableUsers,
  ) {
    String? selectedUserId =
        selectableUsers.isNotEmpty ? selectableUsers.first.userId : null;
    String selectedStatus = AttendanceStatus.present.label;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manual Roll Call Check-In'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectableUsers.isEmpty)
                    const Text('No participants found.')
                  else
                    DropdownButtonFormField<String>(
                      value: selectedUserId,
                      decoration: const InputDecoration(labelText: 'Participant'),
                      items: selectableUsers
                          .map((u) => DropdownMenuItem(
                                value: u.userId,
                                child: Text('${u.name} (${u.role})'),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedUserId = val),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: AttendanceStatus.values
                        .map((s) => DropdownMenuItem(
                              value: s.label,
                              child: Text(s.label),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedStatus = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedUserId == null
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(attendanceControllerProvider.notifier)
                                .markAttendance(
                                  tourId: widget.tourId,
                                  userId: selectedUserId!,
                                  method: 'Manual',
                                  status: selectedStatus,
                                );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            AppToast.showSuccess(
                              'Marked attendance ($selectedStatus) successfully!',
                            );
                          } catch (e) {
                            AppToast.showError('Failed to mark attendance: $e');
                          }
                        },
                  child: const Text('Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
