// MARK: - GraphQL Grammar

class GraphQL {

    init() {

        // MARK: Language

        // sourceChar -> '[\u0009\u000A\u000D\u0020-\uFFFF]'
        let sourceChar = char // TODO: proper sourceChar definition
        self.sourceChar = sourceChar

        // name -> '[_A-Za-z][_0-9A-Za-z]'
        let name = prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" })
            .flatMap { (!$0.isEmpty && !$0.first!.isNumber && $0.first != "_") ? always($0) : .never}
            .map(String.init)
        self.name = name

        // whiteSpace -> [ '\s' '\t' ]
        /// Separator Tokens, found inside `string` or `comment`
        let whiteSpace = oneOf([
            literal(" "),
            literal("\t"),
        ])
        self.whiteSpace = whiteSpace

        // lineTerminator -> [ '\n' '\r' '\f' ]
        /// Separator Tokens, not found anywhere else
        let lineTerminator = oneOf([
            literal("\n"),
            literal("\r"),
        ])
        self.lineTerminator = lineTerminator

        // comma -> ','
        /// Separate lexical tokens, can be trailing or used as line-terminators
        let comma = literal(",")
        self.comma = comma

        // commentChar -> sourceChar != lineTerminator
        let commentChar = zip(
            notOneOf([lineTerminator]),
            char
        ).map { _, c in c}
        self.commentChar = commentChar

        // comment -> " '#' { commentChar }? "
        /// Behaves like whitespace and may appear after any token, or before a line terminator
        let comment = zip(
            literal("#"),
            commentChar
        ).erase()
        self.comment = comment

        let tokenSeparator = zeroOrMore(oneOf([
            comment,
            lineTerminator,
            whiteSpace,
            comma,
        ])).erase()
        self.tokenSeparator = tokenSeparator


        // MARK: Values

        var valueDeferred: Parser<String> = .never
        // value -> [ variable intValue floatValue stringValue booleanValue nullValue listValue objectValue ]
        let value = deferred { valueDeferred }
        self.value = value

        // negativeSign -> '-'
        let negativeSign = char(of: "-")
        self.negativeSign = negativeSign

        // digit -> [ '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ]
        let digit = oneOf([
            char(of: "0"),
            char(of: "1"),
            char(of: "2"),
            char(of: "3"),
            char(of: "4"),
            char(of: "5"),
            char(of: "6"),
            char(of: "7"),
            char(of: "8"),
            char(of: "9"),
        ])
        self.digit = digit

        // nonZeroDigit -> [ '1' '2' '3' '4' '5' '6' '7' '8' '9' ]
        let nonZeroDigit = oneOf([
            char(of: "1"),
            char(of: "2"),
            char(of: "3"),
            char(of: "4"),
            char(of: "5"),
            char(of: "6"),
            char(of: "7"),
            char(of: "8"),
            char(of: "9"),
        ])
        self.nonZeroDigit = nonZeroDigit

        // integerPart -> [ " negativeSign? '0' "
        //                  " negativeSign? nonZeroDigit { digit? } " ]
        let integerPart: Parser<String> = zip(
            maybe(negativeSign),
            oneOrMore(digit)
        ).flatMap { negative, digits in
            if digits.count > 1 && digits.first == "0" { return .never }
            else {
                if let negative = negative.wrappedValue {
                    return always("\(negative)\(String(digits))")
                } else {
                    return always("\(String(digits))")
                }
            }
        }
        self.integerPart = integerPart

        // intValue -> integerPart
        let intValue = integerPart
        self.intValue = intValue

        // exponentIndicator -> [ 'e' 'E' ]
        let exponentIndicator = oneOf([
            literal("e"),
            literal("E"),
        ])
        self.exponentIndicator = exponentIndicator

        // sign -> [ '+' '-' ]
        let sign = oneOf([
            char(of: "+"),
            char(of: "-"),
        ])
        self.sign = sign

        // fractionalPart -> " '.' { digit } "
        let fractionalPart = zip(
            literal("."),
            oneOrMore(digit)
        ).map { _, digits in String(digits)}
        self.fractionalPart = fractionalPart

        // exponentPart -> " exponentIndicator sign? { digit } "
        let exponentPart = zip(
            exponentIndicator,
            maybe(sign),
            oneOrMore(digit)
        ).map { (arg) -> String in
            let (_, sign, digits) = arg
            if let sign = sign.wrappedValue {
                return "e\(sign)\(String(digits))"
            } else {
                return "e+\(String(digits))"
            }
        }
        self.exponentPart = exponentPart

        // floatValue -> [ " integerPart fractionalPart "
        //                 " integerPart exponentPart "
        //                 " integerPart fractionalPart exponentPart " ]
        let floatValue = oneOf([
            zip(integerPart, fractionalPart, exponentPart).map { "\($0.0).\($0.1):\($0.2)" },
            zip(integerPart, fractionalPart).map { "\($0.0).\($0.1)" },
            zip(integerPart, exponentPart).map { "\($0.0):\($0.1)" },
        ])
        self.floatValue = floatValue

        // booleanValue -> [ 'true' 'false' ]
        let booleanValue = oneOf([
            literal("true").map { "bool(true)" },
            literal("false").map { "bool(false)" },
        ])
        self.booleanValue = booleanValue

        // TODO: unicode literal handling
        // escapedUnicode -> [0-9A-Fa-f]{4}
        let escapedUnicode = zip(
            sourceChar,
            sourceChar,
            sourceChar,
            sourceChar
        ).map { _ in Character.init("U") }
        self.escapedUnicode = escapedUnicode

        // escapedCharacter -> [ '"' '\' '/' 'b' 'f' 'n' 'r' 't' ]
        let escapedCharacter = oneOf([
            char(of: "'"),
            char(of: "\\"),
            char(of: "/"),
            char(of: "b"),
            char(of: "f"),
            char(of: "n"),
            char(of: "r"),
            char(of: "t"),
        ])
        self.escapedCharacter = escapedCharacter

        // stringCharacter -> [ sourceCharacter != [ '"' '\' lineTerminator ]
        //                      " '\u' escapedUnicode "
        //                      " '\' escapedCharacter " ]
        let stringCharacter = oneOf([
            zip(notOneOf([literal("\""), literal("\\"), lineTerminator]),
                sourceChar).map { _, c in c},
            zip(literal("\\u"), escapedUnicode).map { _, c in c },
            zip(literal("\\"), escapedCharacter).map { _, c in c },
        ])
        self.stringCharacter = stringCharacter

        // blockStringCharacter -> [ sourceCharacter != [ '"""' '\"""']
        //                           '\"""' ]
        //let blockStringCharacter =

        // stringValue -> [ " '"' { stringCharacter }? '"' "
        //                  " '"""' { blockStringCharacter }? '"""' " ]
        let stringValue = //oneOf([
            zip(literal("\""),
                zeroOrMore(stringCharacter),
                literal("\"")).map { _, chars, _ in String(chars) } //,
        //    zip(literal("\"\"\""),
        //        zeroOrMore(blockStringCharacter),
        //        literal("\"\"\"")),
        //]) // TODO: block strings
        self.stringValue = stringValue

        // nullValue -> 'null'
        let nullValue = literal("null").map { "<null>" }
        self.nullValue = nullValue

        // enumValue -> name != [ booleanValue nullValue ]
        let enumValue = zip(
            notOneOf([
                booleanValue.erase(),
                nullValue.erase(),
            ]),
            name
        ).map { _, n in n}
        self.enumValue = enumValue

        // listValue -> [ " '[' ']' "
        //                " '[' { value } ']' " ]
        let listValue = oneOf([
            zip(literal("["),
                tokenSeparator,
                literal("]")
            ).map { _ in "[]" },
            zip(literal("["),
                tokenSeparator,
                zeroOrMore(value, separatedBy: tokenSeparator),
                tokenSeparator,
                literal("]")
            ).map { _, _, values, _, _ in values }
                .map { "[" + $0.joined(separator: ",") + "]" },
        ])
        self.listValue = listValue

        // objectField -> " name ':' value "
        let objectField = zip(
            name,
            tokenSeparator,
            literal(":"),
            tokenSeparator,
            value
        ).map { name, _, _, _, value in "\(name):\(value)"}
        self.objectField = objectField

        // objectValue -> [ " '{' '}' "
        //                  " '{' { objectField } '}' " ]
        let objectValue = oneOf([
            zip(literal("{"),
                tokenSeparator,
                literal("}")
            ).map { _ in Array<String>() }
                .map { _ in "{}" },
            zip(literal("{"),
                tokenSeparator,
                zeroOrMore(objectField, separatedBy: tokenSeparator),
                tokenSeparator,
                literal("}")
            ).map { _, _, fields, _, _ in fields }
                .map { "{" + $0.joined(separator: ",") + "}" },
        ])
        self.objectValue = objectValue

        // MARK: Type

        var typeDeferred: Parser<String> = .never
        // type -> [ namedType listType nonNullType ]
        let type = deferred { typeDeferred }
        self.type = type

        // namedType -> name
        let namedType = name
        self.namedType = namedType

        // listType -> " '[' type ']' "
        let listType = zip(
            literal("["),
            tokenSeparator,
            type,
            tokenSeparator,
            literal("]")
        ) .map { _, _, type, _, _ in "[\(type)]" }
        self.listType = listType

        // nonNullType -> [ " namedType '!' "
        //                  " listType '!' " ]
        let nonNullType = oneOf([
            zip(listType, literal("!")).map { type, _ in "\(type)!!"},
            zip(namedType, literal("!")).map { type, _ in "\(type)!!"},
        ])
        self.nonNullType = nonNullType


        // MARK: Variables

        // defaultValue -> " '=' value "
        let defaultValue = zip(
            char(of: "="),
            tokenSeparator,
            value
        ).map{ _, _, v in v}
        self.defaultValue = defaultValue

        // variable -> " '$' name "
        let variable = zip(literal("$"), name)
            .map{ _, n in n }
        self.variable = variable

        // variableDefinition -> " variable ':' type defaultValue? "
        let variableDefinition = zip(
            variable,
            tokenSeparator,
            literal(":"),
            tokenSeparator,
            type,
            tokenSeparator,
            maybe(defaultValue)
        ).map { (arg) -> String in
            let (variable, _, _, _, type, _, defValue) = arg
            if let defValue = defValue.wrappedValue {
                return "\(variable):\(type)=\(defValue)"
            } else {
                return "\(variable):\(type)"
            }
        }
        self.variableDefinition = variableDefinition

        // variableDefinitions -> " '(' { variableDefinition } ')' "
        let variableDefinitions = zip(
            literal("("),
            tokenSeparator,
            zeroOrMore(variableDefinition, separatedBy: tokenSeparator),
            tokenSeparator,
            literal(")")
        ).map { _, _, tokens, _, _ in tokens}
        self.variableDefinitions = variableDefinitions


        // MARK: Directives

        // argument -> " name ':' value "
        let argument = zip(
            name,
            tokenSeparator,
            literal(":"),
            tokenSeparator,
            value
        ).map { name, _, _, _, value in "\(name):\(value)" }
        self.argument = argument

        // arguments -> " '(' { argument } ')' "
        let arguments = zip(
            literal("("),
            tokenSeparator,
            zeroOrMore(argument, separatedBy: tokenSeparator),
            literal(")")
        ).map { _, _, arguments, _ in arguments }
            .map { "[\($0.joined(separator: ","))]"}
        self.arguments = arguments

        // directive -> " '@' name arguments? "
        let directive = zip(
            literal("@"),
            name,
            tokenSeparator,
            maybe(arguments)
        ).map { (arg) -> String in
            let (_, name, _, arguments) = arg
            if let arguments = arguments.wrappedValue {
                return "@\(name):\(arguments)"
            } else {
                return "@\(name)"
            }
        }
        self.directive = directive

        // directives -> { directive }
        let directives = zeroOrMore(directive, separatedBy: tokenSeparator)
        self.directives = directives


        // MARK: Selection sets

        var selectionDeferred: Parser<String> = .never
        // selection -> [ field fragmentSpread inlineFragment ]
        let selection = deferred { selectionDeferred }
        self.selection = selection

        // selectionSet -> " '{' { selection } '}' "
        let selectionSet = zip(
            literal("{"),
            tokenSeparator,
            zeroOrMore(selection, separatedBy: tokenSeparator),
            tokenSeparator,
            literal("}")
        ).map { _, _, selections, _, _ in "{\(selections.joined(separator: ","))}" }
        self.selectionSet = selectionSet

        // alias -> " name ':' "
        let alias = zip(
            name,
            tokenSeparator,
            literal(":")
        ).map { n, _, _ in n}
        self.alias = alias

        // field -> " alias? name arguments? directives? selectionSet? "
        let field = zip(
            maybe(alias),
            name,
            maybe(arguments),
            maybe(directive),
            maybe(selectionSet)
        ).map { alias, name, arguments, directive, selectionSet in name }
        self.field = field


        // MARK: Fragments

        // fragmentName -> name != 'on'
        let fragmentName = zip(
            notOneOf([literal("on")]),
            name
        ).map { _, name in name }
        self.fragmentName = fragmentName

        // fragmentSpread -> " '...' fragmentName directives? "
        let fragmentSpread = zip(
            literal("..."),
            fragmentName,
            maybe(directives)
        ).map { _, fragmentName, directives in fragmentName }
        self.fragmentSpread = fragmentSpread

        // typeCondition -> " 'on' namedType "
        let typeCondition = zip(
            literal("on"),
            namedType
        ).map { _, namedType in namedType }
        self.typeCondition = typeCondition

        // fragmentDefinition -> " 'fragment' fragmentName typeCondition directives? selectionSet "
        let fragmentDefinition = zip(
            literal("fragment"),
            fragmentName,
            typeCondition,
            maybe(directives),
            selectionSet
        ).map { _, fragmentName, typeCondition, directives, selectionSet in fragmentName }
        self.fragmentDefinition = fragmentDefinition

        // inlineFragment -> " '...' typeCondition? directives? selectionSet "
        let inlineFragment = zip(
            literal("..."),
            maybe(typeCondition),
            maybe(directives),
            selectionSet
        ).map { _, typeCondition, directives, selectionSet in "..." }
        self.inlineFragment = inlineFragment


        // MARK: Document

        // operationType -> [ 'query' 'mutation' 'subscription' ]
        let operationType = oneOf([
            literal("query").map { "query" },
            literal("mutation").map { "mutation" },
            literal("subscription").map { "subscription" },
        ])
        self.operationType = operationType

        // operationDefinition -> [ " operationType name? variableDefinitions? directives? selectionSet "
        //                          selectionSet ]
        let operationDefinition = oneOf([
            zip(operationType,
                maybe(name),
                maybe(variableDefinitions),
                maybe(directives),
                maybe(selectionSet)).map { $0.0 },
            selectionSet,
        ])
        self.operationDefinition = operationDefinition

        // executableDefinition -> [ operationDefinition fragmentDefinition ]
        let executableDefinition = oneOf([
            operationDefinition,
            fragmentDefinition,
        ])
        self.executableDefinition = executableDefinition

        // definition -> [ executableDefinition typeSystemDefinition TypeSystemExtension ]
        let definition = oneOf([
            executableDefinition
            // typeSystemDefinition, // GraphQL schema and other types not supported
            // TypeSystemExtension, // GraphQL schema and other types not supported
        ])
        self.definition = definition

        // document -> { definition }
        let document = oneOrMore(definition, separatedBy: tokenSeparator)
        self.document = document

        /// Real parsing behaviour for deferred parsers is defined here.
        /// Deferred values are overwritten on `initialise` and then picked up by the canonical `Parser` at runtime.

        valueDeferred = oneOf([
            variable,
            stringValue,
            objectValue,
            listValue,
            nullValue,
            booleanValue,
            floatValue,
            intValue,
        ])

        typeDeferred = oneOf([
            listType,
            nonNullType,
            namedType,
        ])

        selectionDeferred = oneOf([
            field,
            fragmentSpread,
            inlineFragment,
        ])
    }

