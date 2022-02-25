/// Common things for all of the Python objects.
public protocol PyObjectMixin: CustomDebugStringConvertible {
  var ptr: RawPtr { get }
}

extension PyObjectMixin {

  public var header: PyObjectHeader {
    // Assumption: headerOffset = 0, but this should be valid for all of our types.
    return PyObjectHeader(ptr: self.ptr)
  }

  /// Also known as `klass`, but we are using CPython naming convention.
  public var type: PyType { self.header.type }
  /// [Convenience] Name of the type of this Python object.
  public var typeName: String { self.type.name }

  /// Various flags that describe the current state of the `PyObject`.
  ///
  /// It can also be used to store `Bool` properties (via `custom` flags).
  public var flags: PyObjectHeader.Flags { self.header.flags }

  /// [Convenience] Convert this object to `PyObject`.
  public var asObject: PyObject { PyObject(ptr: self.ptr) }

  public var debugDescription: String {
    let type = self.header.type
    return type.debugFn(self.ptr)
  }
}
