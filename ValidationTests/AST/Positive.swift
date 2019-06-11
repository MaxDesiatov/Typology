// declare function #commentsForComments
// This is also a comment
//    but is written over multiple lines.
func first(_ xArg: String) -> String {
  var xStr = xArg
  var yStr: String {
    get {
      return "Hello, "
    }
    set {
      print("world!")
    }
  }
  return xStr
}
