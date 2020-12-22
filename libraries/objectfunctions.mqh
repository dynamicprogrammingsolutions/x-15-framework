//

#include "strfunctions.mqh"

#ifdef __MQL5__
#include "objectfunctions_MT5.mqh"
#else

string recent_objname;
int window_idx = 0;
bool obj_force_color = false;

int delobj_retry = 20;
int delobj_wait = 500;

string objstorefilename = "objstore.dat";
int objstorehandle;
bool obj_usefile = false;
int objfile_namesize = 32;
int objfile_valuesize = 32;

int testline_idx = 0;
string testline_name[];
double testline_price[];
string testline_description[];

int obj_window = 0;
bool obj_load_remove = false;

bool objectsallowed()
{
   return(!IsTesting() || IsVisualMode());
}

int objtotal()
{
   return(ObjectsTotal()+ArraySize(testline_name));
}

string objname(int pos)
{
   if (pos < ObjectsTotal()) return(ObjectName(pos));
   return("");
}

bool line_rename(string oldname, string newname)
{
   if (ObjectFind(oldname) < 0) return(false);
   int type = ObjectType(oldname);
   double price1 = ObjectGet(oldname,OBJPROP_PRICE1);
   double price2 = ObjectGet(oldname,OBJPROP_PRICE2);
   datetime time1 = (datetime)ObjectGet(oldname,OBJPROP_TIME1);
   datetime time2 = (datetime)ObjectGet(oldname,OBJPROP_TIME2);
   string desc = ObjectDescription(oldname);
   color cl = (color)ObjectGet(oldname,OBJPROP_COLOR);
   ObjectDelete(oldname);
   if (ObjectFind(newname) < 0) {
      ObjectCreate(newname,type,window_idx,time1,price1,time2,price2);
      ObjectSet(newname,OBJPROP_COLOR,cl);
      ObjectSetText(newname,desc,0);
   } else {
      ObjectSet(newname,OBJPROP_PRICE1,price1);
      ObjectSet(newname,OBJPROP_PRICE2,price2);
      ObjectSet(newname,OBJPROP_TIME1,time1);
      ObjectSet(newname,OBJPROP_TIME2,time2);
      ObjectSet(newname,OBJPROP_COLOR,cl);
      ObjectSetText(newname,desc,0);
   }
   return(true);
}

void obj_delete_all(string stringfind)
{
   for (int i = ObjectsTotal()-1; i >= 0; i--) {
      if (StringFind(ObjectName(i),stringfind)>=0) ObjectDelete(ObjectName(i));
   }
}

