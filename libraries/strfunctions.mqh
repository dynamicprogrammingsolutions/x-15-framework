//+------------------------------------------------------------------+
//|                                                 strfunctions.mq4 |
//|                                            Zoltan Laszlo Ferenci |
//|                              http://www.metatraderprogrammer.com |
//+------------------------------------------------------------------+
#include  "arrays.mqh"

void str_explode_double(string list_string, double& explode_array[], string delimiter=",")
{
   for (int i = 0; i < 100000; i++) {
      if (list_string == "") { break; }
      array_increase_double(explode_array, i+1);
      explode_array[i] = StrToDouble(strcsv_get(list_string, delimiter));
   }
} 

void str_explode_2double(string list_string, double& val1, double& val2, string delimiter=",")
{
   val1 = StrToDouble(strcsv_get(list_string, delimiter));
   val2 = StrToDouble(strcsv_get(list_string, delimiter));
} 

void str_explode_int(string list_string, int& explode_array[], string delimiter=",")
{
   for (int i = 0; i < 100000; i++) {
      if (list_string == "") { break; }
      array_increase_int(explode_array, i+1);
      explode_array[i] = (int)StrToDouble(strcsv_get(list_string, delimiter));
   }
} 

void str_explode_bool(string list_string, bool& explode_array[], string delimiter=",")
{
   for (int i = 0; i < 100000; i++) {
      if (list_string == "") { break; }
      array_increase_bool(explode_array, i+1);
      explode_array[i] = StrToDouble(strcsv_get(list_string, delimiter));
   }
} 

void str_explode_int_fixed(string list_string, int& explode_array[], string delimiter=",", int def = 0)
{
   for (int i = 0; i < ArraySize(explode_array); i++) {
      if (list_string == "") explode_array[i] = def;
      else explode_array[i] = (int)StrToDouble(strcsv_get(list_string, delimiter));
   }
} 

void str_explode_bool_fixed(string list_string, bool& explode_array[], string delimiter=",", bool def = false)
{
   for (int i = 0; i < ArraySize(explode_array); i++) {
      if (list_string == "") explode_array[i] = def;
      else explode_array[i] = StrToDouble(strcsv_get(list_string, delimiter));
   }
} 

void str_explode_double_fixed(string list_string, double& explode_array[], string delimiter=",", double def = 0)
{
   for (int i = 0; i < ArraySize(explode_array); i++) {
      if (list_string == "") explode_array[i] = def;
      else explode_array[i] = StrToDouble(strcsv_get(list_string, delimiter));
   }
} 

void str_explode_string(string list_string, string& explode_array[], string delimiter=",", int minitems = 0, int maxitems = 100)
{
   ArrayResize(explode_array,minitems);
   for (int i = 0; i < maxitems; i++) {
      if (list_string == "") { break; }
      array_increase_string(explode_array, i+1);
      explode_array[i] = strcsv_get(list_string, delimiter);
   }
} 

void str_implode_string(string& list_string, string& explode_array[], string delimiter=",")
{
   bool first = true;
   for (int i = 0; i < ArraySize(explode_array); i++) {
      if (first) {list_string = list_string + explode_array[i];first=false;}
      else list_string = list_string + delimiter + explode_array[i];
   }
} 


string strcsv_get(string& text, string delimiter = ",")
{
   string ret;
   int pos = StringFind(text,delimiter,0);
   if (pos == -1)
   {
      ret = text;
      text = "";
      return(ret);
   }
   else
   {
      int limlen = StringLen(delimiter);
      if (pos == 0) {
         ret = "";
      } else {
         ret = StringSubstr(text,0,pos);
      }
      text = StringSubstr(text,pos+limlen,StringLen(text)-pos-limlen);
      return(ret);
   }
}

string substr(string text, int start, int end)
{
   return(StringSubstr(text,start,end-start+1));
}

string strcsv_get_pos(string& text, int& pos, string delimiter = ",", string end = "")
{
   int pos1 = pos;
   int pos2 = StringFind(text,delimiter,pos);
   int pos3 = -1;
   if (end != "") {
      pos3 = StringFind(text,end,pos);
      if (pos2 > pos3 || pos2 < 0) pos2 = pos3;
   }
   string ret;
   if (pos2 == -1)
   {
      pos2 = StringLen(text);
      pos = -1;
   } else if (pos2 == pos3) {
      pos = -1;
   } else {
      pos = pos2+1;
   }
   
   
   ret = substr(text,pos1,pos2-1);
   return(ret);
}

string dts(double num, int digit = -1)
{
   //if (digit == -1)
      //digit = digits;
   return(DoubleToStr(num,digit));
}

string its(int num)
{
   return(DoubleToStr(num,0));
}

int sti(string str)
{
   return((int)MathRound(StrToDouble(str)));
}

double std(string str)
{
   return(StrToDouble(str));
}

string substr_fromto(string str, int from, int to)
{
   if (from >= 0 && to >= 0 && to >= from) {
      return(StringSubstr(str,from,to-from+1));
   }
   return("");
}


string str_getvalue(string str, string prefix, string suffix="")
{
   int start = StringFind(str,prefix);
   if (start < 0) return("no pref");
   start += StringLen(prefix);
   
   int end;
   if (StringLen(suffix) > 0) {
      end = StringFind(str,suffix,start)-1;
   } else {
      end = StringLen(str);
   }
   
   //Alert(str," ",suffix," ",start);
   
   if (end < 0) return("no suff");
      
   return(substr_fromto(str, start, end));
}

string str_getvalue_startend(string str, string prefix, string suffix)
{
   int start, end;
   return str_getvalue_startend(str, prefix, suffix, start, end);
}


string str_getvalue_startend(string str, string prefix, string suffix, int& start, int& end)
{
   start = StringFind(str,prefix);
   if (start < 0) return("no pref");
   start += StringLen(prefix);
   
   end = StringFind(str,suffix,start)-1;
   
   //Alert(str," ",suffix," ",start);
   
   if (end < 0) return("no suff");
      
   return(substr_fromto(str, start, end));
}


double str_getnumber_emptyvalue = -1;

void str_getnumber_double(double& var, string orderdata, string str)
{
   double val = str_getnumber(orderdata,str);
   if (val != str_getnumber_emptyvalue) {
      var = val;
   }
}

void str_getnumber_int(int& var, string orderdata, string str)
{
   int val = (int)str_getnumber(orderdata,str);
   if (val != str_getnumber_emptyvalue) {
      var = val;
   }
}

double str_getnumber(string orderdata, string str)
{
   int start = StringFind(orderdata,str);
   if (start < 0) return(str_getnumber_emptyvalue);
   start += StringLen(str);
   int i;
   
   for (i = 0; i <= StringLen(orderdata)-start; i++) {
      string char_ = StringSubstr(orderdata,start+i,1);
      if (char_ != "0" && char_ != "1" && char_ != "2" && char_ != "3" && char_ != "4" && char_ != "5" && char_ != "6" && char_ != "7" && char_ != "8" && char_ != "9"
      && char_ != "." && char_ != "-") {
         if (char_ != ",") {
            i--;
            break;
         } else {
            orderdata = StringSubstr(orderdata,0,start+i)+"."+StringSubstr(orderdata,start+i+1);
         }
      }
   }
   string numstr = StringSubstr(orderdata,start,i-start+1);
   //Alert(numstr);
   return(StrToDouble(numstr));
}