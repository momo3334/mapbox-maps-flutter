package com.mapbox.maps.mapbox_maps

open class SingletonHolder<out T, in A, B, C>(private val constructor: (A, B, C) -> T) {

  @Volatile
  private var instance: T? = null

  fun createInstance(argA: A, argB: B, argC: C): T {
    val newInstance = constructor(argA, argB, argC)
    instance = newInstance
    return newInstance
  }

  fun getInstanceOrNull(): T? = instance
}