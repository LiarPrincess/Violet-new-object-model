public struct PyError: PyObjectMixin {

  public enum Layout {
    public static let messageOffset = SizeOf.objectHeader
    public static let messageSize = SizeOf.string

    public static let size = Layout.messageOffset + Layout.messageSize
  }

  private var messagePtr: Ptr<String> { Ptr(self.ptr, offset: Layout.messageOffset) }
  public var message: String { self.messagePtr.pointee }

  public let ptr: RawPtr

  public init(ptr: RawPtr) {
    self.ptr = ptr
  }

  // MARK: - Initialize

  public func initialize(type: PyType, message: String) {
    self.header.initialize(type: type)
    self.messagePtr.initialize(to: message)
  }

  public static func deinitialize(ptr: RawPtr) {
    let zelf = PyError(ptr: ptr)
    zelf.header.deinitialize()
    zelf.messagePtr.deinitialize()
  }

  // MARK: - Debug

  public static func createDebugString(ptr: RawPtr) -> String {
    let zelf = PyError(ptr: ptr)
    return "PyError(type: \(zelf.typeName), message: \(zelf.message))"
  }
}
