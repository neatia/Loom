/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal struct Sentence {

    let text: String
    let words: [String]

    init(text: String) {
        self.text = text
        self.words = Stemmer.stemmingWordsInText(text)
            .filter { !SentenceSearch.binary(stopwords, target: $0) }
    }

    init(text: String, stopwords: [String] = stopwords) {
        self.text = text
        self.words = Stemmer.stemmingWordsInText(text)
            .filter { !SentenceSearch.binary(stopwords, target: $0) }
    }
}

extension Sentence: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }

    public static func == (lhs: Sentence, rhs: Sentence) -> Bool {
        return lhs.text == rhs.text
    }
}

internal extension String {

    var sentences: [String] {

        var sentences = [String]()
        let range = self.range(of: self)

        self.enumerateSubstrings(in: range!, options: .bySentences) { (substring, _, _, _) in
            sentences.append(substring!)
        }
        return sentences
    }
}
