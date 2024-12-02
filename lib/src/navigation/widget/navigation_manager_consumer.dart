part of mapbox_maps_flutter;

class NavigationManagerConsumer extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    NavigationManager? value,
    Widget? child,
  ) builder;

  const NavigationManagerConsumer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationManager?>(
      builder: builder,
    );
  }
}
