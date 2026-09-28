// Простое форматирование без пакета intl.

const _months = [
  'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июня',
  'июля', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.',
];

const _weekdays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];

String formatDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}, ${_weekdays[d.weekday - 1]}';

String formatDateShort(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m мин';
  if (m == 0) return '$h ч';
  return '$h ч $m мин';
}
