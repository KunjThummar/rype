import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

String formatCurrency(num value) {
  final amount = value.toDouble();
  final prefix = amount < 0 ? '-₹' : '₹';
  final absolute = amount.abs();
  if (absolute >= 10000000) {
    return '$prefix${(absolute / 10000000).toStringAsFixed(2)} Cr';
  }
  if (absolute >= 100000) {
    return '$prefix${(absolute / 100000).toStringAsFixed(2)} L';
  }
  if (absolute >= 1000) {
    return '$prefix${(absolute / 1000).toStringAsFixed(2)} K';
  }
  return '$prefix${absolute.toStringAsFixed(2)}';
}

double asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

String asText(dynamic value, [String fallback = '-']) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.showBack = true,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool showBack;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title, showBack: showBack, actions: actions),
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBack = true,
  });

  final String title;
  final List<Widget> actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      title: Text(title),
      actions: actions,
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: controller.isDark ? 'Light theme' : 'Dark theme',
      onPressed: controller.toggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          controller.isDark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          key: ValueKey(controller.isDark),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?trailing,
      ],
    );
  }
}

class FinanceCard extends StatelessWidget {
  const FinanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: card,
    );
  }
}

class PrimaryCard extends FinanceCard {
  const PrimaryCard({
    super.key,
    required super.child,
    super.padding,
    super.onTap,
  });
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: icon == null
          ? ElevatedButton(
              onPressed: loading ? null : onPressed,
              child: content,
            )
          : ElevatedButton.icon(
              onPressed: loading ? null : onPressed,
              icon: loading ? const SizedBox.shrink() : Icon(icon),
              label: content,
            ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 170,
    this.spacing = 12,
    this.itemHeight = 126,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = math.max(1, constraints.maxWidth ~/ minItemWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class SimplePieChart extends StatelessWidget {
  const SimplePieChart({
    super.key,
    required this.values,
    required this.colors,
    this.size = 128,
  });

  final List<double> values;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PiePainter(values: values, colors: colors),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value.abs());
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;
    if (total <= 0) {
      stroke.color = colors.first.withValues(alpha: 0.18);
      canvas.drawArc(
        rect.deflate(stroke.strokeWidth / 2),
        -math.pi / 2,
        math.pi * 2,
        false,
        stroke,
      );
      return;
    }
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i].abs() / total) * math.pi * 2;
      stroke.color = colors[i % colors.length];
      canvas.drawArc(
        rect.deflate(stroke.strokeWidth / 2),
        start,
        sweep - 0.04,
        false,
        stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}

class LineTrendChart extends StatelessWidget {
  const LineTrendChart({super.key, required this.values, this.height = 150});

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(
          values: values,
          color: Theme.of(context).colorScheme.primary,
          grid: context.finance.border,
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color, required this.grid});

  final List<double> values;
  final Color color;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.length < 2) return;
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = math.max(1, maxValue - minValue);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - minValue) / span * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.10));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}

class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1
        : values.map((e) => e.abs()).reduce(math.max);
    return Column(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  labels[i],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: maxValue == 0 ? 0 : values[i].abs() / maxValue,
                    minHeight: 10,
                    color: values[i] >= 0
                        ? context.finance.success
                        : context.finance.danger,
                    backgroundColor: context.finance.pageSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: Text(
                  formatCurrency(values[i]),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (i != values.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          context.finance.pageSurface,
          context.finance.border,
          _controller.value,
        )!;
        Widget block(double height, {double width = double.infinity}) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            block(160),
            const SizedBox(height: 14),
            ResponsiveGrid(
              itemHeight: 104,
              children: List.generate(4, (_) => block(104)),
            ),
            const SizedBox(height: 14),
            block(220),
            const SizedBox(height: 14),
            block(92),
            const SizedBox(height: 12),
            block(92),
          ],
        );
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: FinanceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: context.finance.danger,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorWidget extends ErrorState {
  const AppErrorWidget({
    super.key,
    required super.message,
    required super.onRetry,
  });
}
