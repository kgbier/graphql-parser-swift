enum GraphQLParser {

    static private let parser = GraphQL()

    static internal func parseWithResult(_ str: String) -> (match: GraphQL.Document?, rest: Substring)  {
        parser.document.parse(str)
    }

    static func parse(_ str: String) -> GraphQL.Document?  {
        parseWithResult(str).match
    }
}
