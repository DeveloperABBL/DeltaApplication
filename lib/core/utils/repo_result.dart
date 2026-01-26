/// คลาสสำหรับจัดการผลลัพธ์จาก Repository ที่สามารถมีสถานะต่างๆ ได้
///
/// [RepoResult] เป็น generic class ที่ใช้ wrap ข้อมูลที่ได้จาก repository
/// พร้อมกับสถานะของการดำเนินการ ซึ่งจะช่วยให้การจัดการ error และ empty state
/// เป็นไปอย่างสะดวกและมีประสิทธิภาพ
///
/// สถานะที่เป็นไปได้:
/// - [RepoState.success]: การดำเนินการสำเร็จและมีข้อมูล
/// - [RepoState.empty]: การดำเนินการสำเร็จแต่ไม่มีข้อมูล
/// - [RepoState.error]: เกิดข้อผิดพลาดระหว่างการดำเนินการ
enum RepoState {
  success,
  empty,
  error,
}

/// คลาส `RepoResult<T>` ใช้สำหรับเก็บผลลัพธ์จากการดึงข้อมูลจาก repository
/// โดยรองรับสถานะต่าง ๆ ได้แก่ สำเร็จ (success), ว่างเปล่า (empty), และเกิดข้อผิดพลาด (error)
class RepoResult<T> {
  RepoResult._internal(
    this._state,
    this._data,
    this._error,
  );

  final T? _data;
  final RepoState _state;
  final Exception? _error;

  factory RepoResult.success({required T data}) => RepoResult._internal(
        RepoState.success,
        data,
        null,
      );

  factory RepoResult.empty({
    Exception? error,
  }) =>
      RepoResult._internal(RepoState.empty, null, error);

  factory RepoResult.error({
    required Exception error,
  }) =>
      RepoResult._internal(RepoState.error, null, error);

  factory RepoResult.dependOn(T? data) {
    if (data == null) {
      return RepoResult.empty();
    }
    return RepoResult.success(data: data);
  }

  bool get isSuccess => _state == RepoState.success;
  bool get isEmpty => _state == RepoState.empty;
  bool get isError => _state == RepoState.error;
  bool get hasError => _error != null;
  bool get hasData => _data != null;
  RepoState get state => _state;
  T get data => _data!;
  Exception get error => _error!;
}
