import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct URLMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let argument = node.argumentList.first else { throw URLMacroErrors.noArgumentsPassed }
    guard let segments = argument.expression.as(StringLiteralExprSyntax.self)?.segments,
          case .stringSegment(let segment)? = segments.first else {
      throw URLMacroErrors.passedNonStringType
    }

    let urlString = segment.content.text
    guard let url = URL(string: urlString), url.isFileURL || (url.host != nil && url.scheme != nil)  else {
      throw URLMacroErrors.invalidURl
    }

    return "URL(string: \(argument))!"
  }
}

fileprivate enum URLMacroErrors: Error, CustomStringConvertible {
  case noArgumentsPassed
  case passedNonStringType
  case invalidURl

  var description: String {
    switch self {
    case .noArgumentsPassed:
      return "safeUrlFrom takes urlString of type String as parameter"
    case .passedNonStringType:
      return "safeUrlFrom takes only string as parameter"
    case .invalidURl:
      return "Please pass a valid url String"
    }
  }
}


@main
struct MyMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    URLMacro.self,
  ]
}
