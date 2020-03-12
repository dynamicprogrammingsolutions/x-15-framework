//+------------------------------------------------------------------+
//|                                                          ptr.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

template<typename T>
class ptr {
private:
   T* m_obj;
   void attach(T* obj) {
      if (CheckPointer(obj) == POINTER_DYNAMIC) {
         obj.refcnt++;
      }
      m_obj = obj;
   }
   void detach() {
      if (CheckPointer(m_obj) == POINTER_DYNAMIC) {
         m_obj.refcnt--;
         if (m_obj.refcnt == 0) delete m_obj;
      }
      m_obj = NULL;
   }
public:
   ptr() {
      
   }
   ptr(T* obj) {
      attach(obj);
   }
   ptr(T& obj) {
      attach(GetPointer(obj));
   }
   ~ptr() {
      detach();
   }
   T* get() {
      return m_obj;
   }
   T* operator~() {
      return m_obj;
   }
   void reset(T* obj) {
      detach();
      attach(m_obj);
   }
};
