/// สถานะต่างๆ ของ UI ที่สามารถเกิดขึ้นได้
enum UiState {
  loading,
  success,
  empty,
  error,
}

/// คลาสสำหรับจัดการผลลัพธ์ของ UI ที่สามารถมีสถานะต่างๆ ได้
class UiResult<T> {
  final T? _data;
  final UiState _state;
  final UiCodeIndex? _code;
  final Exception? _error;

  UiResult._({
    required T? data,
    required UiCodeIndex? code,
    required UiState state,
    required Exception? error,
  })  : _data = data,
        _code = code,
        _state = state,
        _error = error;

  UiCodeIndex? get code => _code;
  String? get codeString => _code.toString();
  bool get isLoading => _state == UiState.loading;
  bool get isSuccess => _state == UiState.success;
  bool get isEmpty => _state == UiState.empty;
  bool get isError => _state == UiState.error;
  bool get hashData => _data != null;
  bool get hasError => _error != null;
  Exception? get error => _error;
  T? get data => _data;
  T get requireData => _data!;

  factory UiResult.loading() => UiResult._(
        data: null,
        state: UiState.loading,
        code: null,
        error: null,
      );

  factory UiResult.empty({
    T? data,
    Exception? error,
  }) =>
      UiResult._(
        data: data,
        state: UiState.empty,
        code: UiCodeIndex.code_00,
        error: error,
      );

  factory UiResult.error({
    required Exception error,
    UiCodeIndex? code,
  }) =>
      UiResult._(
        data: null,
        state: UiState.error,
        code: code ?? UiCodeIndex.code_99,
        error: error,
      );

  factory UiResult.success({
    required T data,
  }) =>
      UiResult._(
        data: data,
        state: UiState.success,
        code: UiCodeIndex.code_01,
        error: null,
      );
}

/// Enum สำหรับจัดการรหัสสถานะต่างๆ ของระบบ
enum UiCodeIndex {
  code_00('Code : 00 - Result Empty'),
  code_01('Code : 01 - Success'),
  code_99('Code : 99 - Error');

  const UiCodeIndex(this.message);
  final String message;

  @override
  String toString() => message;
}
