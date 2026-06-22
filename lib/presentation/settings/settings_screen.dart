import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../application/providers.dart';
import '../../core/core.dart';
import '../widgets/app_button.dart';
import '../widgets/app_icons.dart';
import '../widgets/pill_choice.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/surface_card.dart';
import '../widgets/sukoon_switch.dart';

final _notificationsProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profile = ref.watch(profileProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final motionOverride = ref.watch(reduceMotionOverrideProvider);
    final notifications = ref.watch(_notificationsProvider);

    return ScreenScaffold(
      title: 'Settings',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.xs),
          const SectionLabel('You'),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  label: 'Name',
                  value: profile?.displayName ?? '—',
                  onTap: () async {
                    final v = await _promptText(context,
                        title: 'Your name', initial: profile?.displayName ?? '');
                    if (v != null) {
                      ref.read(actionsProvider).updateProfile(displayName: v);
                    }
                  },
                ),
                const Hairline(indent: Space.md),
                _Row(
                  label: 'Timezone',
                  value: profile?.timezone ?? '—',
                  onTap: () async {
                    final v = await _promptText(context,
                        title: 'Timezone', initial: profile?.timezone ?? '');
                    if (v != null) {
                      ref.read(actionsProvider).updateProfile(timezone: v);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          const SectionLabel('Appearance'),
          _ChoiceBlock(
            label: 'Theme',
            children: [
              PillChoice(
                  label: 'System',
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.system),
              PillChoice(
                  label: 'Sahar · light',
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.light),
              PillChoice(
                  label: 'Layl · dark',
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.dark),
            ],
          ),
          const SizedBox(height: Space.md),
          _ChoiceBlock(
            label: 'Language',
            children: [
              PillChoice(
                  label: 'System',
                  selected: locale == null,
                  onTap: () => ref.read(localeProvider.notifier).state = null),
              PillChoice(
                  label: 'English',
                  selected: locale?.languageCode == 'en',
                  onTap: () => ref.read(localeProvider.notifier).state = const Locale('en')),
              PillChoice(
                  label: 'العربية',
                  selected: locale?.languageCode == 'ar',
                  onTap: () => ref.read(localeProvider.notifier).state = const Locale('ar')),
            ],
          ),
          const SizedBox(height: Space.md),
          _ChoiceBlock(
            label: 'Motion',
            children: [
              PillChoice(
                  label: 'Auto',
                  selected: motionOverride == null,
                  onTap: () => ref.read(reduceMotionOverrideProvider.notifier).state = null),
              PillChoice(
                  label: 'Full',
                  selected: motionOverride == false,
                  onTap: () => ref.read(reduceMotionOverrideProvider.notifier).state = false),
              PillChoice(
                  label: 'Reduced',
                  selected: motionOverride == true,
                  onTap: () => ref.read(reduceMotionOverrideProvider.notifier).state = true),
            ],
          ),
          const SizedBox(height: Space.lg),
          const SectionLabel('Prayers'),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  label: 'Notifications',
                  trailing: SukoonSwitch(
                    value: notifications,
                    onChanged: (v) => ref.read(_notificationsProvider.notifier).state = v,
                  ),
                ),
                const Hairline(indent: Space.md),
                _Row(
                  label: 'Prayer-time source',
                  value: 'Sukoon Launcher',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          AppButton(
            label: 'Sign out',
            tone: AppButtonTone.neutral,
            icon: Icons.logout_rounded,
            onPressed: () => ref.read(actionsProvider).signOut(),
          ),
          const SizedBox(height: Space.lg),
          Center(
            child: Text('Sukoon · UI preview on mock data',
                style: context.type.bodySmall?.copyWith(color: colors.inkMuted)),
          ),
        ],
      ),
    );
  }
}

class _ChoiceBlock extends StatelessWidget {
  const _ChoiceBlock({required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Space.xs, left: 2),
          child: Text(label, style: context.type.labelMedium),
        ),
        Wrap(spacing: Space.xs, runSpacing: Space.xs, children: children),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, this.value, this.trailing, this.onTap});
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              Haptics.select();
              onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
        child: Row(
          children: [
            Expanded(
                child: Text(label, style: context.type.labelLarge?.copyWith(color: colors.ink))),
            if (value != null)
              Text(value!, style: context.type.bodyMedium),
            ?trailing,
            if (onTap != null && trailing == null) ...[
              const SizedBox(width: Space.xs),
              Icon(AppIcons.chevron, size: 18, color: colors.inkMuted),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> _promptText(BuildContext context,
    {required String title, required String initial}) {
  final controller = TextEditingController(text: initial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.colors;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.large)),
            border: Border.all(color: colors.hairline),
          ),
          padding: const EdgeInsets.fromLTRB(
              Space.screenGutter, Space.lg, Space.screenGutter, Space.lg),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ctx.text.serifTitle),
                const SizedBox(height: Space.md),
                TextField(
                  controller: controller,
                  autofocus: true,
                  cursorColor: colors.primary,
                  style: ctx.type.titleMedium,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.surfaceMuted,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: Radii.card_,
                      borderSide: BorderSide(color: colors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: Radii.card_,
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
                ),
                const SizedBox(height: Space.md),
                AppButton(
                  label: 'Save',
                  onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
