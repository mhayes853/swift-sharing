import Foundation

package struct Mutex<Value> {
  private let _lock = NSLock()
  private let _box: Box

  package init(_ initialValue: consuming Value) {
    _box = Box(initialValue)
  }

  private final class Box {
    var value: Value
    init(_ initialValue: consuming Value) {
      value = initialValue
    }
  }
}

extension Mutex: @unchecked Sendable {}

extension Mutex {
  borrowing package func withLock<Result>(
    _ body: (inout Value) throws -> Result
  ) rethrows -> Result {
    _lock.lock()
    defer { _lock.unlock() }
    return try body(&_box.value)
  }

  borrowing package func withLockIfAvailable<Result>(
    _ body: (inout Value) throws -> Result
  ) rethrows -> Result? {
    guard _lock.try() else { return nil }
    defer { _lock.unlock() }
    return try body(&_box.value)
  }
}

extension Mutex where Value == Void {
  borrowing package func _unsafeLock() {
    _lock.lock()
  }

  borrowing package func _unsafeTryLock() -> Bool {
    _lock.try()
  }

  borrowing package func _unsafeUnlock() {
    _lock.unlock()
  }
}
