import XCTest
@testable import GraphQLParser

final class GraphQLParserTests: XCTestCase {

    /// These queries are taken from https://graphql.org/learn/queries/ as reasonable examples to handle

    private func testQuery(_ query: String) {
        let result = GraphQLParser.parseWithResult(query)
        XCTAssertNotNil(result.match)
        XCTAssertEqual("", result.rest)
    }

    func testFields() {
        let query = """
        {
          hero {
            name
            friends {
              name
            }
          }
        }
        """
        testQuery(query)
    }

    // TODO: Comments

    func testArguments() {
        let query = """
        {
          human(id: "1000") {
            name
            height
          }
        }
        """
        testQuery(query)
    }

    func testArgumentsField() {
        let query = """
        {
          human(id: "1000") {
            name
            height(unit: FOOT)
          }
        }
        """
        testQuery(query)
    }

    func testAliases() {
        let query = """
        {
          empireHero: hero(episode: EMPIRE) {
            name
          }
          jediHero: hero(episode: JEDI) {
            name
          }
        }
        """
        testQuery(query)
    }

    func testFragments() {
        let query = """
        {
          leftComparison: hero(episode: EMPIRE) {
            ...comparisonFields
          }
          rightComparison: hero(episode: JEDI) {
            ...comparisonFields
          }
        }

        fragment comparisonFields on Character {
          name
          appearsIn
          friends {
            name
          }
        }
        """
        testQuery(query)
    }

    func testFragmentsWithVariables() {
        let query = """
        query HeroComparison($first: Int = 3) {
          leftComparison: hero(episode: EMPIRE) {
            ...comparisonFields
          }
          rightComparison: hero(episode: JEDI) {
            ...comparisonFields
          }
        }

        fragment comparisonFields on Character {
          name
          friendsConnection(first: $first) {
            totalCount
            edges {
              node {
                name
              }
            }
          }
        }
        """
        testQuery(query)
    }

    func testOperationName() {
        let query = """
        query HeroNameAndFriends {
          hero {
            name
            friends {
              name
            }
          }
        }
        """
        testQuery(query)
    }

    func testVariables() {
        let query = """
        query HeroNameAndFriends($episode: Episode) {
          hero(episode: $episode) {
            name
            friends {
              name
            }
          }
        }
        """
        testQuery(query)
    }

    func testVariablesDefault() {
        let query = """
        query HeroNameAndFriends($episode: Episode = JEDI) {
          hero(episode: $episode) {
            name
            friends {
              name
            }
          }
        }
        """
        testQuery(query)
    }

    func testDirectives() {
        let query = """
        query Hero($episode: Episode, $withFriends: Boolean!) {
          hero(episode: $episode) {
            name
            friends @include(if: $withFriends) {
              name
            }
          }
        }
        """
        testQuery(query)
    }

    func testMutations() {
        let query = """
        mutation CreateReviewForEpisode($ep: Episode!, $review: ReviewInput!) {
          createReview(episode: $ep, review: $review) {
            stars
            commentary
          }
        }
        """
        testQuery(query)
    }

    func testInlineFragment() {
        let query = """
        query HeroForEpisode($ep: Episode!) {
          hero(episode: $ep) {
            name
            ... on Droid {
              primaryFunction
            }
            ... on Human {
              height
            }
          }
        }
        """
        testQuery(query)
    }

    func testMetaFields() {
        let query = """
        {
          search(text: "an") {
            __typename
            ... on Human {
              name
            }
            ... on Droid {
              name
            }
            ... on Starship {
              name
            }
          }
        }
        """
        testQuery(query)
    }
}
