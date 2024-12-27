package com.mapbox.maps.mapbox_maps.navigation

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.view.View
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.asynclayoutinflater.view.AsyncLayoutInflater
import androidx.core.content.ContextCompat.getColor
import androidx.core.content.ContextCompat.getDrawable
import cafe.adriel.broker.Broker
import com.mapbox.common.location.Location
import com.mapbox.maps.EdgeInsets
import com.mapbox.maps.ImageHolder
import com.mapbox.maps.MapInitOptions
import com.mapbox.maps.ViewAnnotationAnchor
import com.mapbox.maps.ViewAnnotationAnchorConfig
import com.mapbox.maps.extension.style.expressions.dsl.generated.interpolate
import com.mapbox.maps.extension.style.layers.properties.generated.Visibility
import com.mapbox.maps.mapbox_maps.MapboxMapController
import com.mapbox.maps.mapbox_maps.MapboxMapsPlugin
import com.mapbox.maps.mapbox_maps.pigeons._NavigationCameraManager
import com.mapbox.maps.plugin.LocationPuck2D
import com.mapbox.maps.plugin.PuckBearing
import com.mapbox.maps.plugin.animation.camera
import com.mapbox.maps.plugin.compass.compass
import com.mapbox.maps.plugin.gestures.OnMapClickListener
import com.mapbox.maps.plugin.gestures.addOnMapClickListener
import com.mapbox.maps.plugin.locationcomponent.OnIndicatorPositionChangedListener
import com.mapbox.maps.plugin.locationcomponent.location
import com.mapbox.maps.plugin.scalebar.scalebar
import com.mapbox.maps.viewannotation.OnViewAnnotationUpdatedListener
import com.mapbox.maps.viewannotation.annotatedLayerFeature
import com.mapbox.maps.viewannotation.annotationAnchors
import com.mapbox.maps.viewannotation.viewAnnotationOptions
import com.mapbox.navigation.base.formatter.DistanceFormatterOptions
import com.mapbox.navigation.core.MapboxNavigation
import com.mapbox.navigation.core.directions.session.RoutesObserver
import com.mapbox.navigation.core.directions.session.RoutesUpdatedResult
import com.mapbox.navigation.core.internal.extensions.flowNavigationSessionState
import com.mapbox.navigation.core.lifecycle.MapboxNavigationApp
import com.mapbox.navigation.core.lifecycle.MapboxNavigationObserver
import com.mapbox.navigation.core.trip.session.LocationMatcherResult
import com.mapbox.navigation.core.trip.session.LocationObserver
import com.mapbox.navigation.core.trip.session.RouteProgressObserver
import com.mapbox.navigation.ui.maps.R
import com.mapbox.navigation.ui.maps.camera.NavigationCamera
import com.mapbox.navigation.ui.maps.camera.data.MapboxNavigationViewportDataSource
import com.mapbox.navigation.ui.maps.camera.lifecycle.NavigationBasicGesturesHandler
import com.mapbox.navigation.ui.maps.camera.transition.NavigationCameraTransitionOptions
import com.mapbox.navigation.ui.maps.location.NavigationLocationProvider
import com.mapbox.navigation.ui.maps.route.RouteLayerConstants
import com.mapbox.navigation.ui.maps.route.arrow.api.MapboxRouteArrowApi
import com.mapbox.navigation.ui.maps.route.arrow.api.MapboxRouteArrowView
import com.mapbox.navigation.ui.maps.route.arrow.model.RouteArrowOptions
import com.mapbox.navigation.ui.maps.route.line.api.MapboxRouteLineApi
import com.mapbox.navigation.ui.maps.route.line.api.MapboxRouteLineView
import com.mapbox.navigation.ui.maps.route.line.model.MapboxRouteLineApiOptions
import com.mapbox.navigation.ui.maps.route.line.model.MapboxRouteLineViewOptions
import com.mapbox.navigation.ui.maps.route.line.model.RouteLineColorResources
import io.flutter.plugin.common.BinaryMessenger
import kotlin.math.roundToInt

