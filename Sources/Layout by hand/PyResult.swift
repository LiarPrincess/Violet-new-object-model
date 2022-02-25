public enum PyResult<Wrapped> {

  /// Use this ctor for ordinary (non-error) values.
  case value(Wrapped)
  /// Use this ctor to raise error in VM.
  case error(PyError)

  /// Error factory
  public static func error(_ message: String) -> PyResult<Wrapped> {
    let error = Py.newError(message: message)
    return .error(error)
  }
}
