//
//  MasterViewController.swift
//  buscadorLibrosISBN
//
//  Created by Guillermo Asencio Sanchez on 11/4/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, buscadorISBNControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var contexto: NSManagedObjectContext? = nil
    
    var libros: Array<Libro> = Array<Libro>()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("petLibros")
        do{
            let librosEntidades = try self.contexto?.executeFetchRequest(peticion!)
            for libro in librosEntidades! {
                let nombre  = libro.valueForKey("nombre") as! String
                let autores = libro.valueForKey("autores") as! String
                let codigoISBN = libro.valueForKey("isbn") as! String
                var imagenPortada = UIImage()
                
                let imagenEntidad = libro.valueForKey("tiene") as! NSObject
                if (imagenEntidad.valueForKey("contenido") != nil){
                    imagenPortada = UIImage(data: imagenEntidad.valueForKey("contenido") as! NSData)!
                }
                
  
                self.libros.append(Libro(nombre: nombre, autores: autores, imagen: imagenPortada, isbn: codigoISBN))

                
            }
        }catch{
            abort()
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        print(self.libros)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
//                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
            let sigVista = segue.destinationViewController as! DetailViewController
            sigVista.libro = self.libros[(self.tableView.indexPathForSelectedRow?.row)!]
            
        }else if segue.identifier == "agregarLibro"{
            
            let sigVista = segue.destinationViewController as! buscardorISBNController
            sigVista.libros = self.libros
            sigVista.contexto = self.contexto
            sigVista.delegate = self
        }
    }
    
    func actualizarLibros(datos: Array<Libro>){
        self.libros = datos
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.libros.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.libros[indexPath.row].nombre
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}

