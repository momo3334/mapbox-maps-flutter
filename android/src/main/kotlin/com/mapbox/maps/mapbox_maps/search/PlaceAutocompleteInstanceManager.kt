package com.mapbox.maps.mapbox_maps.search

import android.annotation.SuppressLint
import android.content.Context
import com.mapbox.maps.mapbox_maps.pigeons._PlaceAutocompleteInstanceManager
import com.mapbox.maps.mapbox_maps.pigeons._PlaceAutocompleteManager
import com.mapbox.search.autocomplete.PlaceAutocomplete
import io.flutter.plugin.common.BinaryMessenger


class PlaceAutocompleteInstanceManager(
  private val context: Context,
  private val messenger: BinaryMessenger,
) : _PlaceAutocompleteInstanceManager {
  @SuppressLint("RestrictedApi")
  override fun setupPlaceAutocompleteManager(channelSuffix: String) {
    val placeAutocomplete = PlaceAutocomplete.create()
    val placeAutocompleteController = PlaceAutocompleteController(context, placeAutocomplete)

    _PlaceAutocompleteManager.setUp(messenger, placeAutocompleteController, channelSuffix)
  }

  override fun tearDownPlaceAutocompleteManager(channelSuffix: String) {
    _PlaceAutocompleteManager.setUp(messenger,null, channelSuffix)
 }
}
