# Requirements
Specifications of implementation requirements for this project.

### About:
Dart native Flutter package for reading RAR archives. This performs the reading in the most efficient form by not unraring the entire file to read its content. Instead this package opens the file and reads it in a random-access fashion. It must include a means to retrieve the entries of the RAR archive without extracting its content. It must also include a way to extract the content of an entry in the RAR archive.

### Packages to use
- [universal_io](https://pub.dev/packages/universal_io)


## Tasks
|Status| File | Purpose |
|-------|------|---------|
| DONE  | [Extraction Context](Context/Extraction/REQUIREMENTS.md) | Complete defition of the extraction context required for reading a RAR archive. |


## Reference Documentation

| File | Purpose |
|------|---------|
| [Reference: STATUS.md](../software-toolbox/reference/STATUS.md) | Explantion actions requred by status. 
| [Reference: STRUCTURE.md](../software-toolbox/software-architecture-patterns/domain-driven-design/STRUCTURE.md) | Complete structure specifications |
| [Reference: design-patterns-requirements.md](../software-toolbox/software-design-patterns/design-patterns-requirements.md) | Complete design patterns requirements specifications to be used when implementing solutions to problems in the application. | 

## Design Patterns
When using a design pattern in the implementation call out the pattern in the documentation of the class or function.

## Progress Tracking
When successfully completing a requirements update its status and any dependent file with the status of DONE.

