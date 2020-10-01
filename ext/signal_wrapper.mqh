#include "../tradesignal.mqh"
#include "../comments.mqh"

#define SIGNAL_EXECUTION_RUN 1
#define SIGNAL_EXECUTION_ONTICK 2

class CSignalWrapper : public CSignal<int,int> {
protected:
   CSignal<int,int>* m_delegate;

public:
   datetime lastrun;
   bool did_run;
   int signal;
   int last_execution_type;
   string signal_name;

public:
   CSignalWrapper(CSignal<int,int>* delegate, string p_signal_name) : m_delegate(delegate), signal_name(p_signal_name) {
      AttachPtr(m_delegate);
   }
   ~CSignalWrapper() {
      DetachPtr(m_delegate);
   }
   virtual int Run(int bar) {
      this.last_execution_type = SIGNAL_EXECUTION_RUN;
      this.did_run = true;
      this.signal = m_delegate.Run(bar);
      this.lastrun = TimeCurrent();
      return this.signal;
   }
   virtual void OnTick() {
      if (this.last_execution_type == SIGNAL_EXECUTION_ONTICK) this.did_run = false;
      this.last_execution_type = SIGNAL_EXECUTION_ONTICK;
      m_delegate.OnTick();
      addcommentln(this.signal_name,": ",SignalToString(this.signal)," lastrun: ",TimeToString(this.lastrun));
   }
};

CSignal<int,int>* WrapSignal(string name, CSignal<int,int>* signal) {
   return new CSignalWrapper(signal,name);
}