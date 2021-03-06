/// Pointer to a Python object as a whole.
///
/// If you need to manitulate memory inside of a Python object, for example a single
/// property like `type`, then use the typed `Ptr`.
public struct RawPtr {

  // Do not change it to 'UnsafeMutableRawPointer'!
  // Any mutation should go through 'Ptr'.
  private let value: UnsafeRawPointer

  public init(_ value: UnsafeRawPointer) {
    self.value = value
  }

  public init(_ value: UnsafeMutableRawPointer) {
    self.value = UnsafeRawPointer(value)
  }

  // MARK: - Subscript

  public subscript(offset: Int) -> RawPtr {
    let ptr = self.value.advanced(by: offset)
    return RawPtr(ptr)
  }

  // MARK: - Bind

  /// Binds the memory to the specified type and returns a typed pointer to the
  /// bound memory.
  ///
  /// Use the `bind(to:)` method to bind the memory referenced by this pointer
  /// to the type `T`. The memory must be uninitialized or initialized to a type
  /// that is layout compatible with `T`. If the memory is uninitialized,
  /// it is still uninitialized after being bound to `T`.
  ///
  /// - Warning: A memory location may only be bound to one type at a time. The
  ///   behavior of accessing memory as a type unrelated to its bound type is
  ///   undefined.
  ///
  /// - Parameters:
  ///   - type: The type `T` to bind the memory to.
  /// - Returns: A typed pointer to the newly bound memory. The memory in this
  ///   region is bound to `T`, but has not been modified in any other way.
  public func bind<T>(to type: T.Type) -> Ptr<T> {
    let unsafePtr = self.value.bindMemory(to: T.self, capacity: 1)
    return Ptr(unsafePtr)
  }

  // MARK: - Allocate

  /// Allocates uninitialized memory with the specified size and alignment.
  ///
  /// You are in charge of managing the allocated memory. Be sure to deallocate
  /// any memory that you manually allocate.
  ///
  /// The allocated memory is not bound to any specific type and must be bound
  /// before performing any typed operations.
  ///
  /// - Parameters:
  ///   - byteCount: The number of bytes to allocate. `byteCount` must not be negative.
  ///   - alignment: The alignment of the new region of allocated memory, in
  ///     bytes.
  /// - Returns: A pointer to a newly allocated region of memory. The memory is
  ///   allocated, but not initialized.
  public static func allocate(byteCount: Int, alignment: Int) -> RawPtr {
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
    return RawPtr(ptr)
  }

  /// Deallocates the previously allocated memory referenced by this pointer.
  ///
  /// The memory to be deallocated must be uninitialized or initialized to a
  /// trivial type.
  public func deallocate() {
    self.value.deallocate()
  }

  // MARK: - Equality

  /// Returns a `Boolean` value indicating whether two `Ptrs` are pointing
  /// to the same object.
  public static func === (lhs: RawPtr, rhs: RawPtr) -> Bool {
    return lhs.value == rhs.value
  }
}
