library mapbox_maps_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_maps_flutter/src/navigation/banner_instruction.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:turf/turf.dart' as turf;
import 'package:permission_handler/permission_handler.dart';

export 'package:turf/helpers.dart';

part 'src/annotation/circle_annotation_manager.dart';

part 'src/annotation/point_annotation_manager.dart';

part 'src/annotation/polygon_annotation_manager.dart';

part 'src/annotation/polyline_annotation_manager.dart';

part 'src/annotation/annotation_manager.dart';

part 'src/callbacks.dart';

part 'src/events.dart';

part 'src/map_widget.dart';

part 'src/mapbox_map.dart';

part 'src/mapbox_maps_options.dart';

part 'src/mapbox_maps_platform.dart';

part 'src/navigation/widget/banner_instruction.widget.dart';

part 'src/pigeons/circle_annotation_messenger.dart';

part 'src/pigeons/point_annotation_messenger.dart';

part 'src/pigeons/polygon_annotation_messenger.dart';

part 'src/pigeons/polyline_annotation_messenger.dart';

part 'src/pigeons/map_interfaces.dart';

part 'src/pigeons/messages.g.dart';

part 'src/pigeons/settings.dart';

part 'src/pigeons/gesture_listeners.dart';

part 'src/snapshotter/snapshotter_messenger.dart';

part 'src/pigeons/log_backend.dart';

part 'src/style/layer/background_layer.dart';

part 'src/style/layer/circle_layer.dart';

part 'src/style/layer/fill_extrusion_layer.dart';

part 'src/style/layer/fill_layer.dart';

part 'src/style/layer/heatmap_layer.dart';

part 'src/style/layer/hillshade_layer.dart';

part 'src/style/layer/line_layer.dart';

part 'src/style/layer/location_indicator_layer.dart';

part 'src/style/layer/model_layer.dart';

part 'src/style/layer/raster_layer.dart';

part 'src/style/layer/sky_layer.dart';

part 'src/style/layer/symbol_layer.dart';

part 'src/style/layer/slot_layer.dart';

part 'src/style/layer/raster_particle_layer.dart';

part 'src/style/layer/clip_layer.dart';

part 'src/style/mapbox_styles.dart';

part 'src/style/source/geojson_source.dart';

part 'src/style/source/image_source.dart';

part 'src/style/source/raster_source.dart';

part 'src/style/source/rasterdem_source.dart';

part 'src/style/source/rasterarray_source.dart';

part 'src/style/source/vector_source.dart';

part 'src/style/style.dart';

part 'src/location_settings.dart';

part 'src/snapshotter/snapshotter.dart';

part 'src/log_configuration.dart';

part 'src/turf_adapters.dart';

part 'src/extensions.dart';

part 'src/map_events.dart';

part 'src/offline/offline_messenger.dart';

part 'src/offline/offline_manager.dart';

part 'src/offline/tile_store.dart';

part 'src/offline/offline_switch.dart';

part 'src/utils.dart';

part 'src/navigation/navigation_events.dart';

part 'src/navigation/navigation_map_events.dart';

part 'src/navigation/navigation_manager.dart';

part 'src/navigation/widget/navigation_event_provider.dart';

part 'src/navigation/widget/navigation_manager_consumer.dart';

part 'src/navigation/widget/navigation_event_consumer.dart';

part 'src/navigation/widget/speed_limit_widget.dart';

part 'src/search/PlaceAutocomplete.dart';

part 'src/search/widget/place_autocomplete_search.dart';

part 'src/search/widget/result_list_view.dart';

part 'src/navigation/navigation_session_status.dart';

part 'src/navigation/route_progress_event.dart';

part 'src/navigation/location_matcher_result.dart';

part 'src/navigation/navigation_event_types.enum.dart';

part 'src/navigation/navigation_events_data.dart';

part 'src/navigation/navigation_map.widget.dart';

part 'src/navigation/navigation_events.dart';

part 'src/navigation/navigation_map_events.dart';

part 'src/navigation/navigation_manager.dart';

part 'src/navigation/widget/navigation_event_provider.dart';

part 'src/navigation/widget/navigation_manager_consumer.dart';

part 'src/navigation/widget/navigation_event_consumer.dart';

part 'src/navigation/widget/speed_limit_widget.dart';

part 'src/search/PlaceAutocomplete.dart';

part 'src/search/widget/place_autocomplete_search.dart';

part 'src/search/widget/result_list_view.dart';

part 'src/navigation/navigation_session_status.dart';

part 'src/navigation/route_progress_event.dart';

part 'src/navigation/location_matcher_result.dart';

part 'src/navigation/navigation_event_types.enum.dart';

part 'src/navigation/navigation_events_data.dart';

part 'src/navigation/navigation_map.widget.dart';

part 'src/navigation/navigation_events.dart';

part 'src/navigation/navigation_map_events.dart';

part 'src/navigation/navigation_manager.dart';

part 'src/navigation/widget/navigation_event_provider.dart';

part 'src/navigation/widget/navigation_manager_consumer.dart';

part 'src/navigation/widget/navigation_event_consumer.dart';

part 'src/navigation/widget/speed_limit_widget.dart';

part 'src/search/PlaceAutocomplete.dart';

part 'src/search/widget/place_autocomplete_search.dart';

part 'src/search/widget/result_list_view.dart';

part 'src/navigation/navigation_session_status.dart';

part 'src/navigation/route_progress_event.dart';

part 'src/navigation/location_matcher_result.dart';

part 'src/navigation/navigation_event_types.enum.dart';

part 'src/navigation/navigation_events_data.dart';

part 'src/navigation/navigation_map.widget.dart';
