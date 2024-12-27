part of mapbox_maps_flutter;

class NavigationEventProvider extends StatelessWidget {
  final Widget child;

  const NavigationEventProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<NavigationManager?>(
      initialData: null,
      create: (BuildContext context) =>
          NavigationManager.createWithEventStreams(),
      child: ChangeNotifierProxyProvider<NavigationManager?, NavigationEvents>(
        lazy: false,
        update: (_, navigationManager, navigationEvents) {
          if (navigationManager == null) {
            return navigationEvents!;
          } else {
            return navigationEvents!.._setupEventStreams(navigationManager);
          }
        },
        create: (_) {
          return NavigationEvents();
        },
        child: child,
      ),
    );
  }
}
