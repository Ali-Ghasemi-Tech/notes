// this is a stream of things that have to pass throgh a test
// one by one and that test is our function
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
