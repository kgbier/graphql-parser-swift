extension GraphQL {
    struct Document {
        let definitions: [Definition]
    }

    enum Definition {
        case executable(definition: ExecutableDefinition)
    }

    enum ExecutableDefinition {
        case operation(definition: OperationDefinition)
        case fragment(definition: FragmentDefinition)
    }

    enum OperationDefinition {
        case operation(definition: Operation)
        case selectionSet(selectionSet: String)

        struct Operation {
            let operationType: OperationType
            let name: String?
            let variableDefinitions: [String]
            let directives: [String]
            let selectionSet: String?
        }
    }

    struct FragmentDefinition {
        let name: String
        let typeCondition: String
        let directives: [String]
        let selectionSet: String
    }

    enum OperationType {
        case query
        case mutation
        case subscription
    }

}
