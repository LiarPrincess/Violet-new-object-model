// This type can be automatically generated.
enum PyCast {

  // MARK: - Not implemented

  static func isNotImplemented(_ object: PyObjectRef) -> Bool {
    return self.isInstance(object, of: Py.Types.notImplemented)
  }

  // MARK: - Int

  static func isInt(_ object: PyObjectRef) -> Bool {
    return self.isInstance(object, of: Py.Types.int)
  }

  static func isIntExact(_ object: PyObjectRef) -> Bool {
    return self.isExactInstance(object, of: Py.Types.int)
  }

  static func asInt(_ object: PyObjectRef) -> PyIntRef? {
    return Self.isInt(object) ? PyIntRef(from: object) : nil
  }

  static func asIntExact(_ object: PyObjectRef) -> PyIntRef? {
    return Self.isIntExact(object) ? PyIntRef(from: object) : nil
  }

  // MARK: - Helpers

  private static func isInstance(_ object: PyObjectRef,
                                 of targetType: PyTypeRef) -> Bool {
    var type: PyTypeRef? = object.type

    while let t = type {
      if t === targetType {
        return true
      }

      type = t.base
    }

    return false
  }

  private static func isExactInstance(_ object: PyObjectRef,
                                      of targetType: PyTypeRef) -> Bool {
    return object.type === targetType
  }
}
