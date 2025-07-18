package com.mapbox.maps.mapbox_maps.navigation

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.mapbox.api.directions.v5.models.RouteOptions
import com.mapbox.common.location.Location
import com.mapbox.geojson.Point
import com.mapbox.maps.mapbox_maps.SingletonHolder
import com.mapbox.maps.mapbox_maps.pigeons._NavigationManager
import com.mapbox.navigation.base.extensions.applyDefaultNavigationOptions
import com.mapbox.navigation.base.options.NavigationOptions
import com.mapbox.navigation.base.route.NavigationRoute
import com.mapbox.navigation.base.route.NavigationRouterCallback
import com.mapbox.navigation.base.route.RouteRefreshOptions
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
) : _NavigationManager {
  var eventSinkRouteProgress: EventSink? = null
  var eventSinkLocation: EventSink? = null
  var eventSinkNavigationState: EventSink? = null
  var eventSinkDirectionRoute: EventSink? = null
  private var mapboxNavigation: MapboxNavigation? = null
  private var gson: Gson = GsonBuilder().create()
  private var lastLocation: Location? = null
  private var isOverview: Boolean = false

  /**
   * Gets notified with MapboxNavigationSDK updates.
   *
   * Register observers when attached to the MapboxNavigationSDK and unregisters them when detached.
   */
  private var mapboxNavigationObserver = object : MapboxNavigationObserver {
    override fun onAttached(mapboxNavigation: MapboxNavigation) {
      this@NavigationController.mapboxNavigation = mapboxNavigation
      mapboxNavigation.registerRouteProgressObserver(routeProgressObserver)
      mapboxNavigation.registerLocationObserver(locationObserver)
      mapboxNavigation.registerNavigationSessionStateObserver(navigationStatusObserver)
    }

    override fun onDetached(mapboxNavigation: MapboxNavigation) {
      mapboxNavigation.unregisterRouteProgressObserver(routeProgressObserver)
      mapboxNavigation.unregisterLocationObserver(locationObserver)
      mapboxNavigation.unregisterNavigationSessionStateObserver(navigationStatusObserver)
    }
  }

  /**
   * Gets notified with NavigationSessionState updates.
   */
  private val navigationStatusObserver = NavigationSessionStateObserver {
    eventSinkNavigationState?.success(
      gson.toJson(getRealNavigationSessionState(it))
    )
  }

  /**
   * Gets notified with location updates.
   *
   * Exposes raw updates coming directly from the location services and the updates enhanced by the
   * Navigation SDK (cleaned up and matched to the road).
   */
  private val locationObserver = object : LocationObserver {
    override fun onNewRawLocation(rawLocation: Location) {
    }

    override fun onNewLocationMatcherResult(locationMatcherResult: LocationMatcherResult) {
      lastLocation = locationMatcherResult.enhancedLocation
      eventSinkLocation?.success(gson.toJson(locationMatcherResult))
    }
  }

  /**
   * Gets notified with RouteProgress updates.
   */
  private val routeProgressObserver = RouteProgressObserver { routeProgress ->
    eventSinkRouteProgress?.success(gson.toJson(routeProgress))
  }

  init {
    if (!MapboxNavigationApp.isSetup()) {
      MapboxNavigationApp.setup {
        NavigationOptions.Builder(context).routeRefreshOptions(
          routeRefreshOptions = RouteRefreshOptions.Builder()
            .intervalMillis(intervalMillis = 60000L).build(),
        ).build()
      }
    }
    MapboxNavigationApp.registerObserver(mapboxNavigationObserver)
    setupEventChannels()
  }

  fun tearDown() {
    MapboxNavigationApp.unregisterObserver(mapboxNavigationObserver)
    MapboxNavigationApp.disable()
  }


  private fun setRouteAndStartNavigation(routes: List<NavigationRoute>) {
    isOverview = true
    mapboxNavigation?.setNavigationRoutes(routes)
  }

  /**
   * Setups all the Flutter event channels and sinks for the NavigationEvents.
   */
  private fun setupEventChannels() {
      EventChannel(messenger, "com.mapbox.maps.flutter/navigation#route_progress").setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, sink: EventSink?) {
          eventSinkRouteProgress = sink
        }

        override fun onCancel(arguments: Any?) {
          eventSinkRouteProgress = null
        }
      })

    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#location_update").setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, sink: EventSink?) {
          eventSinkLocation = sink
        }

        override fun onCancel(arguments: Any?) {
          eventSinkLocation = null
        }
      })
    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#navigation_state").setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, sink: EventSink?) {
          eventSinkNavigationState = sink
        }

        override fun onCancel(arguments: Any?) {
          eventSinkNavigationState = null
        }
      })
    EventChannel(messenger, "com.mapbox.maps.flutter/navigation#direction_route").setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, sink: EventSink?) {
          eventSinkDirectionRoute = sink
        }

        override fun onCancel(arguments: Any?) {
          eventSinkDirectionRoute = null
        }
      })
  }

  override fun setRoute(
    origin: com.mapbox.maps.mapbox_maps.pigeons.GeoPoint,
    destination: com.mapbox.maps.mapbox_maps.pigeons.GeoPoint,
  ) {
    if (lastLocation == null) {
      return
    }

    mapboxNavigation?.getNavigationSessionState()
    mapboxNavigation?.requestRoutes(
      RouteOptions.builder().applyDefaultNavigationOptions().alternatives(true).coordinatesList(
        listOf(
          Point.fromLngLat(lastLocation!!.longitude, lastLocation!!.latitude),
          Point.fromLngLat(destination.coordinates[0], destination.coordinates[1]),
        )
      ).layersList(listOf(mapboxNavigation?.getZLevel(), null)).build(),
      object : NavigationRouterCallback {

        // TODO: Report back this error to Flutter
        override fun onCanceled(routeOptions: RouteOptions, routerOrigin: String) = Unit

        // TODO: Report back this error to Flutter
        override fun onFailure(reasons: List<RouterFailure>, routeOptions: RouteOptions) = Unit

        override fun onRoutesReady(routes: List<NavigationRoute>, routerOrigin: String) =
          setRouteAndStartNavigation(routes)
      },
    )
  }

  override fun setRouteById(routeId: String) {
    val newNavigationRoute = mapboxNavigation?.getNavigationRoutes()?.first { it.id == routeId }
    if (newNavigationRoute == null) {
      return
    }

    isOverview = false
    mapboxNavigation?.setNavigationRoutes(listOf(newNavigationRoute)) {
      if (it.isValue) {
        val currentNavigationSessionState =
          MapboxNavigationApp.current()!!.getNavigationSessionState()
        eventSinkNavigationState?.success(
          gson.toJson(currentNavigationSessionState.javaClass.simpleName)
        )
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
    mapboxNavigation?.setNavigationRoutes(emptyList())
    isOverview = false
  }

  override fun getNavigationSessionState(): String =
    getRealNavigationSessionState(mapboxNavigation?.getNavigationSessionState())

  companion object :
    SingletonHolder<NavigationController, Context, BinaryMessenger>(::NavigationController)
}