    let sourceChar: Parser<Character>
    let name: Parser<String>
    let whiteSpace: Parser<Void>
    let lineTerminator: Parser<Void>
    let comma: Parser<Void>
    let commentChar: Parser<Character>
    let comment: Parser<Void>
    let tokenSeparator: Parser<Void>
    let value: Parser<String>
    let negativeSign: Parser<Character>
    let digit: Parser<Character>
    let nonZeroDigit: Parser<Character>
    let integerPart: Parser<String>
    let intValue: Parser<String>
    let exponentIndicator: Parser<Void>
    let sign: Parser<Character>
    let fractionalPart: Parser<String>
    let exponentPart: Parser<String>
    let floatValue: Parser<String>
    let booleanValue: Parser<String>
    let escapedUnicode: Parser<Character>
    let escapedCharacter: Parser<Character>
    let stringCharacter: Parser<Character>
    let stringValue: Parser<String>
    let nullValue: Parser<String>
    let enumValue: Parser<String>
    let listValue: Parser<String>
    let objectField: Parser<String>
    let objectValue: Parser<String>
    let type: Parser<String>
    let namedType: Parser<String>
    let listType: Parser<String>
    let nonNullType: Parser<String>
    let defaultValue: Parser<String>
    let variable: Parser<String>
    let variableDefinition: Parser<String>
    let variableDefinitions: Parser<[String]>
    let argument: Parser<String>
    let arguments: Parser<String>
    let directive: Parser<String>
    let directives: Parser<[String]>
    let selection: Parser<String>
    let selectionSet: Parser<String>
    let alias: Parser<String>
    let field: Parser<String>
    let fragmentName: Parser<String>
    let fragmentSpread: Parser<String>
    let typeCondition: Parser<String>
    let fragmentDefinition: Parser<String>
    let inlineFragment: Parser<String>
    let operationType: Parser<String>
    let operationDefinition: Parser<String>
    let executableDefinition: Parser<String>
    let definition: Parser<String>
    let document: Parser<[String]>
}
