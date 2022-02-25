public struct PyMemory {

  public func newObject(type: PyType) -> PyObject {
    print("Allocating PyObject")
    let ptr = self.allocateObject(size: PyObject.Layout.size)
    let result = PyObject(ptr: ptr)
    result.initialize(type: type)
    return result
  }

  // swiftlint:disable:next function_parameter_count
  public func newType(type: PyType,
                      name: String,
                      base: PyType?,
                      __add__: PyType.BinaryOperation?,
                      debugFn: @escaping PyType.DebugFn,
                      deinitialize: @escaping PyType.DeinitializerFn) -> PyType {
    print("Allocating PyType:", name)
    let ptr = self.allocateObject(size: PyType.Layout.size)
    let result = PyType(ptr: ptr)
    result.initialize(type: type,
                      name: name,
                      base: base,
                      __add__: __add__,
                      debugFn: debugFn,
                      deinitialize: deinitialize)

    return result
  }

  public func newNone(type: PyType) -> PyNone {
    print("Allocating PyNone")
    let ptr = self.allocateObject(size: PyNone.Layout.size)
    let result = PyNone(ptr: ptr)
    result.initialize(type: type)
    return result
  }

  public func newNotImplemented(type: PyType) -> PyNotImplemented {
    print("Allocating PyNotImplemented")
    let ptr = self.allocateObject(size: PyNotImplemented.Layout.size)
    let result = PyNotImplemented(ptr: ptr)
    result.initialize(type: type)
    return result
  }

  public func newInt(type: PyType, value: Int64) -> PyInt {
    print("Allocating PyInt:", value)
    let ptr = self.allocateObject(size: PyInt.Layout.size)
    let result = PyInt(ptr: ptr)
    result.initialize(type: type, value: value)
    return result
  }

  public func newError(type: PyType, message: String) -> PyError {
    print("Allocating PyError:", message)
    let ptr = self.allocateObject(size: PyError.Layout.size)
    let result = PyError(ptr: ptr)
    result.initialize(type: type, message: message)
    return result
  }

  // MARK: - Allocate

  internal func allocateObject(size: Int) -> RawPtr {
    assert(size >= SizeOf.objectHeader)
    let result = RawPtr.allocate(byteCount: size, alignment: AlignmentOf.word)
    return result
  }

  public func deallocateObject(_ object: PyObject) {
    print("Destroying: \(object)")
    let ptr = object.ptr
    object.type.deinitializer(ptr)
    ptr.deallocate()
  }
}
