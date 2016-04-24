//
//  buscardorISBNController.swift
//  buscadorLibrosISBN
//
//  Created by Guillermo Asencio Sanchez on 11/4/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit
import CoreData

protocol buscadorISBNControllerDelegate: class {
    func actualizarLibros(datos: Array<Libro>)
}

class buscardorISBNController: UIViewController, UITextFieldDelegate{
    
    weak var delegate: buscadorISBNControllerDelegate?
    var contexto: NSManagedObjectContext? = nil
    
    let urlBase = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN"
    
    @IBOutlet weak var respuestaTextView: UITextView!
    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var portada: UIImageView!
    
    var libros: Array<Libro> = Array<Libro>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isbn.delegate = self
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.delegate?.actualizarLibros(self.libros)
    }
    
    func crearImagenEntidad(imagen: UIImage)-> NSObject {
        
        let imagenEntidad = NSEntityDescription.insertNewObjectForEntityForName("Imagen", inManagedObjectContext: self.contexto!)
            imagenEntidad.setValue(UIImagePNGRepresentation(imagen), forKey: "contenido")
        
        return imagenEntidad
    }

    
    @IBAction func textFieldDidEndEditing(textField: UITextField) {
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticionLibro = libroEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petIsbn", substitutionVariables: ["isbn": isbn.text!])
        do{
            let libroPeticion = try self.contexto?.executeFetchRequest(peticionLibro!)
            if (libroPeticion?.count > 0) {
                self.portada.hidden = true
                var informacion: String = ""
                
                let libroResultado = libroPeticion![0]
               
//                let imagenEntidad = libroResultado.valueForKey("tiene") as! Set<NSObject>
//                let imagen = imagenEntidad.first
//                if imagen != nil {
//                    let imagenPortada = UIImage(data: imagen?.valueForKey("contenido") as! NSData)
//                    self.portada.image = imagenPortada
//                    self.portada.hidden = false
//                }
                
                let imagenEntidad = libroResultado.valueForKey("tiene") as! NSObject
                
                if let imagen = imagenEntidad.valueForKey("contenido") {
                
                    let imagenPortada = UIImage(data: imagen as! NSData)
                    self.portada.image = imagenPortada
                    self.portada.hidden = false
                }
                
                let titulo: String = libroResultado.valueForKey("nombre") as! String
                let autores: String = libroResultado.valueForKey("autores") as! String
                
                informacion = "Título: \n\n\(titulo)\n\nAutor(es):\n\n\(autores)"
                self.respuestaTextView.text = informacion
                
            }else{
                let url = NSURL(string: String("\(urlBase):\(isbn.text!)"))
                
                let sesion = NSURLSession.sharedSession()
                
                let bloque = { (datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
                    
                    //Devolver el control al thread principal una vez se tengan los datos
                    dispatch_async(dispatch_get_main_queue()) {
                        if (error?.code) == nil{
                            if let respuestaHTTP = resp as? NSHTTPURLResponse {
                                self.portada.hidden = true
                                switch respuestaHTTP.statusCode {
                                case 200..<400:
                                    
                                    var informacion: String = ""
                                    var imagenPortada = UIImage()
                                    var titulo: String = ""
                                    var autores: String = ""
                                    do{
                                        let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                                        let dico1 = json as! NSDictionary
                                        if let dico2 = dico1["ISBN:\(self.isbn.text!)"] as? NSDictionary{
                                            
                                            let nuevoLibroEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)

                                            
                                            titulo = dico2["title"] as! NSString as String
                                            informacion = "Título: \n\n\(titulo)\n\n"
                                            
                                            if let dico3 = dico2["authors"] as? [NSDictionary] {
                                                
                                                for autor in dico3{
                                                    autores += "\(autor["name"] as! NSString as String)\n"
                                                }
                                                informacion += "Autor(es):\n\n\(autores)"
                                            }
                                            
                                            nuevoLibroEntidad.setValue(titulo, forKey: "nombre")
                                            nuevoLibroEntidad.setValue(autores, forKey: "autores")
                                            nuevoLibroEntidad.setValue(self.isbn.text!, forKey: "isbn")
                                            
                                            //Comprobar si hay portada
                                            
                                            if let dico4 = dico2["cover"] as? NSDictionary{
                                                
                                                let urlImagen = NSURL(string: dico4["medium"] as! NSString as String)
                                                if let imagen = NSData(contentsOfURL: urlImagen!) {
                                                    imagenPortada = UIImage(data: imagen)!
                                                    self.portada.image = imagenPortada
                                                }
                                                self.portada.hidden = false                                            

                                            }
                                        
                                            nuevoLibroEntidad.setValue(self.crearImagenEntidad(imagenPortada), forKey: "tiene")
                                            do{
                                                try self.contexto?.save()
                                                
                                            }catch{
                                                abort()
                                            }
                                            
                                            let nuevoLibro: Libro = Libro(nombre: titulo, autores: autores, imagen: imagenPortada, isbn: self.isbn.text!)
                                            
                                            self.libros.append(nuevoLibro)
                                            
                                            
                                        }else{
                                            informacion = "ISBN no encontrado"
                                        }
                                        
                                        
                                        self.respuestaTextView.text = informacion
                                        
                                        
                                    }catch _ {
                                        print("Error al acceder a los datos")
                                    }
                                    
                                    
                                    break
                                    
                                default:
                                    let alertController = UIAlertController(title: "Error", message:
                                        "Ocurrió un problema al realizar la petición", preferredStyle: UIAlertControllerStyle.Alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                                    
                                    self.presentViewController(alertController, animated: true, completion: nil)
                                }
                            }
                        }else{
                            let alertController = UIAlertController(title: "Error", message:
                                "Ocurrió un problema al realizar la petición", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                    }
                }
                
                let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque)
                dt.resume()

                
            }
            
        }catch{
            abort()
        }
        
        
        
    }
    
    
    @IBAction func textFieldDoneEditing(sender:UITextField)
    {
        sender.resignFirstResponder() //desaparecer el teclado
    }

}
