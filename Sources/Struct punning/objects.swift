// MARK: - Header

struct PyObjectHeader: CustomStringConvertible {

  struct Flags: OptionSet {
    let rawValue: UInt32
  }

  var type: PyTypeRef
  var flags: Flags
  /// Padding is important!
  /// Otherwise Swift would use the remaining space in outer `struct`.
  private let padding = UInt32.max

  /// Name of the type (mostly for convenience).
  var typeName: String {
    return type.name
  }

  var description: String {
    return "PyObjectHeader(type: \(self.typeName), flags: \(self.flags))"
  }
}

// MARK: - Object

struct PyObject: CustomStringConvertible {
  var header: PyObjectHeader

  var description: String {
    return "PyObject(type: \(self.header.typeName))"
  }
}

typealias PyObjectRef = Ref<PyObject>

extension PyObjectRef {
  var type: PyTypeRef { self.pointee.header.type }
  var typeName: String { self.pointee.header.typeName }

  /// Init from `Ref` to another object (pointer type conversion).
  ///
  /// Casting to `PyObjectRef` is so common that we will introcude a specific
  /// alias to avoid typing  `from:` inside `PyObjectRef(from: elsa)`.
  init<T>(_ other: Ref<T>) {
    self.init(from: other)
  }
}

// MARK: - Type

struct PyType: CustomStringConvertible {
  var header: PyObjectHeader
  var name: String
  var base: PyTypeRef?

  // Slots for common functions
  // This should be inside '__dict__', but it is too much work for this simple example.
  typealias BinaryOperation = (PyObjectRef) -> (PyObjectRef) -> PyResult<PyObjectRef>
  var __add__: BinaryOperation?

  var description: String {
    return "PyType(type: \(self.header.typeName), name: \(self.name))"
  }
}

typealias PyTypeRef = Ref<PyType>

extension PyTypeRef {
  var type: PyTypeRef { self.pointee.header.type }
  var name: String { self.pointee.name }
  var base: PyTypeRef? { self.pointee.base }
  var __add__: PyType.BinaryOperation? { self.pointee.__add__ }
}

// MARK: - None

struct PyNone: CustomStringConvertible {
  var header: PyObjectHeader

  var description: String {
    return "PyNone(type: \(self.header.typeName))"
  }
}

typealias PyNoneRef = Ref<PyNone>

extension PyNoneRef {
  var type: PyTypeRef { self.pointee.header.type }
}

// MARK: - NotImplemented

struct PyNotImplemented: CustomStringConvertible {
  var header: PyObjectHeader

  var description: String {
    return "PyNotImplemented(type: \(self.header.typeName))"
  }
}

typealias PyNotImplementedRef = Ref<PyNotImplemented>

extension PyNotImplementedRef {
  var type: PyTypeRef { self.pointee.header.type }
}

// MARK: - Int

struct PyInt: CustomStringConvertible {
  var header: PyObjectHeader
  var value: Int

  var description: String {
    return "PyInt(type: \(self.header.typeName), value: \(self.value))"
  }
}

typealias PyIntRef = Ref<PyInt>

extension PyIntRef {
  var type: PyTypeRef { self.pointee.header.type }
  var value: Int { self.pointee.value }

  // sourcery: pymethod = __add__
  public func add(_ other: PyObjectRef) -> PyResult<PyObjectRef> {
    // This is how the old implementation looks like:
    //
    // guard let other = other as? PyInt else {
    //   return .value(Py.notImplemented)
    // }
    //
    // let result = self.value + other.value
    // return .value(Py.newInt(result))

    guard let other = PyCast.asInt(other) else {
      let notImplemented = PyObjectRef(Py.notImplemented)
      return .value(notImplemented)
    }

    let resultValue = self.value + other.value
    let result = PyMemory.initInt(value: resultValue)
    return .value(PyObjectRef(result))
  }
}

// MARK: - Error

struct PyError: CustomStringConvertible {
  var header: PyObjectHeader
  var message: String

  var description: String {
    return "PyError(type: \(self.header.typeName), message: \(self.message))"
  }
}

typealias PyErrorRef = Ref<PyError>

extension PyErrorRef {
  var type: PyTypeRef { self.pointee.header.type }
}
