//+------------------------------------------------------------------+
//|                                                          ptr.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

template<typename T>
class shared_ptr {
private:
   T* m_obj;
   void attach(T* obj) {
      if (CheckPointer(obj) == POINTER_DYNAMIC) {
         obj.refcnt++;
      }
      m_obj = obj;
   }
   void replace(T* obj) {
      T* tmp = m_obj;
      attach(obj);
      detach(tmp);
   }
   void detach(T* obj) {
      if (CheckPointer(m_obj) == POINTER_DYNAMIC) {
         obj.refcnt--;
         if (obj.refcnt == 0) delete obj;
      }
   }
   void detach() {
      if (CheckPointer(m_obj) == POINTER_DYNAMIC) {
         m_obj.refcnt--;
         if (m_obj.refcnt == 0) delete m_obj;
      }
      m_obj = NULL;
   }
public:
   shared_ptr() {
      
   }
   shared_ptr(shared_ptr<T>* other) {
      attach(other.m_obj);
   }
   shared_ptr(shared_ptr<T>& other) {
      attach(other.m_obj);
   }
   shared_ptr(T* obj) {
      attach(obj);
   }
   shared_ptr(T& obj) {
      attach(GetPointer(obj));
   }
   ~shared_ptr() {
      detach();
   }
   T* get() {
      return m_obj;
   }
   void operator=(T* newobj) {
      replace(newobj);
   }
   void operator=(T& newobj) {
      replace(GetPointer(newobj));
   }
   void operator=(shared_ptr<T> newobj) {
      replace(newobj.get());
   }
   void operator=(shared_ptr<T>& newobj) {
      replace(newobj.get());
   }
   T* operator~() {
      return m_obj;
   }
   void reset(T* obj) {
      detach();
      attach(m_obj);
   }
};

template<typename T>
T* AttachPtr(T* obj) {
   if (CheckPointer(obj) == POINTER_DYNAMIC) {
      obj.refcnt++;
   }
   return obj;
}

template<typename T>
void DetachPtr(T* obj) {
   if (CheckPointer(obj) == POINTER_DYNAMIC) {
      obj.refcnt--;
      if (obj.refcnt == 0) delete obj;
   }
}

template<typename T,typename U>
U* ReplacePtr(T* p, U* obj) {
   AttachPtr(obj);
   DetachPtr(p);
   return obj;
}

template<typename T>
string GetObjectName(T* obj) {
   return typename(T);
}

template<typename T>
bool IsInstanceOf(void* obj) {
   T* o = dynamic_cast<T*>(obj);
   return o != NULL;
}