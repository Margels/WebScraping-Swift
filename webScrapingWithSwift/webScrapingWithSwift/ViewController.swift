//
//  ViewController.swift
//  webScrapingWithSwift
//
//  Created by Margels on 15/10/22.
//

import UIKit
import Foundation
import SwiftSoup
import Erik

class ViewController: UIViewController {
    
    var strings: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        webScraping()
//        webScrapingWithSwiftSoup()
        webScrapingDynamicWebsites()
    }
    
    func webScraping() {
        
        let string = "https://en.wikipedia.org/wiki/Elizabeth_II"
        let url = URL(string: string)!
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Unable to fetch data.")
                return
            }
            guard let htmlString = String(data: data, encoding: .utf8) else {
                print("Unable to cast data to String.")
                return
            }
            
            print(htmlString)
            
            let startingString = """
            <th colspan="2" class="infobox-header" style="text-align:left">
            """
            let endingString = """
            Signature</th>
            """
            
            if let startOfRange = htmlString.range(of: startingString),
               let endOfRange = htmlString.range(of: endingString) {
                
                let rangeOfData = startOfRange.upperBound..<endOfRange.lowerBound
                let string = htmlString[rangeOfData]
                self.removeHTMLFormat(from: String(string))
            }
            
        }
        task.resume()
        
    }
    
    func removeHTMLFormat(from string: String) {
        
        let strings = string.split(whereSeparator: { $0 == "<" })
        var finalArray = strings
        finalArray.forEach({ s in
            if s.contains(">") {
                var newString = s
                let range = s.startIndex...s.firstIndex(of: ">")!
                newString.removeSubrange(range)
                let oldString = finalArray.firstIndex(of: s)
                finalArray.remove(at: oldString!)
                finalArray.insert(newString, at: oldString!)
            }
            if s == strings.last {
                finalArray.removeAll(where: { $0 == "" })
                print(finalArray)
            }
        })
        
    }
    
    func webScrapingWithSwiftSoup() {
        
        if let content = try? String(contentsOf: URL(string: "https://en.wikipedia.org/wiki/Elizabeth_II")!),
           let doc = try? SwiftSoup.parse(content) {
            let table = try! doc.select("table.infobox").first()!
            let rows = try! table.select("tr")
            let title = try? rows.compactMap { row throws -> String? in
//                print only queen elizabeth's full name
//                let cellWithFullName = try row.select("td.infobox-full-data.nickname")
//                guard cellWithFullName.count == 1, let name = try  cellWithFullName[0].select("td").first() else {
//                    return nil
//                }
//                print(try name.text())
                let cells = try row.select("td.infobox-data")
                guard cells.count == 1, let name = try cells[0].select("td").first() else {
                    return nil
                }
                print(try name.text())
                return try name.text()
            }
            let keywords = ["Prince", "Princess", "King", "Queen"]
            if let title = title {
                let royals = title.filter({ title in
                keywords.contains(where: { title.lowercased().contains($0.lowercased()) })
            })
                print(royals)
            }
        }
    }
    
    func webScrapingDynamicWebsites() {
        guard let url = URL(string: "https://www.youtube.com") else { return }
        let browser = Erik.visit(url: url) { document, error in
            print("title: ", document!.title!)
        }
        
        DispatchQueue.main.async {
            Erik.visit(url: url) { object, error in
                if let e = error {
                    print(e)
                } else if object != nil {
                    Erik.currentContent { (obj, err) -> Void in
                        if let document = obj {
                           // HTML Inspection
                            print(document.title!, document.body!.elements[0])
                        }
                    }
                }
            }
        }
        
    }
    

}

