import XCTest
@testable import GraphQLParser

final class GraphQLTests: XCTestCase {

    var graphQlparser = GraphQL()

    func testName() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.name.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("abc"))
        XCTAssertEqual("a123", testSubject("a123"))
        XCTAssertEqual("with_underscore_", testSubject("with_underscore_"))
        XCTAssertNil(testSubject("_abc"))
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
        func testSubject(_ str: String) -> String? {
            graphQlparser.argument.parse(str).match
        }

        XCTAssertEqual("abc:xyz", testSubject("abc : \"xyz\""))
        XCTAssertEqual("abc:123", testSubject("abc : 123"))
        XCTAssertEqual("abc:123", testSubject("abc:123"))
    }

    func testArguments() {
        func testSubject(_ str: String) -> [String]? {
            graphQlparser.arguments.parse(str).match
        }

        XCTAssertEqual(["abc:xyz"], testSubject("(abc:\"xyz\")"))
        XCTAssertEqual(["abc:123"], testSubject("(abc:123)"))
        XCTAssertEqual(["abc:123"], testSubject("( abc : 123 )"))
        XCTAssertEqual(["abc:123","def:xyz"], testSubject("(abc : 123, def : \"xyz\")"))
    }

    func testDirective() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.directive.parse(str).match
        }

        XCTAssertEqual("@named[abc:xyz]", testSubject("@named (abc : \"xyz\")"))
        XCTAssertEqual("@named[abc:xyz]", testSubject("@named(abc : \"xyz\")"))
    }

    func testDirectives() {
        func testSubject(_ str: String) -> [String]? {
            graphQlparser.directives.parse(str).match
        }

        XCTAssertEqual(["@named[abc:xyz]", "@other[abc:xyz]"], testSubject("@named (abc : \"xyz\") @other (abc : \"xyz\")"))
    }

    func testSelection() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.selectionSet.parse(str).match
        }

        XCTAssertEqual("{:abc(),:def(),:xyz()}", testSubject("{abc def,xyz}"))
        XCTAssertEqual("{:abc(),:def(),:xyz()}", testSubject("{ abc def,xyz }"))
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
        func testSubject(_ str: String) -> String? {
            graphQlparser.field.parse(str).match
        }

        XCTAssertEqual(":named()", testSubject("named"))
        XCTAssertEqual("aliased:named()", testSubject("aliased:named"))
        XCTAssertEqual(":named()@annotated[]", testSubject("named@annotated"))
        XCTAssertEqual(":named()@annotated[with:123]", testSubject("named@annotated(with:123)"))
        XCTAssertEqual("alias:named(with:123)@annotated[with:456]{:also()}", testSubject("alias:named(with:123)@annotated(with:456){ also }"))
        XCTAssertEqual("alias:named(with:123)@annotated[with:456]{:also()}", testSubject("alias : named ( with : 123 ) @annotated ( with: 456 ) { also }"))
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
        func testSubject(_ str: String) -> String? {
            graphQlparser.fragmentSpread.parse(str).match
        }

        XCTAssertEqual("named", testSubject("...named"))
        XCTAssertEqual("named@annotated[]", testSubject("...named@annotated"))
        XCTAssertEqual("Named@annotated[]", testSubject("... Named @annotated"))
        XCTAssertNil(testSubject("..."))
        XCTAssertNil(testSubject("... 123"))
    }

    func testTypeCondition() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.typeCondition.parse(str).match
        }

        XCTAssertEqual("named", testSubject("on named"))
        XCTAssertEqual("Named", testSubject("on Named"))
        XCTAssertNil(testSubject("on"))
        XCTAssertNil(testSubject("abc"))
        // XCTAssertNil(testSubject("onnamed")) // TODO: Fix this neatly
    }

    func testInlineFragment() {
        func testSubject(_ str: String) -> String? {
            graphQlparser.inlineFragment.parse(str).match
        }

        XCTAssertEqual("{}", testSubject("...{}"))
        XCTAssertEqual("named{}", testSubject("...on named{}"))
        XCTAssertEqual("@annotated[]{}", testSubject("...@annotated{}"))
        XCTAssertEqual("named@annotated[]{}", testSubject("... on named @annotated { }"))
    }

    //    func testSandbox() {
    //        dump(graphQlparser.selectionSet.parse("{ hello, world }"))
    //    }
}
