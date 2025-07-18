package com.mapbox.maps.mapbox_maps.navigation

import android.content.Context
import com.mapbox.maps.mapbox_maps.pigeons.NavigationCameraStates
import com.mapbox.maps.mapbox_maps.pigeons._NavigationCameraManager
import com.mapbox.navigation.ui.maps.camera.NavigationCamera
import com.mapbox.navigation.ui.maps.camera.data.MapboxNavigationViewportDataSource

class NavigationCameraController(
  private val navigationCamera: NavigationCamera,
  private val viewportDataSource: MapboxNavigationViewportDataSource,
  private val context: Context
) : _NavigationCameraManager {
  override fun requestNavigationCameraToOverview() {
    navigationCamera.requestNavigationCameraToOverview()
  }

  override fun requestNavigationCameraToFollowing() {
    navigationCamera.requestNavigationCameraToFollowing()
  }

  override fun getNavigationCameraState(): NavigationCameraStates {
    return NavigationCameraStates.ofRaw(navigationCamera.state.ordinal)
      ?: NavigationCameraStates.IDLE
  }

  override fun followingPitchPropertyOverride(pitch: Double) {
    viewportDataSource.followingPitchPropertyOverride(pitch)
  }

  override fun followingBearingPropertyOverride(bearing: Double) {
    viewportDataSource.followingBearingPropertyOverride(bearing)
  }

  override fun overviewPitchPropertyOverride(pitch: Double) {
    viewportDataSource.overviewPitchPropertyOverride(pitch)
  }

  override fun overviewBearingPropertyOverride(bearing: Double) {
    viewportDataSource.overviewBearingPropertyOverride(bearing)
  }

  override fun overviewZoomPropertyOverride(zoom: Double) {
    viewportDataSource.overviewZoomPropertyOverride(zoom)
  }

  override fun followingZoomPropertyOverride(zoom: Double) {
    viewportDataSource.followingZoomPropertyOverride(zoom)
  }

  override fun clearFollowingOverrides() {
    viewportDataSource.clearFollowingOverrides()
  }

  override fun clearOverviewOverrides() {
    viewportDataSource.clearOverviewOverrides()
  }
}