//+------------------------------------------------------------------+
//|                                              commonfunctions.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>

void array_increase_double(double& array[], int size, double initial_value = 0) {
   int oldsize = ArraySize(array);
   if (oldsize < size) {
      ArrayResize(array,size);
      for (int i = oldsize; i < size; i++) {
         array[i] = initial_value;
      }
   }
}

void array_increase_int(int& array[], int size, int initial_value = 0) {
   int oldsize = ArraySize(array);
   if (oldsize < size) {
      ArrayResize(array,size);
      for (int i = oldsize; i < size; i++) {
         array[i] = initial_value;
      }
   }
}

void array_increase_bool(bool& array[], int size, bool initial_value = 0) {
   int oldsize = ArraySize(array);
   if (oldsize < size) {
      ArrayResize(array,size);
      for (int i = oldsize; i < size; i++) {
         array[i] = initial_value;
      }
   }
}


void array_increase_datetime(datetime& array[], int size, datetime initial_value = 0) {
   int oldsize = ArraySize(array);
   if (oldsize < size) {
      ArrayResize(array,size);
      for (int i = oldsize; i < size; i++) {
         array[i] = initial_value;
      }
   }
}

void array_increase_string(string& array[], int size, string initial_value = "") {
   int oldsize = ArraySize(array);
   if (oldsize < size) {
      ArrayResize(array,size);
      for (int i = oldsize; i < size; i++) {
         array[i] = initial_value;
      }
   }
}

void array_increase_object(CObject*& array[], int size) {
   int oldsize = ArraySize(array);
   if (oldsize < size) {
      ArrayResize(array,size);
      /*for (int i = oldsize; i < size; i++) {
         array[i] = initial_value;
      }*/
   }
}

void array_shift_double(double& array[], int shift, int start = 0)
{
   int oldsize = ArraySize(array);
   ArrayResize(array,ArraySize(array)+shift);
   for (int i = oldsize-1; i >= start; i--) {
      array[i+shift] = array[i];
   }
}

string get_strarraydata_double(double& array[], string delimiter)
{
   string arrdata;
   for (int i = 0; ; i++) {
      arrdata = arrdata+DoubleToString(array[i]);
      if (i < ArraySize(array)-1) {
         arrdata = arrdata+delimiter;         
      } else {
         break;
      }
   }
   return(arrdata);
}

double array_average_double(double& array[], int mindata=1, int maxdata=0)
{
   if (ArraySize(array) < mindata) return(0);
   double sum = 0;
   double cnt = 0;
   for (int i = 0; i < ArraySize(array) && (maxdata == 0 || i < maxdata); i++) {
      sum += array[i];
      cnt++;
   }
   return(sum/cnt);
}

void array_add_string(string& array[], string value) {
   int oldsize = ArraySize(array);
   ArrayResize(array,oldsize+1);
   array[oldsize] = value;
}

void array_add_int(int& array[], int value) {
   int oldsize = ArraySize(array);
   ArrayResize(array,oldsize+1);
   array[oldsize] = value;
}

int array_find_string(string& array[], string value) {
   int size = ArraySize(array);
   for (int i = 0; i < size; i++) {
      //Print(i," ",array[i]," ",value);
      if (array[i] == value) return(i);
   }
   return(-1);
}

void set_arrayitem_string(string& array[], int idx, string value, string default_value = "") {
   array_increase_string(array, idx+1, default_value);
   array[idx] = value;
}

void set_arrayitem_int(int& array[], int idx, int value, int default_value = 0) {
   array_increase_int(array, idx+1, default_value);
   array[idx] = value;
}

void set_arrayitem_double(double& array[], int idx, double value, double default_value = 0) {
   array_increase_double(array, idx+1, default_value);
   array[idx] = value;
}

void set_arrayitem_bool(bool& array[], int idx, bool value, bool default_value = false) {
   array_increase_bool(array, idx+1, default_value);
   array[idx] = value;
}

void set_arrayitem_datetime(datetime& array[], int idx, datetime value, datetime default_value = 0) {
   array_increase_datetime(array, idx+1, default_value);
   array[idx] = value;
}