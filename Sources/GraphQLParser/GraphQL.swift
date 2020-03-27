// MARK: - GraphQL Grammar

enum GraphQL {

    // MARK: Language

    // sourceChar -> '[\u0009\u000A\u000D\u0020-\uFFFF]'
    static let sourceChar = char // TODO: proper sourceChar definition

    // name -> '[_A-Za-z][_0-9A-Za-z]'
    static let name = prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" })
        .flatMap { (!$0.isEmpty && !$0.first!.isNumber && $0.first != "_") ? always($0) : .never}
        .map(String.init)

    // whiteSpace -> [ '\s' '\t' ]
    /// Separator Tokens, found inside `string` or `comment`
    static let whiteSpace = oneOf([
        literal(" "),
        literal("\t"),
    ])

    // lineTerminator -> [ '\n' '\r' '\f' ]
    /// Separator Tokens, not found anywhere else
    static let lineTerminator = oneOf([
        literal("\n"),
        literal("\r"),
    ])

    // comma -> ','
    /// Separate lexical tokens, can be trailing or used as line-terminators
    static let comma = literal(",")

    // commentChar -> sourceChar != lineTerminator
    static let commentChar = zip(
        notOneOf([lineTerminator]),
        char
    ).map { _, c in c}

    // comment -> " '#' { commentChar }? "
    /// Behaves like whitespace and may appear after any token, or before a line terminator
    static let comment = zip(
        literal("#"),
        commentChar
    ).erase()

    static let tokenSeparator = zeroOrMore(oneOf([
        comment,
        lineTerminator,
        whiteSpace,
        comma,
    ])).erase()


    // MARK: Values

    static var valueDeferred: Parser<String> = .never
    // value -> [ variable intValue floatValue stringValue booleanValue nullValue listValue objectValue ]
    static let value = deferred { Self.valueDeferred }

    // negativeSign -> '-'
    static let negativeSign = char(of: "-")

