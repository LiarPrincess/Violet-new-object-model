enum PyResult<Wrapped> {

  /// Use this ctor for ordinary (non-error) values.
  case value(Wrapped)
  /// Use this ctor to raise error in VM.
  case error(PyErrorRef)

  /// Error factory
  static func error(_ msg: String) -> PyResult<Wrapped> {
    return .error(PyMemory.initError(message: msg))
  }
}
