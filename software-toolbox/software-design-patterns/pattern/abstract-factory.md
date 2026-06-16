# Intent
Provide an interface for creating families of related or dependent objects without specifying their concrete classes.

# Applicability
Use the Abstract Factory pattern when:
- A system should be independent of how its products are created, composed, and represented.
- A system should be configurable with one of many families of products.
- A family of related product objects is designed to be used together, and you need to enforce this constraint.
- You want to provide a class library of products, and you want to reveal just their interfaces, not their implementations.

# Structure
```mermaid
classDiagram
    class AbstractFactory {
        +createProductA()
        +createProductB()
    }
    class ConcreteFactory1 {
        +createProductA()
        +createProductB()
    }
    class ConcreteFactory2 {
        +createProductA()
        +createProductB()
    }
    class ProductA {
        +operationA()
    }
    class ProductB {
        +operationB()
    }
    class ConcreteProductA1 {
        +operationA()
    }
    class ConcreteProductA2 {
        +operationA()
    }
    class ConcreteProductB1 {
        +operationB()
    }
    class ConcreteProductB2 {
        +operationB()
    }
    AbstractFactory <|-- ConcreteFactory1
    AbstractFactory <|-- ConcreteFactory2
    ConcreteFactory1 --> ProductA : createProductA
    ConcreteFactory1 --> ProductB : createProductB
    ConcreteFactory2 --> ProductA : createProductA
    ConcreteFactory2 --> ProductB : createProductB
    ProductA <|-- ConcreteProductA1
    ProductA <|-- ConcreteProductA2
    ProductB <|-- ConcreteProductB1
    ProductB <|-- ConcreteProductB2
```
