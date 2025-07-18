package com.mapbox.maps.mapbox_maps.search

import android.content.Context
import com.mapbox.bindgen.Expected
import com.mapbox.maps.mapbox_maps.MapboxEventHandler
import com.mapbox.maps.mapbox_maps.pigeons.GeoPoint
import com.mapbox.maps.mapbox_maps.pigeons.PlaceAutoCompleteSuggestion
import com.mapbox.maps.mapbox_maps.pigeons.PlaceAutocompleteType
import com.mapbox.maps.mapbox_maps.pigeons.RoutablePoint
import com.mapbox.maps.mapbox_maps.pigeons._PlaceAutocompleteManager
import com.mapbox.search.autocomplete.PlaceAutocomplete
import com.mapbox.search.autocomplete.PlaceAutocompleteResult
import com.mapbox.search.autocomplete.PlaceAutocompleteSuggestion
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class PlaceAutocompleteController(
  private val context: Context,
  private val placeAutocomplete: PlaceAutocomplete,
) : _PlaceAutocompleteManager {
  private val scope = CoroutineScope(Dispatchers.Main)
  private var currentSuggestions: List<PlaceAutocompleteSuggestion>? = null;

  override fun suggestions(
    query: String,
    callback: (Result<List<PlaceAutoCompleteSuggestion>>) -> Unit
  ) {
    scope.launch {
      val suggestions = placeAutocomplete.suggestions(query);
      if (suggestions.isValue) {
        currentSuggestions = suggestions.value
        val transformedSuggestions = requireNotNull(suggestions.value).map {
          val coordinates: GeoPoint?;
          if (it.routablePoints != null && it.routablePoints?.isNotEmpty() == true) {
            val routablePoint = it.routablePoints!![0]
            coordinates = GeoPoint(
              type = routablePoint.point.type(),
              coordinates = routablePoint.point.coordinates()
            )
          } else {
            coordinates = it.coordinate?.let { coordinate ->
              GeoPoint(
                type = coordinate.type(),
                coordinates = coordinate.coordinates()
              )
            }
          }

          return@map PlaceAutoCompleteSuggestion(
            name = it.name,
            formattedAddress = it.formattedAddress,
            coordinate = coordinates,
            routablePoints = null,
            makiIcon = it.makiIcon,
            distanceMeters = it.distanceMeters,
            etaMinutes = it.etaMinutes,
            type = PlaceAutocompleteType.PLACE,
            categories = it.categories,
          );
        };
        callback.invoke(Result.success(transformedSuggestions));
      } else {
        callback.invoke(Result.success(emptyList()));
      }
    }
  }

  override fun select(
    index: Long,
    callback: (Result<com.mapbox.maps.mapbox_maps.pigeons.PlaceAutocompleteResult?>) -> Unit
  ) {
    scope.launch {
      if (currentSuggestions != null) {
        val selectedSuggestion = placeAutocomplete.select(currentSuggestions!![index.toInt()]);
        if (selectedSuggestion.isValue) {
          val transformedSuggestionResult =
            com.mapbox.maps.mapbox_maps.pigeons.PlaceAutocompleteResult(
              id = selectedSuggestion.value!!.id,
              mapboxId = selectedSuggestion.value!!.mapboxId,
              name = selectedSuggestion.value!!.name,
              coordinate = selectedSuggestion.value!!.coordinate.let { coordinate ->
                GeoPoint(
                  type = coordinate.type(),
                  coordinates = coordinate.coordinates()
                )
              },
              routablePoints = null,
              makiIcon = selectedSuggestion.value!!.makiIcon,
              distanceMeters = selectedSuggestion.value!!.distanceMeters,
              etaMinutes = selectedSuggestion.value!!.etaMinutes,
              type = PlaceAutocompleteType.PLACE,
              categories = selectedSuggestion.value!!.categories,
              averageRating = selectedSuggestion.value!!.averageRating,
              phone = selectedSuggestion.value!!.phone,
              website = selectedSuggestion.value!!.website,
              reviewCount = selectedSuggestion.value!!.reviewCount?.toLong(),
            )
          callback.invoke(Result.success(transformedSuggestionResult));

        } else {
          callback.invoke(Result.success(null));
        }
      }
    }
  }
}

