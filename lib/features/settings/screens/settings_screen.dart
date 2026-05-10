import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final quoteState = ref.watch(quoteControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 32),
              _SettingsSection(
                title: 'Preferences',
                children: [
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                    isDark: isDark,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                  const SizedBox(height: 12),
                  _NotificationTile(
                    isDark: isDark,
                    isEnabled: notificationsEnabled,
                    onToggle: () async {
                      final notifService = ref.read(notificationServiceProvider);
                      final newState = !notificationsEnabled;
                      if (newState) {
                        try {
                          final hasPermission = await notifService.requestPermission();
                          if (hasPermission && quoteState.quote != null) {
                            await notifService.scheduleDailyNotification(
                              hour: ref.read(notificationHourProvider),
                              minute: ref.read(notificationMinuteProvider),
                              quote: quoteState.quote!,
                            );
                            ref.read(notificationsEnabledProvider.notifier).state = true;
                          }
                        } catch (e) {
                          ref.read(notificationsEnabledProvider.notifier).state = false;
                        }
                      } else {
                        await notifService.cancelAll();
                        ref.read(notificationsEnabledProvider.notifier).state = false;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (notificationsEnabled)
                    _TimePickerTile(
                      isDark: isDark,
                      hour: ref.watch(notificationHourProvider),
                      minute: ref.watch(notificationMinuteProvider),
                      onTimeChanged: (hour, minute) async {
                        ref.read(notificationHourProvider.notifier).state = hour;
                        ref.read(notificationMinuteProvider.notifier).state = minute;
                        final notifService = ref.read(notificationServiceProvider);
                        if (quoteState.quote != null) {
                          await notifService.scheduleDailyNotification(
                            hour: hour,
                            minute: minute,
                            quote: quoteState.quote!,
                          );
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _SettingsSection(
                title: 'About',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildFooter(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E1B2E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customize your experience',
              style: GoogleFonts.lato(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF9B9B9B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/icon1.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quotify',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E1B2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with ❤️',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: isDark ? Colors.white38 : const Color(0xFF9B9B9B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9F7AEA), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E1B2E),
                )),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : const Color(0xFF6B6B7B),
                )),
          ])),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : const Color(0xFF9B9B9B), size: 22),
          ),
        ]),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B5CF6),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final bool isDark;
  final bool isEnabled;
  final VoidCallback onToggle;

  const _NotificationTile({
    required this.isDark,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? const LinearGradient(colors: [Color(0xFF9F7AEA), Color(0xFF6366F1)])
                  : null,
              color: isEnabled
                  ? null
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: isEnabled
                  ? Colors.white
                  : (isDark ? Colors.white54 : const Color(0xFF6B6B7B)),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daily Reminder',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E1B2E),
                )),
            const SizedBox(height: 2),
            Text(isEnabled ? 'Enabled' : 'Disabled',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : const Color(0xFF6B6B7B),
                )),
          ])),
          Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              gradient: isEnabled ? GradientHelper.primaryGradient : null,
              color: isEnabled
                  ? null
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(15),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final bool isDark;
  final int hour;
  final int minute;
  final void Function(int, int) onTimeChanged;

  const _TimePickerTile({
    required this.isDark,
    required this.hour,
    required this.minute,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: const Color(0xFF8B5CF6),
                  surface: isDark ? const Color(0xFF1A1333) : Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onTimeChanged(picked.hour, picked.minute);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.access_time_rounded,
                color: isDark ? Colors.white54 : const Color(0xFF6B6B7B), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Notification Time',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E1B2E),
                )),
            const SizedBox(height: 2),
            Text(timeString,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : const Color(0xFF6B6B7B),
                )),
          ])),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : const Color(0xFF9B9B9B), size: 22),
          ),
        ]),
      ),
    );
  }
}
