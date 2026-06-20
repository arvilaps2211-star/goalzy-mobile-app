import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart' as gd;
import '../../../../shared/domain/entities/calendar_event.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/state_widgets.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calendar', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Plan your life with clarity', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ViewTabs(
                selected: state.viewMode,
                onSelected: (mode) => ref.read(calendarStateProvider.notifier).setViewMode(mode),
              ),
              _DateNavigator(
                date: state.selectedDate,
                viewMode: state.viewMode,
                onPrevious: () => ref.read(calendarStateProvider.notifier).goToPrevious(),
                onNext: () => ref.read(calendarStateProvider.notifier).goToNext(),
                onToday: () => ref.read(calendarStateProvider.notifier).goToToday(),
              ),
              Expanded(
                child: state.isLoading
                    ? const LoadingState(message: 'Loading events...')
                    : state.error != null
                        ? ErrorState(
                            message: state.error!,
                            onRetry: () => ref.read(calendarStateProvider.notifier).loadEvents(),
                          )
                        : _CalendarBody(viewMode: state.viewMode, events: state.events, selectedDate: state.selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewTabs extends StatelessWidget {
  const _ViewTabs({required this.selected, required this.onSelected});

  final CalendarViewMode selected;
  final ValueChanged<CalendarViewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (CalendarViewMode.daily, 'Daily'),
      (CalendarViewMode.weekly, 'Weekly'),
      (CalendarViewMode.monthly, 'Monthly'),
      (CalendarViewMode.agenda, 'Agenda'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = selected == tab.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(tab.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : Colors.transparent,
                  ),
                  child: Text(
                    tab.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.viewMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime date;
  final CalendarViewMode viewMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  String get _label => switch (viewMode) {
        CalendarViewMode.daily || CalendarViewMode.agenda => gd.DateUtils.formatDate(date),
        CalendarViewMode.weekly => 'Week of ${gd.DateUtils.formatShort(gd.DateUtils.startOfWeek(date))}',
        CalendarViewMode.monthly => gd.DateUtils.formatMonth(date),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _NavButton(icon: Icons.chevron_left, onTap: onPrevious),
          Expanded(
            child: Text(_label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ),
          _NavButton(icon: Icons.chevron_right, onTap: onNext),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.glassFill,
              ),
              child: const Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
          color: AppColors.glassFill,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CalendarBody extends StatelessWidget {
  const _CalendarBody({required this.viewMode, required this.events, required this.selectedDate});

  final CalendarViewMode viewMode;
  final List<CalendarEvent> events;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyState(
        title: 'No events scheduled',
        message: 'Your calendar is clear for this period',
        icon: Icons.event_available_outlined,
      );
    }

    return switch (viewMode) {
      CalendarViewMode.daily => _DailyView(events: events),
      CalendarViewMode.weekly => _WeeklyView(events: events, weekStart: gd.DateUtils.startOfWeek(selectedDate)),
      CalendarViewMode.monthly => _MonthlyView(events: events, month: selectedDate),
      CalendarViewMode.agenda => _AgendaView(events: events),
    };
  }
}

class _DailyView extends StatelessWidget {
  const _DailyView({required this.events});

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _EventCard(event: events[i]),
    );
  }
}

class _WeeklyView extends StatelessWidget {
  const _WeeklyView({required this.events, required this.weekStart});

  final List<CalendarEvent> events;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final day = days[i];
        final dayEvents = events.where((e) => gd.DateUtils.isSameDay(e.startTime, day)).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gd.DateUtils.formatDay(day),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary),
                ),
                Text(gd.DateUtils.formatShort(day), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                if (dayEvents.isEmpty)
                  Text('No events', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted))
                else
                  ...dayEvents.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _EventRow(event: e),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlyView extends StatelessWidget {
  const _MonthlyView({required this.events, required this.month});

  final List<CalendarEvent> events;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((d) => Text(d, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: firstWeekday - 1 + daysInMonth,
              itemBuilder: (_, i) {
                if (i < firstWeekday - 1) return const SizedBox.shrink();
                final day = i - (firstWeekday - 1) + 1;
                final date = DateTime(month.year, month.month, day);
                final count = events.where((e) => gd.DateUtils.isSameDay(e.startTime, date)).length;
                final isToday = gd.DateUtils.isSameDay(date, DateTime.now());

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isToday ? AppColors.primary.withValues(alpha: 0.2) : AppColors.glassFill,
                    border: Border.all(color: isToday ? AppColors.primary.withValues(alpha: 0.5) : AppColors.glassBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day', style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500)),
                      if (count > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 12),
              ...events.take(4).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _EventRow(event: e),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgendaView extends StatelessWidget {
  const _AgendaView({required this.events});

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<CalendarEvent>>{};
    for (final event in events) {
      final key = gd.DateUtils.formatDate(event.startTime);
      grouped.putIfAbsent(key, () => []).add(event);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary)),
              const SizedBox(height: 8),
              ...entry.value.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _EventCard(event: e, compact: true),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.compact = false});

  final CalendarEvent event;
  final bool compact;

  Color get _color => Color(int.parse('FF${event.colorHex}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 4,
            height: compact ? 40 : 56,
            decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(child: _EventRow(event: event)),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          '${gd.DateUtils.formatTime(event.startTime)} – ${gd.DateUtils.formatTime(event.endTime)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
