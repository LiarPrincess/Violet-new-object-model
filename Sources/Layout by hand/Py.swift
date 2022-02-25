public struct PyContext {

  // MARK: - Types

  public struct Types {

    public let type: PyType
    public let object: PyType

    public let none: PyType
    public let notImplemented: PyType
    public let int: PyType
    public let error: PyType

    public init(memory: PyMemory) {
      let pair = memory.newTypeAndObjectTypes()
      self.type = pair.typeType
      self.object = pair.objectType

      self.none = memory.newType(type: self.type,
                                 name: "NoneType",
                                 base: self.object,
                                 __add__: nil,
                                 debugFn: PyNone.createDebugString(ptr:),
                                 deinitialize: PyNone.deinitialize(ptr:))

      self.notImplemented = memory.newType(type: self.type,
                                           name: "NotImplementedType",
                                           base: self.object,
                                           __add__: nil,
                                           debugFn: PyNotImplemented.createDebugString(ptr:),
                                           deinitialize: PyNotImplemented.deinitialize(ptr:))

      self.int = memory.newType(type: self.type,
                                name: "int",
                                base: self.object,
                                __add__: PyInt.__add__(zelf:other:),
                                debugFn: PyInt.createDebugString(ptr:),
                                deinitialize: PyInt.deinitialize(ptr:))

      self.error = memory.newType(type: self.type,
                                  name: "Error",
                                  base: self.object,
                                  __add__: nil,
                                  debugFn: PyError.createDebugString(ptr:),
                                  deinitialize: PyError.deinitialize(ptr:))
    }
  }

  // MARK: - Properties + init

  public let memory: PyMemory
  public let types: Types

  public let none: PyNone
  public let notImplemented: PyNotImplemented

  public init() {
    self.memory = PyMemory()
    self.types = Types(memory: self.memory)

    self.none = memory.newNone(type: self.types.none)
    self.notImplemented = memory.newNotImplemented(type: self.types.notImplemented)
  }

  // MARK: - New

  public func newInt(value: Int64) -> PyInt {
    let type = self.types.int
    return self.memory.newInt(type: type, value: value)
  }

  public func newError(message: String) -> PyError {
    let type = self.types.error
    return self.memory.newError(type: type, message: message)
  }

  // MARK: - Methods

  public func add(left: PyObject, right: PyObject) -> PyResult<PyObject> {
    // We should also check if 'left' has not overriden '__add__',
    // but we don't have subtypes in this tiny program.
    if let fn = left.type.__add__ {
      let result = fn(left, right)
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
    let message = "unsupported operand type(s) for +: \(left.typeName) and \(right.typeName)."
    return .error(message)
  }
}
