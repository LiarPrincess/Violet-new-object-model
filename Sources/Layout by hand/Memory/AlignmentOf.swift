public enum AlignmentOf {

  // We only have 1 possible alignment for all of the Python objects.
  public static let word = SizeOf.pointer

  internal static func checkInvariants() {
    Self.checkAlignment(of: RawPtr.self, isLessEqual: AlignmentOf.word)
    Self.checkAlignment(of: Ptr<PyObject>.self, isLessEqual: AlignmentOf.word)

    Self.checkAlignment(of: Int64.self, isLessEqual: AlignmentOf.word)
    Self.checkAlignment(of: UInt32.self, isLessEqual: AlignmentOf.word)
    Self.checkAlignment(of: UInt64.self, isLessEqual: AlignmentOf.word)
    Self.checkAlignment(of: String.self, isLessEqual: AlignmentOf.word)

    Self.checkAlignment(of: PyType.DeinitializerFn.self, isLessEqual: AlignmentOf.word)
  }

  private static func checkAlignment<T>(of type: T.Type, isLessEqual: Int) {
    let alignment = MemoryLayout<T>.alignment
    if alignment > isLessEqual {
      let typeName = String(describing: type)
      trap("[Invariant] \(typeName) has alignment \(alignment) instead of expected \(isLessEqual)")
    }
  }
}
