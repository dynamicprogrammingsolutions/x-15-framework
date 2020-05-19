#property strict

#include "..\order_request_base.mqh"
#include "..\order_request_codes.mqh"
#include "..\symbols.mqh"
#include "..\..\collections.mqh"
#include "..\share\position_details.mqh"

typedef void(*SelectPositionsCallbackFunc)(CPositionDetails* details, void* obj);

class CRequestSelectPositions : public CRequest {

public:
   bool count_only;
   bool filter_by_symbol;
   bool filter_by_magic;
   CSymbol* symbol;
   int filter;
   int magic;
   int cnt;
   SelectPositionsCallbackFunc callback;
   void* callback_obj;
   CIteratorObj<CPositionDetails>* iterator;

   virtual int Type() { return ORDER_REQUEST_SELECT_ORDERS; }
   
   CRequestSelectPositions():
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
   
   CRequestSelectPositions(CRequestSelectPositions* other):
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
   
   CRequestSelectPositions(CRequestSelectPositions& other):
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