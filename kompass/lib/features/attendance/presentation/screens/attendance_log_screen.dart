import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../data/models/roll_call_session_model.dart';
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
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    // Refresh countdown timer every second for active roll call session
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
        tour.canManageTour(currentUser.userId);
    final isPrimaryGuide = currentUser != null &&
        tour != null &&
        tour.isPrimaryGuide(currentUser.userId);

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

    final activeSessionAsync = ref.watch(activeRollCallSessionProvider(widget.tourId));
    final activeSession = activeSessionAsync.valueOrNull;
    final isSessionActive =
        activeSession != null && activeSession.isActive && !activeSession.isExpired;
    final isUserPresent =
        currentUser != null && latestPresentMap.containsKey(currentUser.userId);

    return Scaffold(
      appBar: KompassAppBar(
        title: 'Roll Call & Attendance',
        actions: [
          if (!isPrimaryGuide) ...[
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              tooltip: 'My QR Badge',
              onPressed: () => context.push('/tours/${widget.tourId}/qr'),
            ),
            if (!isUserPresent)
              IconButton(
                icon: const Icon(Icons.pin_outlined),
                tooltip: 'Enter 4-Digit Code',
                onPressed: () => _showEnterCodeDialog(context, activeSession),
              ),
          ],
          if (canManageAttendance) ...[
            IconButton(
              icon: Icon(
                isSessionActive ? Icons.timer : Icons.pin_outlined,
                color: isSessionActive ? AppColors.primaryGold : null,
              ),
              tooltip: isSessionActive
                  ? 'Active 4-Digit Roll Call Session'
                  : 'Start 4-Digit Roll Call Session',
              onPressed: () => _showStartSessionDialog(
                context,
                currentSession: activeSession,
              ),
            ),
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

          // ── 2. 4-Digit Roll Call Session Banner ──
          if (canManageAttendance)
            _buildGuideSessionSection(context, activeSession, isSessionActive)
          else
            _buildParticipantRollCallSection(
              context,
              activeSession,
              isSessionActive,
              isUserPresent,
            ),

          // ── 3. Participant Search Bar ──
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
              error: (e, _) => RefreshIndicator(
                color: AppColors.primaryGold,
                backgroundColor: AppColors.surface,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text('Error: $e')),
                  ],
                ),
              ),
              data: (_) {
                Widget tabBody;
                if (enrolledUsers.isEmpty && _currentFilter != AttendanceTabFilter.logs) {
                  tabBody = ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const SizedBox(height: 80),
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
                  );
                } else {
                  switch (_currentFilter) {
                    case AttendanceTabFilter.all:
                      tabBody = _buildParticipantList(
                        users: filteredAll,
                        latestPresentMap: latestPresentMap,
                        canManage: canManageAttendance,
                        emptyMessage: _searchQuery.isNotEmpty
                            ? 'No participants match "$_searchQuery"'
                            : 'No participants enrolled.',
                      );
                    case AttendanceTabFilter.present:
                      tabBody = _buildParticipantList(
                        users: filteredPresent,
                        latestPresentMap: latestPresentMap,
                        canManage: canManageAttendance,
                        emptyMessage: _searchQuery.isNotEmpty
                            ? 'No present participants match "$_searchQuery"'
                            : 'No participants marked present yet.',
                      );
                    case AttendanceTabFilter.absent:
                      tabBody = _buildParticipantList(
                        users: filteredAbsent,
                        latestPresentMap: latestPresentMap,
                        canManage: canManageAttendance,
                        emptyMessage: _searchQuery.isNotEmpty
                            ? 'No absent participants match "$_searchQuery"'
                            : 'Awesome! All enrolled participants are checked in.',
                      );
                    case AttendanceTabFilter.logs:
                      tabBody = _buildRawLogsList(
                        records: records,
                        canManage: canManageAttendance,
                      );
                  }
                }

                return RefreshIndicator(
                  color: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  onRefresh: _onRefresh,
                  child: tabBody,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canManageAttendance
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isSessionActive)
                  FloatingActionButton.extended(
                    heroTag: 'start_session_fab',
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.background,
                    onPressed: () => _showStartSessionDialog(context),
                    icon: const Icon(Icons.pin_outlined),
                    label: const Text(
                      'Start 4-Digit Session',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (!isSessionActive) const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'manual_checkin_fab',
                  onPressed: () => _showManualAttendanceDialog(
                    context,
                    enrolledUsers.isNotEmpty ? enrolledUsers : allUsers,
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Manual Check-In'),
                ),
              ],
            )
          : (!isUserPresent
              ? FloatingActionButton.extended(
                  heroTag: 'enter_code_fab',
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.background,
                  onPressed: () => _showEnterCodeDialog(context, activeSession),
                  icon: const Icon(Icons.pin_outlined),
                  label: const Text(
                    'Enter 4-Digit Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : null),
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

  Future<void> _onRefresh() async {
    ref.invalidate(tourAttendanceProvider(widget.tourId));
    ref.invalidate(tourDetailProvider(widget.tourId));
    ref.invalidate(allUsersProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Widget _buildParticipantList({
    required List<UserModel> users,
    required Map<String, AttendanceModel> latestPresentMap,
    required bool canManage,
    required String emptyMessage,
  }) {
    if (users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 100),
          Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 100),
          Text(
            'No attendance history records logged yet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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

  // ══════════════════════════════════════════════════════════════
  // ── 4-DIGIT ROLL CALL SESSION WIDGETS & DIALOGS ──
  // ══════════════════════════════════════════════════════════════

  Widget _buildGuideSessionSection(
    BuildContext context,
    RollCallSessionModel? session,
    bool isActive,
  ) {
    if (isActive && session != null) {
      final remaining = session.remainingDuration;
      final minutesStr = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
      final secondsStr = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
      final timeStr = '$minutesStr:$secondsStr';

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE ROLL CALL CODE',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.primaryGold),
                      const SizedBox(width: 4),
                      Text(
                        'Expires in $timeStr',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 4 Digits Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: session.code.split('').map((digit) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 52,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGold, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    digit,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.primaryGold,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: session.code));
                    AppToast.showSuccess('Code ${session.code} copied to clipboard!');
                  },
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.primaryGold),
                  label: const Text(
                    'Copy Code',
                    style: TextStyle(color: AppColors.primaryGold),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _confirmEndSession(context),
                  icon: const Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.error),
                  label: const Text(
                    'End Session',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // When no active session, show Start Session card for Guide
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pin_outlined, color: AppColors.primaryGold, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4-Digit Roll Call Session',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Generate a timed code for participants to mark themselves present.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showStartSessionDialog(context),
            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantRollCallSection(
    BuildContext context,
    RollCallSessionModel? session,
    bool isActive,
    bool isUserPresent,
  ) {
    if (isUserPresent) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checked In — Present',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your attendance has been recorded for this expedition.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final remaining = session != null ? session.remainingDuration : Duration.zero;
    final timeStr = isActive
        ? '${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}'
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryGold : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pin_invoke_outlined, color: AppColors.primaryGold, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Roll Call Check-In',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (isActive && timeStr != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          timeStr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? 'Live session active! Enter the 4-digit code from your Guide.'
                      : 'Enter the 4-digit code from your Guide to mark yourself Present.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showEnterCodeDialog(context, session),
            child: const Text('Enter Code', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStartSessionDialog(
    BuildContext context, {
    RollCallSessionModel? currentSession,
  }) {
    int selectedMinutes = 5; // Default: 5 minutes
    final customController = TextEditingController();
    bool isCustom = false;
    final currentUser = ref.read(currentUserProvider).valueOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final now = DateTime.now();
            final expiryTime = now.add(Duration(minutes: selectedMinutes));
            final expiryFormatted = DateFormat('h:mm a').format(expiryTime);

            final presets = [1, 2, 3, 5, 10, 15, 30];

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pin_outlined, color: AppColors.primaryGold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start 4-Digit Roll Call',
                              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Participants enter this code on their phones to check in',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'SESSION DURATION (DEFAULT: 5 MIN)',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...presets.map((mins) {
                        final isSelected = !isCustom && selectedMinutes == mins;
                        return ChoiceChip(
                          label: Text(mins == 5 ? '5 min (Default)' : '$mins min'),
                          selected: isSelected,
                          selectedColor: AppColors.primaryGold,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.background : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                isCustom = false;
                                selectedMinutes = mins;
                                customController.clear();
                              });
                            }
                          },
                        );
                      }),
                      ChoiceChip(
                        label: const Text('Custom...'),
                        selected: isCustom,
                        selectedColor: AppColors.primaryGold,
                        labelStyle: TextStyle(
                          color: isCustom ? AppColors.background : AppColors.textPrimary,
                          fontWeight: isCustom ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            isCustom = selected;
                          });
                        },
                      ),
                    ],
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration in minutes (1 - 120)',
                        suffixText: 'minutes',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val.trim());
                        if (parsed != null && parsed > 0 && parsed <= 120) {
                          setModalState(() {
                            selectedMinutes = parsed;
                          });
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.primaryGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Session will remain valid for $selectedMinutes minute${selectedMinutes > 1 ? 's' : ''} (until $expiryFormatted).',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'GENERATE 4-DIGIT CODE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      onPressed: () async {
                        try {
                          Navigator.pop(ctx);
                          final session = await ref
                              .read(attendanceControllerProvider.notifier)
                              .createRollCallSession(
                                tourId: widget.tourId,
                                guideId: currentUser?.userId ?? '',
                                guideName: currentUser?.name ?? 'Tour Guide',
                                durationMinutes: selectedMinutes,
                              );
                          AppToast.showSuccess(
                            'Session started! Code: ${session.code} (Expires in $selectedMinutes min)',
                          );
                        } catch (e) {
                          AppToast.showError('Failed to start session: $e');
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEnterCodeDialog(BuildContext context, RollCallSessionModel? session) {
    final codeController = TextEditingController();
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final remaining = session != null ? session.remainingDuration : Duration.zero;
            final isSessionActive = session != null && session.isActive && !session.isExpired;
            final timeStr = isSessionActive
                ? '${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                : null;

            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pin_invoke_outlined, color: AppColors.primaryGold, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Roll Call Check-In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter the 4-digit code announced or displayed by your Tour Guide:',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  if (isSessionActive && timeStr != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.primaryGold),
                        const SizedBox(width: 4),
                        Text(
                          'Session active • Expires in $timeStr',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 16,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryGold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final code = codeController.text.trim();
                          if (code.length != 4) {
                            AppToast.showError('Please enter a full 4-digit code.');
                            return;
                          }

                          if (currentUser == null) {
                            AppToast.showError('User session not found.');
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            await ref
                                .read(attendanceControllerProvider.notifier)
                                .verifyCodeAndCheckIn(
                                  tourId: widget.tourId,
                                  userId: currentUser.userId,
                                  enteredCode: code,
                                );
                            if (ctx.mounted) Navigator.pop(ctx);
                            AppToast.showSuccess('✓ Check-in successful! Marked as Present.');
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            final msg = e.toString().replaceFirst('Exception: ', '').replaceFirst('DatabaseException: ', '');
                            AppToast.showError(msg);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                        )
                      : const Text('Check In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmEndSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End Roll Call Session?'),
        content: const Text(
          'Ending this session will invalidate the 4-digit code. Participants who haven\'t checked in yet will not be able to use this code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(attendanceControllerProvider.notifier)
                    .endRollCallSession(widget.tourId);
                AppToast.showInfo('Roll call session ended.');
              } catch (e) {
                AppToast.showError('Failed to end session: $e');
              }
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}
