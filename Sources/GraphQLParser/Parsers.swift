let always = Parser<Void> { _ in () }
func always<A>( _ a: A) -> Parser<A> {
    return Parser<A> { _ in a }
}

//func flatMap<B>(_ f: @escaping (A) -> Parser<B> ) -> Parser<B> {
//    return Parser<B> { str -> B? in
//        let original = str
//        let matchA = self.parse(&str)
//        let parserB = matchA.map(f)
//        guard let matchB = parserB?.parse(&str) else {
//            str = original
//            return nil
//        }
//        return matchB
//    }
//}
func deferred<B>(_ f: @escaping () -> Parser<B> ) -> Parser<B> {
    return Parser<B> { str -> B? in
        f().parse(&str)
    }
}

extension Parser {
    static var never: Parser {
        return Parser { _ in nil }
    }
}

func zeroOrMore<A>(_ p: Parser<A>, separatedBy s: Parser<Void>? = nil) -> Parser<[A]> {
    return Parser<[A]> { str in
        var rest = str
        var matches: [A] = []
        while let match = p.parse(&str) {
            rest = str
            matches.append(match)
            if let s = s, s.parse(&str) == nil {
                return matches
            }
        }
        str = rest
        return matches
    }
}

func oneOrMore<A>(_ p: Parser<A>, separatedBy s: Parser<Void>? = nil) -> Parser<[A]> {
    zeroOrMore(p, separatedBy: s).flatMap { $0.isEmpty ? .never : always($0)}
}

func oneOf<A>(_ ps: [Parser<A>]) -> Parser<A> {
    return Parser<A> { str in
        for p in ps {
            if let match = p.parse(&str) {
                return match
            }
        }
        return nil
    }
}

func notOneOf<A>(_ ps: [Parser<A>]) -> Parser<Void> {
    return Parser<Void> { str in
        for p in ps {
            if p.parse(&str) != nil {
                return nil
            }
        }
        return ()
    }
}

struct Maybe<A> {
    let wrappedValue: A?

    init(_ value: A?) {
        wrappedValue = value
    }
}

func maybe<A>(_ p: Parser<A>) -> Parser<Maybe<A>> {
    return Parser<Maybe<A>> { str in
        if let match = p.parse(&str) {
            return Maybe(match)
        }
        return Maybe(nil)
    }
}

let int = Parser<Int> { str in
    let prefix = str.prefix { $0.isNumber }
    guard let value = Int(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return value
}

let char = Parser<Character> { str in
    guard !str.isEmpty else { return nil }
    return str.removeFirst()
}

func char(of c: Character) -> Parser<Character> {
    return Parser<Character> { str in
        guard str.first == c else { return nil }
        return str.removeFirst()
    }
}

func literal (_ literal: String) -> Parser<Void> {
    return Parser<Void>{ str in
        guard str.hasPrefix(literal) else { return nil }
        str.removeFirst(literal.count)
        return ()
    }
}

func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
    return Parser<Substring> { str in
        let prefix = str.prefix(while: p)
        str.removeFirst(prefix.count)
        return prefix
    }
}
