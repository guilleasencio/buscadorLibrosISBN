//
//  DetailViewController.swift
//  buscadorLibrosISBN
//
//  Created by Guillermo Asencio Sanchez on 11/4/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var informacion: UITextView!
    @IBOutlet weak var portada: UIImageView!
    
    var libro: Libro? = nil
    
    var detailItem: AnyObject? {
    didSet {
    // Update the view.
    self.configureView()
    }
    }
    
    func configureView() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.informacion.text = "Título: \n\n\(self.libro!.nombre)\n\nAutor(es):\n\n\(self.libro!.autores)\nISBN: \n\n\(self.libro!.isbn)"
        self.portada.image = self.libro!.portada
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

