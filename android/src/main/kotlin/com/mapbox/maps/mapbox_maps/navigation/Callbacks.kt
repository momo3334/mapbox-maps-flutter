package com.mapbox.maps.mapbox_maps.navigation

import com.mapbox.navigation.base.route.NavigationRoute

data class RouteLineChangedEvent(
  val navigationRoute: NavigationRoute?
)