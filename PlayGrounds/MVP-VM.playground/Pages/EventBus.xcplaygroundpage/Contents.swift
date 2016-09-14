import Foundation

/**
 #EventBus Pattern Sample
 
 Eventbus should be used between Presenter communication.
 Internal or View to Presenter communication should use direct call methods either initiated from
 Presenter of from View, so it is good when components do not reference each other e.g. View2View 
 or Presenter2Presenter communication.
                            v
                        Presenter3
                            ^
                            |
                            |
                            v
 View1<-->Presenter1<-->EventBus<-->Presenter2<-->View2
 
 the View2Presenter or Presenter2View communicate without events but rather with a "two way communication contract"
 
 1. Presenter --> View Communication. Presenter defines an internal public interface *ViewProtocol*, which includes
 the API the Presenter expects its view to implement. e.g. view.doSomethingOnView()
 
 2. View --> Presenter communication. Presenter can implement an otehr interface for example UiHandlerProtocol and
 sets itself to the View's handlers e.g. view.setUiHandlers(this) if the communicaiton is 1-N communication (1 View and N Presenters)
 or just use direct call methos as it was in the View.
 
 If you would like to use 1 Presenter to different views than you should UiHandler for Presenter instead.
 e.g. 1V-NP View has uihandlers storing a lot Presenter
 or 1P-NV Presenter should has that Uihandlers and setUihandlers method to add View to the listeners for example.
 
 For NP-NP whihc uset this" http://www.gwtproject.org/articles/mvp-architecture.html#events
 "App-wide events are really the only events that you want to be passing around on the Event Bus. The app is uninterested in events such as “the user clicked enter” or “an RPC is about to be made”. Instead (at least in our example app), we pass around events such as a contact being updated, the user switching to the edit view, or an RPC that deleted a user has successfully returned from the server."
 
 See more at: http://www.tikalk.com/gwt-ramblings-flex-developer-view-presenter-communication-events-vs-uihandlers/#sthash.9epLhj2n.dpuf
 
 See more at: http://www.tikalk.com/gwt-ramblings-flex-developer-view-presenter-communication-events-vs-uihandlers/#sthash.Ezi197iE.dpuf
 
 Google I/O 2013 - Demystifying MVP and EventBus in GWT
 Video: https://www.youtube.com/watch?v=kilmaSRq49g

 Source: http://www.codeproject.com/Articles/88390/MVP-VM-Model-View-Presenter-ViewModel-with-Data-Bi

 Source: http://www.codeproject.com/KB/architecture/MVPVMWindowsForms.aspx

 */
class View/*: IView*/ {
    
}


let v = View()






