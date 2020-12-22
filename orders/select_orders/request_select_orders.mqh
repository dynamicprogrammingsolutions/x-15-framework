#property strict

#include "../order_request_base.mqh"
#include "../order_request_codes.mqh"
#include "../symbols.mqh"
#include "../share/pending_order_details.mqh"
#include "../../collections.mqh"

typedef void(*SelectPendingOrdersCallbackFunc)(CPendingOrderDetails* details, void* obj);
typedef bool(*SelectOrdersFilterCallback)(CPendingOrderDetails* details);


class CRequestSelectOrders : public CRequest {

public:
   bool count_only;
   bool filter_by_symbol;
   bool filter_by_magic;
   CSymbol* symbol;
   int filter;
   SelectOrdersFilterCallback filter_callback;
   int magic;
   int cnt;
   SelectPendingOrdersCallbackFunc callback;
   void* callback_obj;
   CIteratorObj<CPendingOrderDetails>* iterator;

   virtual int Type() { return ORDER_REQUEST_SELECT_ORDERS; }
   
   CRequestSelectOrders():
      filter_by_symbol(true),
      filter_by_magic(true),
      symbol(NULL),
      filter(0),
      magic(-1),
      cnt(0),
      callback(NULL),
      callback_obj(NULL),
      iterator(NULL),
      count_only(false)
   {}
   
   CRequestSelectOrders(CRequestSelectOrders* other):
      filter_by_symbol(other.filter_by_symbol),
      filter_by_magic(other.filter_by_magic),
      symbol(other.symbol),
      filter(other.filter),
      magic(other.magic),
      cnt(other.cnt),
      callback(other.callback),
      callback_obj(other.callback_obj),
      iterator(other.iterator),
      count_only(other.count_only)
   {}
   
   CRequestSelectOrders(CRequestSelectOrders& other):
      filter_by_symbol(other.filter_by_symbol),
      filter_by_magic(other.filter_by_magic),
      symbol(other.symbol),
      filter(other.filter),
      magic(other.magic),
      cnt(other.cnt),
      callback(other.callback),
      callback_obj(other.callback_obj),
      iterator(other.iterator),
      count_only(other.count_only)
   {}

};


