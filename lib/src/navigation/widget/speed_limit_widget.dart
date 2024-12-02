part of mapbox_maps_flutter;

class SpeedLimitInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationEvents>(
      builder: (context, navigationEvent, child) {
        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: 52),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    navigationEvent.location?.enhancedLocation?.speed
                        ?.round()
                        .toString() ??
                        "",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                        color: _getSpeedColor(
                            navigationEvent.location?.enhancedLocation?.speed
                                ?.round(),
                            navigationEvent.location?.speedLimit?.speed)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      "km/h",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ),
                  if (navigationEvent.location?.speedLimit?.speed != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          navigationEvent.location?.speedLimit?.speed
                              ?.toString() ??
                              "",
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getSpeedColor(int? currentSpeed, int? speedLimit) {
    if (currentSpeed == null || speedLimit == null) {
      return Colors.black;
    }
    return currentSpeed < speedLimit ? Colors.black : Colors.red;
  }
}
