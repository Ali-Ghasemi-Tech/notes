import 'package:flutter/cupertino.dart ' show BuildContext, ModalRoute;

//
extension GetArgument on BuildContext {
  // we are going to return a value of the type "T"
  // and we call this function getArgument

  T? getArgument<T>() {
    // modal route of the build context which gets it from the build
    final modalRoute = ModalRoute.of(this);
    // we need to guard our selves from modal route being null
    if (modalRoute != null) {
      // now we get all the arguments from our modal route
      // and also the args final is an object now
      final args = modalRoute.settings.arguments;
      // we protect our selves from args being null
      //and say if args is a value of givin type "T"
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
// what this code is saying is that if the value of args is
// the same type of the givin type it can be returned
// other wise we return null