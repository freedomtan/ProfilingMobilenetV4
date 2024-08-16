//
//  ContentView.swift
//  ProfilingMobilenetV4
//
//  Created by Koan-Sin Tan on 8/16/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var dictLoaded = false
    @State private var analyticsDict = Dictionary<AnyHashable, Any>()
    @State private var showMIL = false
    @State private var showSimple = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, profiling!")
            HStack {
                Button("Show MIL") {
                    if (!showMIL) && (showSimple) {
                        showSimple.toggle()
                    }
                    showMIL.toggle()
                }
                Button("Show Simple") {
                    if (!showSimple) && (showMIL) {
                        showMIL.toggle()
                    }
                    showSimple.toggle()
                }
            }

            if (showMIL) {
                if (dictLoaded) {
                    // "at program:line:col" -> program
                    let fileName = ((analyticsDict.first!.key as! String).components(separatedBy: " ")[1]).components(separatedBy: ":")[0]
                    let milString = try! String.init(contentsOfFile: fileName, encoding: String.Encoding.utf8)
                    ScrollView(.vertical) {
                        ScrollView(.horizontal) {
                            Text(milString).font(.system(size:12))
                        }
                    }
                } else {
                    Text("MIL")
                }
            }
            if (showSimple) {
                if (dictLoaded) {
                    // "at program:line:col" -> program
                    // let fileName = ((analyticsDict.first!.key as! String).components(separatedBy: " ")[1]).components(separatedBy: ":")[0]
                    // let milString = try! String.init(contentsOfFile: fileName, encoding: String.Encoding.utf8)
                    ScrollView(.vertical) {
                        ScrollView(.horizontal) {
                            Text(getSimple(d: analyticsDict)).font(.system(size:12))
                        }
                    }
                    
                } else {
                    Text("Simple")
                }
            }
        }
        .padding()
        .task() {
            if (!dictLoaded) {
                analyticsDict = getProfilingDict()
                dictLoaded.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}

func getProfilingDict() -> [AnyHashable: Any] {
    let url = Mobilenetv4.urlOfModelInThisBundle
    
    let configuration = MLModelConfiguration()
    configuration.setProfilingOptions(1)
    
    let mlmodel = try! MLModel(contentsOf: url, configuration: configuration)
    let e5engine = mlmodel.program() as! MLE5Engine
    
    // hack:
    //   cannot get class of e5engine.program (OBJC_$_MLE5ProgramLibary), so hack with dynamic binding
    //   downcast to NSObject to invoke segmentationAnalyticsAndReturnError:
    //    e5engine.programLibrary() as! NSObject
    let d = (e5engine.programLibrary() as! NSObject).segmentationAnalyticsAndReturnError(nil)
    // print(String.init(format: "%@", d!))
    print("loaded")
    
    return d!
}

func getSimple(d: Dictionary<AnyHashable, Any>) -> String {
    let allKeys = d.keys
    let sortedKeys = allKeys.sorted(by: {
        (obj1, obj2) in
       
        let loc_1 = ((obj1 as! String).components(separatedBy: ":")[1] as NSString).integerValue
        let loc_2 = ((obj2 as! String).components(separatedBy: ":")[1] as NSString).integerValue;
        return (loc_1 < loc_2)
    })
    // print(sortedKeys)
    
    var max_backends = 0;
    var all_backends: Array<String> = Array.init()
    
    for e in sortedKeys {
        let backends = (d[e] as! Dictionary<AnyHashable, Any>)["BackendSupport"] as! Dictionary<AnyHashable, Any>
        if (backends.count > max_backends) {
            max_backends = backends.count
            all_backends = backends.map { $0.key } as! [String]
        }
    }
    // print(all_backends)
    
    var toReturn: String = String()
    
    for e in sortedKeys {
        let d_casted = d[e] as! Dictionary<AnyHashable, Any>
        
        let debugName = d_casted["DebugName"] as! String
        let opType = d_casted["OpType"] as! String
        let selectedBackend = d_casted["SelectedBackend"] as! String
        
        var backends = Array<String>();
        var estimateds = Array<String>();
        var errorMessages = Array<String>();
        
        let supportedBackends = (d_casted["BackendSupport"] as! Dictionary<String, Any>).map{$0.key} as! [String]
        let estimated = (d_casted["EstimatedRunTime"] as! Dictionary<AnyHashable, Any>).map{$0.key} as! [String]
        let validationMessages = (d_casted["ValidationMessages"] as! Dictionary<AnyHashable, Any>).map{$0.key} as! [String]
        // print(supportedBackends)
        
        // print(debugName)
        
        for i in 0...max_backends-1 {
            // supportedBackends.contains
            if (supportedBackends.contains(all_backends[i])) {
                backends.append(all_backends[i])
            } else {
                backends.append("")
            }
            
            if (estimated.contains(all_backends[i])) {
                let r = (d_casted["EstimatedRunTime"] as! Dictionary<String, NSNumber>)[all_backends[i]]
                estimateds.append(r!.stringValue)
            } else {
                estimateds.append("")
            }
            
            if (validationMessages.contains(all_backends[i])) {
                let r = (d_casted["ValidationMessages"] as! Dictionary<String, String>)[all_backends[i]]
                errorMessages.append(r!)
            } else {
                errorMessages.append("")
            }
        }
        // print(backends)
        // print(estimateds)
        var entry : String = String()
        entry = entry.appendingFormat("%@, %@, %@, ",  debugName, opType, selectedBackend)
        
        for i in 0...max_backends-1 {
            entry = entry.appendingFormat("%@, ", backends[i])
        }
        for i in 0...max_backends-1 {
            entry = entry.appendingFormat("%@, ", estimateds[i])
        }
        for i in 0...max_backends-2 {
            entry = entry.appendingFormat("%@, ", errorMessages[i])
        }
        entry = entry.appendingFormat("%@\n", errorMessages[max_backends - 1])
        // print(entry)
        toReturn = toReturn.appending(entry)
    }
    return toReturn
}
