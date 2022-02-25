public enum PyCast {

  // MARK: - Not implemented

  public static func isNotImplemented(_ object: PyObject) -> Bool {
    return self.isInstance(object, of: Py.types.notImplemented)
  }

  // MARK: - Int

  public static func isInt(_ object: PyObject) -> Bool {
    return self.isInstance(object, of: Py.types.int)
  }

  public static func isIntExact(_ object: PyObject) -> Bool {
    return self.isExactInstance(object, of: Py.types.int)
  }

  public static func asInt(_ object: PyObject) -> PyInt? {
    return PyCast.isInt(object) ? PyInt(ptr: object.ptr) : nil
  }

  public static func asIntExact(_ object: PyObject) -> PyInt? {
    return Self.isIntExact(object) ? PyInt(ptr: object.ptr) : nil
  }

  // MARK: - Helpers

  private static func isInstance(_ object: PyObject, of targetType: PyType) -> Bool {
    var type: PyType? = object.type

    while let t = type {
      if t.ptr === targetType.ptr {
        return true
      }

      type = t.base
    }

    return false
  }

  private static func isExactInstance(_ object: PyObject, of targetType: PyType) -> Bool {
    return object.type.ptr === targetType.ptr
  }
}
