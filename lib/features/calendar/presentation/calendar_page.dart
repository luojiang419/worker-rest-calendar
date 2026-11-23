import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_segmented_control.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/calendar/application/calendar_controller.dart';
import 'package:worker_rest_calendar/features/calendar/presentation/calendar_day_cell.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({
    required this.onOpenDay,
    required this.onEditDay,
    super.key,
  });

  final ValueChanged<CalendarDate> onOpenDay;
  final ValueChanged<CalendarDate> onEditDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(activeScheduleControllerProvider);
    final calendar = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);
    final scrollAxis =
        ref.watch(appPreferencesProvider).value?.calendarScrollAxis ??
        CalendarScrollAxis.horizontal;
    final tokens = context.tokens;
    final viewport = MediaQuery.sizeOf(context);
    final compactDesktop = viewport.width >= 700 && viewport.height < 700;
    final horizontalPadding = viewport.width >= 600
        ? tokens.sizes.desktopHorizontalPadding
        : tokens.sizes.mobileHorizontalPadding;
    final verticalPadding = compactDesktop
        ? tokens.spacing.sm
        : tokens.spacing.lg;
    final sectionGap = compactDesktop ? tokens.spacing.sm : tokens.spacing.lg;
    final periodGap = compactDesktop ? tokens.spacing.xs : tokens.spacing.md;
    final cardPadding = compactDesktop ? tokens.spacing.xs : tokens.spacing.sm;
    final weekdayPadding = compactDesktop
        ? tokens.spacing.xs
        : tokens.spacing.sm;
    final minimumDayCellExtent = MediaQuery.textScalerOf(context).scale(
      tokens.sizes.minTouch +
          (compactDesktop ? tokens.spacing.sm : tokens.spacing.xxl),
    );

    return SafeArea(
      bottom: false,
      child: schedule.when(
        loading: () => const Center(child: AppLoadingState(label: '正在生成日历')),
        error: (error, stackTrace) => Center(
          child: error is StateError
              ? const AppEmptyState(title: '还没有设置班制', message: '完成首次设置后即可查看日历')
              : AppErrorState(
                  title: '日历加载失败',
                  message: '请稍后重试',
                  onRetry: () =>
                      ref.invalidate(activeScheduleControllerProvider),
                ),
        ),
        data: (state) {
          final today = ref.watch(todayProvider);
          return LayoutBuilder(
            builder: (context, constraints) {
              final bottomPadding = compactDesktop
                  ? tokens.spacing.sm
                  : tokens.spacing.xxl;
              final rowCount = calendar.mode == CalendarViewMode.month ? 6 : 1;
              final minimumCalendarHeight =
                  cardPadding * 2 +
                  minimumDayCellExtent * rowCount +
                  tokens.spacing.xs * (rowCount - 1) +
                  MediaQuery.textScalerOf(context).scale(
                    Theme.of(context).textTheme.labelMedium?.fontSize ?? 12,
                  ) +
                  weekdayPadding * 2;
              final fixedContentHeight =
                  tokens.sizes.buttonHeight * 3 +
                  sectionGap * 2 +
                  periodGap +
                  verticalPadding +
                  bottomPadding;
              final canFillViewport =
                  constraints.maxHeight >=
                  fixedContentHeight + minimumCalendarHeight;

              final content = <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '日历',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    AppButton.secondary(
                      label: '回到今天',
                      icon: Icons.today_outlined,
                      onPressed: controller.goToday,
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                AppSegmentedControl<CalendarViewMode>(
                  segments: const [
                    ButtonSegment(
                      value: CalendarViewMode.month,
                      label: Text('月'),
                    ),
                    ButtonSegment(
                      value: CalendarViewMode.week,
                      label: Text('周'),
                    ),
                  ],
                  selected: {calendar.mode},
                  onSelectionChanged: (selection) =>
                      controller.setMode(selection.single),
                ),
                SizedBox(height: sectionGap),
                Row(
                  children: [
                    IconButton.outlined(
                      tooltip:
                          '上一个${calendar.mode == CalendarViewMode.month ? '月' : '周'}',
                      onPressed: controller.previousPeriod,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(
                        calendar.periodLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip:
                          '下一个${calendar.mode == CalendarViewMode.month ? '月' : '周'}',
                      onPressed: controller.nextPeriod,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                SizedBox(height: periodGap),
                if (calendar.mode == CalendarViewMode.month)
                  _InfiniteMonthPager(
                    key: ValueKey(scrollAxis),
                    schedule: state,
                    today: today,
                    calendar: calendar,
                    controller: controller,
                    scrollAxis: scrollAxis,
                    cardPadding: cardPadding,
                    weekdayPadding: weekdayPadding,
                    minimumDayCellExtent: minimumDayCellExtent,
                    onOpenDay: onOpenDay,
                    onEditDay: onEditDay,
                  )
                else
                  _CalendarGridCard(
                    visibleDays: state.days(
                      calendar.visibleStart,
                      calendar.visibleDayCount,
                    ),
                    today: today,
                    calendar: calendar,
                    controller: controller,
                    cardPadding: cardPadding,
                    weekdayPadding: weekdayPadding,
                    minimumDayCellExtent: minimumDayCellExtent,
                    onOpenDay: onOpenDay,
                    onEditDay: onEditDay,
                  ),
              ];

              final padding = EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                bottomPadding,
              );
              if (!canFillViewport) {
                return ListView(
                  padding: padding,
                  children: [
                    ...content.take(content.length - 1),
                    SizedBox(
                      height: minimumCalendarHeight,
                      child: content.last,
                    ),
                  ],
                );
              }
              return Padding(
                padding: padding,
                child: Column(
                  children: [
                    ...content.take(content.length - 1),
                    Expanded(child: content.last),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfiniteMonthPager extends StatefulWidget {
  const _InfiniteMonthPager({
    required this.schedule,
    required this.today,
    required this.calendar,
    required this.controller,
    required this.scrollAxis,
    required this.cardPadding,
    required this.weekdayPadding,
    required this.minimumDayCellExtent,
    required this.onOpenDay,
    required this.onEditDay,
    super.key,
  });

  final ActiveScheduleState schedule;
  final CalendarDate today;
  final CalendarViewState calendar;
  final CalendarController controller;
  final CalendarScrollAxis scrollAxis;
  final double cardPadding;
  final double weekdayPadding;
  final double minimumDayCellExtent;
  final ValueChanged<CalendarDate> onOpenDay;
  final ValueChanged<CalendarDate> onEditDay;

  @override
  State<_InfiniteMonthPager> createState() => _InfiniteMonthPagerState();
}

class _InfiniteMonthPagerState extends State<_InfiniteMonthPager> {
  static const _anchorPage = 120000;

  late final CalendarDate _anchorMonth;
  late final PageController _pageController;
  var _currentPage = _anchorPage;

  @override
  void initState() {
    super.initState();
    _anchorMonth = _monthStart(widget.calendar.displayedDate);
    _pageController = PageController(initialPage: _anchorPage);
  }

  @override
  void didUpdateWidget(covariant _InfiniteMonthPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameMonth(
      oldWidget.calendar.displayedDate,
      widget.calendar.displayedDate,
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showDisplayedMonth();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        child: PageView.builder(
          key: const ValueKey('calendar-month-pager'),
          controller: _pageController,
          scrollDirection: widget.scrollAxis == CalendarScrollAxis.horizontal
              ? Axis.horizontal
              : Axis.vertical,
          allowImplicitScrolling: true,
          pageSnapping: false,
          padEnds: false,
          physics: const ClampingScrollPhysics(),
          onPageChanged: _handlePageChanged,
          itemBuilder: (context, page) {
            final month = _monthForPage(page);
            final pageState = widget.calendar.copyWith(displayedDate: month);
            final isFocusedMonth = _sameMonth(
              month,
              widget.calendar.displayedDate,
            );
            return AnimatedOpacity(
              key: ValueKey('calendar-month-page-${month.year}-${month.month}'),
              opacity: isFocusedMonth ? 1 : 0.58,
              duration: context.tokens.motion.fast,
              child: _CalendarGridCard(
                visibleDays: widget.schedule.days(
                  pageState.visibleStart,
                  pageState.visibleDayCount,
                ),
                today: widget.today,
                calendar: pageState,
                controller: widget.controller,
                cardPadding: widget.cardPadding,
                weekdayPadding: widget.weekdayPadding,
                minimumDayCellExtent: widget.minimumDayCellExtent,
                enablePeriodGesture: false,
                onOpenDay: widget.onOpenDay,
                onEditDay: widget.onEditDay,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handlePageChanged(int page) {
    _currentPage = page;
    widget.controller.showMonth(_monthForPage(page));
  }

  void _showDisplayedMonth() {
    if (!_pageController.hasClients) return;
    final targetPage = _pageForMonth(widget.calendar.displayedDate);
    if (targetPage == _currentPage) return;
    final distance = (targetPage - _currentPage).abs();
    if (distance > 1) {
      _pageController.jumpToPage(targetPage);
      return;
    }
    unawaited(
      _pageController.animateToPage(
        targetPage,
        duration: context.tokens.motion.normal,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_pageController.hasClients) {
      return;
    }
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    if (delta.abs() < 4) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _pageController.position.pointerScroll(delta);
    });
  }

  int _pageForMonth(CalendarDate date) =>
      _anchorPage +
      (date.year - _anchorMonth.year) * 12 +
      date.month -
      _anchorMonth.month;

  CalendarDate _monthForPage(int page) {
    final normalized = DateTime.utc(
      _anchorMonth.year,
      _anchorMonth.month + page - _anchorPage,
      1,
    );
    return CalendarDate(normalized.year, normalized.month, 1);
  }

  static CalendarDate _monthStart(CalendarDate date) =>
      CalendarDate(date.year, date.month, 1);

  static bool _sameMonth(CalendarDate first, CalendarDate second) =>
      first.year == second.year && first.month == second.month;
}

class _CalendarGridCard extends StatelessWidget {
  const _CalendarGridCard({
    required this.visibleDays,
    required this.today,
    required this.calendar,
    required this.controller,
    required this.cardPadding,
    required this.weekdayPadding,
    required this.minimumDayCellExtent,
    required this.onOpenDay,
    required this.onEditDay,
    this.enablePeriodGesture = true,
  });

  final List<DayPresentation> visibleDays;
  final CalendarDate today;
  final CalendarViewState calendar;
  final CalendarController controller;
  final double cardPadding;
  final double weekdayPadding;
  final double minimumDayCellExtent;
  final ValueChanged<CalendarDate> onOpenDay;
  final ValueChanged<CalendarDate> onEditDay;
  final bool enablePeriodGesture;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final card = AppCard(
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        children: [
          Row(
            children: [
              for (var weekday = 1; weekday <= 7; weekday++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: weekdayPadding),
                    child: Text(
                      CalendarDate(2026, 7, 12 + weekday).weekdayShortLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: tokens.colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rowCount = calendar.mode == CalendarViewMode.month
                    ? 6
                    : 1;
                final availableCellHeight =
                    (constraints.maxHeight -
                        tokens.spacing.xs * (rowCount - 1)) /
                    rowCount;
                final dayCellExtent = availableCellHeight < minimumDayCellExtent
                    ? minimumDayCellExtent
                    : availableCellHeight;
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleDays.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: dayCellExtent,
                    crossAxisSpacing: tokens.spacing.xs,
                    mainAxisSpacing: tokens.spacing.xs,
                  ),
                  itemBuilder: (context, index) {
                    final day = visibleDays[index];
                    return CalendarDayCell(
                      day: day,
                      isToday: day.date == today,
                      isSelected: day.date == calendar.selectedDate,
                      isInDisplayedMonth:
                          calendar.mode == CalendarViewMode.week ||
                          day.date.month == calendar.displayedDate.month,
                      onTap: () {
                        controller.selectDate(day.date);
                        onOpenDay(day.date);
                      },
                      onLongPress: () {
                        controller.selectDate(day.date);
                        onEditDay(day.date);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
    if (!enablePeriodGesture) return card;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -200) {
          controller.nextPeriod();
        } else if (velocity > 200) {
          controller.previousPeriod();
        }
      },
      child: card,
    );
  }
}
