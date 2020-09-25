import Foundation

extension String {
    /// A Boolean value indicating whether this string is considered snake case.
    ///
    /// For example, the following strings are all snake case:
    ///
    /// - "snake_case"
    /// - "example"
    /// - "date_formatter"
    ///
    /// String can contain lowercase letters and underscores only.
    /// In snake case, words are separated by underscores.
    var isSnakeCase: Bool {
        // Strip all underscores and check if the rest is lowercase
        return self.filter{ $0 != "_" }.allSatisfy { $0.isLowercase || $0.isNumber }
    }
    
    /// A Boolean value indicating whether this string is considered lower camel case.
    ///
    /// For example, the following strings are all lower camel case:
    ///
    /// - "lowerCamelCase"
    /// - "example"
    /// - "dateFormatter"
    ///
    /// String can contain lowercase and uppercase letters only.
    /// In lower camel case, words are separated by uppercase letters.
    var isLowerCamelCase: Bool {
        // Check if the first character is lowercase and the rest contains letters
        if let firstCharacter = self.first, firstCharacter.isLowercase && self.allSatisfy({ $0.isLetter }) {
            return true
        }
        return false
    }
    
    /// A Boolean value indicating whether this string is considered upper camel case.
    ///
    /// For example, the following strings are all upper camel case:
    ///
    /// - "UpperCamelCase"
    /// - "Example"
    /// - "DateFormatter"
    ///
    /// String can contain lowercase and uppercase letters only.
    /// In upper camel case, words are separated by uppercase letters.
    var isUpperCamelCase: Bool {
        // Check if the first character is uppercase and the rest contains letters
        if let firstCharacter = self.first, firstCharacter.isUppercase && self.allSatisfy({ $0.isLetter }) {
            return true
        }
        return false
    }
    
    /// Checks if all characters are letters
    private var isAllLetters: Bool {
        return self.allSatisfy({ $0.isLetter })
    }
}

public extension String {
    /// Splits given string by variations between two characters and
    /// returns and array of strings.
    ///
    /// In this example, `lowercasedStrings` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters.
    private func lowercasedStrings() -> [String] {
        var lastCharacter: Character = " "
        var results: [String] = []
        
        for character in Array<Character>(self) {
            if results.isEmpty && (character.isLetter || character.isNumber) {
                results.append(String(character))
            } else if ((lastCharacter.isLetter || lastCharacter.isNumber) && character.isLowercase) ||
                        (lastCharacter.isNumber && character.isNumber) {
                results[results.count - 1] = results[results.count - 1] + String(character)
            } else if (character.isLetter || character.isNumber) {
                results.append(String(character))
            }
            lastCharacter = character
        }
        
        return results.map { $0.capitalized }
    }
    
    /// Returns a lower camel case version of the string.
    ///
    /// Here's an example of transforming a string to lower camel case.
    ///
    ///     let event = "Keynote Event"
    ///     print(event.lowerCamelCased())
    ///     // Prints "keynoteEvent"
    ///
    /// - Returns: A lower camel case copy of the string.
    func lowerCamelCased() -> String {
        if self.isLowerCamelCase { return self }
        var strings = lowercasedStrings()
        if let firstString = strings.first {
            strings[0] = firstString.lowercased()
        }
        return strings.joined()
    }
    
    /// Returns an upper camel case version of the string.
    ///
    /// Here's an example of transforming a string to upper camel case.
    ///
    ///     let event = "Keynote Event"
    ///     print(event.upperCamelCased())
    ///     // Prints "KeynoteEvent"
    ///
    /// - Returns: An upper camel case copy of the string.
    func upperCamelCased() -> String {
        if self.isUpperCamelCase { return self }
        return lowercasedStrings().joined()
    }
    
    /// Returns snake case version of the string.
    ///
    /// Here's an example of transforming a string to snake case.
    ///
    ///     let event = "Keynote Event"
    ///     print(event.snakeCased())
    ///     // Prints "keynote_event"
    ///
    /// - Returns: A snake case copy of the string.
    func snakeCased() -> String {
        if self.isSnakeCase { return self }
        return lowercasedStrings().map{ $0.lowercased() }.joined(separator: "_")
    }
}
