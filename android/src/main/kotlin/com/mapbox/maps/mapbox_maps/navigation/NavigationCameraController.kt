package com.mapbox.maps.mapbox_maps.navigation

import android.content.Context
import com.mapbox.maps.MapboxMap
import com.mapbox.maps.mapbox_maps.pigeons._NavigationCameraManager
import com.mapbox.navigation.ui.maps.camera.NavigationCamera

class NavigationCameraController(private val navigationCamera: NavigationCamera, private val context: Context): _NavigationCameraManager {
  override fun requestNavigationCameraToOverview() {
    navigationCamera.requestNavigationCameraToOverview()
  }

  override fun requestNavigationCameraToFollowing() {
    navigationCamera.requestNavigationCameraToFollowing()
  }
}