//+------------------------------------------------------------------+
//|                                                     comments.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

string commentstring;

void __addcomment(const string s1) {
   StringAdd(commentstring,s1);
};

void __addcomment(const string s1, const string s2) {
   __addcomment(s1);
   StringAdd(commentstring,s2);
};

void __addcomment(const string s1, const string s2, const string s3) {
   __addcomment(s1,s2);
   StringAdd(commentstring,s3);
};

void __addcomment(const string s1, const string s2, const string s3, const string s4) {
   __addcomment(s1,s2,s3);
   StringAdd(commentstring,s4);
};

void __addcomment(const string s1, const string s2, const string s3, const string s4, const string s5) {
   __addcomment(s1,s2,s3,s4);
   StringAdd(commentstring,s5);
};

void __addcomment(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6) {
   __addcomment(s1,s2,s3,s4,s5);
   StringAdd(commentstring,s6);
};

void __addcomment(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6, const string s7) {
   __addcomment(s1,s2,s3,s4,s5,s6);
   StringAdd(commentstring,s7);
};

void __addcomment(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6, const string s7, const string s8) {
   __addcomment(s1,s2,s3,s4,s5,s6,s7);
   StringAdd(commentstring,s8);
};

void __addcomment(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6, const string s7, const string s8, const string s9) {
   __addcomment(s1,s2,s3,s4,s5,s6,s7,s8);
   StringAdd(commentstring,s9);
};

void __addcommentln(const string s1) {
   __addcomment(s1,"\n");
};

void __addcommentln(const string s1, const string s2) {
   __addcomment(s1,s2,"\n");
};

void __addcommentln(const string s1, const string s2, const string s3) {
   __addcomment(s1,s2,s3,"\n");
};

void __addcommentln(const string s1, const string s2, const string s3, const string s4) {
   __addcomment(s1,s2,s3,s4,"\n");
};

void __addcommentln(const string s1, const string s2, const string s3, const string s4, const string s5) {
   __addcomment(s1,s2,s3,s4,s5,"\n");
};

void __addcommentln(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6) {
   __addcomment(s1,s2,s3,s4,s5,s6,"\n");
};

void __addcommentln(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6, const string s7) {
   __addcomment(s1,s2,s3,s4,s5,s6,s7,"\n");
};

void __addcommentln(const string s1, const string s2, const string s3, const string s4, const string s5, const string s6, const string s7, const string s8) {
   __addcomment(s1,s2,s3,s4,s5,s6,s7,s8,"\n");
};

void __writecomment(){
   Comment(commentstring);
}

void __delcomment() {
   StringInit(commentstring,0);
}

void __donothing() {}

#ifndef DISABLE_COMMENTS

#define addcomment __addcomment
#define addcommentln __addcommentln
#define writecomment __writecomment
#define delcomment __delcomment

#endif

#ifdef DISABLE_COMMENTS

#define addcomment(s1)
#define addcommentln(s1)
#define writecomment(s1)
#define delcomment(s1)

#endif