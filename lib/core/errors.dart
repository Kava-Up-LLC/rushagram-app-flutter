/// What can go wrong, in the words the UI needs.
enum FailureKind { noConnection, unexpected }

class AppFailure implements Exception {
  const AppFailure(this.kind, [this.cause]);

  final FailureKind kind;
  final Object? cause;

  String get message => switch (kind) {
        FailureKind.noConnection => 'No connection',
        FailureKind.unexpected => 'Something went wrong. Try again.',
      };

  @override
  String toString() => 'AppFailure($kind, $cause)';
}
