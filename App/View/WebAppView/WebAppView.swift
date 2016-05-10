/*-
 *
 * Author:
 *    Pal Dorogi "ilap" <pal.dorogi@gmail.com>
 *
 * Copyright (c) 2016 Pal Dorogi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Express
import BrightFutures

// Express example: https://github.com/crossroadlabs/Express/blob/master/Demo/main.swift
//
public class WebAppView: GeneralView {
    
    public func show() throws {
    }
    
    var port: UInt16
    var webApp = express()
    
    //let basePath = "/Users/ilap/Developer/Dissertation/WebAppViews"
    

    init(port: UInt16 = 8000) {
        
        self.port = port
        
        webApp.views.register(JsonView())
        // TODO: Mustache does not build on latest Swift
        //webApp.views.register(MustacheViewEngine())
        webApp.views.register(StencilViewEngine())
        
        //TODO: Fix ofr Linux
        guard let basePath = NSBundle.mainBundle().resourcePath else { return }
        
        //Enable for production
        //app.views.cache = true
        webApp.views.register(basePath + "/views")
        
        // StaticAction is just a predefined configurable handler for serving static files.
        // It's important to pass exactly the same param name to it from the url pattern.
        webApp.get("/assets/:file+", action: StaticAction(path: basePath + "/public", param:"file"))
        
        webApp.get("/") { request in
            
            var pams: [Any] = []
            
            
            for pam in PAM.findAll () { //select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [PAM] {
                print ("FINDALL")
                pams.append(self.createDictFromInstance(pam))
            }
            
            var variants: [Any] = []
            
            
            for nuclease in Nuclease.findAll () { //select(selectRequest: Select.SelectAll( OrderOperator.Ascending, ""))! as! [PAM] {
                print ("FINDALL VARIANT")
                variants.append(self.createDictFromInstance(nuclease))
            }
            
            let context:[String: Any] = ["pams": pams, "nucleases": variants]
            
            print ("PAMS \(pams)")
            print ("Nucelases \(variants)")
            
            
            return Action.render("index", context: context)
        }
    }
    
    func createDictFromInstance(instance: CamembertModel) -> [String: Any?]{
        
        let mirror = Mirror(reflecting: instance)
        let children = mirror.children
        
        var dict = ["id" : instance.id as Any?]
        
        for i in children {
            dict[i.label!] = i.value as Any?
        }
        
        return dict
    }
    
    public func execute() {
        print ("Starting webapp on port \(port)")
        
        webApp.listen(port).onSuccess { server in
            print("Design Guide is running on http://127.0.0.1:\(server.port)")
            
        }
        webApp.run()
    }
}




