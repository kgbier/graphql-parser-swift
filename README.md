# GraphQLParser
### Konrad Biernacki (<kgbier@gmail.com>)

A utility for parsing GraphQL queries.

Current functionality is limited to understanding a GraphQL Query as detailed in the
official [spec](https://spec.graphql.org/June2018/), and producing simple domain specific strings.

### Limitations:
- Does not parse into an AST
- Does not support Unicode literals
- Does not support block strings
