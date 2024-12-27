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
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.14),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: -1,
              ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: Offset(0, 4),
                  blurRadius: 5,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(0, 1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(_getSpeedInKmh(
                      navigationEvent.location?.enhancedLocation?.speed)
                      .toString() ?? "",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                      color: _getSpeedColor(
                          navigationEvent.location?.enhancedLocation?.speed
                          ,
                          navigationEvent.location?.speedLimit?.speed),),
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

  int? _getSpeedInKmh(double? speedMs) {
    if (speedMs == null) {
      return null;
    }
    return (speedMs! * 3.6).round();
  }

  Color _getSpeedColor(double? currentSpeed, int? speedLimit) {
    if (currentSpeed == null || speedLimit == null) {
      return Colors.black;
    }
    return (_getSpeedInKmh(currentSpeed) ?? 0) < speedLimit
        ? Colors.black
        : Colors.red;
  }
}
