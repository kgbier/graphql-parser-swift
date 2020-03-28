@testable import GraphQLParser

extension GraphQL.Document : DumpEquatable {}
extension GraphQL.Definition : DumpEquatable {}
extension GraphQL.ExecutableDefinition : DumpEquatable {}
extension GraphQL.OperationDefinition : DumpEquatable {}
extension GraphQL.OperationDefinition.Operation : DumpEquatable {}
extension GraphQL.FragmentDefinition : DumpEquatable {}
