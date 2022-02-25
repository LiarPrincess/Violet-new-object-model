Test the various [object models for Violet](https://github.com/LiarPrincess/Violet/issues/1).

# Layout by hand

We can just allocate a block of memory and manually assign where do each field starts and ends.

(Following code example is an approximation, see the real code for better illustration of the concept.)

```Swift
struct PyInt {

  internal let ptr: UnsafeRawPointer

  // `PyObjectHeader` holds `type/flags` (and maybe `__dict__`).
  internal var header: PyObjectHeader {
    return PyObjectHeader(ptr: self.ptr)
  }

  // Without using [flexible array member](https://en.wikipedia.org/wiki/Flexible_array_member).
  // This may also invoke needless COW when we modify the value, but there are
  // ways to prevent this.
  internal var value: Int {
    // We also need to align this 'ptr', but we will skip this in the example,
    // since the code for this would depend on the property type.
    // Or we could craft 'PyObjectHeader', so that its 'size' is always word aligned.
    let ptr = self.ptr + PyObjectHeader.size
    return ptr.pointee
  }
}

extension PyMemory {

  internal func newInt(type: PyType, value: Int) {
    // Skipping alignment (again…)
    let memorySize = PyObjectHeader.size + Int.size
    let ptr = self.allocate(size: memorySize)
    let int = PyInt(ptr: ptr)

    int.header.type = type
    int.header.flags = // Something…
    int.value = value

    // register for garbage collection/arc
    self.startTracking(object: int.header)
  }
}
```

This is really promising since the whole concept is quite simple. The execution (as in: writing the code) is a little bit more complicated since it lacks the compiler support for proper alignment.

# `Struct` punning

In this approach would be to use `struct` and type punning to create object hierarchy by hand (this is more-or-less what CPython does).

(Following code example is an approximation, see the real code for better illustration of the concept.)

```Swift
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

As we can see both `PyObject` and `PyInt` start with `PyObjectHeader`, so one could assume that they can easily convert from `Ref<PyInt>` to `Ref<PyObject>`.

Well… Swift does not guarantee that the memory layout will be the same as declaration order (even with [SE-0210: Add an offset(of:) method to MemoryLayout](https://github.com/apple/swift-evolution/blob/master/proposals/0210-key-path-offset.md)). Yes, this *is* what happens right now, but it may change in the future. There are some exceptions, for example:
- `struct` with single member will have the same layout as this member
- `enum` with single `case` with payload will have the payload layout
- homogenous tuples will look “as expected”
- `@frozen` thingies with library-evolution enabled

But, none of them applies in our case.

This approach also blocks us from using [flexible array member](https://en.wikipedia.org/wiki/Flexible_array_member), unless we do some additional things (allocate more space, and then offset the `struct` pointer to get aligned address of array members).

Related resources:
- [WWDC 2020: Safely manage pointers in Swift](https://developer.apple.com/videos/play/wwdc2020/10167)
- [Swift forum: “Guarantee (in-memory) tuple layout…or don’t” thread by Jordan Rose](https://forums.swift.org/t/guarantee-in-memory-tuple-layout-or-dont/40122)
- [Swift docs: TypeSafeMemory.rst](https://github.com/atrick/swift/blob/type-safe-mem-docs/docs/TypeSafeMemory.rst)
- [Swift evolution: UnsafeRawPointer API](https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md)
