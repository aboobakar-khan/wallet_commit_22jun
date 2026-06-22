import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'app_icons.dart';

/// A circular, hairline icon button — the app's one icon-button shape.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(side: BorderSide(color: colors.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  Haptics.select();
                  onTap!();
                },
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: colors.ink),
          ),
        ),
      ),
    );
  }
}

/// Standard scaffold for pushed screens: a quiet header (back + serif title +
/// actions) over the app ground, with a scrollable or fixed body.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.showBack = true,
    this.bottomBar,
    this.scrollable = true,
    this.bodyPadding =
        const EdgeInsets.symmetric(horizontal: Space.screenGutter),
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottomBar;
  final bool scrollable;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
          Space.md, Space.sm, Space.md, Space.xs),
      child: Row(
        children: [
          if (showBack && Navigator.of(context).canPop())
            Padding(
              padding: const EdgeInsets.only(right: Space.sm),
              child: CircleIconButton(
                icon: AppIcons.back,
                semanticLabel: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: context.text.serifTitle,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          ...?actions,
        ],
      ),
    );

    final content = Padding(padding: bodyPadding, child: body);

    return Scaffold(
      backgroundColor: colors.bg,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: Space.xxl),
                      child: content,
                    )
                  : content,
            ),
          ],
        ),
      ),
    );
  }
}
