// 1) https://github.com/atrick/swift/blob/type-safe-mem-docs/docs/TypeSafeMemory.rst
//   Really important as it talks about 'related types' and 'layout compatible types'.
//
//   As for the related types we will be using the following definition:
//   2. one type may be a tuple, enum, or struct that contains the other type
//     as part of its own storage
//
//   For 'layout compatible types' we have:
//   - identical types and type aliases
//   - pointer types (e.g. OpaquePointer, UnsafePointer)
//   - fragile structs with one stored property and their stored property type
//   Also important: layout compatibility is transitive.
//
// 2) https://developer.apple.com/documentation/swift/unsafemutablerawpointer
//   Eh... it is long, but you kind of have to read it.

// swiftlint:disable force_unwrapping

SizeOf.checkInvariants()
AlignmentOf.checkInvariants()

// swiftlint:disable:next static_operator
public func === (lhs: PyType, rhs: PyType) -> Bool {
  // This is a helper for tests, not a thing that should be included in Violet.
  return lhs.ptr === rhs.ptr
}

let Py = PyContext()

print()

do {
  print("=== Types ===")
  print()

  print(">>> Type type")
  let typeType = Py.types.type
  print(typeType)
  assert(typeType.name == "type")
  assert(typeType.base! === Py.types.object)
  assert(typeType.type === Py.types.type)
  print()

  print(">>> Object type")
  let objectType = Py.types.object
  print(objectType)
  assert(objectType.name == "object")
  assert(objectType.base == nil)
  assert(objectType.type === Py.types.type)
  print()

  print(">>> Int type")
  let intType = Py.types.int
  print(intType)
  assert(intType.name == "int")
  assert(intType.base! === Py.types.object)
  assert(intType.type === Py.types.type)
  print()
}

do {
  print("=== Objects ===")
  print()

  print(">>> None")
  let none = Py.none
  print(none)
  assert(none.type === Py.types.none)
  print()

  print(">>> NotImplemented")
  let notImplemented = Py.notImplemented
  print(notImplemented)
  assert(notImplemented.type === Py.types.notImplemented)
  print()

  print(">>> Int")
  let int = Py.newInt(value: 2)
  print(int)
  assert(int.type === Py.types.int)
  assert(int.value == 2)
  Py.memory.deallocateObject(int.asObject)
  print()
}

do {
  print("=== Testing pointer conversion ===")
  print()

  print(">>> Starting as PyIntRef")
  let int = Py.newInt(value: 2)
  print(int)
  assert(int.type === Py.types.int)
  assert(int.value == 2)
  print()

  print(">>> Casting to PyObject")
  let object = PyObject(ptr: int.ptr)
  print(object)
  assert(object.type === Py.types.int)
  // assert(object.value == 2) // not available
  print()

  print(">>> Back to PyInt (via: PyCast.asInt)")
  switch PyCast.asInt(object) {
  case .some(let intAgain):
    print(intAgain)
    assert(intAgain.type === Py.types.int)
    assert(intAgain.value == 2)
  case .none:
    print("Failed")
  }

  Py.memory.deallocateObject(int.asObject)
  print()
}

do {
  print("=== Testing method calls ===")
  print()

  func addAndPrint(left: PyObject, right: PyObject, expecting: Int?) {
    let result = Py.add(left: left, right: right)
    switch result {
    case let .value(object):
      let int = PyCast.asInt(object)! // We only have 'int' addition
      print("Result:", int)
      assert(int.type === Py.types.int)
      assert(int.value == expecting!)
      Py.memory.deallocateObject(object) // Or 'int', whatever...
    case let .error(e):
      print("Result:", e)
      assert(expecting == nil)
      assert(e.type === Py.types.error)
      Py.memory.deallocateObject(e.asObject)
    }
  }

  print(">>> 2 + 2 = 4")
  let two = Py.newInt(value: 2)
  addAndPrint(left: two.asObject, right: two.asObject, expecting: 4)
  print()

  print(">>> 2 + None = Error (because 'int' returns 'NotImplemented')")
  let none = Py.none
  addAndPrint(left: two.asObject, right: none.asObject, expecting: nil)
  print()

  print(">>> None + 2 = Error (because 'None' does not support '__add__')")
  addAndPrint(left: none.asObject, right: two.asObject, expecting: nil)

  Py.memory.deallocateObject(two.asObject)
  print()
}
