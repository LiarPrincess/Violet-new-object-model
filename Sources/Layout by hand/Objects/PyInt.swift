public struct PyInt: PyObjectMixin {

  public enum Layout {
    public static let valueOffset = SizeOf.objectHeader
    public static let valueSize = SizeOf.int64

    public static let size = Layout.valueOffset + Layout.valueSize
  }

  private var valuePtr: Ptr<Int64> { Ptr(self.ptr, offset: Layout.valueOffset) }
  public var value: Int64 { self.valuePtr.pointee }

  public let ptr: RawPtr

  public init(ptr: RawPtr) {
    self.ptr = ptr
  }

  // MARK: - Initialize

  public func initialize(type: PyType, value: Int64) {
    self.header.initialize(type: type)
    self.valuePtr.initialize(to: value)
  }

  public static func deinitialize(ptr: RawPtr) {
    let zelf = PyInt(ptr: ptr)
    zelf.header.deinitialize()
    zelf.valuePtr.deinitialize()
  }

  // MARK: - Debug

  public static func createDebugString(ptr: RawPtr) -> String {
    let zelf = PyInt(ptr: ptr)
    return "PyInt(type: \(zelf.typeName), value: \(zelf.value))"
  }

  // MARK: - Binary methods

  public static func __add__(zelf: PyObject, other: PyObject) -> PyResult<PyObject> {
    guard let zelfInt = PyCast.asInt(zelf) else {
      return self.createZelfError(zelf: zelf, method: "__add__")
    }

    guard let otherInt = PyCast.asInt(other) else {
      return .value(Py.notImplemented.asObject)
    }

    let value = zelfInt.value + otherInt.value
    let result = Py.newInt(value: value)
    return .value(result.asObject)
  }

  // MARK: - Helpers

  private static func createZelfError(zelf: PyObject, method: String) -> PyError {
    let zelfType = zelf.typeName
    let message = "descriptor '\(method)' requires a 'int' object but received a '\(zelfType)'"
    return Py.newError(message: message)
  }

  private static func createZelfError(zelf: PyObject, method: String) -> PyResult<PyObject> {
    let error: PyError = createZelfError(zelf: zelf, method: method)
    return .error(error)
  }
}
