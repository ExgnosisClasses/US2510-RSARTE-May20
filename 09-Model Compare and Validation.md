# 09. Model Compare and Validate

RSARTE uses a validation checking mechanism for comparing models and validating them to ensure consistency, correctness, and adherence to modeling standards.

#### Visual Comparison: 

- Allows users to see differences in diagrams, such as added or removed elements, changes in relationships, and modifications to properties. 
- Useful for understanding structural changes in the model.

#### Textual Comparison: 

- Displays differences in the underlying model files, highlighting changes in code or model definitions. 
- Useful for detailed inspections and for identifying changes not immediately visible in diagrams.

### Limitations

#### Nested Model Issues: 

- Comparisons involving deeply nested models can be challenging because changes in lower-level elements might not be immediately clear in higher-level views.

#### Merge Conflicts: 

- When multiple developers work on the same model elements concurrently, merge conflicts can occur. 
- RSARTE provides tools to resolve these conflicts, but complex scenarios may require manual intervention to ensure the model's integrity.

---

## Model Validation Rules
   
RSARTE includes a set of model validation rules that perform static checks to ensure models adhere to defined standards and practices:

#### Consistency Checks: 

- Verify that model elements are correctly connected and that relationships are valid.

#### Completeness Checks: 
- Ensure that all necessary elements are present and properly defined.

#### Syntax Checks: 

- Detect issues like missing names, incorrect data types, or invalid configurations.
- These checks are designed for catching common modeling structural errors 
- However, they might not detect semantic errors or issues that arise from complex interactions within the model.
- Like a grammar checker, it can make sure a sentence is well-formed, but has no idea what it means

#### Use Cases:

- _Early Detection of Errors:_ Identifying issues during the modeling phase reduces downstream problems during code generation or deployment.
- _Enforcing Modeling Standards:_ Ensures that models conform to organizational or industry standards, facilitating better collaboration and maintenance.
- _Improving Model Understanding:_ Helps new team members understand model structures and relationships by ensuring clarity and correctness.

#### Limitations:

- _False Positives/Negatives:_ Some checks might flag non-issues or miss subtle errors, requiring manual review. 
- _Performance Overhead:_ Running extensive validation checks on large models can impact performance. It's advisable to schedule validations appropriately.
- _Customization Needs:_ Out-of-the-box validation rules might not cover all organizational requirements, requiring the development of custom rules.

---

## Model Validation Rules

Types of Validation Rules and Examples 

#### Missing or Invalid Names

- Rule: Every model element (capsule, protocol, class, port, etc.) must have a non-empty, valid name.
- Violation: You create a port on a capsule but forget to name it.
- Why It Matters:
- Generated code will be syntactically invalid if elements are unnamed. 

#### Invalid Port Protocol Assignment
- Rule: Behavior port must be typed with a valid protocol.
- Violation: You add a port but forget to set its protocol type.
- Limitation: This check won't catch a wrong protocol assignment semantically — only missing/invalid ones. 

#### Conjugation Conflicts Between Ports
- Rule: When connecting ports between capsules, one port must be conjugated, and the protocols must match.
- Violation: You connect two non-conjugated ports of the same protocol.
- Example: Assembly connector between port A and B uses two non-conjugated ports — invalid configuration.

#### Multiple Services on the Same Protocol
- Rule: Only one service port per protocol is allowed per capsule instance.
- Violation: Two service ports in the same capsule are typed with the same protocol.
- Example: Capsule 'Controller' defines multiple service ports using protocol 'CmdProtocol'.

#### Circular Inheritance in Class Hierarchy
- Rule: Class inheritance must not be cyclic.
- Violation: Class A inherits from B, and B inherits (directly or indirectly) from A.
- Example: Inheritance cycle detected: A → B → A

#### Unsupported or Incomplete Protocol Definitions
- Rule: Protocols must define at least one in-event or out-event.
- Violation: You define a protocol called EmptyProtocol with no events.

#### Missing Transitions in State Machines
- Rule: Every non-final state in a state machine should have at least one outgoing transition.
- Violation: A state is unreachable or "dead" — no transitions can enter or leave it.
- Example: State 'Waiting' in capsule 'Receiver' is unreachable.

### When Validation Rules Are Applied 

- Automatically when models are saved
- During transformation 
- Via explicit validation

### Best Practices

- Regular Validation: Incorporate validation checks into the regular development workflow to catch issues early.
- Team Collaboration: Encourage team members to communicate changes and coordinate on model updates to minimize conflicts.
- Training and Documentation: Provide training on using comparison and validation tools effectively, and maintain documentation on modeling standards and practices.
- Customization: Develop custom validation rules tailored to specific project or organizational needs to enhance model quality assurance.


### Custom Rules (Advanced)

You can define custom validation rules by extending the model compiler with:
- Java-based plug-ins
- Constraint expressions (e.g., OCL)
- Specialized scripts during transformation
- Example use case: enforce that all capsules with a logPort must also import RTSystemProtocol.