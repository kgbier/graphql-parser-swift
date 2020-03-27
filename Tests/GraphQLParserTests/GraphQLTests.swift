import XCTest
@testable import GraphQLParser

final class GraphQLTests: XCTestCase {

    override func setUp() {
        GraphQL.initialise()
    }

    func testName() {
        func testSubject(_ str: String) -> String? {
            GraphQL.name.parse(str).match
        }

        XCTAssertEqual("abc", testSubject("abc"))
        XCTAssertEqual("a123", testSubject("a123"))
        XCTAssertEqual("with_underscore_", testSubject("with_underscore_"))
        XCTAssertNil(testSubject("_abc"))
        XCTAssertNil(testSubject("123"))
    }

    // alias: integerPart
    func testIntValue() {
        func testSubject(_ str: String) -> String? {
            GraphQL.intValue.parse(str).match
        }
        
        XCTAssertEqual("123", testSubject("123"))
        XCTAssertEqual("-123", testSubject("-123"))
        XCTAssertNil(testSubject("0123"))
        // TODO: XCTAssertEqual("-0", testSubject("-0"))
    }

    func testNegativeSign() {
        func testSubject(_ str: String) -> Character? {
            GraphQL.negativeSign.parse(str).match
        }

        XCTAssertEqual("-", testSubject("-"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testDigit() {
        func testSubject(_ str: String) -> Character? {
            GraphQL.digit.parse(str).match
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
            GraphQL.nonZeroDigit.parse(str).match
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

    func testFloatValue() {
        func testSubject(_ str: String) -> String? {
            GraphQL.floatValue.parse(str).match
        }

        XCTAssertEqual("6.0221413:e+23", testSubject("6.0221413e23"))
        XCTAssertEqual("6.123", testSubject("6.123"))
        XCTAssertEqual("1:e+10", testSubject("1e10"))
    }

    func testExponentIndicator() {
        func testSubject(_ str: String) -> Void? {
            GraphQL.exponentIndicator.parse(str).match
        }

        XCTAssertNotNil(testSubject("E"))
        XCTAssertNotNil(testSubject("e"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testExponentPart() {
        func testSubject(_ str: String) -> String? {
            GraphQL.exponentPart.parse(str).match
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

    func testFractionalPart() {
        func testSubject(_ str: String) -> String? {
            GraphQL.fractionalPart.parse(str).match
        }

        XCTAssertEqual("123", testSubject(".123"))
        XCTAssertEqual("012", testSubject(".012"))
        XCTAssertNil(testSubject("012"))
        XCTAssertNil(testSubject("."))
        XCTAssertNil(testSubject("a"))
    }

    func testSign() {
        func testSubject(_ str: String) -> Character? {
            GraphQL.sign.parse(str).match
        }

        XCTAssertEqual("+", testSubject("+"))
        XCTAssertEqual("-", testSubject("-"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testBooleanValue() {
        func testSubject(_ str: String) -> String? {
             GraphQL.booleanValue.parse(str).match
         }

        XCTAssertEqual("bool(true)", testSubject("true"))
        XCTAssertEqual("bool(false)", testSubject("false"))
        XCTAssertNil(testSubject("a"))
        XCTAssertNil(testSubject("1"))
        XCTAssertNil(testSubject(" "))
    }

    func testStringValue() {
        func testSubject(_ str: String) -> String? {
             GraphQL.stringValue.parse(str).match
         }

        XCTAssertEqual("hello sailor", testSubject("\"hello sailor\""))
        XCTAssertEqual(" hello sailor ", testSubject("\" hello sailor \""))
        XCTAssertEqual("123 abc", testSubject("\"123 abc\""))
        XCTAssertNil(testSubject("hello sailor\""))
        XCTAssertNil(testSubject("\"hello sailor"))
    }

    func testNullValue() {
        func testSubject(_ str: String) -> String? {
             GraphQL.nullValue.parse(str).match
         }

        XCTAssertEqual("<null>", testSubject("null"))
        XCTAssertNil(testSubject("012"))
        XCTAssertNil(testSubject("."))
        XCTAssertNil(testSubject("a"))
    }

    func testEnumValue() {
        func testSubject(_ str: String) -> String? {
             GraphQL.enumValue.parse(str).match
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
             GraphQL.listValue.parse(str).match
         }

        XCTAssertEqual("[]", testSubject("[ ]"))
        XCTAssertEqual("[]", testSubject("[]"))
        XCTAssertEqual("[]", testSubject("[ , ]"))
        XCTAssertEqual("[bool(true)]", testSubject("[true]"))
        XCTAssertEqual("[bool(true),bool(false)]", testSubject("[ true, false ]"))
    }

    func testObjectValue() {
        func testSubject(_ str: String) -> String? {
             GraphQL.objectValue.parse(str).match
         }
        XCTAssertEqual("{}", testSubject("{}"))
        XCTAssertEqual("{}", testSubject("{ }"))
        XCTAssertEqual("{}", testSubject("{ , }"))
        XCTAssertEqual("{name:123}", testSubject("{name:123}"))
        XCTAssertEqual("{name:123}", testSubject("{ name : 123 }"))
        XCTAssertEqual("{nameone:123,nametwo:abc}", testSubject("{ nameone : 123, nametwo : \"abc\" }"))
    }

//    func testSandbox() {
//        dump(GraphQL.selectionSet.parse("{ hello, world }"))
//    }
}
