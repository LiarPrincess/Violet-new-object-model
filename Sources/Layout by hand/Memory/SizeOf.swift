public enum SizeOf {

  public static let objectHeader = PyObjectHeader.Layout.size
  public static let pointer = 8

  public static let int64 = 8
  public static let uint32 = 4
  public static let uint64 = 8
  public static let string = 16

  public static let method = 16
  public static let deinitializer = Self.method

  public static let padding32 = Self.uint32

  internal static func checkInvariants() {
    Self.checkSize(of: RawPtr.self, expected: Self.pointer)
    Self.checkSize(of: Ptr<PyObject>.self, expected: Self.pointer)

    Self.checkSize(of: Int64.self, expected: Self.int64)
    Self.checkSize(of: UInt32.self, expected: Self.uint32)
    Self.checkSize(of: UInt64.self, expected: Self.uint64)
    Self.checkSize(of: String.self, expected: Self.string)

    Self.checkSize(of: PyType.DeinitializerFn.self, expected: Self.deinitializer)
  }

  private static func checkSize<T>(of type: T.Type, expected: Int) {
    let size = MemoryLayout<T>.stride
    if size != expected {
      let typeName = String(describing: type)
      trap("[Invariant] \(typeName) has size \(size) instead of expected \(expected)")
    }
  }
}
