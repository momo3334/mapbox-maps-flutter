package com.mapbox.maps.mapbox_maps.navigation

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import com.mapbox.api.directions.v5.models.RouteOptions
import com.mapbox.common.location.Location
import com.mapbox.geojson.Point
import com.mapbox.maps.mapbox_maps.SingletonHolder
import com.mapbox.maps.mapbox_maps.pigeons._NavigationManager
import com.mapbox.navigation.base.extensions.applyDefaultNavigationOptions
import com.mapbox.navigation.base.options.NavigationOptions
import com.mapbox.navigation.base.route.NavigationRoute
import com.mapbox.navigation.base.route.NavigationRouterCallback
import com.mapbox.navigation.base.route.RouterFailure
import com.mapbox.navigation.core.MapboxNavigation
import com.mapbox.navigation.core.lifecycle.MapboxNavigationApp
import com.mapbox.navigation.core.lifecycle.MapboxNavigationObserver
import com.mapbox.navigation.core.trip.session.LocationMatcherResult
import com.mapbox.navigation.core.trip.session.LocationObserver
import com.mapbox.navigation.core.trip.session.NavigationSessionState
import com.mapbox.navigation.core.trip.session.NavigationSessionStateObserver
import com.mapbox.navigation.core.trip.session.RouteProgressObserver
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


