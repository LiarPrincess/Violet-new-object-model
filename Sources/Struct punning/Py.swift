enum Py {

  // MARK: - Interned

  static let none = PyMemory.initNone()
  static let notImplemented = PyMemory.initNotImplemented()

  // MARK: - Types

  enum Types {

    private static var _object: PyTypeRef?
    private static var _type: PyTypeRef?

    /// Root of the Python type hierarchy
    static var object: PyTypeRef {
      if let result = Self._object { return result }
      Self.initializeTypeAndObjectTypes()
      return Self._object!
    }

    /// Type that is the type of all of the type objects (including itself)
    static var type: PyTypeRef {
      if let result = Self._type { return result }
      Self.initializeTypeAndObjectTypes()
      return Self._type!
    }

    static let none = PyMemory.initType(
      name: "NoneType",
      base: Self.object
    )

    static let notImplemented = PyMemory.initType(
      name: "NotImplementedType",
      base: Self.object
    )

    static let error = PyMemory.initType(
      name: "Error",
      base: Self.object
    )

    static let int = PyMemory.initType(
      name: "int",
      base: Self.object,
      __add__: Self.downcastLhsAsInt(fnName: "__add__", fn: PyIntRef.add(_:))
    )

    private static func initializeTypeAndObjectTypes() {
      let (typeType, objectType) = PyMemory.initTypeAndObjectTypes()
      Self._type = typeType
      Self._object = objectType
    }

    private static func downcastLhsAsInt(
      fnName: String,
      fn: @escaping (PyIntRef) -> (PyObjectRef) -> PyResult<PyObjectRef>
    ) -> PyType.BinaryOperation {
      return { (lhs: PyObjectRef) in { (rhs: PyObjectRef) in
        if let lhsAsInt = PyCast.asInt(lhs) {
          return fn(lhsAsInt)(rhs)
        }

        return .error(
          "descriptor '\(fnName)' requires a 'int' object but received a '\(lhs.typeName)'"
        )
      }}
    }
  }

  // MARK: - Add

  static func add(left: PyObjectRef, right: PyObjectRef) -> PyResult<PyObjectRef> {
    // We should also check if 'left' has not overriden '__add__',
    // but we don't have subtypes in this tiny program.
    if let fn = left.type.__add__ {
      let result = fn(left)(right)
      switch result {
      case let .value(object):
        // If '__add__' returns 'NotImplemented' then operands are not supported.
        if PyCast.isNotImplemented(object) {
          break
        }

        return result
      case let .error(e):
        return .error(e)
      }
    }

    // We will skip dispatch from 'type.__dict__' because our types don't have '__dict__'.
    // We will also skip '__radd__'.
    // This leaves us with:
    return .error(
      "unsupported operand type(s) for +: \(left.typeName) and \(right.typeName)."
    )
  }
}
