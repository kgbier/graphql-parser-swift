@testable import GraphQLParser

extension GraphQL.Document : DumpEquatable {}
extension GraphQL.Definition : DumpEquatable {}
extension GraphQL.ExecutableDefinition : DumpEquatable {}
extension GraphQL.OperationDefinition : DumpEquatable {}
extension GraphQL.OperationDefinition.Operation : DumpEquatable {}
extension GraphQL.FragmentDefinition : DumpEquatable {}
extension GraphQL.InlineFragment : DumpEquatable {}
extension GraphQL.FragmentSpread : DumpEquatable {}
extension GraphQL.TypeCondition : DumpEquatable {}
extension GraphQL.Field : DumpEquatable {}
extension GraphQL.Selection : DumpEquatable {}
