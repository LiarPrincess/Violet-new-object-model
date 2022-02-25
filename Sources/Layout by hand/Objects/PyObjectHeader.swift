public struct PyObjectHeader {

  public enum Layout {
    public static let typeOffset = 0
    public static let typeSize = SizeOf.pointer

    public static let flagsOffset = Layout.typeOffset + Layout.typeSize
    public static let flagsSize = SizeOf.uint32

    // Round up the 'flags' up to the full word.
    private static let padding = SizeOf.padding32
    internal static let size = Layout.flagsOffset + Layout.flagsSize + Layout.padding
  }

  public struct Flags {
    public var value = UInt32.zero

    public init() {}
  }

  // MARK: - Properties and init

  private var typePtr: Ptr<PyType> { Ptr(self.ptr, offset: Layout.typeOffset) }
  public var type: PyType { self.typePtr.pointee }

  private var flagsPtr: Ptr<Flags> { Ptr(self.ptr, offset: Layout.flagsOffset) }
  public var flags: Flags {
    get { self.flagsPtr.pointee }
    set { self.flagsPtr.pointee = newValue }
  }

  public let ptr: RawPtr

  public init(ptr: RawPtr) {
    self.ptr = ptr
  }

  // MARK: - Initialize

  public func initialize(type: PyType) {
    let flags = PyObjectHeader.Flags()
    self.typePtr.initialize(to: type)
    self.flagsPtr.initialize(to: flags)
  }

  public func deinitialize() {
    self.typePtr.deinitialize()
    self.flagsPtr.deinitialize() // Trivial
  }
}
