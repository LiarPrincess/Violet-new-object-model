public struct PyObject: PyObjectMixin {

  public enum Layout {
    public static let size = SizeOf.objectHeader
  }

  public let ptr: RawPtr

  public init(ptr: RawPtr) {
    self.ptr = ptr
  }

  // MARK: - Initialize

  public func initialize(type: PyType) {
    self.header.initialize(type: type)
  }

  public static func deinitialize(ptr: RawPtr) {
    let zelf = PyObject(ptr: ptr)
    zelf.header.deinitialize()
  }

  // MARK: - Debug

  public static func createDebugString(ptr: RawPtr) -> String {
    let zelf = PyObject(ptr: ptr)
    return "PyObject(type: \(zelf.typeName))"
  }
}
