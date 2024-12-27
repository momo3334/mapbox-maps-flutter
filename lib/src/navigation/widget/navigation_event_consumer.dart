part of mapbox_maps_flutter;

class NavigationEventConsumer extends StatelessWidget {
  final Widget Function(
      BuildContext context,
      NavigationEvents? value,
      Widget? child,
      ) builder;

  const NavigationEventConsumer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationEvents?>(
      builder: builder,
    );
  }
}
