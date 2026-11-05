/// Вердикт операции с данными (C8): значение или сообщение для экрана.
/// Ожидаемый отказ — это значение, а не исключение, летящее через UI.
/// sealed: switch по Result исчерпывающий — компилятор не даст
/// забыть ветку ошибки.
sealed class Result<T> {
  const Result();
}

/// Успех: внутри — полученное значение.
class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

/// Провал: внутри — сообщение, готовое для показа человеку.
class Err<T> extends Result<T> {
  const Err(this.msg);
  final String msg;
}
