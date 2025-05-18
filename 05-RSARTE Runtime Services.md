# 05: RSARTE Runtime Services

## Goal and Design Purpose

The RT Services Library (RTS) is the core runtime framework used by applications generated from UML-RT models in RSARTE. It supports real-time, event-driven execution in C++ and abstracts key OS/platform services.


### Primary Goals

- Provide a portable C++ runtime for UML-RT model execution.
- Offer message-passing, state machine, and threading support without exposing low-level OS details.
- Integrate smoothly with generated code and allow user extensions.
- Support timing, logging, event dispatching, and dynamic capsule management.

### Design Principles

- Layered, modular C++ library structure.
- Designed to work with both MSVC and GCC/Clang environments.
- Supports single-threaded or multi-threaded execution.
- Uses active object model for capsule behavior, mapping logical threads to physical ones.
- Emphasizes run-to-completion semantics and real-time safety.

#### The Active Object pattern 

Decouples method execution from method invocation to allow asynchronous behavior. In RSARTE:

A capsule is treated as an active object. It has:
- Its own logical thread of control
- A message queue
- A state machine that reacts to events

Decouples method execution from method invocation to allow asynchronous behavior. In RSARTE:
- A capsule is treated as an active object. It has:
  - Its own logical thread of control
  - A message queue
  - A state machine that reacts to events

How It Works in RSARTE
- Other capsules (or systems) send messages to a capsule via its ports.
- These messages are enqueued, not handled immediately.
- The capsule's logical thread dispatches one message at a time.
- The state machine handles the message using run-to-completion semantics.
- No other message is processed until the current one is fully handled.
This is different from a passive object, which only executes when called directly by another thread. 

### Main Functionality Provided by RTS

Logging Services
- Implemented via the Log protocol.
- Allows capsules to log messages to stdout or stderr using:
- logPort.log("Capsule started!");
- Optional structured trace and debug logging for observability.

Timer and Scheduling Services
- Provided by the Timing protocol.
- Capsules can set timers and receive timeout events:
- Essential for modeling time-based transitions and delays.

Event Services
- Core of RTS — implements asynchronous message delivery between capsules.
- Messages routed through ports and connectors with queued, thread-safe dispatch.
- Supports:
  - Prioritized events
  - Deferred and recalled events
  - Port binding/unbinding notifications (rtBound, rtUnbound)

Capsule Lifecycle and Threading
- Supports dynamic incarnation and destruction of capsule instances at runtime:
- `RTActorId id = frame.incarnate(myCapsulePart);`
- Allows capsules to be scheduled on different logical or physical threads.
- Threads can be reused for lightweight execution.

### RTS Benefits

- Enables model-to-code mapping for real-time systems.
- Abstracts OS-specific APIs and thread management.
- Implements deterministic behavior via:
  - Queueing semantics
  - State machine integrity
  - Controlled lifecycle
- Reduces need for manual concurrency logic.
- Provides out-of-the-box support for common real-time concerns:
  - Deadlines, timeouts, encapsulation, modularity

### Code Generation Hooks for Service Customization

Advanced users can modify code generation behavior to integrate with custom services:

- Custom Logging/Tracing:
  - Replace default logging macros in RTLog.cpp or override log ports.
- Timer Service Hooks:
  - Inject custom timer behavior via transform-time overrides or subclassing.
- Main Loop Extensions:
  - Modify the generated main() function or subclass RTMain to add diagnostics or alternate boot logic.
 - Custom Protocols:
   - Add new RT Service protocols and expose as ports for capsules to interact with.

---

## Official Documentation Overview

For this we will use the document `ModelRealTime Services Library.pdf` in the resources folder

