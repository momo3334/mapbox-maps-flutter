part of mapbox_maps_flutter;

enum NavigationSessionState {
  idle(name: "idle"),
  freeDrive(name: "freeDrive"),
  overview(name: "overview"),
  activeGuidance(name: "activeGuidance");

  const NavigationSessionState({
    required this.name,
  });

  final String name;

  factory NavigationSessionState.fromString(String name) {
    return NavigationSessionState.values.firstWhereOrNull(
          (value) => value.name.toLowerCase() == name.toLowerCase(),
    ) ??
        NavigationSessionState.idle;
  }
}
