public protocol DumpEquatable: Equatable {
    static func == (_ lhs: Self, _ rhs: Self) -> Bool
}

public extension DumpEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        var ldump = ""
        var rdump = ""
        dump(lhs, to: &ldump)
        dump(rhs, to: &rdump)
        return ldump == rdump
    }
}