class NavigationMapController(
  private val context: Context,
  mapInitOptions: MapInitOptions,
  lifecycleProvider: MapboxMapsPlugin.LifecycleProvider,
  messenger: BinaryMessenger,
  channelSuffix: Long,
  pluginVersion: String,
  eventTypes: List<Long>,
) :
  MapboxMapController(
    context,
    mapInitOptions,
    lifecycleProvider,
    messenger,
    channelSuffix,
    pluginVersion,
    eventTypes,
  ) {
  private var navigationMapEventHandler: NavigationMapEventHandler
  private lateinit var viewportDataSource: MapboxNavigationViewportDataSource
  private lateinit var routeLineView: MapboxRouteLineView
  private lateinit var navigationCamera: NavigationCamera
  private var pixelDensity = context.resources.displayMetrics.density
  private val navigationLocationProvider = NavigationLocationProvider()
  private val navigationCameraController: NavigationCameraController
  private val broker: Broker = Broker()
  private var primaryEtaAnnotation: View? = null
  private var altEtaAnnotation: View? = null

  private val overviewPadding: EdgeInsets by lazy {
    EdgeInsets(40.0 * pixelDensity, 40.0 * pixelDensity, 100.0 * pixelDensity, 40.0 * pixelDensity)
  }

  private val followingPadding: EdgeInsets by lazy {
    EdgeInsets(100.0 * pixelDensity, 40.0 * pixelDensity, 140.0 * pixelDensity, 40.0 * pixelDensity)
  }

  /**
   * Generates updates for the [routeLineView] with the geometries and properties of the routes that
   * should be drawn on the map.
   */
  private lateinit var routeLineApi: MapboxRouteLineApi

  // Define distance formatter options
  private val distanceFormatterOptions: DistanceFormatterOptions by lazy {
    DistanceFormatterOptions.Builder(context).build()
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
        val enhancedLocation = locationMatcherResult.enhancedLocation

        // update location puck's position on the map
        navigationLocationProvider.changePosition(
          location = enhancedLocation,
          keyPoints = locationMatcherResult.keyPoints,
        )

        // update camera position to account for new location
        viewportDataSource.onLocationChanged(enhancedLocation)
        viewportDataSource.evaluate()

        // if this is the first location update the activity has received,
        // it's best to immediately move the camera to the current user location
        if (!firstLocationUpdateReceived) {
          firstLocationUpdateReceived = true
          navigationCamera.requestNavigationCameraToOverview(
            stateTransitionOptions =
            NavigationCameraTransitionOptions.Builder()
              .maxDuration(0) // instant transition
              .build()
          )
        }
      }
    }

  /**
   * Generates updates for the [routeArrowView] with the geometries and properties of maneuver
   * arrows that should be drawn on the map.
   */
  private val routeArrowApi: MapboxRouteArrowApi = MapboxRouteArrowApi()

  /** Draws maneuver arrows on the map based on the data [routeArrowApi]. */
  private lateinit var routeArrowView: MapboxRouteArrowView

  private val routeProgressObserver =
    RouteProgressObserver { routeProgress
      -> // update the camera position to account for the progressed fragment of the route
      viewportDataSource.onRouteProgressChanged(routeProgress)
      viewportDataSource.evaluate()

      // draw the upcoming maneuver arrow on the map
      val style = mapView?.mapboxMap?.style
      if (style != null) {
        val maneuverArrowResult = routeArrowApi.addUpcomingManeuverArrow(routeProgress)
        routeArrowView.renderManeuverUpdate(style, maneuverArrowResult)

        routeLineApi.updateWithRouteProgress(routeProgress) { result ->
          routeLineView.renderRouteLineUpdate(style, result)
        }
      }
    }

  /**
   * Gets notified whenever the tracked routes change.
   *
   * A change can mean:
   * - routes get changed with [MapboxNavigation.setNavigationRoutes]
   * - routes annotations get refreshed (for example, congestion annotation that indicate the live
   *   traffic along the route)
   * - driver got off route and a reroute was executed
   */
  private val routesObserver = RoutesObserver { routeUpdateResult ->
    if (routeUpdateResult.navigationRoutes.isNotEmpty()) {
      /**
       * obtain metadata to enhance visualization of alternative routes and hide parts that overlap
       * with the primary route
       */
      val alternativesMetadata =
        MapboxNavigationApp.current()?.getAlternativeMetadataFor(routeUpdateResult.navigationRoutes)
      if (alternativesMetadata != null) {
        // generate route geometries asynchronously and render them
        routeLineApi.setNavigationRoutes(
          routeUpdateResult.navigationRoutes,
          alternativesMetadata,
        ) { value ->
          mapView?.mapboxMap?.style?.apply {
            routeLineView.showAlternativeRoutes(this)
            routeLineView.renderRouteDrawData(this, value)
          }
        }
      }

      val navigationSessionState =
        NavigationController.getInstanceOrNull()?.getNavigationSessionState()

      if (navigationSessionState == "overview") {
        broker.publish(
          RouteLineChangedEvent(navigationRoute = routeUpdateResult.navigationRoutes.first())
        )
      }

      // TODO: add update annotation time when route updates
      updateAnnotations(routeUpdateResult, navigationSessionState)
      observeViewAnnotationUpdate()
      // update the camera position to account for the new route
      viewportDataSource.onRouteChanged(routeUpdateResult.navigationRoutes.first())
      viewportDataSource.evaluate()
    } else {
      // remove the route line and route arrow from the map
      val style = mapView?.mapboxMap?.style
      if (style != null) {
        routeLineApi.clearRouteLine { value ->
          routeLineView.renderClearRouteLineValue(style, value)
        }
        routeArrowView.render(style, routeArrowApi.clearArrows())
      }

      // remove the route reference from camera position evaluations
      viewportDataSource.clearRouteData()
      viewportDataSource.evaluate()
    }
  }

  @SuppressLint("SetTextI18n")
  private fun updateAnnotations(
    routeUpdateResult: RoutesUpdatedResult,
    navigationSessionState: String?,
  ) {

    if (navigationSessionState == "ActiveGuidance") {
      primaryEtaAnnotation?.let { mapView?.viewAnnotationManager?.removeViewAnnotation(it) }
      altEtaAnnotation?.let { mapView?.viewAnnotationManager?.removeViewAnnotation(it) }
      primaryEtaAnnotation = null
      altEtaAnnotation = null
      return
    }

    // primaryRoute
    if (primaryEtaAnnotation == null) {
      mapView
        ?.viewAnnotationManager
        ?.addViewAnnotation(
          resId = com.mapbox.maps.mapbox_maps.R.layout.item_dva_eta,
          options =
          viewAnnotationOptions {
            annotatedLayerFeature("mapbox-layerGroup-1-main")
            annotationAnchors(
              { anchor(ViewAnnotationAnchor.TOP_RIGHT) },
              { anchor(ViewAnnotationAnchor.TOP_LEFT) },
              { anchor(ViewAnnotationAnchor.BOTTOM_RIGHT) },
              { anchor(ViewAnnotationAnchor.BOTTOM_LEFT) },
            )
          },
          asyncInflater = AsyncLayoutInflater(context),
          asyncInflateCallback = { annotationView: View ->
            primaryEtaAnnotation = annotationView
            val findViewById =
              annotationView.findViewById<TextView>(com.mapbox.maps.mapbox_maps.R.id.textNativeView)

            // TODO: add time text formatting
            findViewById.text =
              "${(routeUpdateResult.navigationRoutes.first().directionsRoute.duration() / 60).roundToInt()} min"
          },
        )
    }

    // alternativeRoute
    if (altEtaAnnotation == null && routeUpdateResult.navigationRoutes.size > 1) {
      mapView
        ?.viewAnnotationManager
        ?.addViewAnnotation(
          resId = com.mapbox.maps.mapbox_maps.R.layout.item_dva_eta,
          options =
          viewAnnotationOptions {
            annotatedLayerFeature("mapbox-layerGroup-2-main")
            annotationAnchors(
              { anchor(ViewAnnotationAnchor.TOP_RIGHT) },
              { anchor(ViewAnnotationAnchor.TOP_LEFT) },
              { anchor(ViewAnnotationAnchor.BOTTOM_RIGHT) },
              { anchor(ViewAnnotationAnchor.BOTTOM_LEFT) },
            )
          },
          asyncInflater = AsyncLayoutInflater(context),
          asyncInflateCallback = { annotationView: View ->
            altEtaAnnotation = annotationView
            val findViewById =
              annotationView.findViewById<TextView>(com.mapbox.maps.mapbox_maps.R.id.textNativeView)

            // TODO: add time text formatting
            findViewById.text =
              "${(routeUpdateResult.navigationRoutes[1].directionsRoute.duration() / 60).roundToInt()} min"
          },
        )
    }
  }

  private fun observeViewAnnotationUpdate() {
    mapView
      ?.viewAnnotationManager
      ?.addOnViewAnnotationUpdatedListener(
        object : OnViewAnnotationUpdatedListener {
          override fun onViewAnnotationAnchorUpdated(
            view: View,
            anchor: ViewAnnotationAnchorConfig,
          ) {
            // set different background according to the anchor
            when (view) {
              primaryEtaAnnotation -> {
                view.background =
                  getBackground(
                    anchor,
                    getColor(context, com.mapbox.navigation.ui.components.R.color.colorOnPrimary),
                  )
              }

              altEtaAnnotation -> {
                view.background =
                  getBackground(
                    anchor,
                    getColor(context, com.mapbox.navigation.ui.components.R.color.colorOnPrimary),
                  )
              }

              else -> {
                // no-op
              }
            }
          }
        }
      )
  }

  private fun getBackground(
    anchorConfig: ViewAnnotationAnchorConfig,
    @ColorInt tint: Int,
  ): Drawable {
    var flipX = false
    var flipY = false

    when (anchorConfig.anchor) {
      ViewAnnotationAnchor.BOTTOM_RIGHT -> {
        flipX = true
        flipY = true
      }

      ViewAnnotationAnchor.TOP_RIGHT -> {
        flipX = true
      }

      ViewAnnotationAnchor.BOTTOM_LEFT -> {
        flipY = true
      }

      else -> {
        // no-op
      }
    }

    return BitmapDrawable(
      context.resources,
      drawableToBitmap(
        getDrawable(context, com.mapbox.maps.mapbox_maps.R.drawable.bg_dva_eta)!!,
        flipX = flipX,
        flipY = flipY,
        tint = tint,
      ),
    )
  }

  private fun drawableToBitmap(
    sourceDrawable: Drawable,
    flipX: Boolean = false,
    flipY: Boolean = false,
    @ColorInt tint: Int? = null,
  ): Bitmap {
    return if (sourceDrawable is BitmapDrawable) {
      sourceDrawable.bitmap
    } else {
      // copying drawable object to not manipulate on the same reference
      val constantState = sourceDrawable.constantState!!
      val drawable = constantState.newDrawable().mutate()
      val bitmap =
        Bitmap.createBitmap(
          drawable.intrinsicWidth,
          drawable.intrinsicHeight,
          Bitmap.Config.ARGB_8888,
        )
      tint?.let(drawable::setTint)
      val canvas = Canvas(bitmap)
      drawable.setBounds(0, 0, canvas.width, canvas.height)
      canvas.scale(
        if (flipX) -1f else 1f,
        if (flipY) -1f else 1f,
        canvas.width / 2f,
        canvas.height / 2f,
      )
      drawable.draw(canvas)
      bitmap
    }
  }

  private var mapboxNavigationObserver =
    object : MapboxNavigationObserver {
      override fun onAttached(mapboxNavigation: MapboxNavigation) {
        registerCallbacks()
      }

      override fun onDetached(mapboxNavigation: MapboxNavigation) {}
    }

  private val onPositionChangedListener = OnIndicatorPositionChangedListener { point ->
    val result = routeLineApi.updateTraveledRouteLine(point)
    if (mapView?.mapboxMap?.style != null) {
      routeLineView.renderRouteLineUpdate(mapView!!.mapboxMap.style!!, result)
    }
  }

  private val mapClickListener = OnMapClickListener {
    mapView?.mapboxMap?.style?.apply {
      if (
        routeLineView.getPrimaryRouteVisibility(this) == Visibility.VISIBLE &&
        routeLineView.getAlternativeRoutesVisibility(this) == Visibility.VISIBLE
      ) {
        routeLineApi.findClosestRoute(it, mapView!!.mapboxMap, 30f) {
          if (it.isValue) {
            val primaryRoute = routeLineApi.getPrimaryNavigationRoute()
            if (it.value!!.navigationRoute != routeLineApi.getPrimaryNavigationRoute()) {
              val newNavigationRoutes =
                MapboxNavigationApp.current()?.getNavigationRoutes()?.toMutableList()
              newNavigationRoutes?.set(it.value!!.navigationRoute.routeIndex, primaryRoute!!)
              newNavigationRoutes?.set(0, it.value!!.navigationRoute)
              routeLineApi.setNavigationRoutes(newNavigationRoutes!!) { routeSet ->
                if (routeSet.isValue) {
                  mapView?.mapboxMap?.style?.apply {
                    routeLineView.renderRouteDrawData(this, routeSet)
                    MapboxNavigationApp.current()?.flowNavigationSessionState()
                  }
                }
                broker.publish(RouteLineChangedEvent(navigationRoute = it.value!!.navigationRoute))
              }
            }
          }
        }
      }
    }
    return@OnMapClickListener false
  }

  init {
    // initialize route line, the withRouteLineBelowLayerId is specified to place
    // the route line below road labels layer on the map
    // the value of this option will depend on the style that you are using
    // and under which layer the route line should be placed on the map layers stack
    val mapboxRouteLineApiOptions =
      MapboxRouteLineApiOptions.Builder().vanishingRouteLineEnabled(true)
        .styleInactiveRouteLegsIndependently(true).build()
    routeLineApi = MapboxRouteLineApi(mapboxRouteLineApiOptions)
    val mapboxRouteLineViewOptions =
      MapboxRouteLineViewOptions.Builder(context)
        .routeLineBelowLayerId("road-label-navigation")
        .routeLineColorResources(
          RouteLineColorResources.Builder()
            .routeLineTraveledColor(Color.GRAY)
            .alternativeRouteDefaultColor(Color.GREEN)
            .alternativeRouteClosureColor(Color.MAGENTA)
            .alternativeRouteUnknownCongestionColor(Color.parseColor("#BCCEFB"))
            .alternativeRouteModerateCongestionColor(Color.parseColor("#BCCEFB"))
            .alternativeRouteLowCongestionColor(Color.parseColor("#BCCEFB"))
            .alternativeRouteHeavyCongestionColor(Color.parseColor("#BCCEFB"))
            .alternativeRouteSevereCongestionColor(Color.parseColor("#BCCEFB"))
            .alternativeRouteCasingColor(Color.parseColor("#6A83D7"))
            .build()
        )
        .displaySoftGradientForTraffic(true)
        .build()

    routeLineView = MapboxRouteLineView(mapboxRouteLineViewOptions)

    // initialize Navigation Camera
    viewportDataSource = MapboxNavigationViewportDataSource(mapView!!.mapboxMap)
    navigationCamera = NavigationCamera(mapView!!.mapboxMap, mapView!!.camera, viewportDataSource)

    navigationCameraController = NavigationCameraController(navigationCamera, context)
    _NavigationCameraManager.setUp(messenger, navigationCameraController, this.channelSuffix)

    viewportDataSource.overviewPadding = overviewPadding
    viewportDataSource.followingPadding = followingPadding
    viewportDataSource.followingPadding = followingPadding

    mapView!!.location.puckBearing = PuckBearing.HEADING

    // initialize maneuver arrow view to draw arrows on the map
    val routeArrowOptions =
      RouteArrowOptions.Builder(context)
        .withSlotName(RouteLayerConstants.TOP_LEVEL_ROUTE_LINE_LAYER_ID)
        .build()
    routeArrowView = MapboxRouteArrowView(routeArrowOptions)

    // TODO Implement correct teardown logic to unregister this observer.
    MapboxNavigationApp.registerObserver(mapboxNavigationObserver)

    mapView!!
      .camera
      .addCameraAnimationsLifecycleListener(NavigationBasicGesturesHandler(navigationCamera))
    mapView!!.location.addOnIndicatorPositionChangedListener(onPositionChangedListener)
    mapView!!.location.apply {
      setLocationProvider(navigationLocationProvider)
      this.locationPuck =
        LocationPuck2D(
          bearingImage = ImageHolder.Companion.from(R.drawable.mapbox_navigation_puck_icon),
          scaleExpression =
          interpolate {
            linear()
            zoom()
            stop {
              literal(0)
              literal(0.3)
            }
            stop {
              literal(20.0)
              literal(1.0)
            }
          }
            .toJson(),
        )
      puckBearing = PuckBearing.HEADING
      puckBearingEnabled = true
      enabled = true
    }

    mapView!!.mapboxMap.addOnMapClickListener(mapClickListener)

    navigationMapEventHandler =
      NavigationMapEventHandler(this.broker, messenger, eventTypes, this.channelSuffix)

    mapView!!.scalebar.enabled = false
    mapView!!.compass.enabled = false
  }

  override fun onFlutterViewAttached(flutterView: View) {
    super.onFlutterViewAttached(flutterView)
    MapboxNavigationApp.attach(lifecycleHelper!!)
  }

  @SuppressLint("MissingPermission")
  private fun registerCallbacks() {
    val mapboxNavigation = MapboxNavigationApp.current()!!
    mapboxNavigation.registerRoutesObserver(routesObserver)
    mapboxNavigation.registerLocationObserver(locationObserver)
    mapboxNavigation.registerRouteProgressObserver(routeProgressObserver)
    mapboxNavigation.startTripSession()
  }
}
