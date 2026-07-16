import 'package:framefit/core/utils/edit_history.dart';
import 'package:test/test.dart';

void main() {
  test('undo and redo restore states in order', () {
    final history = EditHistory<int>();
    history.record(0);
    history.record(1);

    expect(history.undo(2), 1);
    expect(history.undo(1), 0);
    expect(history.undo(0), isNull);
    expect(history.redo(0), 1);
    expect(history.redo(1), 2);
    expect(history.redo(2), isNull);
  });

  test('a new edit clears redo history', () {
    final history = EditHistory<String>();
    history.record('original');
    expect(history.undo('warm'), 'original');
    expect(history.canRedo, isTrue);

    history.record('cool');
    expect(history.canRedo, isFalse);
    expect(history.redo('new edit'), isNull);
  });

  test('history drops the oldest state at its configured limit', () {
    final history = EditHistory<int>(maxEntries: 2);
    history.record(0);
    history.record(1);
    history.record(2);

    expect(history.undo(3), 2);
    expect(history.undo(2), 1);
    expect(history.undo(1), isNull);
  });
}
