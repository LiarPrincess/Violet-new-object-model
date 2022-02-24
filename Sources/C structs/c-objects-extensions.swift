/* ===================================== */
/* === Solution 1 (C1) - with struct === */
/* ===================================== */

extension C1_ObjectHeader {

  var type: PyTypeRef {
    return PyTypeRef(ptr: self._type)
  }

  var flags: PyObjectHeader.Flags {
    get { return PyObjectHeader.Flags(rawValue: self._flags) }
    set { self._flags = newValue.rawValue }
  }

  init(type: PyTypeRef, flags: PyObjectHeader.Flags) {
    self.init(_type: type.ptr, _flags: flags.rawValue)
  }
}

extension C1_Type {

  var header: C1_ObjectHeader {
    return self._header
  }

  var base: PyTypeRef? {
    return self._base.map(PyTypeRef.init(ptr:))
  }

  init(type: PyTypeRef, flags: PyObjectHeader.Flags, base: PyTypeRef?) {
    let header = C1_ObjectHeader(type: type, flags: flags)
    self.init(_header: header, _base: base?.ptr)
  }
}

/* ==================================== */
/* === Solution 2 (C2) - with macro === */
/* ==================================== */

extension C2_Type {

  var type: PyTypeRef {
    return PyTypeRef(ptr: self._type)
  }

  var flags: PyObjectHeader.Flags {
    get { return PyObjectHeader.Flags(rawValue: self._flags) }
    set { self._flags = newValue.rawValue }
  }

  var base: PyTypeRef? {
    return self._base.map(PyTypeRef.init(ptr:))
  }

  init(type: PyTypeRef, flags: PyObjectHeader.Flags, base: PyTypeRef?) {
    self.init(_type: type.ptr, _flags: flags.rawValue, _base: base?.ptr)
  }
}