bool hline_put(string name, double price, color cl, int ticket = -1, int width = -1)
{
   if (name == "") {
      Print("hline_put: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
      
   recent_objname = name;
 
   if (ObjectFind(name) == -1)
   {
      ObjectCreate(name,OBJ_HLINE,window_idx,0,price);
      ObjectSet(name,OBJPROP_COLOR,cl);
      if (width >= 0) ObjectSet(name,OBJPROP_WIDTH,width);
      return(true);
   }
   else
   {
      if (ObjectType(name) == OBJ_HLINE) {
         ObjectSet(name,OBJPROP_PRICE1,price);
         if (width >= 0) ObjectSet(name,OBJPROP_WIDTH,width);
         if (obj_force_color) ObjectSet(name,OBJPROP_COLOR,cl);         
      }
      return(false);
   }
}

bool tline_put(string in_symbol, int in_timeframe, string name, double price1, int bar1, double price2, int bar2, color cl, int ticket = -1, int width = -1)
{
   if (name == "") {
      Print("tline_put: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
   recent_objname = name;
  
   datetime time1 = iTime(in_symbol,in_timeframe,bar1);
   datetime time2 = iTime(in_symbol,in_timeframe,bar2);
  
   if (ObjectFind(name) == -1)
   {
      ObjectCreate(name,OBJ_TREND,window_idx,time1,price1,time2,price2);
      ObjectSet(name,OBJPROP_COLOR,cl);
      if (width >= 0) ObjectSet(name,OBJPROP_WIDTH,width);
      return(true);
   }
   else
   {
      if (ObjectType(name) == OBJ_TREND) {
         ObjectSet(name,OBJPROP_PRICE1,price1);
         ObjectSet(name,OBJPROP_PRICE2,price2);
         ObjectSet(name,OBJPROP_TIME1,time1);
         ObjectSet(name,OBJPROP_TIME2,time2);
         if (obj_force_color) ObjectSet(name,OBJPROP_COLOR,cl);         
      }
      return(false);
   }
}

void delete_all_mt4arrows()
{
   for (int i = 0; i < ObjectsTotal(); i++) {
      string objname = ObjectName(i);
      int start, end;
      string ordervalue = str_getvalue_startend(objname,"#"," ",start,end);
      if (start == 1 && (ordervalue=="0" || StrToDouble(ordervalue) > 0)) ObjectDelete(objname);
   }
}

bool line_beingdragged(string name, int ticket = -1)
{
   return(hline_beingdragged(name, ticket));
}

bool hline_beingdragged(string name, int ticket = -1)
{
   if (name == "") {
      Print("hline_beingdragged: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
   double price = ObjectGet(name,OBJPROP_PRICE1);
   double priceto = MathRound((price+Point)/Point)*Point;
   ObjectSet(name,OBJPROP_PRICE1,priceto);
   double price1 = ObjectGet(name,OBJPROP_PRICE1);
   if (price1 == priceto) {
      ObjectSet(name,OBJPROP_PRICE1,price);
      return(false);
   } else {
      return(true);
   }
}

void draw_box(string name, datetime time1, datetime time2, double price1, double price2, color cl = -1)
{
   obj_put(name, OBJ_RECTANGLE, time1, price1, time2, price2, 0, 0, -1, cl);
}

bool obj_put(string name, int type, datetime time1, double price1, datetime time2=0, double price2=0, datetime time3=0, double price3=0, int ticket = -1, color cl = clrNONE)
{
   if (name == "") {
      Print("obj_put: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
   recent_objname = name;
   ObjectDelete(name);
   ObjectCreate(name,type,obj_window,time1,price1,time2,price2,time3,price3);
   if (cl != clrNONE) {
      ObjectSet(name,OBJPROP_COLOR,cl);
   }
   return(true);
}

bool arrow_put(string name, datetime time1, double price1, int arrowcode, color cl, int ticket = -1)
{
   if (name == "") {
      Print("arrow_put: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
   obj_put(name,OBJ_ARROW,time1,price1,0,0,0,0,-1,cl);
   ObjectSet(name,OBJPROP_ARROWCODE,arrowcode);
   return(true);
}

bool objfind(string name,int ticket = -1)
{
   if (name == "") {
      Print("objfind: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) >= 0) return(true);
   else return(false);
}

bool obj_set(int prop, double value)
{
   if (recent_objname == "") {
      Print("obj_set: empty name");
      return(false);
   }
   ObjectSet(recent_objname,prop,value);
   return(true);
}

double hline_get(string name, int ticket = -1)
{
   if (name == "") {
      Print("hline_get: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
      
   if (ObjectFind(name) == -1)
      return(-1);
   else
      return(ObjectGet(name,OBJPROP_PRICE1));
}

double line_get(string name, int ticket = -1, int in_bar = 0)
{
   if (name == "") {
      Print("line_get: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);

   if (ObjectFind(name) == -1) return(-1);
   
   int type = ObjectType(name);

   if (type == OBJ_HLINE)
    return(ObjectGet(name,OBJPROP_PRICE1));

   if (type == OBJ_TREND)
    return(ObjectGetValueByShift(name,in_bar));

   return(-1);
}

bool change_hline_to_trendline(string name, int bar_start = 5, int bar_end = 0, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) == -1) return(false);
   double price = line_get(name);
   color cl = (color)ObjectGet(name,OBJPROP_COLOR);
   datetime time1 = iTime(Symbol(),0,bar_start);
   datetime time2 = iTime(Symbol(),0,bar_end);
   objdel(name);
   obj_put(name, OBJ_TREND, time1, price, time2, price, 0, 0, -1, cl);
   return(true);
}

void obj_putlabel(string name, string text, int corner, int x, int y, int fontsize = 7, string fontname = "Tahoma", color cl = White)
{
   ObjectCreate(name,OBJ_LABEL,0,0,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,0);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,fontsize,fontname,cl);
}

void objdel(string name, int ticket = -1)
{
   if (name == "") {
      Print("objdel: empty name");
      return;
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);

   for (int i = 0; i <= delobj_retry; i++) {
      ObjectDelete(name);
      if (!objfind(name)) break;
      else Sleep(delobj_wait);
   }     
}

string ordobjname(int ticket, string name)
{
   return(DoubleToStr(ticket,0)+name);
}

void obj_changedesc(string name, string text, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   ObjectSetText(name,text,0);
}

void obj_storetext(string name, string text, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
            
   if (ObjectFind(name) < 0) hline_put(name,0,CLR_NONE);
   ObjectSetText(name,text,0);
}

void obj_storestring(string name, string str, int ticket = -1)
{
   obj_storetext(name,str,ticket);
}

void obj_storeint(string name, int num, int ticket = -1)
{
   obj_storetext(name,DoubleToStr(num,0),ticket);
}

void obj_storetime(string name, datetime num, int ticket = -1)
{
   obj_storetext(name,DoubleToStr(num,0),ticket);
}

void obj_storebool(string name, bool num, int ticket = -1)
{
   obj_storetext(name,DoubleToStr(num,0),ticket);
}

void obj_storedouble(string name, double num, int ticket = -1, int precision = 10)
{
   obj_storetext(name,DoubleToStr(num,precision),ticket);
}

string obj_getdesc(string name, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) < 0) return NULL;
   return(ObjectDescription(name));
}

int obj_getdesc_int(string name, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str == NULL)
      return(EMPTY_VALUE);
   else
      return((int)MathRound(StrToDouble(str)));
}

bool obj_getdesc_bool(string name, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str == NULL)
      return(false);
   else
      return((bool)MathRound(StrToDouble(str)));
}

double obj_getdesc_double(string name, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str == NULL)
      return(EMPTY_VALUE);
   else
      return(StrToDouble(str));
}



void obj_loadstring(string name, string& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL)
      var = str;
   return;
}

void obj_loaddouble(string name, double& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL)
      var = StrToDouble(str);
   return;
}

void obj_loadint(string name, int& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL) {
      var = (int)MathRound(StrToDouble(str));
   }
   return;
}

int obj_loadenum(string name, int var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL) {
      return (int)MathRound(StrToDouble(str));
   }
   return var;
}

void obj_loaddatetime(string name, datetime& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL)
      var = (datetime)MathRound(StrToDouble(str));
   return;
}

void obj_loadtime(string name, datetime& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL)
      var = (datetime)MathRound(StrToDouble(str));
   return;
}

void obj_loadbool(string name, bool& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (obj_load_remove) objdel(name,ticket);
   if (str != NULL)
      var = MathRound(StrToDouble(str));
   return;
}

/*
void change_hline_to_trendline(string name, int bar_start = 5, int bar_end = 0, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) == -1) return(-1);
   double price = line_get(name);
   color cl = ObjectGet(name,OBJPROP_COLOR);
   datetime time1 = iTime(Symbol(),0,bar_start);
   datetime time2 = iTime(Symbol(),0,bar_end);
   objdel(name);
   obj_put(name, OBJ_TREND, time1, price, time2, price, 0, 0, -1, cl);
   ObjectSet(name,OBJPROP_RAY_RIGHT,1);
}
*/

#endif