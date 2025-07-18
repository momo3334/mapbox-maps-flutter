package com.mapbox.maps.mapbox_maps

open class SingletonHolder<out T, in A, B>(private val constructor: (A, B) -> T) {

  @Volatile
  private var instance: T? = null

  fun createInstance(argA: A, argB: B): T {
    val newInstance = constructor(argA, argB)
    instance = newInstance
    return newInstance
  }

  fun getInstanceOrNull(): T? = instance
}