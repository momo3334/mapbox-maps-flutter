part of mapbox_maps_flutter;

class BannerInstruction extends StatelessWidget {
  const BannerInstruction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationEvents>(
      builder: (context, value, child) {
        if (value.routeProgress?.bannerInstructions == null) {
          return Container();
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xfffffbf6),
                border: Border.all(
                  color: Color(0xffffdeb1),
                  width: 1,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
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
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    // TODO: Convert to font for better vertical baseline alignment (only works with icon fonts).
                    // crossAxisAlignment: CrossAxisAlignment.baseline,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // TODO: Convert to font for better vertical baseline alignment (only works with icon fonts).
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0, left: 16, right: 16,),
                        child: getTurnIcon(
                            type: value.routeProgress?.bannerInstructions
                                ?.primary?.type,
                            modifier: value.routeProgress?.bannerInstructions
                                ?.primary?.modifier,
                            drivingSide: "right"),
                      ),
                      Expanded(
                        child: Text(
                          getText(
                            value.routeProgress?.currentLegProgress
                                ?.currentStepProgress?.distanceRemaining,
                          ),
                          textAlign: TextAlign.left,
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.routeProgress?.bannerInstructions?.primary?.text ??
                          "",
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String getText(double? distance) {
    if (distance == null) {
      return "";
    }

    if (distance < 300) {
      return "${(distance / 10.0).round() * 10}m";
    } else if (distance < 1000) {
      return "${(distance / 50.0).round() * 50}m";
    } else if (distance < 10000) {
      final mod = pow(10.0, 1);
      final roundedDistance =
      (((distance / 1000) * mod).round().toDouble() / mod);
      return "${(roundedDistance).toStringAsFixed(
          (roundedDistance).roundToDouble() == roundedDistance ? 0 : 1)}km";
    } else {
      return "${(distance / 1000).round()}km";
    }
  }

  SvgPicture getTurnIcon(
      {String? type, double? degrees, String? modifier, String? drivingSide}) {
    String assetName;

    // When type == null and modifier == null
    if ((type?.isEmpty ?? true) && (modifier?.isEmpty ?? true)) {
      assetName = "mapbox_ic_turn_straight.svg";
    }
    // When type != null and modifier == null
    else if ((type?.isNotEmpty ?? false) && (modifier?.isEmpty ?? true)) {
      switch (type) {
        case "merge":
        case "turn":
          assetName = "mapbox_ic_turn_straight.svg";
        case "end of road":
          assetName = "mapbox_ic_end_of_road_left.svg";
        default:
          assetName = "mapbox_ic_${type!.replaceAll(" ", "_")}.svg";
      }
    }
    // When type = null and modifier != null
    else if ((type?.isEmpty ?? true) && (modifier?.isNotEmpty ?? false)) {
      if (modifier == "uturn") {
        assetName = "mapbox_ic_uturn.svg";
      } else {
        assetName = "mapbox_ic_turn_${modifier!.replaceAll(" ", "_")}.svg";
      }
    } else {
      if (modifier == "uturn") {
        assetName = "mapbox_ic_uturn.svg";
      } else {
        assetName =
        "mapbox_ic_${type!.replaceAll(" ", "_")}_${modifier!.replaceAll(
            " ", "_")}.svg";
      }
    }
    return SvgPicture.asset("lib/assets/icons/navigation/svg/$assetName",
        package: "mapbox_maps_flutter");
  }
}
