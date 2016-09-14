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

/**
 Implements the Model View Presenter ViewModel design pattern.
 
 Implementing Presenter claas
 1. directly invoking methods in the presenter by implementing additional methods
 in the presenter and couples the view with a particular presenter
 2. View raise event as user events occur.
 
 The View and the Presenter hold a reference to each other.
 
 ```
 class View: ViewProtocol {
 ...
 presenter.doSomething()
 ...
 }
 
 class Presenter: PresenterProtocol {
 ...
 func doSomething() {
 view.someProperty = domainObject.doIt(view.someProperty)
 }
 ...
 ```
 */
public class AnyView<T>: ViewProtocol {
    
    var presenter: AnyPresenter<T>
    var optionService: DesignOptionsService

    required public init(presenter: AnyPresenter<T>, optionService: DesignOptionsService) {
        self.presenter = presenter
        self.optionService = optionService
        if self is T {
            self.presenter.view = self as? T
        } else {
            //FIXME: Throw an error
            assertionFailure("\(#file):\(#line) Type error")
        }
        
        // Notify the presenter that the View is initialised.
        presenter.onViewInitialised()
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
