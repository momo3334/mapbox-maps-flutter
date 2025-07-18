part of mapbox_maps_flutter;

class ResultListView {
  late Function(void Function()) setState;
  List<PlaceAutoCompleteSuggestion>? suggestions;
  final Color? textFieldBorderColor;
  final Color? textFieldFocusedBorderColor;
  final Color? textFieldColor;

  ResultListView(
      {this.textFieldFocusedBorderColor, this.textFieldBorderColor, this.textFieldColor,});

  Widget _build(BuildContext context) {
    return Consumer<PlaceAutocomplete?>(
      builder: (context, placeAutocomplete, child) =>
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    filled: true,
                    fillColor: textFieldColor ?? Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: textFieldBorderColor ?? Color(0xFF000000),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: textFieldFocusedBorderColor ?? Color(0xFF000000),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                  ),
                  onChanged: (value) async {
                    final results =
                    await placeAutocomplete?.suggestions(query: value);
                    setState(() => suggestions = results);
                  },
                ),
                Expanded(
                  child: buildResults(placeAutocomplete),
                ),
              ],
            ),
          ),
    );
  }

  Future<PlaceAutocompleteResult?> show(parentContext) =>
      showDialog(
        context: parentContext,
        builder: (context) =>
            FutureProvider<PlaceAutocomplete?>(
              initialData: null,
              create: (context) => PlaceAutocomplete.create(),
              child: StatefulBuilder(
                builder: (stfContext, stfSetState) {
                  setState = stfSetState;
                  return Dialog.fullscreen(
                    backgroundColor: Colors.white,
                    child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        body: _build(stfContext)),
                  );
                },
              ),
            ),
      );

  Widget buildResults(PlaceAutocomplete? placeAutocomplete) {
    return ListView.builder(
      cacheExtent: double.infinity,
      itemCount: suggestions?.length ?? 0,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            final result = await placeAutocomplete?.select(index: index);
            Navigator.of(context).pop(result);
          },
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      _getIcon(suggestions?[index].type),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  suggestions?[index].name ?? "",
                                  textAlign: TextAlign.left,
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (suggestions?[index].distanceMeters != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    "\u2022",
                                    textAlign: TextAlign.left,
                                    style:
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              Text(
                                getText(suggestions?[index].distanceMeters),
                                textAlign: TextAlign.left,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            textAlign: TextAlign.left,
                            suggestions?[index].formattedAddress ?? "",
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (index != suggestions!.length - 1)
                Divider(
                  height: 5,
                ),
            ],
          ),
        );
      },
    );
  }

  IconData? _getIcon(PlaceAutocompleteType? type) {
    switch (type) {
      case null:
        return Icons.location_on;
      case PlaceAutocompleteType.country:
        return Icons.flag;
      case PlaceAutocompleteType.region:
        return Icons.location_on;
      case PlaceAutocompleteType.postcode:
        return Icons.location_on;
      case PlaceAutocompleteType.district:
        return Icons.location_on;
      case PlaceAutocompleteType.place:
        return Icons.location_on;
      case PlaceAutocompleteType.locality:
        return Icons.location_city;
      case PlaceAutocompleteType.neighborhood:
        return Icons.location_on;
      case PlaceAutocompleteType.street:
        return Icons.location_on;
      case PlaceAutocompleteType.address:
        return Icons.location_on;
    }
  }

  // TODO: Extract this as a distance formatter class.
  String getText(double? distance) {
    if (distance == null) {
      return "";
    }

    if (distance < 300) {
      return "${(distance / 10.0).round() * 10}m";
    } else if (distance.round() < 1000) {
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
}
