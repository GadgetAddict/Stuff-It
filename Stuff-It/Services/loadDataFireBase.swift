//
//  loadDataFireBase.swift
//  Stuff-It
//
//  Created by Michael King on 4/19/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


import Firebase
import Foundation


class downloadFromFireBase {
    
    
    var item: Item!
    
    func downloadImageFromFirebase(item:Item){
        
        if let itemImageURL = self.item.itemImgUrl {
            
            
            let ref = FIRStorage.storage().reference(forURL: itemImageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("MK: Unable to download image from Firebase storage")
                } else {
                    print("MK: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            
                        }
                    }
                }
            })
        }
    }
    
    
}

/*
class Workout {
     var title: String!
    var workoutText: String!
     
    init(title: String,   workoutText: String) {
   
        self.title = title
        self.workoutText = workoutText
        
    }
    
}

class IceCreamListDataSource: NSObject, UITableViewDataSource
{
    let dataStore = IceCreamStore()
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("IceCreamListDataSource numberOfRows \(dataStore.allItems().count)")

        return dataStore.allItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = dataStore.allItems()[indexPath.row]
        print("IceCreamListDataSource CellForRow \(item.itemName)")

        let cell = tableView.dequeueReusableCell(withIdentifier: "IceCreamListCell", for: indexPath)
        cell.textLabel?.text = item.itemName
        return cell
    }
}



class IceCreamStore
{
     let flavors = ["Vanilla", "Chocolate", "Strawberry", "Coffee", "Cookies & Cream", "Rum Raisins", "Mint Chocolate Chip", "Peanut Butter Cup"]
    
   var items = [Item]()
    let REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")

    
    
    func allItems() -> [Item]
    {
          self.items = []
        REF_ITEMS.observe(.value, with: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                 for snap in snapshots {
                    print("loadFBhelper items Snap: \(snap)")
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let item = Item(itemKey: key, dictionary: itemDict)
                        self.items.append(item)
                    }
                }
            }
        })
        return items
    }
}


class WorkoutDataSource{
    var workouts:[Workout]
    
    init() {
        workouts = []
        let wk1 = Workout(title: "Jumping Jacks",   workoutText: "A calisthenic jump done from a standing position with legs together and arms at the sides to a position with the legs apart and the arms over the head.")
            workouts.append(wk1)
        
        let wk2 = Workout(title: "Wall Sits", workoutText: "A wall sit, also known as a Roman Chair, is an exercise done to strengthen the quadriceps muscles. It is characterized by the two right angles formed by the body, one at the hips and one at the knees.")
        workouts.append(wk2)
        
        
        let wk4 = Workout(title: "Abdominal Crunches",  workoutText: "A crunch begins with lying face up on the floor with knees bent. The movement begins by curling the shoulders towards the pelvis. The hands can be behind or beside the neck or crossed over the chest. Injury can be caused by pushing against the head or neck with hands.")
        workouts.append(wk4)
        
        let wk3 = Workout(title: "Push Ups",  workoutText: "An exercise in which a person lies facing the floor and, keeping their back straight, raises their body by pressing down on their hands.")
        workouts.append(wk3)
  
        
    }
    
    func getWorkOuts() -> [Workout]{
    return workouts
    }
    
}





class ItemFeedDataSource {
  let REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")

    var items = [Item]()
//    var items2: [Item]!

//    var workouts:[Workout]
    
//    init() {
//        items2 = []
//        let wk1 = Item(itemName: "Tree", itemCat: "Christmas", itemSubcat: "Decorations", itemColor: "blue")
//        items2.append(wk1)
//        
//        let wk2 = Item(itemName: "Cat", itemCat: "Christmas", itemSubcat: "Decorations", itemColor: "blue")
//        items2.append(wk2)
//        
//        self.REF_ITEMS.observe(.value, with: { snapshot in
//            
//            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshots {
//                    print("loadFBhelper items Snap: \(snap)")
//                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
//                        let key = snap.key
//                        let item = Item(itemKey: key, dictionary: itemDict)
//                        print("FB Item name \(item.itemName ) ")
//                        
//                        //                    if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> { // FIRDataSnapshot{
//                        //                        let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
//                        //                        let itemBoxKey = childSnapshotDict["itemBoxKey"]
//                        //                        let itemIsBoxed = childSnapshotDict["itemIsBoxed"]
//                        //
//                        //                        //                            print("childSnapshot itemBoxNumber: \(itemBoxNumber)")
//                        //                        item.itemBoxKey = itemBoxKey as! String?
//                        //                        item.itemBoxNum = itemBoxNumber as! String?
//                        //                        item.itemIsBoxed = itemIsBoxed as! Bool
//                        //                    }
//                        
//                        self.items2.append(item)
//                        print("item array count \(self.items2.count)")
//                    }
//                }
//            }})
//    }
    
    
//    func closureReturn( withCompletionHandler:([Item]) -> Void) {
//        let wk1 = Item(itemName: "Tree", itemCat: "Christmas", itemSubcat: "Decorations", itemColor: "blue")
//        //        items2.append(wk1)
//
//        withCompletionHandler([wk1])
//        
//    }
//
//    closureReturn() { (newBoxNumber) -> Void in
//    let counting = newBoxNumber.count
//    print("people: \(counting)")
//    }
//
//    
    
 

    func getFirebase( withCompletionHandler:() -> Void) {
        
    
        self.items = []
    self.REF_ITEMS.observe(.value, with: { snapshot in
        
        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
            for snap in snapshots {
                print("loadFBhelper items Snap: \(snap)")
                if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                    let key = snap.key
                    let item = Item(itemKey: key, dictionary: itemDict)
                    
                    
//                    if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> { // FIRDataSnapshot{
//                        let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
//                        let itemBoxKey = childSnapshotDict["itemBoxKey"]
//                        let itemIsBoxed = childSnapshotDict["itemIsBoxed"]
//                        
//                        //                            print("childSnapshot itemBoxNumber: \(itemBoxNumber)")
//                        item.itemBoxKey = itemBoxKey as! String?
//                        item.itemBoxNum = itemBoxNumber as! String?
//                        item.itemIsBoxed = itemIsBoxed as! Bool
//                    }
                    self.items.append(item)
                }
            }
        }
        
    })
         withCompletionHandler()
    
    }
    
   
//    func getFireBaseItems() -> [Item]{
//        return items2
//    }
    
}
*/
