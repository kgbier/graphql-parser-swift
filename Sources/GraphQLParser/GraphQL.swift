// MARK: - GraphQL Grammar

class GraphQL {

    init() {

        // MARK: Language

        // sourceChar -> '[\u0009\u000A\u000D\u0020-\uFFFF]'
        let sourceChar = char // TODO: proper sourceChar definition
        self.sourceChar = sourceChar

        // name -> '[_A-Za-z][_0-9A-Za-z]'
        let name = prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" })
            .flatMap { (!$0.isEmpty && !$0.first!.isNumber) ? always($0) : .never}
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
            zeroOrMore(commentChar)
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

        var valueDeferred: Parser<Value> = .never
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
        let intValue = integerPart.map { Value.int(value: $0)}
        self.intValue = intValue

        // exponentIndicator -> [ 'e' 'E' ]
        let exponentIndicator = oneOf([
            literal("e"),
            literal("E"),
        ])
        self.exponentIndicator = exponentIndicator

        // sign -> [ '+' '-' ]
        let sign = oneOf([
            literal("+").map { FloatingPointSign.plus },
            literal("-").map { .minus },
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
                return "e\(sign == .plus ? "+" : "-" )\(String(digits))"
            } else {
                return "e+\(String(digits))"
            }
        }
        self.exponentPart = exponentPart

        // floatValue -> [ " integerPart fractionalPart "
        //                 " integerPart exponentPart "
        //                 " integerPart fractionalPart exponentPart " ]
        let floatValue = oneOf([
            zip(integerPart, fractionalPart, exponentPart)
                .map { Value.float(value: "\($0.0).\($0.1):\($0.2)") },
            zip(integerPart, fractionalPart)
                .map { .float(value: "\($0.0).\($0.1)") },
            zip(integerPart, exponentPart)
                .map { .float(value: "\($0.0):\($0.1)") },
        ])
        self.floatValue = floatValue

        // booleanValue -> [ 'true' 'false' ]
        let booleanValue = oneOf([
            literal("true").map { Value.boolean(value: true) },
            literal("false").map { .boolean(value: false) },
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
                literal("\"")).map { _, chars, _ in Value.string(value: String(chars)) } //,
        //    zip(literal("\"\"\""),
        //        zeroOrMore(blockStringCharacter),
        //        literal("\"\"\"")),
        //]) // TODO: block strings
        self.stringValue = stringValue

        // nullValue -> 'null'
        let nullValue = literal("null").map { Value.null }
        self.nullValue = nullValue

        // enumValue -> name != [ booleanValue nullValue ]
        let enumValue = zip(
            notOneOf([
                booleanValue.erase(),
                nullValue.erase(),
            ]),
            name
        ).map { _, name in Value.enum(value: name) }
        self.enumValue = enumValue

        // listValue -> [ " '[' ']' "
        //                " '[' { value } ']' " ]
        let listValue = oneOf([
            zip(literal("["),
                tokenSeparator,
                literal("]")
            ).map { _ in Value.list(value: []) },
            zip(literal("["),
                tokenSeparator,
                zeroOrMore(value, separatedBy: tokenSeparator),
                tokenSeparator,
                literal("]")
            ).map { _, _, values, _, _ in values }
                .map { Value.list(value: $0) },
        ])
        self.listValue = listValue

        // objectField -> " name ':' value "
        let objectField = zip(
            name,
            tokenSeparator,
            literal(":"),
            tokenSeparator,
            value
        ).map { name, _, _, _, value in
            ObjectField(name: name, value: value)
        }
        self.objectField = objectField

        // objectValue -> [ " '{' '}' "
        //                  " '{' { objectField } '}' " ]
        let objectValue = oneOf([
            zip(literal("{"),
                tokenSeparator,
                literal("}")
            ).map { _ in [] }
                .map { _ in Value.object(value: []) },
            zip(literal("{"),
                tokenSeparator,
                oneOrMore(objectField, separatedBy: tokenSeparator),
                tokenSeparator,
                literal("}")
            ).map { _, _, fields, _, _ in fields }
                .map { Value.object(value: $0) },
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
        ).map{ _, _, value in value}
        self.defaultValue = defaultValue

        // variable -> " '$' name "
        let variable = zip(
            literal("$"),
            name
        ).map{ _, name in  name }
        self.variable = variable

        /// Wrapper to use as a possible `value`
        let variableValue = variable.map { Value.variable(name: $0)}
        self.variableValue = variableValue

        // variableDefinition -> " variable ':' type defaultValue? "
        let variableDefinition = zip(
            variable,
            tokenSeparator,
            literal(":"),
            tokenSeparator,
            type,
            tokenSeparator,
            maybe(defaultValue)
        ).map { variable, _, _, _, type, _, defaultValue in
            VariableDefinition(variable: variable, type: type, defaultValue: defaultValue.wrappedValue)
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
        ).map { name, _, _, _, value in
            Argument(name: name, value: value)
        }
        self.argument = argument

        // arguments -> " '(' { argument } ')' "
        let arguments = zip(
            literal("("),
            tokenSeparator,
            zeroOrMore(argument, separatedBy: tokenSeparator),
            tokenSeparator,
            literal(")")
        ).map { _, _, arguments, _, _ in arguments }
        self.arguments = arguments

        // directive -> " '@' name arguments? "
        let directive = zip(
            literal("@"),
            name,
            tokenSeparator,
            maybe(arguments)
        ).map { _, name, _, arguments in
            Directive(name: name, arguments: arguments.wrappedValue ?? [])
        }
        self.directive = directive

        // directives -> { directive }
        let directives = zeroOrMore(directive, separatedBy: tokenSeparator)
        self.directives = directives


        // MARK: Selection sets

        var selectionDeferred: Parser<GraphQL.Selection> = .never
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
        ).map { _, _, selections, _, _ in selections }
        self.selectionSet = selectionSet

        // alias -> " name ':' "
        let alias = zip(
            name,
            tokenSeparator,
            literal(":")
        ).map { name, _, _ in name}
        self.alias = alias

        // field -> " alias? name arguments? directives? selectionSet? "
        let field = zip(
            maybe(alias),
            tokenSeparator,
            name,
            tokenSeparator,
            maybe(arguments),
            tokenSeparator,
            maybe(directives),
            tokenSeparator,
            maybe(selectionSet)
        ).map { alias, _, name, _, arguments, _, directives, _, selectionSet in
            Field(alias: alias.wrappedValue,
                  name: name,
                  arguments: arguments.wrappedValue ?? [],
                  directives: directives.wrappedValue ?? [],
                  selectionSet: selectionSet.wrappedValue ?? [])
        }
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
            tokenSeparator,
            fragmentName,
            tokenSeparator,
            maybe(directives)
        ).map { _, _, fragmentName, _, directives in
            FragmentSpread(name: fragmentName, directives: directives.wrappedValue ?? [])
        }
        self.fragmentSpread = fragmentSpread

        // typeCondition -> " 'on' namedType "
        let typeCondition = zip(
            literal("on"),
            tokenSeparator,
            namedType
        ).map { _, _, namedType in TypeCondition(namedType: namedType) }
        self.typeCondition = typeCondition

        // fragmentDefinition -> " 'fragment' fragmentName typeCondition directives? selectionSet "
        let fragmentDefinition = zip(
            literal("fragment"),
            tokenSeparator,
            fragmentName,
            tokenSeparator,
            typeCondition,
            tokenSeparator,
            maybe(directives),
            tokenSeparator,
            selectionSet
        ).map { _, _, fragmentName, _, typeCondition, _, directives, _, selectionSet in
            FragmentDefinition(name: fragmentName,
                               typeCondition: typeCondition,
                               directives: directives.wrappedValue ?? [],
                               selectionSet: selectionSet)
        }
        self.fragmentDefinition = fragmentDefinition

        // inlineFragment -> " '...' typeCondition? directives? selectionSet "
        let inlineFragment = zip(
            literal("..."),
            tokenSeparator,
            maybe(typeCondition),
            tokenSeparator,
            maybe(directives),
            tokenSeparator,
            selectionSet
        ).map { _, _, typeCondition, _, directives, _, selectionSet in
            InlineFragment(typeCondition: typeCondition.wrappedValue, directives: directives.wrappedValue ?? [], selectionSet: selectionSet)
        }
        self.inlineFragment = inlineFragment


        // MARK: Document

        // operationType -> [ 'query' 'mutation' 'subscription' ]
        let operationType = oneOf([
            literal("query").map { OperationType.query },
            literal("mutation").map { .mutation },
            literal("subscription").map { .subscription },
        ])
        self.operationType = operationType

        // operationDefinition -> [ " operationType name? variableDefinitions? directives? selectionSet "
        //                          selectionSet ]
        let operationDefinition = oneOf([
            zip(operationType,
                tokenSeparator,
                maybe(name),
                tokenSeparator,
                maybe(variableDefinitions),
                tokenSeparator,
                maybe(directives),
                tokenSeparator,
                maybe(selectionSet)
            ).map { operationType, _, name, _, variableDefinitions, _, directives, _, selectionSet in
                OperationDefinition.operation(definition: OperationDefinition.Operation(
                    operationType: operationType,
                    name: name.wrappedValue,
                    variableDefinitions: variableDefinitions.wrappedValue ?? [],
                    directives: directives.wrappedValue ?? [],
                    selectionSet: selectionSet.wrappedValue ?? []))
            },
            selectionSet.map(OperationDefinition.selectionSet),
        ])
        self.operationDefinition = operationDefinition

        // executableDefinition -> [ operationDefinition fragmentDefinition ]
        let executableDefinition = oneOf([
            operationDefinition.map(ExecutableDefinition.operation),
            fragmentDefinition.map(ExecutableDefinition.fragment),
        ])
        self.executableDefinition = executableDefinition

        // definition -> [ executableDefinition typeSystemDefinition TypeSystemExtension ]
        let definition = oneOf([
            executableDefinition.map(Definition.executable)
            // typeSystemDefinition, // GraphQL schema and other types not supported
            // TypeSystemExtension, // GraphQL schema and other types not supported
        ])
        self.definition = definition

        // document -> { definition }
        let document = oneOrMore(definition, separatedBy: tokenSeparator)
            .map(Document.init)
        self.document = document

        /// Real parsing behaviour for deferred parsers is defined here.
        /// Deferred values are overwritten on `initialise` and then picked up by the canonical `Parser` at runtime.

        valueDeferred = oneOf([
            variableValue,
            stringValue,
            objectValue,
            listValue,
            nullValue,
            booleanValue,
            enumValue,
            floatValue,
            intValue,
        ])

        typeDeferred = oneOf([
            listType,
            nonNullType,
            namedType,
        ])

        selectionDeferred = oneOf([
            field.map(Selection.field),
            fragmentSpread.map(Selection.fragmentSpread),
            inlineFragment.map(Selection.inlineFragment),
        ])
    }

