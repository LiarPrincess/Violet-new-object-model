// This type can be automatically generated (mostly).
enum PyMemory {

  // MARK: - Init

  /// Those types require special treatement because:
  /// - `object` type has `type` type
  /// - `type` type has `type` type (self reference) and `object` type as base
  static func initTypeAndObjectTypes() -> (typeType: PyTypeRef, objectType: PyTypeRef) {
    print("Allocating types: type & object")

    let typeType = PyTypeRef.allocate()
    let objectType = PyTypeRef.allocate()

    // For a second we will be using uninitialized pointers
    let header = Self.createHeader(type: typeType)
    let typeTypeValue = PyType(header: header, name: "type", base: objectType)
    let objectTypeValue = PyType(header: header, name: "object", base: nil)

    typeType.initialize(to: typeTypeValue)
    objectType.initialize(to: objectTypeValue)

    return (typeType, objectType)
  }

  static func initType(
    name: String,
    base: PyTypeRef?,
    __add__: PyType.BinaryOperation? = nil
  ) -> PyTypeRef {
    print("Allocating type: \(name)")
    let header = Self.createHeader(type: Py.Types.type)
    let value = PyType(header: header, name: name, base: base, __add__: __add__)
    return Ref.allocateAndInitialize(from: value)
  }

  static func initNone() -> PyNoneRef {
    print("Allocating None")
    let header = Self.createHeader(type: Py.Types.none)
    let value = PyNone(header: header)
    return Ref.allocateAndInitialize(from: value)
  }

  static func initNotImplemented() -> PyNotImplementedRef {
    print("Allocating NotImplemented")
    let header = Self.createHeader(type: Py.Types.notImplemented)
    let value = PyNotImplemented(header: header)
    return Ref.allocateAndInitialize(from: value)
  }

  static func initInt(value: Int) -> PyIntRef {
    print("Allocating int: \(value)")
    let header = Self.createHeader(type: Py.Types.int)
    let value = PyInt(header: header, value: value)
    return Ref.allocateAndInitialize(from: value)
  }

  static func initError(message: String) -> PyErrorRef {
    print("Allocating Error: \(message)")
    let header = Self.createHeader(type: Py.Types.error)
    let value = PyError(header: header, message: message)
    return Ref.allocateAndInitialize(from: value)
  }

  // MARK: - Destroy

  static func destroy<T>(_ ref: Ref<T>) {
    print("Destroying: \(ref)")
    ref.deallocate()
  }

  // MARK: - Helpers

  private static func createHeader(type: PyTypeRef) -> PyObjectHeader {
    let flags = PyObjectHeader.Flags()
    return PyObjectHeader(type: type, flags: flags)
  }
}
