public struct PyType: PyObjectMixin {

  public typealias BinaryOperation = (PyObject, PyObject) -> PyResult<PyObject>
  public typealias DebugFn = (RawPtr) -> String
  public typealias DeinitializerFn = (RawPtr) -> Void

  public enum Layout {
    public static let nameOffset = SizeOf.objectHeader
    public static let nameSize = SizeOf.string

    public static let baseOffset = Layout.nameOffset + Layout.nameSize
    public static let baseSize = SizeOf.pointer

    public static let __add__Offset = Layout.baseOffset + Layout.baseSize
    public static let __add__Size = SizeOf.method

    public static let debugFnOffset = Layout.__add__Offset + Layout.__add__Size
    public static let debugFnSize = SizeOf.method

    public static let deinitializerOffset = Layout.debugFnOffset + Layout.debugFnSize
    public static let deinitializerSize = SizeOf.deinitializer

    public static let size = Layout.deinitializerOffset + Layout.deinitializerSize
  }

  private var namePtr: Ptr<String> { Ptr(self.ptr, offset: Layout.nameOffset) }
  public var name: String { self.namePtr.pointee }

  private var basePtr: Ptr<PyType?> { Ptr(self.ptr, offset: Layout.baseOffset) }
  public var base: PyType? { self.basePtr.pointee }

  private var __add__Ptr: Ptr<BinaryOperation?> { Ptr(self.ptr, offset: Layout.__add__Offset) }
  public var __add__: BinaryOperation? { self.__add__Ptr.pointee }

  private var debugFnPtr: Ptr<DebugFn> { Ptr(self.ptr, offset: Layout.debugFnOffset) }
  public var debugFn: DebugFn { self.debugFnPtr.pointee }

  // swiftlint:disable:next line_length
  private var deinitializerPtr: Ptr<DeinitializerFn> { Ptr(self.ptr, offset: Layout.deinitializerOffset) }
  public var deinitializer: DeinitializerFn { self.deinitializerPtr.pointee }

  public let ptr: RawPtr

  public init(ptr: RawPtr) {
    self.ptr = ptr
  }

  // MARK: - Initialize

  // swiftlint:disable:next function_parameter_count
  public func initialize(type: PyType,
                         name: String,
                         base: PyType?,
                         __add__: BinaryOperation?,
                         debugFn: @escaping PyType.DebugFn,
                         deinitialize: @escaping PyType.DeinitializerFn) {
    self.header.initialize(type: type)
    self.namePtr.initialize(to: name)
    self.basePtr.initialize(to: base)
    self.__add__Ptr.initialize(to: __add__)
    self.debugFnPtr.initialize(to: debugFn)
    self.deinitializerPtr.initialize(to: deinitialize)
  }

  public static func deinitialize(ptr: RawPtr) {
    let zelf = PyType(ptr: ptr)
    zelf.header.deinitialize()
    zelf.namePtr.deinitialize()
    zelf.basePtr.deinitialize()
    zelf.__add__Ptr.deinitialize()
    zelf.debugFnPtr.deinitialize()
    zelf.deinitializerPtr.deinitialize()
  }

  // MARK: - Debug

  public static func createDebugString(ptr: RawPtr) -> String {
    let zelf = PyType(ptr: ptr)
    return "PyType(type: \(zelf.typeName), name: \(zelf.name))"
  }
}

// MARK: - PyMemory

extension PyMemory {

  /// Those types require special treatment because:
  /// - `object` type has `type` type
  /// - `type` type has `type` type (self reference) and `object` type as base
  public func newTypeAndObjectTypes() -> (typeType: PyType, objectType: PyType) {
    print("Allocating PyTypes: type & object")

    let size = PyType.Layout.size
    let typeTypePtr = self.allocateObject(size: size)
    let objectTypePtr = self.allocateObject(size: size)

    let typeType = PyType(ptr: typeTypePtr)
    let objectType = PyType(ptr: objectTypePtr)

    typeType.initialize(type: typeType,
                        name: "type",
                        base: objectType,
                        __add__: nil,
                        debugFn: PyType.createDebugString(ptr:),
                        deinitialize: PyType.deinitialize(ptr:))

    objectType.initialize(type: typeType,
                          name: "object",
                          base: nil,
                          __add__: nil,
                          debugFn: PyObject.createDebugString(ptr:),
                          deinitialize: PyObject.deinitialize(ptr:))

    return (typeType, objectType)
  }
}
