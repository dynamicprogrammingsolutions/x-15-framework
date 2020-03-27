#include "..\..\signals.mqh"
#include "..\tickcounter.mqh"

template<typename In, typename Out>
int filter_trade_only_firsttick(In bar, CSignal<In,Out>* next) {
   if (isfirsttick()) {
      return next.Run(bar);
   } else {
      return SIGNAL_NONE;
   }
}

template<typename In, typename Out>
class CFilterTradeOnlyFirsttick : public CFilter<In,Out> {
public:
   virtual int Apply(In bar, CSignal<In,Out>* next) {
      return filter_trade_only_firsttick<In,Out>(bar,next);
   }
};