import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/dashboard/presentation/screens/guide_dashboard_screen.dart';
import '../features/dashboard/presentation/screens/participant_dashboard_screen.dart';
import '../features/tour/presentation/screens/tour_list_screen.dart';
import '../features/tour/presentation/screens/tour_detail_screen.dart';
import '../features/tour/presentation/screens/create_tour_screen.dart';
import '../features/itinerary/presentation/screens/itinerary_screen.dart';
import '../features/attendance/presentation/screens/qr_scanner_screen.dart';
import '../features/attendance/presentation/screens/qr_generator_screen.dart';
import '../features/attendance/presentation/screens/attendance_log_screen.dart';
import '../features/messaging/presentation/screens/chat_screen.dart';
import '../features/messaging/presentation/screens/announcements_screen.dart';
import '../features/location/presentation/screens/map_screen.dart';
import '../features/documents/presentation/screens/document_list_screen.dart';
import '../features/emergency/presentation/screens/sos_screen.dart';
import 'route_names.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Redirect away from auth pages if already logged in
      if (isLoggedIn && isAuthRoute) {
        // Route to appropriate dashboard based on role
        // This will be enhanced once the user profile is loaded
        return '/guide-dashboard';
      }

      return null;
    },
    routes: [
      // ── Auth Routes ──
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Dashboard Routes ──
      GoRoute(
        path: '/admin-dashboard',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/guide-dashboard',
        name: RouteNames.guideDashboard,
        builder: (context, state) => const GuideDashboardScreen(),
      ),
      GoRoute(
        path: '/participant-dashboard',
        name: RouteNames.participantDashboard,
        builder: (context, state) => const ParticipantDashboardScreen(),
      ),

      // ── Tour Routes ──
      GoRoute(
        path: '/tours',
        name: RouteNames.tours,
        builder: (context, state) => const TourListScreen(),
      ),
      GoRoute(
        path: '/tours/create',
        name: RouteNames.createTour,
        builder: (context, state) => const CreateTourScreen(),
      ),
      GoRoute(
        path: '/tours/:tourId',
        name: RouteNames.tourDetail,
        builder: (context, state) {
          final tourId = state.pathParameters['tourId']!;
          return TourDetailScreen(tourId: tourId);
        },
        routes: [
          GoRoute(
            path: 'itinerary',
            name: RouteNames.itinerary,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return ItineraryScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'attendance',
            name: RouteNames.attendance,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return AttendanceLogScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'scan',
            name: RouteNames.qrScanner,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return QRScannerScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'qr',
            name: RouteNames.qrGenerator,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return QRGeneratorScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'chat',
            name: RouteNames.chat,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return ChatScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'announcements',
            name: RouteNames.announcements,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return AnnouncementsScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'map',
            name: RouteNames.map,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return MapScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'documents',
            name: RouteNames.documents,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return DocumentListScreen(tourId: tourId);
            },
          ),
          GoRoute(
            path: 'sos',
            name: RouteNames.sos,
            builder: (context, state) {
              final tourId = state.pathParameters['tourId']!;
              return SOSScreen(tourId: tourId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
