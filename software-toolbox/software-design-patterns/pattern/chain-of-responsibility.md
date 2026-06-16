# Intent
Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it.

# Applicability
Use Chain of Responsibility when:
- More than one object may handle a request, and the handler isn't known a priori. 
- You want to issue a request to one of several objects without specifying the receiver explicitly. 
- The set of objects that can handle a request should be specified dynamically.

# Structure
```mermaid
classDiagram
    class Handler {
        +handleRequest()
    }
    class ConcreteHandler1 {
        +handleRequest()
    }
    class ConcreteHandler2 {
        +handleRequest()
    }
    class ConcreteHandler3 {
        +handleRequest()
    }
    Handler <|-- ConcreteHandler1
    Handler <|-- ConcreteHandler2
    Handler <|-- ConcreteHandler3
    ConcreteHandler1 --> ConcreteHandler2 : next
    ConcreteHandler2 --> ConcreteHandler3 : next
```