import SwiftUI

#if DEBUG
import OSLog
#endif

extension EnvironmentValues {
  /// Find arbitrary environment values with a key & type.
  public func value<T>(of key: String, as: T.Type = T.self) -> T? {
    #if DEBUG
    let logger = Logger(subsystem: "com.splunk", category: key)
    #endif

    let desiredKey = "TypedElement<EnvironmentPropertyKey<\(key)>>"
    guard let environment = Mirror(reflecting: self).descendant(0, 0, "some") else {
      #if DEBUG
      logger.error("could not find environment.")
      #endif
      return nil
    }
    func visit(_ node: Any) -> T? {
      let currentKey = String(describing: type(of: node))
      let mirror = Mirror(reflecting: node)
      if currentKey == desiredKey {
        if let value = mirror.descendant(0, "some") as? T {
          return value
        } else if let value = mirror.descendant(0) as? T {
          return value
        }

        return nil
      }

      guard let nextNode = mirror.superclassMirror?.descendant("after", "some") else {
        #if DEBUG
        logger.error("could not find key: \(key) of type: \(T.self).")
        #endif
        return nil
      }
      return visit(nextNode)
    }
    return visit(environment)
  }

  public func _value(of key: String) -> Any? {
    #if DEBUG
    let logger = Logger(subsystem: "com.splunk", category: key)
    #endif

    let desiredKey = "TypedElement<EnvironmentPropertyKey<\(key)>>"
    guard let environment = Mirror(reflecting: self).descendant(0, 0, "some") else {
      #if DEBUG
      logger.error("could not find environment.")
      #endif
      return nil
    }
    func visit(_ node: Any) -> Any? {
      let currentKey = String(describing: type(of: node))
      let mirror = Mirror(reflecting: node)
      if currentKey == desiredKey {
        return mirror.descendant(0)
      }

      guard let nextNode = mirror.superclassMirror?.descendant("after", "some") else {
        #if DEBUG
        logger.error("could not find key: \(key).")
        #endif
        return nil
      }
      return visit(nextNode)
    }
    return visit(environment)
  }
}
