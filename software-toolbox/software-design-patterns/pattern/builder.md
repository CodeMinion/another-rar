# Intent
Separate the construction of a complex object from its representation so that the same construction process can create different representations.

# Applicability
Use the Builder pattern when:
- The algorithm for constructing a complex object should be independent of the parts that make up the object and how they are assembled.
- The construction process must allow different representations for the object that is constructed.

# Structure
```mermaid
classDiagram
    class Builder {
        +BuildPartA()
        +BuildPartB()
        +BuildPartC()
        +GetResult()
    }
    class ConcreteBuilder {
        +BuildPartA()
        +BuildPartB()
        +BuildPartC()
        +GetResult()
    }
    class Product {
        +AddPartA()
        +AddPartB()
        +AddPartC()
    }
    class Director {
        +Construct()
    }

    Builder <|-- ConcreteBuilder
    Director --> Builder
    Builder --> Product
```