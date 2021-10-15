func printTypes() {
  print("=== Types ===")

  print(">>> Type type")
  let typeType = Py.Types.type
  print(typeType)
  assert(typeType.name == "type")
  assert(typeType.base! === Py.Types.object)
  assert(typeType.type === Py.Types.type)

  print(">>> Object type")
  let objectType = Py.Types.object
  print(objectType)
  assert(objectType.name == "object")
  assert(objectType.base == nil)
  assert(objectType.type === Py.Types.type)

  print(">>> Int type")
  let intType = Py.Types.int
  print(intType)
  assert(intType.name == "int")
  assert(intType.base! === Py.Types.object)
  assert(intType.type === Py.Types.type)
}

func printObjects() {
  print("=== Objects ===")

  print(">>> None")
  let none = Py.none
  print(none)
  assert(none.type === Py.Types.none)

  print(">>> NotImplemented")
  let notImplemented = Py.notImplemented
  print(notImplemented)
  assert(notImplemented.type === Py.Types.notImplemented)

  print(">>> Int")
  let int = PyMemory.initInt(value: 2)
  defer { PyMemory.destroy(int) }
  print(int)
  assert(int.type === Py.Types.int)
  assert(int.value == 2)
}

func testPointerConversion() {
  print("=== Testing pointer conversion ===")
  // TODO: This is not valid in Swift
  // https://developer.apple.com/videos/play/wwdc2020/10167
  // https://forums.swift.org/t/guarantee-in-memory-tuple-layout-or-dont/40122
  // https://github.com/atrick/swift/blob/type-safe-mem-docs/docs/TypeSafeMemory.rst
  // https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md
  // https://en.cppreference.com/w/c/language/type
  // Btw. tail allocation:
  // https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md#expected-use-cases

  print(">>> Starting as PyIntRef")
  let int = PyMemory.initInt(value: 2)
  defer { PyMemory.destroy(int) }
  print(int)
  assert(int.type === Py.Types.int)
  assert(int.value == 2)

  print(">>> Casting to PyObjectRef")
  let object = PyObjectRef(int)
  print(object)
  assert(object.type === Py.Types.int)
//  assert(object.value == 2) // not available

  print(">>> Back to PyIntRef (via: PyCast.asInt)")
  switch PyCast.asInt(object) {
  case .some(let intAgain):
    print(intAgain)
    assert(intAgain.type === Py.Types.int)
    assert(intAgain.value == 2)
  case .none:
    print("Failed")
  }
}

func testMethodCalls() {
  print("=== Testing method calls ===")

  func addAndPrint(left: PyObjectRef, right: PyObjectRef, expecting: Int?) {
    let result = Py.add(left: left, right: right)
    switch result {
    case let .value(object):
      let int = PyCast.asInt(object)! // We only have 'int' addition
      print(int)
      assert(int.type === Py.Types.int)
      assert(int.value == expecting)
      PyMemory.destroy(object) // Or 'int', whatever...
    case let .error(e):
      print(e)
      assert(expecting == nil)
      assert(e.type === Py.Types.error)
      PyMemory.destroy(e)
    }
  }

  print(">>> 2 + 2 = 4")
  let two = PyObjectRef(PyMemory.initInt(value: 2))
  defer { PyMemory.destroy(two) }
  addAndPrint(left: two, right: two, expecting: 4)

  print(">>> 2 + None = Error (because 'int' returns 'NotImplemented')")
  let none = PyObjectRef(Py.none)
  addAndPrint(left: two, right: none, expecting: nil)

  print(">>> None + 2 = Error (because 'None' does not support '__add__')")
  addAndPrint(left: none, right: two, expecting: nil)
}

printTypes()
print()
printObjects()
print()
testPointerConversion()
print()
testMethodCalls()
print()

//print("===")
//print("size:     ", MemoryLayout<PyObjectHeader>.size)
//print("stride:   ", MemoryLayout<PyObjectHeader>.stride)
//print("alignment:", MemoryLayout<PyObjectHeader>.alignment)
//static_assert(sizeof(HeapObject) == 2*sizeof(void*),
//              "HeapObject must be two pointers long");
//
//static_assert(alignof(HeapObject) == alignof(void*),
//              "HeapObject must be pointer-aligned");
