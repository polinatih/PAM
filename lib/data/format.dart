// Форматирование дат и длительности без пакета intl.

const _months = [
  'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
  'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
];

const _weekdays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];

String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

String monthName(DateTime d) => _months[d.month - 1];

String formatDateShort(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day.$month.${d.year}, ${weekdayShort(d)}';
}

String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m мин';
  if (m == 0) return '$h ч';
  return '$h ч ${m.toString().padLeft(2, '0')} мин';
}