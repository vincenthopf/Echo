---

description: Complete a task following systematic iOS development methodology
argument-hint: enter the task you want the agent to complete
----------------------------------

You are working on the VoiceInk/Embr Echo macOS application. Complete the following task using the systematic methodology below:

**TASK**: \$ARGUMENTS

## Mandatory Process - Follow These Steps in Order:

### Step 1: File Identification & Cross-Validation

* Systematically work through the codebase to find the correct files that need editing
* Once you are 90% confident, deploy a subagent with NO context about this task
* Ask the subagent to accomplish the SAME task with NO technical details provided to it
* The subagent must respond back with what files need to be changed
* Cross-reference the subagent's suggested changes with your own analysis
* If the subagent's suggestions differ from yours, work out why and determine who is actually correct from the perspective of a senior iOS Developer
* DO NOT proceed until file identification is validated

### Step 2: Research & Documentation

* Do appropriate web searches for the task at hand
* Use the context7 MCP server to find relevant documentation
* When searching, ALWAYS mention:
  * The language: Swift/SwiftUI
  * The architecture: Native macOS app with SwiftData
  * The specific issue or question you have
* Gather all necessary technical information before implementation

### Step 3: UI/UX & Copywriting (if applicable)

* If writing copy is needed OR designing UI/layout components effectively
* ALWAYS deploy the @apple-best-practices subagent
* Provide the subagent with:
  * A description of what you are doing
  * The task at hand
  * What needs to be completed by the subagent
* The subagent should ONLY write the copy OR give you feedback on Human Interface Guidelines best practices (i.e., good UX/design)
* Wait for the subagent's response before implementing UI/copy changes

### Step 4: Implementation

* Implement the changes using the validated files from Step 1
* Apply the technical knowledge from Step 2
* Use the UI/UX guidance from Step 3 (if applicable)
* Follow Apple's best practices for macOS development
* Ensure code quality meets senior iOS Developer standards

### Step 5: Verification

* Test the changes thoroughly
* Verify the implementation matches the original task requirements
* Confirm all files identified in Step 1 were correctly modified
* Check that UI/UX follows Apple Human Interface Guidelines (if applicable)

***

**IMPORTANT**: You MUST complete Steps 1-3 before any implementation. This ensures high-quality, well-researched solutions that align with best practices.
