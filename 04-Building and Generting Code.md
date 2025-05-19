# 4. Building and Generating Code

## Build Process

The translation of a UML model into an executable real-time application goes through the following steps:
1. A subset of the model is transformed to C++ code.
2. Eclipse CDT project and a makefile are generated.
3. A make tool is launched to build the generated code using the makefile.
4. Messages (such as compilation errors) that are produced during the build are captured and printed.

### Build Modes

There are two ways of building a model.

**Interactive**: Executed from RSARTE user interface

**Batch**: Executed from the command line or invoked from a script scripts. In both cases 

Both modes perform exactly the same set of steps described earlier

The difference between build modes are:
- How the build is triggered
- What happens after the build is done. For example:
  - In an interactive build, most build messages are printed to the UML Development Console
  - In a batch, build messages are typically printed to the command line console or written to a log file.

### Model Compiler

The RSARTE utility which builds a model is called the model compiler. 
- Stand-alone command line tool mode
  - Can be run as a separate application independent of the RSARTE IDE. 
  - Can be used for true batch builds without using IDE. 
- Interactive build mode from within the IDE. 
  - RSaRTE will launch the model compiler for generating the code and a make file
  - The generated code is then built by make.

#### Parallel Builds

If the C++ build system supports parallel execution of make rules
- It is possible to generate a single make file from RSARTE that contains rules that invoke the model compiler for the code generation. 
- The entire build can be driven by a single make file. 
- This could boost build performance by parallelizing the generation of C++ files
- But the model compiler will be invoked multiple times, which involves some overhead. 
- To see if this is an advantage, performance measurement on the build platform is necessary
- Parallel builds are only available for batch builds.

---

## Transformation Configurations

The transformation of a model to compiled code can be done in many ways depending on the build configuration properties like the following.
- The subset of the model to be built
- How should the generated C++ code be compiled
- Which target configuration of the RT services library should be used



# Code Generation Overview

RSARTE generates executable platform-specific C++ code from a platform-independent UML-RT model.

The code generation process includes:
- State machine logic for capsules.
- Port and protocol definitions.
- Inter-capsule communication.
- Top-level configuration (main function and RTS initialization).

## State Machine Logic for Capsules

- Capsules encapsulate behavior using hierarchical state machines.
- The generated code must preserve deterministic execution and message-driven semantics.

Code Generation Behavior:
- Each capsule gets a C++ class, where:
  - States become methods or enum values.
  - Transitions become switch or dispatch logic.
  - Entry/exit actions are translated into function bodies.
- State logic is typically placed in methods like `handleEvent()` or `inject()`.

## Port and Protocol Definitions

- UML-RT uses typed ports to enforce contract-based communication between capsules.
- Each port is typed with a protocol (a set of incoming/outgoing messages).

Code Generation Behavior:
- Ports become class attributes (RTSystemPort, RTConjugatePort).
- Each protocol generates:
  - Message identifiers (e.g., signalId_X)
  - Dispatcher stubs to call appropriate handlers
  - Header files defining messages, roles, and direction

## Inter-Capsule Communication

Capsules are loosely coupled, communicating only via ports.
- Ensures safe message-passing and isolation between components.

Messages are queued and dispatched by the RTS (run-time system).

The code generator creates:
- Message class instances
- Queue management logic (e.g., send(), receive() methods)
- Connectors for wiring capsules (defined in the model's composite structure)


---

## Code Transformations

The Transformation Configuration (TC) file defines how the UML-RT model is converted into executable C++ (or C) source code. 
- Acts as a bridge between the logical model and the generated code, specifying what should be generated, how it should be organized, and what additional artifacts or settings apply.

A TC is a model element (usually named RTComponent) stored in a .etx file. It provides instructions for:
- Code generation targets and settings
- Output folder structure
- Inclusion and linking of external libraries
- Mapping between model elements and generated artifacts

### Key Elements and Properties of a Transformation Configuration

Name and Type
- The TC typically has a name like RTComponent and is applied at the project level.
- Language-specific (e.g., C++, C).

Target Directory
- Defines where generated source and header files are placed.
- Example: MyModel_target/src/ and include/.

Model Elements to Generate
- Can be set to generate:
  - Entire model (.emx file)
  - Specific packages or capsules
    - Fragmented models use .epx files and the TC manages how these are aggregated during generation.

Include Paths and External Code
- Specify additional header search paths.
- Define dependencies on external libraries or artifacts.
- Example: include <RTServices> for runtime services.

Code Generation Options
- Flags to control:
  - Inline function generation
  - Virtual/pure virtual declarations 
  - Generation of destructor implementations
  - Naming conventions (prefixes/suffixes)

Build Configuration
- Integrates with Eclipse CDT for building the generated code.
- Links model output with a C++ target project (e.g., MyModel_target).
- Ensures header and source files are recognized by the Eclipse build system.

### Location and Management
- TC files are typically saved with a .etx extension inside the modeling project.

### How It Operates

- Modeler builds the UML-RT model.
- Transformation is triggered manually or by build actions.
- The Transformation Configuration reads:
  - Which parts of the model to include
  - Where to output code
  - How to structure classes, functions, and files
- RSARTE generates .cpp and .h files accordingly.
- The output project is built using Eclipse CDT or external build tools.

### Best Practices

- Maintain one TC file per model project unless generating multiple variants.
- Use fragmented models for large systems and include them in the TC via .epx references.
- Always verify output directories to prevent overwriting or misplaced code.
- Keep TC files under version control—they define how your models are turned into software.

### Documentation Review

[TC Deep Dive](https://www.ibm.com/docs/en/dmrt/12.1.0?topic=SS5JSH_12.1/Articles/Building/Building%20CPP%20Applications/Applying%20Transformation%20Configurations/Configuring%20Transformation%20Configuration%20Properties.htm)

---