@SuppressLint("MissingPermission")
class NavigationController(
  private val context: Context,
  private val messenger: BinaryMessenger,
  private val channelSuffix: String,
) : _NavigationManager {
  var eventSink: EventSink? = null
  var eventSinkLocation: EventSink? = null
  var eventSinkNavigationState: EventSink? = null
  var eventSinkDirectionRoute: EventSink? = null
  var navigationControllerEventSink: EventSink? = null
  private var mapboxNavigation: MapboxNavigation? = null
  private var gson: Gson = GsonBuilder().create()

  private var lastLocation: Location? = null

  private val navigationStatusObserver = NavigationSessionStateObserver {
    if (!isOverview) {
      eventSinkNavigationState?.success(gson.toJson(it.javaClass.simpleName))
    } else {
      eventSinkNavigationState?.success(gson.toJson("overview"))
    }
  }
  private var isOverview: Boolean = false

  private var mapboxNavigationObserver =
    object : MapboxNavigationObserver {
      override fun onAttached(mapboxNavigation: MapboxNavigation) {
        //        setupEventChannels()
        MapboxNavigationApp.current()?.registerRouteProgressObserver(routeProgressObserver)
        MapboxNavigationApp.current()?.registerLocationObserver(locationObserver)
        MapboxNavigationApp.current()
          ?.registerNavigationSessionStateObserver(navigationStatusObserver)
      }

      override fun onDetached(mapboxNavigation: MapboxNavigation) {}
    }

  /**
   * Gets notified with location updates.
   *
   * Exposes raw updates coming directly from the location services and the updates enhanced by the
   * Navigation SDK (cleaned up and matched to the road).
   */
  private val locationObserver =
    object : LocationObserver {
      var firstLocationUpdateReceived = false

      override fun onNewRawLocation(rawLocation: Location) {
        // not handled
      }

      override fun onNewLocationMatcherResult(locationMatcherResult: LocationMatcherResult) {
        lastLocation = locationMatcherResult.enhancedLocation
        eventSinkLocation?.success(gson.toJson(locationMatcherResult))
      }
    }

  private val routeProgressObserver = RouteProgressObserver { routeProgress ->
    eventSink?.success(gson.toJson(routeProgress))
  }

  init {
    if (!MapboxNavigationApp.isSetup()) {
      MapboxNavigationApp.setup { NavigationOptions.Builder(context).build() }
    }
    // TODO Implement correct teardown logic to unregister this observer.
    MapboxNavigationApp.registerObserver(mapboxNavigationObserver)
    setupEventChannels()
  }

  private fun setRouteAndStartNavigation(routes: List<NavigationRoute>) {
    // set routes, where the first route in the list is the primary route that
    // will be used for active guidance
    isOverview = true
    MapboxNavigationApp.current()?.setNavigationRoutes(routes)
    //
    //    // show UI elements
    //    binding.soundButton.visibility = View.VISIBLE
    //    binding.routeOverview.visibility = View.VISIBLE
    //    binding.tripProgressCard.visibility = View.VISIBLE
    //
    // move the camera to overview when new route is available
    //    navigationCamera.requestNavigationCameraToOverview()
  }

  private fun setupEventChannels() {
    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#route_progress")
      .setStreamHandler(
        object : EventChannel.StreamHandler {
          override fun onListen(arguments: Any?, sink: EventSink?) {
            eventSink = sink
          }

          override fun onCancel(arguments: Any?) {}
        }
      )
    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#location_update")
      .setStreamHandler(
        object : EventChannel.StreamHandler {
          override fun onListen(arguments: Any?, sink: EventSink?) {
            eventSinkLocation = sink
          }

          override fun onCancel(arguments: Any?) {}
        }
      )
    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#navigation_state")
      .setStreamHandler(
        object : EventChannel.StreamHandler {
          override fun onListen(arguments: Any?, sink: EventSink?) {
            eventSinkNavigationState = sink
          }

          override fun onCancel(arguments: Any?) {}
        }
      )
    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#direction_route")
      .setStreamHandler(
        object : EventChannel.StreamHandler {
          override fun onListen(arguments: Any?, sink: EventSink?) {
            eventSinkDirectionRoute = sink
          }

          override fun onCancel(arguments: Any?) {}
        }
      )
  }

  override fun getHostLanguage(): String {
    TODO("Not yet implemented")
  }

  override fun example() {
    //    navigationCamera.requestNavigationCameraToFollowing()
  }

  override fun setRoute(
    origin: com.mapbox.maps.mapbox_maps.pigeons.GeoPoint,
    destination: com.mapbox.maps.mapbox_maps.pigeons.GeoPoint,
  ) {
    MapboxNavigationApp.current()?.getNavigationSessionState()
    MapboxNavigationApp.current()
      ?.requestRoutes(
        RouteOptions.builder()
          .applyDefaultNavigationOptions()
          .alternatives(true)
          .coordinatesList(
            listOf(
              Point.fromLngLat(lastLocation!!.longitude, lastLocation!!.latitude),
              Point.fromLngLat(destination.coordinates[0], destination.coordinates[1]),
            )
          )
          .layersList(listOf(MapboxNavigationApp.current()?.getZLevel(), null))
          .build(),
        object : NavigationRouterCallback {

          override fun onCanceled(routeOptions: RouteOptions, routerOrigin: String) {
            TODO("Not yet implemented")
          }

          override fun onFailure(reasons: List<RouterFailure>, routeOptions: RouteOptions) {
            // no impl
          }

          override fun onRoutesReady(routes: List<NavigationRoute>, routerOrigin: String) {
            setRouteAndStartNavigation(routes)
          }
        },
      )
  }

  override fun setRouteById(routeId: String) {
    val newNavigationRoute =
      MapboxNavigationApp.current()?.getNavigationRoutes()?.first { it.id == routeId }

    if (newNavigationRoute != null) {
      isOverview = false
      MapboxNavigationApp.current()?.setNavigationRoutes(listOf(newNavigationRoute)) {
        if (it.isValue) {
          val currentNavigationSessionState =
            MapboxNavigationApp.current()!!.getNavigationSessionState()
          eventSinkNavigationState?.success(
            gson.toJson(currentNavigationSessionState.javaClass.simpleName)
          )
        }
      }
    }
  }

  private fun getRealNavigationSessionState(navigationSessionState: NavigationSessionState?) =
    if (navigationSessionState == null) {
      ""
    } else if (!isOverview) {
      navigationSessionState.javaClass.simpleName
    } else {
      "overview"
    }

  override fun cancelRoute() {
    MapboxNavigationApp.current()?.setNavigationRoutes(emptyList())
    isOverview = false
  }

  override fun getNavigationSessionState(): String {
    val navigationSessionState = MapboxNavigationApp.current()?.getNavigationSessionState()
    return getRealNavigationSessionState(navigationSessionState)
  }

  companion object :
    SingletonHolder<NavigationController, Context, BinaryMessenger, String>(::NavigationController)
}
