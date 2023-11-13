@propertyWrapper public struct Reference<Value> {
  public init(wrappedValue: Value) {
    box = .init(value: wrappedValue)
  }
  private final class Box {
    init(value: Value) { self.value = value }
    var value: Value
  }
  private var box: Box
  public var wrappedValue: Value {
    get { box.value }
    set { box.value = newValue }
  }
}

@propertyWrapper public struct WeakReference<Value: AnyObject> {
  public init(wrappedValue: Value?) {
    box = .init(value: wrappedValue)
  }
  private final class Box {
    init(value: Value?) { self.value = value }
    weak var value: Value?
  }
  private var box: Box
  public var wrappedValue: Value? {
    get { box.value }
    set { box.value = newValue }
  }
}
