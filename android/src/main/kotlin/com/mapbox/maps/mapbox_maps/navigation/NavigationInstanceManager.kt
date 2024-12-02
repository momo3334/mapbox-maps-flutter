package com.mapbox.maps.mapbox_maps.navigation

import android.content.Context
import com.mapbox.maps.mapbox_maps.pigeons._NavigationInstanceManager
import com.mapbox.maps.mapbox_maps.pigeons._NavigationManager
import io.flutter.plugin.common.BinaryMessenger

class NavigationInstanceManager(
  private val context: Context,
  private val messenger: BinaryMessenger,
) : _NavigationInstanceManager {
  override fun setupNavigationManager(channelSuffix: String) {
    val navigationController =
      NavigationController.createInstance(context, messenger, channelSuffix)
    _NavigationManager.setUp(messenger, navigationController, channelSuffix)
  }

  override fun tearDownNavigationManager(channelSuffix: String) {
    _NavigationManager.setUp(messenger, null, channelSuffix)
  }
}
