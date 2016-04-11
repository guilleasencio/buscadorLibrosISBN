//
//  Libro.swift
//  buscadorLibrosISBN
//
//  Created by Guillermo Asencio Sanchez on 11/4/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import Foundation
import UIKit

class Libro {
    let isbn: String
    let nombre: String
    let autores: String
    let portada: UIImage
    
    init(nombre: String, autores: String, imagen: UIImage, isbn: String){
        self.nombre = nombre
        self.autores = autores
        self.portada = imagen
        self.isbn = isbn
    }
}
