import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/map/map_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/friends/friends_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'main.dart'; // for supabase instance

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // Simple auth check - if no user, show login
        if (supabase.auth.currentUser == null) {
          return const LoginScreen();
        }
        return const MapScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/groups',
      builder: (context, state) => const GroupsScreen(),
    ),
    GoRoute(
      path: '/messages',
      builder: (context, state) => const MessagesScreen(),
    ),
  ],
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final onLoginPage = state.uri.toString() == '/login';
    
    if (session == null && !onLoginPage) return '/login';
    if (session != null && onLoginPage) return '/map';
    return null;
  },
);
