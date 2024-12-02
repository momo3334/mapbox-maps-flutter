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
      child: Consumer<NavigationManager?>(
        builder: (context, _, __) {
          return ChangeNotifierProxyProvider<NavigationManager?,
              NavigationEvents>(
            update: (_, navigationManager, navigationEvents) =>
                navigationManager == null
                    ? navigationEvents!
                    : navigationManager._navigationEvents,
            create: (_) => NavigationEvents(),
            child: child,
          );
        },
      ),
    );
  }
}
