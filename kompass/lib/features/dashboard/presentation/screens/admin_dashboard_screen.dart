import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_lifecycle_helper.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/kompass_button.dart';
import '../../../../core/widgets/kompass_card.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../location/providers/location_providers.dart';
import '../../../../services/permissions/app_permission_service.dart';
import '../../../tour/providers/tour_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.name ?? 'Admin';
    final allUsersAsync = ref.watch(allUsersProvider);
    final toursAsync = ref.watch(toursProvider);
    final gpsStatus = ref.watch(gpsStatusProvider);

    final totalUsersCount = allUsersAsync.valueOrNull?.length ?? 0;
    final totalTours = toursAsync.valueOrNull ?? [];
    final activeToursCount =
        totalTours.where((t) => t.status.toLowerCase() == 'active').length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        if (kIsWeb) {
          AppPermissionService.instance.checkAndPromptWebNotifications(context: context);
        } else {
          AppPermissionService.instance.checkAndPromptBatteryOptimization(context: context);
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        AppLifecycleHelper.sendToBackground();
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              AppToast.showInfo('Signed out successfully.');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(currentUserProvider);
          ref.invalidate(allUsersProvider);
          ref.invalidate(toursProvider);
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            if (gpsStatus.isGpsDisabledWhenRequired) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: AppColors.primaryGold, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GPS Location is Turned Off',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryGold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tour tracking is active for your guided tour. Please turn on Location in Settings so participants can track your position.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
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
                      onPressed: () => Geolocator.openLocationSettings(),
                      child: const Text('Turn On', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
            Text('Welcome, $userName!', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: KompassCard(
                    margin: EdgeInsets.zero,
                    onTap: () => _showUserDirectorySheet(
                      context,
                      allUsersAsync.valueOrNull ?? [],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.people, color: AppColors.primaryGold, size: 28),
                        const SizedBox(height: 8),
                        Text('Total Users', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          allUsersAsync.isLoading ? '...' : '$totalUsersCount',
                          style: AppTextStyles.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_in_talk, size: 12, color: AppColors.primaryGold),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to Call',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KompassCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        const Icon(Icons.explore, color: AppColors.secondaryTealLight, size: 28),
                        const SizedBox(height: 8),
                        Text('Active / Total Tours', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          toursAsync.isLoading
                              ? '...'
                              : '$activeToursCount / ${totalTours.length}',
                          style: AppTextStyles.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expeditions',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            KompassButton(
              label: 'Create New Tour',
              icon: Icons.add,
              onPressed: () => context.push('/tours/create'),
            ),
            const SizedBox(height: 12),
            KompassButton(
              label: 'Manage All Tours',
              icon: Icons.list_alt,
              isOutlined: true,
              onPressed: () => context.push('/tours'),
            ),
            const SizedBox(height: 12),
            KompassButton(
              label: 'User Directory & Contact Dialer',
              icon: Icons.phone_forwarded,
              isOutlined: true,
              onPressed: () => _showUserDirectorySheet(
                context,
                allUsersAsync.valueOrNull ?? [],
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Tours', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            if (totalTours.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No tours created yet.')),
              )
            else
              ...totalTours.take(5).map(
                    (tour) => KompassCard(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      onTap: () => context.push('/tours/${tour.tourId}'),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tour.name, style: AppTextStyles.headlineMedium),
                        subtitle: Text(
                          'Status: ${tour.status} • Participants: ${tour.participantCount}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      AppToast.showWarning('No valid phone number found to call.');
      return;
    }
    final uri = Uri.parse('tel:$clean');
    try {
      if (kIsWeb) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppToast.showError('Could not open phone dialer: $e');
    }
  }

  void _showUserDirectorySheet(BuildContext context, List<UserModel> users) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        String searchQuery = '';
        String roleFilter = 'all';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredUsers = users.where((u) {
              if (roleFilter != 'all') {
                if (roleFilter == 'guide' && !u.isGuide) return false;
                if (roleFilter == 'participant' && !u.isParticipant) return false;
                if (roleFilter == 'admin' && !u.isAdmin) return false;
              }
              if (searchQuery.isNotEmpty) {
                final matchName = u.name.toLowerCase().contains(searchQuery);
                final matchEmail = u.email.toLowerCase().contains(searchQuery);
                final matchPhone = u.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '').contains(searchQuery);
                return matchName || matchEmail || matchPhone;
              }
              return true;
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User Directory & Dialer',
                          style: AppTextStyles.headlineLarge,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryGold, width: 0.8),
                          ),
                          child: Text(
                            '${users.length} Users',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search any user in KOMPASS and tap the phone button to launch the dialer instantly.',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (val) => setSheetState(() => searchQuery = val.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or phone...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryGold),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Users'),
                            selected: roleFilter == 'all',
                            onSelected: (_) => setSheetState(() => roleFilter = 'all'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Participants'),
                            selected: roleFilter == 'participant',
                            onSelected: (_) => setSheetState(() => roleFilter = 'participant'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Guides'),
                            selected: roleFilter == 'guide',
                            onSelected: (_) => setSheetState(() => roleFilter = 'guide'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Admins'),
                            selected: roleFilter == 'admin',
                            onSelected: (_) => setSheetState(() => roleFilter = 'admin'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredUsers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No users found matching "$searchQuery"',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                          ),
                        ),
                      )
                    else
                      ...filteredUsers.map((user) {
                        final hasPhone = user.phoneNumber.trim().isNotEmpty;
                        final hasEmergency = user.emergencyContact.trim().isNotEmpty;
                        final hasAddress = user.address.trim().isNotEmpty;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.border, width: 0.8),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: user.isAdmin
                                  ? AppColors.primaryGold.withValues(alpha: 0.25)
                                  : user.isGuide
                                      ? AppColors.secondaryTealLight.withValues(alpha: 0.2)
                                      : AppColors.surface,
                              backgroundImage: user.profileImage.isNotEmpty
                                  ? NetworkImage(user.profileImage)
                                  : null,
                              child: user.profileImage.isEmpty
                                  ? Icon(
                                      user.isAdmin
                                          ? Icons.admin_panel_settings
                                          : user.isGuide
                                              ? Icons.navigation
                                              : Icons.person_outline,
                                      size: 18,
                                      color: user.isAdmin
                                          ? AppColors.primaryGold
                                          : user.isGuide
                                              ? AppColors.secondaryTealLight
                                              : AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.isAdmin
                                        ? AppColors.primaryGold
                                        : user.isGuide
                                            ? AppColors.secondaryTealLight
                                            : AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: user.isAdmin
                                          ? AppColors.primaryGold
                                          : user.isGuide
                                              ? AppColors.secondaryTealLight
                                              : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    user.userRole.label,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: (user.isAdmin || user.isGuide)
                                          ? Colors.black
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email, style: AppTextStyles.bodySmall),
                                if (hasPhone)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 12, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.phoneNumber,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasPhone)
                                  IconButton(
                                    icon: const Icon(Icons.phone, color: AppColors.success, size: 20),
                                    tooltip: 'Call ${user.name}',
                                    onPressed: () => _makePhoneCall(user.phoneNumber),
                                  ),
                                if (hasEmergency)
                                  IconButton(
                                    icon: const Icon(Icons.phone_in_talk, color: AppColors.sosRed, size: 20),
                                    tooltip: 'Call Emergency Contact',
                                    onPressed: () => _makePhoneCall(user.emergencyContact),
                                  ),
                              ],
                            ),
                            children: [
                              const Divider(height: 12),
                              // 1. Personal Phone & Call row
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.primaryGold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Contact Number', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        Text(
                                          hasPhone ? user.phoneNumber : 'Not provided',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontWeight: hasPhone ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasPhone)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(0, 30),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      ),
                                      icon: const Icon(Icons.call, size: 13),
                                      label: const Text('Call', style: TextStyle(fontSize: 11)),
                                      onPressed: () => _makePhoneCall(user.phoneNumber),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 2. Address row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryGold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Address', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        Text(
                                          hasAddress ? user.address : 'Not provided',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 3. Gender & Age row
                              Row(
                                children: [
                                  const Icon(Icons.badge_outlined, size: 16, color: AppColors.primaryGold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Gender & Age', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                        Text(
                                          'Gender: ${user.gender.isNotEmpty ? user.gender : "Not provided"} • Age: ${user.age != null ? "${user.age} yrs" : "Not provided"}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 4. Emergency Contact row
                              Row(
                                children: [
                                  const Icon(Icons.emergency_outlined, size: 16, color: AppColors.sosRed),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Emergency: ${user.emergencyContactName.isNotEmpty ? user.emergencyContactName : "Contact"}',
                                          style: const TextStyle(fontSize: 10, color: AppColors.sosRed, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          hasEmergency ? user.emergencyContact : 'Not provided',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontWeight: hasEmergency ? FontWeight.w600 : FontWeight.normal,
                                            color: hasEmergency ? AppColors.textPrimary : AppColors.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasEmergency)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.sosRed,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(0, 30),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      ),
                                      icon: const Icon(Icons.phone_in_talk, size: 13),
                                      label: const Text('Call SOS', style: TextStyle(fontSize: 11)),
                                      onPressed: () => _makePhoneCall(user.emergencyContact),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
