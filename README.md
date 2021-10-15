Test the following [object model for Violet](https://github.com/LiarPrincess/Violet/issues/1):

```swift
struct Ref<Pointee> {
  let ptr: UnsafePointer<Pointee>
}

struct PyObjectHeader {
  var type: Ref<PyType>
  var flags: UInt32
  private let padding = UInt32.max
}

struct PyObject {
  var header: PyObjectHeader
}

struct PyInt {
  var header: PyObjectHeader
  var value: Int
}

func newInt(value: Int) -> Ref<PyInt> {
  // Basically malloc(sizeof(PyInt)) + filling properties
}

// 'int' is a Python object representing number '2'
let int = newInt(value: 2)

// Cast it to 'PyObject' — this is really important since
// we will need to do this to store object on VM stack.
// (spoiler: this is not legal!)
let object = Ref<PyObject>(ptr: int.ptr)
```

Please note that this not legal in Swift, as the memory layout of `struct` is not guaranteed to follow declaration order! For details see [this issue](https://github.com/LiarPrincess/Violet/issues/1)).

Btw. ignore any of the `C` files.
