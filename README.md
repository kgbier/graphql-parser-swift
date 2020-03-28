# GraphQLParser
### Konrad Biernacki (<kgbier@gmail.com>)

![Swift](https://github.com/kgbier/graphql-parser-swift/workflows/Swift/badge.svg)

A utility for parsing GraphQL queries. Written with help from the excellent 
[Point·Free](https://www.pointfree.co/collections/parsing).

Current functionality is limited to understanding a GraphQL Query as detailed in the
official [spec](https://spec.graphql.org/June2018/), and producing an AST (abstract syntax tree).

### Limitations:
- Does not support Unicode literals
- Does not support block strings
