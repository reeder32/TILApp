//
//  Category.swift
//  App
//
//  Created by Nick Reeder on 12/22/18.
//

import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}
extension Category: PostgreSQLModel {}

extension Category {
    var acronyms: Siblings<Category,
        Acronym,
        AcronymCategoryPivot> {
        return siblings()
    }
}
