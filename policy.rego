# policy.rego
package tfplan.mgc

import future.keywords.contains
import future.keywords.if
import future.keywords.in

deny contains msg if {
    resource := input.resource_changes[_]
    "delete" in resource.change.actions
    msg := sprintf("EN-US: Deletion of resource %v is not allowed by policy. | PT-BR: A exclusão do recurso %v não é permitida pela política.", [resource.address])
}