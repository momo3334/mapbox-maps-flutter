part of mapbox_maps_flutter;

class PlaceAutocompleteSearch extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onTapOutside;

  const PlaceAutocompleteSearch({super.key, this.onTap, this.onTapOutside});

  @override
  State<PlaceAutocompleteSearch> createState() =>
      _PlaceAutocompleteSearchState();
}

class _PlaceAutocompleteSearchState extends State<PlaceAutocompleteSearch>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;

  // final Animation<double> opacity = Tween<double>(
  //   begin: 0.0,
  //   end: 1.0,
  // ).animate(
  //   CurvedAnimation(
  //     parent: _animationController,
  //     curve: const Interval(
  //       0.0,
  //       1.0,
  //       curve: Curves.ease,
  //     ),
  //     reverseCurve: const Interval(
  //       0.0,
  //       1.0,
  //       curve: Curves.easeInQuart,
  //     ),
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlaceAutocomplete>(
      future: PlaceAutocomplete.create(),
      builder: (context, placeAutocomplete) {
        return SizedBox(
          width: 300,
          child: TextField(
            onTap: () {
              widget.onTap?.call();
              ResultListView().show(context);
            },
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onTapOutside?.call();
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
            ),
            controller: _controller,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "");

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
