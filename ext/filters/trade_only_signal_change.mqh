#include "../../signals.mqh"

class CTradeOnlySignalChangeState {
public:
   int lastsignal;
   CTradeOnlySignalChangeState(): lastsignal(SIGNAL_NONE) {}
};

template<typename In, typename Out>
int filter_trade_only_signal_change(In bar, CSignal<In,int>* next, void*& _state) {
   if (_state == NULL) {
      _state = new CTradeOnlySignalChangeState();
   }
   CTradeOnlySignalChangeState* state = _state;
   int signal = next.Run(bar);
   if (signal == SIGNAL_NONE) return signal;
   if (signal == state.lastsignal) {
      state.lastsignal = signal;
      return SIGNAL_NO;
   } else {
      state.lastsignal = signal;
      return signal;
   }
}

template<typename In, typename Out>
class CFilterTradeOnlySignalChange : public CFilter<In,Out> {
   void* m_state;
public:
   ~CFilterTradeOnlySignalChange() {
      if (CheckPointer(m_state)==POINTER_DYNAMIC) delete m_state;
   }
   virtual int Apply(In bar, CSignal<In,Out>* next) {
      return filter_trade_only_signal_change<In,Out>(bar,next,m_state);
   }
};