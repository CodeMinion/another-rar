# Intent
Define an interface for creating an object, but let subclasses decide which class to instantiate. Factory Method lets a class defer instantiation to subclasses.

# Applicability
Use the Factory Method pattern when:
- A class can't anticipate the class of objects it must create.
- A class wants its subclasses to specify the objects it creates.
- Classes delegate responsibility to one of several helper subclasses, and you want to localize the knowledge of which subclass helper is the delegate.

# Structure
```mermaid
classDiagram
    class Product {
        +operation()
    }
    class ConcreteProduct1 {
        +operation()
    }
    class ConcreteProduct2 {
        +operation()
    }
    class Creator {
        +factoryMethod()
        +someOperation()
    }
    class ConcreteCreator1 {
        +factoryMethod()
    }
    class ConcreteCreator2 {
        +factoryMethod()
    }

    Product <|-- ConcreteProduct1
    Product <|-- ConcreteProduct2
    Creator --> Product : createProduct
    Creator <|-- ConcreteCreator1
    Creator <|-- ConcreteCreator2
```