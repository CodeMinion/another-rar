
## CRITICAL: The Dependency Rule

Dependencies point **inward only**. Outer layers depend on inner layers, never the reverse.

```
Infrastructure → Application → Domain
   (adapters)     (use cases)    (core)
```

## Directory Structure

```
lib/
|──{context}/
|  ├── domain/                    # All Core business logic interfaces (NO external dependencies)
|  ├── application/               # Use cases / Application services
|  ├── infrastructure/            # Adapters (external concerns)
└── main                          # Bootstrap / entry point

out/                              # Binrary artifacts generated from building the project.  

test/                             # Stores all test cases
|──{context}/
|  ├── domain/                    # All Core business logic interfaces (NO external dependencies)
|  ├── application/               # Use cases / Application services
|  ├── infrastructure/            # Adapters (external concerns)
└── main                          # Bootstrap / entry point

```

## Namning Conventions

Package names stay as clean short directory names.

Files within a context must following the following format: {context_name}_{type}_{name}.{extension}

Example:
- content_update_domain_event_item_not_found.go: Where content_update is the domain, domain_event is the type, and item_not_found is the name.

## Cross Context Interaction
If a context needs to access another context it must do so through the application layer of the other context by implementing a repository in its infrastructure layer. 

## Exception Handling
1. Always wrap any exceptions with context specific exceptions.
2. Log exceptions to the console when possible. 
3. Visually persent the error to the user on the UI when possible.