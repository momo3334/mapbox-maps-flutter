part of mapbox_maps_flutter;

class ResultListView {
  late Function(void Function()) setState;
  List<PlaceAutoCompleteSuggestion>? suggestions;

  Widget _build(BuildContext context) {
    return Consumer<PlaceAutocomplete?>(
      builder: (context, placeAutocomplete, child) =>
          Column(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  autofocus: true,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                  ),
                  onChanged: (value) async {
                    final results =
                    await placeAutocomplete?.suggestions(query: value);
                    setState(() => suggestions = results);
                  },
                ),
              ),
              buildResults(placeAutocomplete),
            ],
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
                    child: _build(stfContext),
                  );
                },
              ),
            ),
      );

  Widget buildResults(PlaceAutocomplete? placeAutocomplete) {
    return ListView.builder(
      shrinkWrap: true,
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestions?[index].name ?? "",
                            textAlign: TextAlign.left,
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium,
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
}