    // digit -> [ '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' ]
    static let digit = oneOf([
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

    // nonZeroDigit -> [ '1' '2' '3' '4' '5' '6' '7' '8' '9' ]
    static let nonZeroDigit = oneOf([
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

    // integerPart -> [ " negativeSign? '0' "
    //                  " negativeSign? nonZeroDigit { digit? } " ]
    static let integerPart = zip(
        maybe(negativeSign),
        nonZeroDigit,
        zeroOrMore(digit)
    ).map { (arg) -> [Character] in let ( negative, nonZero, includingZeroes) = arg
        var digits = includingZeroes
        digits.insert(nonZero, at: digits.startIndex)
        if let negative = negative.wrappedValue {
            digits.insert(negative, at: digits.startIndex)
        }
        return digits
    }.map { String($0) }

    // intValue -> integerPart
    static let intValue = integerPart

    // exponentIndicator -> [ 'e' 'E' ]
    static let exponentIndicator = oneOf([
        literal("e"),
        literal("E"),
    ])

    // sign -> [ '+' '-' ]
    static let sign = oneOf([
        char(of: "+"),
        char(of: "-"),
    ])

    // fractionalPart -> " '.' { digit } "
    static let fractionalPart = zip(
        literal("."),
        oneOrMore(digit)
    ).map { _, digits in String(digits)}

    // exponentPart -> " exponentIndicator sign? { digit } "
    static let exponentPart = zip(
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

    // floatValue -> [ " integerPart fractionalPart "
    //                 " integerPart exponentPart "
    //                 " integerPart fractionalPart exponentPart " ]
    static let floatValue = oneOf([
        zip(integerPart, fractionalPart, exponentPart).map { "\($0.0).\($0.1):\($0.2)" },
        zip(integerPart, fractionalPart).map { "\($0.0).\($0.1)" },
        zip(integerPart, exponentPart).map { "\($0.0):\($0.1)" },
    ])

    // booleanValue -> [ 'true' 'false' ]
    static let booleanValue = oneOf([
        literal("true").map { "bool(true)" },
        literal("false").map { "bool(false)" },
    ])

    // TODO: unicode literal handling
    // escapedUnicode -> [0-9A-Fa-f]{4}
    static let escapedUnicode = zip(
        sourceChar,
        sourceChar,
        sourceChar,
        sourceChar
    ).map { _ in Character.init("U") }

    // escapedCharacter -> [ '"' '\' '/' 'b' 'f' 'n' 'r' 't' ]
    static let escapedCharacter = oneOf([
        char(of: "'"),
        char(of: "\\"),
        char(of: "/"),
        char(of: "b"),
        char(of: "f"),
        char(of: "n"),
        char(of: "r"),
        char(of: "t"),
    ])

    // stringCharacter -> [ sourceCharacter != [ '"' '\' lineTerminator ]
    //                      " '\u' escapedUnicode "
    //                      " '\' escapedCharacter " ]
    static let stringCharacter = oneOf([
        zip(notOneOf([literal("\""), literal("\\"), lineTerminator]),
            sourceChar).map { _, c in c},
        zip(literal("\\u"), escapedUnicode).map { _, c in c },
        zip(literal("\\"), escapedCharacter).map { _, c in c },
    ])

    // blockStringCharacter -> [ sourceCharacter != [ '"""' '\"""']
    //                           '\"""' ]
    //static let blockStringCharacter =

    // stringValue -> [ " '"' { stringCharacter }? '"' "
    //                  " '"""' { blockStringCharacter }? '"""' " ]
    static let stringValue = //oneOf([
        zip(literal("\""),
            zeroOrMore(stringCharacter),
            literal("\"")).map { _, chars, _ in String(chars) } //,
    //    zip(literal("\"\"\""),
    //        zeroOrMore(blockStringCharacter),
    //        literal("\"\"\"")),
    //]) // TODO: block strings

    // nullValue -> 'null'
    static let nullValue = literal("null").map { "<null>" }

    // enumValue -> name != [ booleanValue nullValue ]
    static let enumValue = zip(
        notOneOf([
            booleanValue.erase(),
            nullValue.erase(),
        ]),
        name
    ).map { _, n in n}

    // listValue -> [ " '[' ']' "
    //                " '[' { value } ']' " ]
    static let listValue = oneOf([
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

    // variable -> " '$' name "
    static let variable = zip(literal("$"), name)
        .map{ _, n in n }

    // objectField -> " name ':' value "
    static let objectField = zip(
        name,
        tokenSeparator,
        literal(":"),
        tokenSeparator,
        value
    ).map { name, _, _, _, value in "\(name):\(value)"}

    // objectValue -> [ " '{' '}' "
    //                  " '{' { objectField } '}' " ]
    static let objectValue = oneOf([
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

    // MARK: Type

    static var typeDeferred: Parser<String> = .never
    // type -> [ namedType listType nonNullType ]
    static let type = deferred { Self.typeDeferred }

    // namedType -> name
    static let namedType = name

    // listType -> " '[' type ']' "
    static let listType = zip(
        literal("["),
        tokenSeparator,
        type,
        tokenSeparator,
        literal("]")
    ) .map { _, _, type, _, _ in "[\(type)]" }

    // nonNullType -> [ " namedType '!' "
    //                  " listType '!' " ]
    static let nonNullType = oneOf([
        zip(listType, literal("!")).map { type, _ in "\(type)!!"},
        zip(namedType, literal("!")).map { type, _ in "\(type)!!"},
    ])


    // MARK: Variables

    // defaultValue -> " '=' value "
    static let defaultValue = zip(
        char(of: "="),
        tokenSeparator,
        value
    ).map{ _, _, v in v}

    // variableDefinition -> " variable ':' type defaultValue? "
    static let variableDefinition = zip(
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

    // variableDefinitions -> " '(' { variableDefinition } ')' "
    static let variableDefinitions = zip(
        literal("("),
        tokenSeparator,
        zeroOrMore(variableDefinition, separatedBy: tokenSeparator),
        tokenSeparator,
        literal(")")
    ).map { _, _, tokens, _, _ in tokens}


    // MARK: Directives

    // argument -> " name ':' value "
    static let argument = zip(
        name,
        tokenSeparator,
        literal(":"),
        tokenSeparator,
        value
    ).map { name, _, _, _, value in "\(name):\(value)" }

    // arguments -> " '(' { argument } ')' "
    static let arguments = zip(
        literal("("),
        tokenSeparator,
        zeroOrMore(argument, separatedBy: tokenSeparator),
        literal(")")
    ).map { _, _, arguments, _ in arguments }
        .map { "[\($0.joined(separator: ","))]"}

    // directive -> " '@' name arguments? "
    static let directive = zip(
        literal("@"),
        name,
        maybe(arguments)
    ).map { (arg) -> String in
        let (_, name, arguments) = arg
        if let arguments = arguments.wrappedValue {
            return "@\(name):\(arguments)"
        } else {
            return "@\(name)"
        }
    }

    // directives -> { directive }
    static let directives = zeroOrMore(directive, separatedBy: tokenSeparator)


    // MARK: Selection sets

    static var selectionDeferred: Parser<String> = .never
    // selection -> [ field fragmentSpread inlineFragment ]
    static let selection = deferred { Self.selectionDeferred }

    // selectionSet -> " '{' { selection } '}' "
    static let selectionSet = zip(
        literal("{"),
        tokenSeparator,
        zeroOrMore(selection, separatedBy: tokenSeparator),
        tokenSeparator,
        literal("}")
    ).map { _, _, selections, _, _ in "{\(selections.joined(separator: ","))}" }

    // alias -> " name ':' "
    static let alias = zip(
        name,
        tokenSeparator,
        literal(":")
    ).map { n, _, _ in n}

    // field -> " alias? name arguments? directives? selectionSet? "
    static let field = zip(
        maybe(alias),
        name,
        maybe(arguments),
        maybe(directive),
        maybe(selectionSet)
    ).map { alias, name, arguments, directive, selectionSet in name }


    // MARK: Fragments

    // fragmentName -> name != 'on'
    static let fragmentName = zip(
        notOneOf([literal("on")]),
        name
    ).map { _, name in name }

    // fragmentSpread -> " '...' fragmentName directives? "
    static let fragmentSpread = zip(
        literal("..."),
        fragmentName,
        maybe(directives)
    ).map { _, fragmentName, directives in fragmentName }

    // fragmentDefinition -> " 'fragment' fragmentName typeCondition directives? selectionSet "
    static let fragmentDefinition = zip(
        literal("fragment"),
        fragmentName,
        typeCondition,
        maybe(directives),
        selectionSet
    ).map { _, fragmentName, typeCondition, directives, selectionSet in fragmentName }

    // typeCondition -> " 'on' namedType "
    static let typeCondition = zip(
        literal("on"),
        namedType
    ).map { _, namedType in namedType }

    // inlineFragment -> " '...' typeCondition? directives? selectionSet "
    static let inlineFragment = zip(
        literal("..."),
        maybe(typeCondition),
        maybe(directives),
        selectionSet
    ).map { _, typeCondition, directives, selectionSet in "..." }


    // MARK: Document

    // operationType -> [ 'query' 'mutation' 'subscription' ]
    static let operationType = oneOf([
        literal("query").map { "query" },
        literal("mutation").map { "mutation" },
        literal("subscription").map { "subscription" },
    ])

    // operationDefinition -> [ " operationType name? variableDefinitions? directives? selectionSet "
    //                          selectionSet ]
    static let operationDefinition = oneOf([
        zip(operationType,
            maybe(name),
            maybe(variableDefinitions),
            maybe(directives),
            maybe(selectionSet)).map { $0.0 },
        selectionSet,
    ])

    // executableDefinition -> [ operationDefinition fragmentDefinition ]
    static let executableDefinition = oneOf([
        operationDefinition,
        fragmentDefinition,
    ])

    // definition -> [ executableDefinition typeSystemDefinition TypeSystemExtension ]
    static let definition = oneOf([
        executableDefinition
        // typeSystemDefinition, // GraphQL schema and other types not supported
        // TypeSystemExtension, // GraphQL schema and other types not supported
        ])

    // document -> { definition }
    static let document = oneOrMore(definition, separatedBy: tokenSeparator)

    static func initialise() {
        /// Real parsing behaviour for deferred parsers is defined here.
        /// Deferred values are overwritten on `initialise` and then picked up by the canonical `Parser` at runtime.

        Self.valueDeferred = oneOf([
            Self.variable,
            Self.stringValue,
            Self.objectValue,
            Self.listValue,
            Self.nullValue,
            Self.booleanValue,
            Self.floatValue,
            Self.intValue,
        ])

        Self.typeDeferred = oneOf([
            Self.listType,
            Self.nonNullType,
            Self.namedType,
        ])

        Self.selectionDeferred = oneOf([
            Self.field,
            Self.fragmentSpread,
            Self.inlineFragment,
        ])
    }
}
