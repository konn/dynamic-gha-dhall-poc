let origSchema =
      https://raw.githubusercontent.com/regadas/github-actions-dhall/master/package.dhall

let WorkflowCall = { Type = {}, default = {=} }

let workflowCallType = { workflow_call : Optional WorkflowCall.Type }
let defaultWorkflowCall = { workflow_call = None WorkflowCall.Type }
let newOnType =
      origSchema.On.Type //\\ workflowCallType

let newOnDef =
      origSchema.On.default /\ defaultWorkflowCall

let NewOn = { Type = newOnType, default = newOnDef }

in  (origSchema // { WorkflowCall })
  with On = NewOn
  with Workflow.Type = origSchema.Workflow.Type //\\ {on : workflowCallType }
