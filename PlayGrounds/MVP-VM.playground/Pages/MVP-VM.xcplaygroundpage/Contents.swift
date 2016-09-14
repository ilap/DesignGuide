///
/// Model-View-Presenter ViewModel (MVP-VM) Design Pattern implementation.
///
/// two type: Passive View and Passive Presenter (Supervising Controller)
///
/// Two main construction routes: Presener or View first.
///
/// https://github.com/BillKrat/Framework
///
/// Example based on; MVVM for .NET Winforms – MVP-VM (Model View Presenter - View Model) Introduction
/// Great example: http://aviadezra.blogspot.com/2009/08/mvp-mvvm-winforms-data-binding.html
///
///
/// MVP Styles: **Encapsulated Presenter** or **View** styles and the **Opserving Presenter** Style
/// Reference(s): https://lostechies.com/derekgreer/2008/11/23/model-view-presenter-styles/
/// In MVVM you're calling a command on the viewmodel
/// In MVC you're calling an action on a controller
/// In MVP you're calling a method on the presenter.
/// In MVPVM you're calling ???
/// Master-Detail Implementation using ViewModels: Similar impelemntation
/// Reference(s): http://codereview.stackexchange.com/questions/71459/creating-list-viewmodels-in-the-correct-way
///
/// Any Presenter/View Implementation
/// Reference:
///
///
/// Unittest the presenter Example with Fixture: Check MVPQuickstart and MVPCWAQuickstart
/// Reference(s): http://webclientguidance.codeplex.com/wikipage?title=HowToUnitTestPresenter&referringTitle=HowToImplementModelViewPresenterPattern
/// Git Sources(s): https://github.com/albertocsm/open-wscf-2010/blob/master/sources/WCSF2010/
///
/// Great expllanation
/// Read through: https://msdn.microsoft.com/en-us/magazine/hh580734.aspx?f=255&MSPPError=-2147217396
///
/// MVP-VM can be implemented in different ways.
/// But the main goal is to separate the functionalities.
/// This majorly helps to do unit testing and better code maintainability for long run.
///
/// Evolution from MVC->Presentation Model->MVP (Supervising controller or Passive View)
/// Read: http://www.global-webnet.net/blogengine/post/2010/02/05/MVPVM-Model-View-Presenter-View-Model-the-natural-evolution.aspx
/// 
///
/// Simplest Example of MVP-VM
/// REference/Source: http://www.pinfaq.com/6/what-mvpvm-design-pattern-implement-winforms-application

import Foundation

public protocol ViewProtocol {
    func show()
    func showMessage(message: String)
}

public protocol PresenterProtocol {
    associatedtype T
    
    var view: T { get set }
    func onViewInitialised()
    func onViewLoaded()
}

public class AnyPresenter<T>: PresenterProtocol {
    public var view: T? = nil
    
    public func onViewInitialised() {
        // Should not be called directly
        assertionFailure("\(#function) Should not be called directly")
    }
    public func onViewLoaded() {
        // Should not be called directly
        assertionFailure("\(#function) Should not be called directly")
    }
}

/**
 View should implements "Passive View" through interface or
 Supervising controller using events
 */
public class AnyView<T>: ViewProtocol {
    
    var presenter: AnyPresenter<T>
    
    public init(presenter: AnyPresenter<T>) {
        self.presenter = presenter
        if self is T {
            self.presenter.view = self as? T
        } else {
            //FIXME: Throw an error
        }
    }
    
    public func show() {
        // Should not be called directly
        assertionFailure("\(#function) Should not be called directly")
    }
    
    public func showMessage(message: String) {
        // Should not be called directly
        assertionFailure("\(#function) Should not be called directly")
    }
}

/**
 View is nothing but some which are visible to users and its responsibility is to display information to the user and read information from the user.
 Modify the appearance of the screen etc. It should not do anything except this.
 - Note: View will not know anything about the model. So, View does not care about the data source.
 */
protocol ContactViewProtocol {
    func showContacts(ContactViewModelList: [ContactViewModel])
    func readData() -> ContactViewModel
}

class ContactView: AnyView<ContactViewProtocol>, ContactViewProtocol {
    
    override init(presenter: AnyPresenter<ContactViewProtocol>) {
        super.init(presenter: presenter)
    }
    
    func showContacts(ContactViewModelList: [ContactViewModel]) {
        for Contact in ContactViewModelList {
            print(Contact.fullName + " " + String(Contact.age))
        }
    }
    
    func readData() -> ContactViewModel {
        let vm =  ContactViewModel()
        vm.fullName = "Pal Dorogi"
        
        return vm
    }
}

/**
 Presenter will be acting like a bridge between, View, ViewModel and Model.
 This will take care of getting data from Model and pass it to View through View model.
 It may be little confusing because it will look like both ViewModel and Presenter both are doing the same functionality.
 But there is a small difference.
 ViewModel will have only the properties which are used to Bind data to View and hold data that comes from View.
 
 - Note: Presenter will have other implementations to talk to business layer and get domain model and update view model to pass the information to View.
 
 Presenter will not know anything about the view.
 Instead, it will would with an interface which is implemented by the View.
 So, my view can be my Winforms or Unit testing or any other interface which is implementing the same interface.
 */
class ContactPresenter: AnyPresenter<ContactViewProtocol> {
    
    // Buttons on View
    var passwordButton = "PasswordButton";
    var loginAsNewUserButton = "LoginAsNewUserButton";
    
    // Presenters to navigate to
    var contactPresenter = "ContactPresenter";
    var loginPresenter = "LoginPresenter";
    
    //
    // Only the Presenter will be tightly coupled in MVPVM components.
    // It will be tightly coupled to the View, ViewModel and the BLL inter­faces
    //
    func save() {
        
        print("SAVING")
        
        let vm = view?.readData() // From View
        let model = vm?.person // From Model
        
        model?.firstName = "Peter"
        model?.lastName = "Bourne"
        model?.birthDate = "1997-11-29"
    }
}

/**
ViewModel will have only the properties which are used to Bind data to View and hold data that comes from View.

 View Model does not need to have any private properties to hold information.
 Instead it can use the Domain Model properties in the Get and Set method of ViewModel Properties.
 */
class ContactViewModel {
    
    var person: Person
    
    init() {
        self.person = Person(firstName: "Pal", lastName: "Dorogi", birthDate: "1969-12-08")
    }
    
    init(model: Person) {
        self.person = model
    }
    
    var fullName: String {
        get {
            return person.firstName + " " + person.lastName
        }
        set {
            
            let arr = newValue.components( separatedBy: " ")
            person.firstName = arr[0]
            person.lastName = arr[1]
        }
    }
    
    var age: Int {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"
            let date = dateFormatter.date(from: person.birthDate)
            let interval = date?.timeIntervalSinceNow ?? 0
            
            let age = Int(abs(interval) / (365*24*3600))
            return age
        }
    }
}

/**
 Model is nothing but our business object.
 So, this will have properties and functionality which are very specific to Business Domain.
 That is what the responsibility for Model.
 */
class Person {
    var firstName: String
    var lastName: String
    var birthDate: String
    init(firstName: String, lastName: String, birthDate: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
    }
}

//let v = ContactView()
let p = ContactPresenter()
let v = ContactView(presenter: p)

let vm = v.readData()

print(vm.fullName)
vm.fullName = "Elek Viz"

print(vm.fullName)

