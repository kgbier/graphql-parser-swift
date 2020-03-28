import XCTest
@testable import GraphQLParser

final class GraphQLTests: XCTestCase {

    var graphQlparser = GraphQL()

    func testName() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.name.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("abc"))
        XCTAssertEqual("abc", testSubject("abc"))
        XCTAssertEqual("a123", testSubject("a123"))
        XCTAssertEqual("with_underscore_", testSubject("with_underscore_"))
        XCTAssertEqual("__typename", testSubject("__typename"))
        XCTAssertNil(testSubject("123"))
    }

    func testNegativeSign() {
        func testSubject(_ str: String) -> Character? {
            graphQlparser.negativeSign.parse(str).match
        }

        XCTAssertEqual("-", testSubject("-"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testDigit() {
        func testSubject(_ str: String) -> Character? {
            graphQlparser.digit.parse(str).match
        }

        XCTAssertEqual("0", testSubject("0"))
        XCTAssertEqual("1", testSubject("1"))
        XCTAssertEqual("2", testSubject("2"))
        XCTAssertEqual("3", testSubject("3"))
        XCTAssertEqual("4", testSubject("4"))
        XCTAssertEqual("5", testSubject("5"))
        XCTAssertEqual("6", testSubject("6"))
        XCTAssertEqual("7", testSubject("7"))
        XCTAssertEqual("8", testSubject("8"))
        XCTAssertEqual("9", testSubject("9"))
    }

    func testnonZeroDigit() {
        func testSubject(_ str: String) -> Character? {
            graphQlparser.nonZeroDigit.parse(str).match
        }

        XCTAssertNil(testSubject("0"))
        XCTAssertEqual("1", testSubject("1"))
        XCTAssertEqual("1", testSubject("1"))
        XCTAssertEqual("2", testSubject("2"))
        XCTAssertEqual("3", testSubject("3"))
        XCTAssertEqual("4", testSubject("4"))
        XCTAssertEqual("5", testSubject("5"))
        XCTAssertEqual("6", testSubject("6"))
        XCTAssertEqual("7", testSubject("7"))
        XCTAssertEqual("8", testSubject("8"))
        XCTAssertEqual("9", testSubject("9"))
    }

    // alias: integerPart
    func testIntValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.intValue.parse(str).match
        }
        
        XCTAssertEqual("123", testSubject("123"))
        XCTAssertEqual("-123", testSubject("-123"))
        XCTAssertNil(testSubject("0123"))
        XCTAssertEqual("-0", testSubject("-0"))
    }

    func testExponentIndicator() {
        func testSubject(_ str: String) -> Void? {
            graphQlparser.exponentIndicator.parse(str).match
        }

        XCTAssertNotNil(testSubject("E"))
        XCTAssertNotNil(testSubject("e"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testSign() {
        func testSubject(_ str: String) -> Character? {
            graphQlparser.sign.parse(str).match
        }

        XCTAssertEqual("+", testSubject("+"))
        XCTAssertEqual("-", testSubject("-"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testFractionalPart() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.fractionalPart.parse(str).match
        }

        XCTAssertEqual("123", testSubject(".123"))
        XCTAssertEqual("012", testSubject(".012"))
        XCTAssertNil(testSubject("012"))
        XCTAssertNil(testSubject("."))
        XCTAssertNil(testSubject("a"))
    }

    func testExponentPart() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.exponentPart.parse(str).match
        }

        XCTAssertEqual("e+123", testSubject("e123"))
        XCTAssertEqual("e+123", testSubject("e+123"))
        XCTAssertEqual("e-123", testSubject("e-123"))
        XCTAssertNil(testSubject("e"))
        XCTAssertNil(testSubject("e+"))
        XCTAssertNil(testSubject("e-"))
        XCTAssertNil(testSubject("E"))
        XCTAssertNil(testSubject("E+"))
        XCTAssertNil(testSubject("E-"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testFloatValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.floatValue.parse(str).match
        }

        XCTAssertEqual("6.0221413:e+23", testSubject("6.0221413e23"))
        XCTAssertEqual("6.123", testSubject("6.123"))
        XCTAssertEqual("1:e+10", testSubject("1e10"))
    }

    func testBooleanValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.booleanValue.parse(str).match
        }

        XCTAssertEqual("bool(true)", testSubject("true"))
        XCTAssertEqual("bool(false)", testSubject("false"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testStringValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.stringValue.parse(str).match
        }

        XCTAssertEqual("hello sailor", testSubject("\"hello sailor\""))
        XCTAssertEqual(" hello sailor ", testSubject("\" hello sailor \""))
        XCTAssertEqual("123 abc", testSubject("\"123 abc\""))
        XCTAssertEqual("", testSubject("\"\""))
        XCTAssertNil(testSubject("hello sailor\""))
        XCTAssertNil(testSubject("\"hello sailor"))
    }

    func testNullValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.nullValue.parse(str).match
        }

        XCTAssertEqual("<null>", testSubject("null"))
        XCTAssertNil(testSubject("012"))
        XCTAssertNil(testSubject("."))
        XCTAssertNil(testSubject("a"))
    }

    func testEnumValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.enumValue.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("abc"))
        XCTAssertEqual("abc123", testSubject("abc123"))
        XCTAssertEqual("ENUM_VALUE", testSubject("ENUM_VALUE"))
        XCTAssertNil(testSubject("true"))
        XCTAssertNil(testSubject("false"))
        XCTAssertNil(testSubject("null"))
        XCTAssertNil(testSubject("123"))
    }

    func testListValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.listValue.parse(str).match
        }

        XCTAssertEqual("[]", testSubject("[ ]"))
        XCTAssertEqual("[]", testSubject("[]"))
        XCTAssertEqual("[]", testSubject("[ , ]"))
        XCTAssertEqual("[bool(true)]", testSubject("[true]"))
        XCTAssertEqual("[bool(true),bool(false)]", testSubject("[ true, false ]"))
    }

    func testObjectField() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.objectField.parse(str).match
        }
        XCTAssertEqual("name:123", testSubject("name : 123"))
        XCTAssertEqual("name:abc", testSubject("name : \"abc\""))
    }

    func testObjectValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.objectValue.parse(str).match
        }
        XCTAssertEqual("{}", testSubject("{}"))
        XCTAssertEqual("{}", testSubject("{ }"))
        XCTAssertEqual("{}", testSubject("{ , }"))
        XCTAssertEqual("{name:123}", testSubject("{name:123}"))
        XCTAssertEqual("{name:123}", testSubject("{ name : 123 }"))
        XCTAssertEqual("{nameone:123,nametwo:abc}", testSubject("{ nameone : 123, nametwo : \"abc\" }"))
    }

    func testListType() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.listType.parse(str).match
        }

        XCTAssertEqual("[Int]", testSubject("[Int]"))
        XCTAssertEqual("[Int]", testSubject("[ Int ]"))
        XCTAssertEqual("[[Char]]", testSubject("[ [ Char ] ]"))
        XCTAssertNil(testSubject("[ ]"))
        XCTAssertNil(testSubject("[]"))
        XCTAssertNil(testSubject("[ , ]"))
    }

    func testNonNullType() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.nonNullType.parse(str).match
        }

        XCTAssertEqual("[Int]!!", testSubject("[Int]!"))
        XCTAssertEqual("Int!!", testSubject("Int!"))
    }

    func testDefaultValue() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.defaultValue.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("= \"abc\""))
        XCTAssertEqual("123", testSubject("=123"))
    }

    func testVariable() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.variable.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("$abc"))
        XCTAssertNil(testSubject("abc"))
    }

    func testVariableDefinition() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.variableDefinition.parse(str).match
        }

        XCTAssertEqual("abc:Int", testSubject("$abc : Int"))
        XCTAssertEqual("abc:Int=123", testSubject("$abc : Int = 123"))
        XCTAssertEqual("abc:Int=123", testSubject("$abc:Int=123"))
    }

    func testArgument() {
        func testSubject(_ str: String) -> GraphQL.Argument? {
            graphQlparser.argument.parse(str).match
        }

        XCTAssertEqual(.init(name: "abc", value: "xyz"), testSubject("abc : \"xyz\""))
        XCTAssertEqual(.init(name: "abc", value: "123"), testSubject("abc : 123"))
        XCTAssertEqual(.init(name: "abc", value: "123"), testSubject("abc:123"))
    }

    func testArguments() {
        func testSubject(_ str: String) -> [GraphQL.Argument]? {
            graphQlparser.arguments.parse(str).match
        }

        XCTAssertEqual([.init(name: "abc", value: "xyz")], testSubject("(abc:\"xyz\")"))
        XCTAssertEqual([.init(name: "abc", value: "123")], testSubject("(abc:123)"))
        XCTAssertEqual([.init(name: "abc", value: "123")], testSubject("( abc : 123 )"))
        XCTAssertEqual([.init(name: "abc", value: "123"),
                        .init(name: "def", value: "xyz")],
                       testSubject("(abc : 123, def : \"xyz\")"))
    }

    func testDirective() {
        func testSubject(_ str: String) -> GraphQL.Directive? {
            graphQlparser.directive.parse(str).match
        }

        XCTAssertEqual(.init(name: "named", arguments: [.init(name: "abc", value: "xyz")]),
                       testSubject("@named (abc : \"xyz\")"))
        XCTAssertEqual(.init(name: "named", arguments: [.init(name: "abc", value: "xyz")]),
                       testSubject("@named(abc : \"xyz\")"))
    }

    func testDirectives() {
        func testSubject(_ str: String) -> [GraphQL.Directive]? {
            graphQlparser.directives.parse(str).match
        }

        XCTAssertEqual([.init(name: "named", arguments: [.init(name: "abc", value: "xyz")]),
                        .init(name: "other", arguments: [.init(name: "abc", value: "xyz")])],
                       testSubject("@named (abc : \"xyz\") @other (abc : \"xyz\")"))
    }

    func testSelection() {
        func testSubject(_ str: String) -> [GraphQL.Selection]? {
            graphQlparser.selectionSet.parse(str).match
        }

        XCTAssertEqual([.field(selection: .init(alias: nil, name: "abc", arguments: [], directives: [], selectionSet: [])),
                        .field(selection: .init(alias: nil, name: "def", arguments: [], directives: [], selectionSet: [])),
                        .field(selection: .init(alias: nil, name: "xyz", arguments: [], directives: [], selectionSet: []))],
                       testSubject("{abc def,xyz}"))
        XCTAssertEqual([.field(selection: .init(alias: nil, name: "abc", arguments: [], directives: [], selectionSet: [])),
                        .field(selection: .init(alias: nil, name: "def", arguments: [], directives: [], selectionSet: [])),
                        .field(selection: .init(alias: nil, name: "xyz", arguments: [], directives: [], selectionSet: []))],
                       testSubject("{ abc def,xyz }"))
    }

    func testAlias() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.alias.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("abc:"))
        XCTAssertEqual("abc", testSubject("abc :"))
        XCTAssertNil(testSubject("abc"))
        XCTAssertNil(testSubject("123"))
    }

    func testField() {
        func testSubject(_ str: String) -> GraphQL.Field? {
            graphQlparser.field.parse(str).match
        }

        XCTAssertEqual(.init(alias: nil, name: "named", arguments: [], directives: [], selectionSet: []),
                       testSubject("named"))
        XCTAssertEqual(.init(alias: "aliased", name: "named", arguments: [], directives: [], selectionSet: []),
                       testSubject("aliased:named"))
        XCTAssertEqual(.init(alias: nil, name: "named", arguments: [.init(name: "with", value: "123")], directives: [], selectionSet: []),
                       testSubject("named(with:123)"))
        XCTAssertEqual(.init(alias: nil, name: "named", arguments: [], directives: [.init(name: "annotated", arguments: [])], selectionSet: []),
                       testSubject("named@annotated"))
        XCTAssertEqual(.init(alias: nil, name: "named", arguments: [], directives: [.init(name: "annotated", arguments: [.init(name: "with", value: "123")])], selectionSet: []),
                       testSubject("named@annotated(with:123)"))
        XCTAssertEqual(.init(alias: "alias", name: "named", arguments: [.init(name: "with", value: "123")], directives: [.init(name: "annotated", arguments: [.init(name: "with", value: "456")])], selectionSet: [.field(selection: .init(alias: nil, name: "also", arguments: [], directives: [], selectionSet: []))]),
                       testSubject("alias:named(with:123)@annotated(with:456){ also }"))
        XCTAssertEqual(.init(alias: "alias", name: "named", arguments: [.init(name: "with", value: "123")], directives: [.init(name: "annotated", arguments: [.init(name: "with", value: "456")])], selectionSet: [.field(selection: .init(alias: nil, name: "also", arguments: [], directives: [], selectionSet: []))]),
                       testSubject("alias : named ( with : 123 ) @annotated ( with: 456 ) { also }"))
    }

    func testFragmentName() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.fragmentName.parse(str).match
        }

        XCTAssertEqual("named", testSubject("named"))
        XCTAssertEqual("Named", testSubject("Named"))
        XCTAssertNil(testSubject("on"))
    }

    func testFragmentSpread() {
        func testSubject(_ str: String) -> GraphQL.FragmentSpread? {
            graphQlparser.fragmentSpread.parse(str).match
        }

        XCTAssertEqual(.init(name: "named", directives: []), testSubject("...named"))
        XCTAssertEqual(.init(name: "named", directives: [.init(name: "annotated", arguments: [])]), testSubject("...named@annotated"))
        XCTAssertEqual(.init(name: "Named", directives: [.init(name: "annotated", arguments: [])]), testSubject("... Named @annotated"))
        XCTAssertNil(testSubject("..."))
        XCTAssertNil(testSubject("... 123"))
    }

    func testTypeCondition() {
        func testSubject(_ str: String) -> GraphQL.TypeCondition? {
            graphQlparser.typeCondition.parse(str).match
        }

        XCTAssertEqual(.init(namedType: "named"), testSubject("on named"))
        XCTAssertEqual(.init(namedType: "Named"), testSubject("on Named"))
        XCTAssertNil(testSubject("on"))
        XCTAssertNil(testSubject("abc"))
        // XCTAssertNil(testSubject("onnamed")) // FIXME: Fix this neatly
    }

    func testFragmentDefinition() {
        func testSubject(_ str: String) -> GraphQL.FragmentDefinition? {
            graphQlparser.fragmentDefinition.parse(str).match
        }

        XCTAssertEqual(.init(name: "named", typeCondition: .init(namedType: "typename"), directives: [], selectionSet: []),
                       testSubject("fragment named on typename {}"))
        XCTAssertEqual(.init(name: "named", typeCondition: .init(namedType: "typename"), directives: [], selectionSet: []),
                       testSubject("fragment named on typename{}"))
        XCTAssertEqual(.init(name: "named", typeCondition: .init(namedType: "typename"), directives: [.init(name: "annotated", arguments: [])], selectionSet: []),
                       testSubject("fragment named on typename @annotated {}"))
        XCTAssertEqual(.init(name: "named", typeCondition: .init(namedType: "typename"), directives: [.init(name: "annotated", arguments: [])], selectionSet: []),
                       testSubject("fragment named on typename@annotated{}"))
        // XCTAssertNil(testSubject("fragmentnamed on typename{}")) // FIXME: Fix this neatly
        XCTAssertNil(testSubject("fragment namedon typename{}"))
        // XCTAssertNil(testSubject("fragment named ontypename{}")) // FIXME: Fix this neatly
    }

    func testInlineFragment() {
        func testSubject(_ str: String) -> GraphQL.InlineFragment? {
            graphQlparser.inlineFragment.parse(str).match
        }

        XCTAssertEqual(.init(typeCondition: nil, directives: [], selectionSet: []), testSubject("...{}"))
        XCTAssertEqual(.init(typeCondition: .init(namedType: "named"), directives: [], selectionSet: []), testSubject("...on named{}"))
        XCTAssertEqual(.init(typeCondition: nil, directives: [.init(name: "annotated", arguments: [])], selectionSet: []), testSubject("...@annotated{}"))
        XCTAssertEqual(.init(typeCondition: .init(namedType: "named"), directives: [.init(name: "annotated", arguments: [])], selectionSet: []), testSubject("... on named @annotated { }"))
    }

    func testOperationType() {
        func testSubject(_ str: String) -> GraphQL.OperationType? {
            graphQlparser.operationType.parse(str).match
        }

        XCTAssertEqual(.query, testSubject("query"))
        XCTAssertEqual(.mutation, testSubject("mutation"))
        XCTAssertEqual(.subscription, testSubject("subscription"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testOperationDefinition() {
        func testSubject(_ str: String) -> GraphQL.OperationDefinition? {
            graphQlparser.operationDefinition.parse(str).match
        }

        XCTAssertEqual(.selectionSet(selectionSet: []), testSubject("{}"))
        XCTAssertEqual(.operation(definition: .init(operationType: .query, name: nil, variableDefinitions: [], directives: [], selectionSet: [])),
                       testSubject("query"))
        XCTAssertEqual(.operation(definition: .init(operationType: .query, name: "named", variableDefinitions: [], directives: [], selectionSet: [])),
                       testSubject("query named"))
        XCTAssertEqual(.operation(definition: .init(operationType: .query, name: nil, variableDefinitions: ["abc:Int", "xyz:Int"], directives: [], selectionSet: [])),
                       testSubject("query ($abc:Int, $xyz:Int)"))
        XCTAssertEqual(.operation(definition: .init(operationType: .query, name: nil, variableDefinitions: [], directives: [.init(name: "annotated", arguments: []), .init(name: "with", arguments: [])], selectionSet: [])),
                       testSubject("query @annotated @with"))
        XCTAssertEqual(.operation(definition: .init(operationType: .query, name: nil, variableDefinitions: [], directives: [], selectionSet: [])),
                       testSubject("query {}"))
        XCTAssertEqual(.operation(definition: .init(operationType: .query, name: "named", variableDefinitions: ["abc:Int"], directives: [.init(name: "annotated", arguments: [])], selectionSet: [])),
                       testSubject("query named ($abc: Int) @annotated {}"))
        XCTAssertEqual(.operation(definition: .init(operationType: .mutation, name: "named", variableDefinitions: ["abc:Int"], directives: [.init(name: "annotated", arguments: [])], selectionSet: [])),
                       testSubject("mutation named ($abc: Int) @annotated {}"))
        XCTAssertEqual(.operation(definition: .init(operationType: .subscription, name: "named", variableDefinitions: ["abc:Int"], directives: [.init(name: "annotated", arguments: [])], selectionSet: [])),
                       testSubject("subscription named ($abc: Int) @annotated {}"))
        XCTAssertNil(testSubject("invalid named ($abc: Int) @annotated {}"))
    }

    func testExecutableDefinition() {
        func testSubject(_ str: String) -> GraphQL.ExecutableDefinition? {
            graphQlparser.executableDefinition.parse(str).match
        }

        XCTAssertEqual(.operation(definition: .selectionSet(selectionSet: [])),
                       testSubject("{}"))
        XCTAssertEqual(.operation(definition: .operation(definition: .init(operationType: .query, name: "named", variableDefinitions: ["abc:Int"], directives: [.init(name: "annotated", arguments: [])], selectionSet: []))),
                       testSubject("query named ($abc: Int) @annotated {}"))
        XCTAssertEqual(.fragment(definition: .init(name: "named", typeCondition: .init(namedType: "typename"), directives: [.init(name: "annotated", arguments: [])], selectionSet: [])),
                       testSubject("fragment named on typename @annotated {}"))
    }

    func testDocument() {
        func testSubject(_ str: String) -> GraphQL.Document? {
            graphQlparser.document.parse(str).match
        }

        XCTAssertEqual(
            .init(definitions: [
                .executable(definition: .operation(definition: .operation(
                    definition: .init(operationType: .query, name: "named", variableDefinitions: ["abc:Int"], directives: [.init(name: "annotated", arguments: [])], selectionSet: [])))),
                .executable(definition: .fragment(
                    definition: .init(name: "named", typeCondition: .init(namedType: "typename"), directives: [.init(name: "annotated", arguments: [])], selectionSet: [])))
            ]),
            testSubject("query named ($abc: Int) @annotated {} \n fragment named on typename @annotated {}")
        )
    }

    //    func testSandbox() {
    //        dump(graphQlparser.selectionSet.parse("{ hello, world }"))
    //    }
}
