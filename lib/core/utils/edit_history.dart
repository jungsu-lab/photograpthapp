/// Bounded undo/redo history for immutable editing state.
///
/// The caller supplies the current value when moving backwards or forwards;
/// this keeps the helper independent from Flutter and safe to unit test.
class EditHistory<T> {
  EditHistory({this.maxEntries = 30}) : assert(maxEntries > 0);

  final int maxEntries;
  final List<T> _undo = <T>[];
  final List<T> _redo = <T>[];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Stores the state being left. A new edit always invalidates redo history.
  void record(T current) {
    _undo.add(current);
    if (_undo.length > maxEntries) _undo.removeAt(0);
    _redo.clear();
  }

  /// Returns the prior state, or null when there is no prior state.
  T? undo(T current) {
    if (_undo.isEmpty) return null;
    _redo.add(current);
    return _undo.removeLast();
  }

  /// Returns the next state, or null when redo history is empty.
  T? redo(T current) {
    if (_redo.isEmpty) return null;
    _undo.add(current);
    if (_undo.length > maxEntries) _undo.removeAt(0);
    return _redo.removeLast();
  }
}
