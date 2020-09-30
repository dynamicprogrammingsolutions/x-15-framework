#include "stops/stops.mqh"
#include "stops/request_with_stops.mqh"
#include "stops/stops_ticks.mqh"

#define REGISTER_STOPS_FILTER RegisterStopsFilter();

void RegisterStopsFilter() {
   RegisterOrderProcessor(OrderProcessorStops);
}
