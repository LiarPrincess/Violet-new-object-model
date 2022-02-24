/// A pointer for accessing and manipulating data of a specific type.
///
/// Important reads:
/// https://github.com/atrick/swift/blob/type-safe-mem-docs/docs/TypeSafeMemory.rst
/// https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md
struct Ref<Pointee>: CustomStringConvertible {

  private typealias Ptr = UnsafeMutableRawPointer
  private var ptr: Ptr

  private var typedPtr: UnsafeMutablePointer<Pointee> {
    // The memory was bound inside `self.initialize`,
    // now we just assume that you know what you are doing.
    return self.ptr.assumingMemoryBound(to: Pointee.self)
  }

  /// Accesses the instance referenced by this pointer.
  var pointee: Pointee {
    return self.typedPtr.pointee
  }

  var description: String {
    return "Ref(ptr: \(self.ptr)) -> \(self.pointee)"
  }

  /// Init with allocated and initialized pointer.
  private init(ptr: Ptr) {
    self.ptr = ptr
  }

  /// Init from `Ref` to another object (pointer type conversion).
  init<T>(from other: Ref<T>) {
    self.ptr = other.ptr
  }

  // MARK: - Lifetime

  /// Allocates and initializes this pointer’s memory with a instance
  /// of the given value.
  static func allocateAndInitialize(from value: Pointee) -> Self {
    let ref = Self.allocate()
    ref.initialize(to: value)
    return ref
  }

  /// Allocates uninitialized memory for the instance of type `Pointee`.
  static func allocate() -> Self {
    let ptr = UnsafeMutablePointer<Pointee>.allocate(capacity: 1)
    let rawPtr = Ptr(ptr)
    return Ref(ptr: rawPtr)
  }

  /// Initializes this pointer’s memory with a instance of the given value.
  func initialize(to value: Pointee) {
    let boundPtr = self.ptr.bindMemory(to: Pointee.self, capacity: 1)
    boundPtr.initialize(to: value)
  }

  /// Deinitialize and deallocate the memory block previously allocated at this pointer.
  func deallocate() {
    // Calling 'deinitialize' is essential to update ARC for managed objects.
    let uninitializedRawPtr = self.typedPtr.deinitialize(count: 1)
    assert(uninitializedRawPtr == self.ptr)
    uninitializedRawPtr.deallocate()
  }

  // MARK: - Referential equality

  /// Returns a `Boolean` value indicating whether two `Refs` are pointing
  /// to the same object.
  static func === (lhs: Self, rhs: Self) -> Bool {
    return lhs.ptr == rhs.ptr
  }
}
