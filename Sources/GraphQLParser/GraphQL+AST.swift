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
        case selectionSet(selectionSet: [Selection])

        struct Operation {
            let operationType: OperationType
            let name: String?
            let variableDefinitions: [String]
            let directives: [Directive]
            let selectionSet: [Selection]
        }
    }

    struct FragmentDefinition {
        let name: String
        let typeCondition: TypeCondition
        let directives: [Directive]
        let selectionSet: [Selection]
    }

    struct InlineFragment {
        let typeCondition: TypeCondition?
        let directives: [Directive]
        let selectionSet: [Selection]
    }

    struct FragmentSpread {
        let name: String
        let directives: [Directive]
    }

    enum OperationType {
        case query
        case mutation
        case subscription
    }

    struct TypeCondition {
        let namedType: String
    }

    struct Field {
        let alias: String?
        let name: String
        let arguments: [Argument]
        let directives: [Directive]
        let selectionSet: [Selection]
    }

    enum Selection {
        case field(selection: Field)
        case fragmentSpread(selection: FragmentSpread)
        case inlineFragment(selection: InlineFragment)
    }

    struct Directive {
        let name: String
        let arguments: [Argument]
    }

    struct Argument {
        let name: String
        let value: String
    }
}
