package com.mapbox.maps.mapbox_maps.navigation

import cafe.adriel.broker.Broker
import cafe.adriel.broker.BrokerSubscriber
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonElement
import com.google.gson.JsonPrimitive
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import com.google.gson.TypeAdapter
import com.google.gson.TypeAdapterFactory
import com.google.gson.reflect.TypeToken
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonWriter
import com.mapbox.common.Cancelable
import com.mapbox.maps.mapbox_maps.pigeons._NavigationEventTypes
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import java.lang.reflect.Type
import java.util.Date

class NavigationMapEventHandler(
  private val eventProvider: Broker,
  binaryMessenger: BinaryMessenger,
  eventTypes: List<Long>,
  channelSuffix: String,
) : MethodChannel.MethodCallHandler {
  private val channel: MethodChannel
  private val cancellables = HashSet<Cancelable>()
  private val scope = CoroutineScope(Dispatchers.Main)

  private val gson = GsonBuilder()
    .registerTypeAdapter(Date::class.java, MicrosecondsDateTypeAdapter)
    .registerTypeAdapterFactory(EnumOrdinalTypeAdapterFactory)
    .create()

  init {
    val pigeon_channelSuffix = if (channelSuffix.isNotEmpty()) ".$channelSuffix" else ""
    channel =
      MethodChannel(
        binaryMessenger,
        "com.mapbox.maps.flutter.navigation_map_events$pigeon_channelSuffix"
      )
    channel.setMethodCallHandler(this)

    eventTypes.mapNotNull { _NavigationEventTypes.ofRaw(it.toInt()) }
      .forEach { subscribeToEvent(it) }
  }

  override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
    if (methodCall.method == "subscribeToEvents" && methodCall.arguments is List<*>) {
      cancellables.forEach { it.cancel() }
      cancellables.clear()

      val rawEventTypes = methodCall.arguments as List<Long>

      rawEventTypes.mapNotNull { _NavigationEventTypes.ofRaw(it.toInt()) }
        .forEach { subscribeToEvent(it) }
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  private fun subscribeToEvent(event: _NavigationEventTypes) {
    when (event) {
      _NavigationEventTypes.ROUTE_LINE_CHANGED -> eventProvider.subscribe(
        this,
        RouteLineChangedEvent::class,
        scope = scope,
      ) {
        channel.invokeMethod(event.methodName, gson.toJson(it))
      }
    }
  }
}

object EnumOrdinalTypeAdapterFactory : TypeAdapterFactory {
  override fun <T : Any?> create(gson: Gson?, type: TypeToken<T>?): TypeAdapter<T>? {
    if (type == null || !type.rawType.isEnum) {
      return null
    }

    return EnumOrdinalTypeAdapter()
  }
}

object MicrosecondsDateTypeAdapter : JsonSerializer<Date> {
  override fun serialize(
    src: Date,
    typeOfSrc: Type?,
    context: JsonSerializationContext?
  ): JsonElement {
    return JsonPrimitive(src.time * 1000)
  }
}

class EnumOrdinalTypeAdapter<T>() : TypeAdapter<T>() {
  override fun write(out: JsonWriter?, value: T) {
    out?.value((value as Enum<*>).ordinal)
  }

  override fun read(`in`: JsonReader?): T {
    throw NotImplementedError("Not supported")
  }
}

private val _NavigationEventTypes.methodName: String
  get() = "event#$ordinal"
