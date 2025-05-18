# 06: 06-Modeling Behavioral Logic – State Machines


## HSM (Hierarchical State Machine) Design Concepts
   
A state machine models how a capsule responds to incoming messages:
- States: Represent behavioral modes.
- Transitions: Describe the conditions and actions that move from one state to another.
- Triggers: Specify which event (usually from a port) causes a transition.
- Entry/Exit Actions: Optional code that runs when entering or exiting a state.

### Composite (Hierarchical) States
- A composite state contains a sub state machine.
- Allows decomposition for clarity and reuse.
- Entering a composite state:
  - Triggers initial substate unless a history pseudo state is used.
  - History substate allows re-entrant logic
- Transitioning out must pass through an exit point.

#### Key Pseudo States

- Initial: Entry point to the machine or composite state.
- Choice: Allows decision based on guard conditions.
- Junction: For converging or reusing transition effects.
- History (H*): Recalls last active substate configuration on re-entry.


### Actions in Transitions and States

Where Action Code Appears
- Transition effects: Code run when a transition is taken.
- Entry/Exit: Code run when a state is entered or exited.
- Guard conditions: Boolean expressions controlling transition eligibility.

```text 
// Example guard
return value > 5;

// Example transition effect
logPort.log("Transition taken");

```

The action code is written in C++ (or C) and is embedded in the model.

Run-to-Completion Semantics
- Only one transition executes at a time.
- All related actions (exit, effect, entry) complete before the next message is handled.
- Helps maintain behavioral integrity under concurrency.

### Handling History and Entry/Exit Actions

History Pseudo State (H*)
- Recalls the previously active state configuration when re-entering a composite state.
- Useful in nested workflows or interruptible sequences.
- `A → B → C → H*` means that if C is exited and later re-entered, the substate last active inside C is restored.

### State Entry Instrumentation

Use `rtgStateEntry()` for a global trace hook:

```text 
void rtgStateEntry() {
logPort.log("Entering state...");
}
```

Called before the actual entry action of the state.

### Modeling Navigation and Control Flow

#### Common Patterns
- Self-transitions (internal/external) for repetitive processing.
- Compound transitions: Chains of transitions triggered by one event.
- Internal transitions: Do not exit or re-enter the state.

#### Transition Resolution
- Start in innermost active state.
- Search for enabled transitions (trigger + guard).
- Climb up the hierarchy if none found.
- Discard unhandled messages (potential design flaw).

### Best Practices

- Use entry points and exit points for clarity.
- Avoid overly complex flat state machines—prefer decomposition.