    internal let sourceChar: Parser<Character>
    internal let name: Parser<String>
    internal let whiteSpace: Parser<Void>
    internal let lineTerminator: Parser<Void>
    internal let comma: Parser<Void>
    internal let commentChar: Parser<Character>
    internal let comment: Parser<Void>
    internal let tokenSeparator: Parser<Void>
    internal let value: Parser<Value>
    internal let negativeSign: Parser<Character>
    internal let digit: Parser<Character>
    internal let nonZeroDigit: Parser<Character>
    internal let integerPart: Parser<String>
    internal let intValue: Parser<Value>
    internal let exponentIndicator: Parser<Void>
    internal let sign: Parser<FloatingPointSign>
    internal let fractionalPart: Parser<String>
    internal let exponentPart: Parser<String>
    internal let floatValue: Parser<Value>
    internal let booleanValue: Parser<Value>
    internal let escapedUnicode: Parser<Character>
    internal let escapedCharacter: Parser<Character>
    internal let stringCharacter: Parser<Character>
    internal let stringValue: Parser<Value>
    internal let nullValue: Parser<Value>
    internal let enumValue: Parser<Value>
    internal let listValue: Parser<Value>
    internal let objectField: Parser<ObjectField>
    internal let objectValue: Parser<Value>
    internal let type: Parser<String>
    internal let namedType: Parser<String>
    internal let listType: Parser<String>
    internal let nonNullType: Parser<String>
    internal let defaultValue: Parser<Value>
    internal let variable: Parser<String>
    internal let variableValue: Parser<Value>
    internal let variableDefinition: Parser<VariableDefinition>
    internal let variableDefinitions: Parser<[VariableDefinition]>
    internal let argument: Parser<Argument>
    internal let arguments: Parser<[Argument]>
    internal let directive: Parser<Directive>
    internal let directives: Parser<[Directive]>
    internal let selection: Parser<Selection>
    internal let selectionSet: Parser<[Selection]>
    internal let alias: Parser<String>
    internal let field: Parser<Field>
    internal let fragmentName: Parser<String>
    internal let fragmentSpread: Parser<FragmentSpread>
    internal let typeCondition: Parser<TypeCondition>
    internal let fragmentDefinition: Parser<FragmentDefinition>
    internal let inlineFragment: Parser<InlineFragment>
    internal let operationType: Parser<OperationType>
    internal let operationDefinition: Parser<OperationDefinition>
    internal let executableDefinition: Parser<ExecutableDefinition>
    internal let definition: Parser<Definition>
    internal let document: Parser<Document>
}
