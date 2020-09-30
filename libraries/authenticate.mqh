
#ifdef __MQL5__
#include "md5_mql5.mqh"
#else
#include "md5.mqh"
#endif

#include "Base64.mqh"

string auth_response = "";
string secret_key = "D0e1F2a3U4l5T6s7E8c9R0e1T2k3E4y5";

string auth_custom = "";

bool authenticate(string licence_key)
{
   //Alert("authentication");
   
   string licencestring = "";
   Base64Decode(licence_key,licencestring);
   //Alert(licencestring);
   
   int pos = 0;
   int nextpos = 0;
   nextpos = StringFind(licencestring," ",pos);
   //Alert(pos," ",nextpos);
   int account_number = StrToDouble(StringSubstr(licencestring,pos,nextpos-pos));
   pos = nextpos+1;
   nextpos = pos+1;
   bool demo_enabled = StrToDouble(StringSubstr(licencestring,pos,nextpos-pos));
   pos = nextpos;   
   nextpos = pos+1;
   bool real_enabled = StrToDouble(StringSubstr(licencestring,pos,nextpos-pos));
   pos = nextpos;   
   nextpos = pos+1;
   bool test_enabled = StrToDouble(StringSubstr(licencestring,pos,nextpos-pos));
   pos = nextpos;   
   nextpos = pos+1;
   bool optimization_enabled = StrToDouble(StringSubstr(licencestring,pos,nextpos-pos));
   pos = nextpos;   
   nextpos = StringFind(licencestring," ",pos);
   datetime expiration = StrToDouble(StringSubstr(licencestring,pos,nextpos-pos));
   pos = nextpos+1;   
   nextpos = StringFind(licencestring," ",pos);
   if (nextpos >= 0) {
      auth_custom = StringSubstr(licencestring,pos,nextpos-pos+1);
      pos = nextpos+1;   
   }
   //Alert("pos=",pos);
   string checksum = StringSubstr(licencestring,pos);
   
   string newlicencestring = numtostr(account_number,0)+" "+numtostr(demo_enabled,1)+numtostr(real_enabled,1)+numtostr(test_enabled,1)+numtostr(optimization_enabled,1)+numtostr(expiration,0)+" "+auth_custom;
   if (checksum != MD5(newlicencestring+secret_key)) {
      auth_response = "invalid licence key";
      return(false);
   }
   
   if (account_number != 0) {
      if (account_number != AccountNumber()) {
         auth_response = "invalid account number";
         return(false);
      }
   }
   
   if (!demo_enabled && IsDemo()) {
      auth_response = "demo not enabled";
      return(false);
   }

   if (!real_enabled && !IsDemo()) {
      auth_response = "real not enabled";
      return(false);
   }
   
   if (!test_enabled && IsTesting()) {
      auth_response = "test not enabled";
      return(false);
   }
   
   if (!optimization_enabled && IsOptimization()) {
      auth_response = "optimization not enabled";
      return(false);
   }
   
   if (expiration > 0) {
      if (expiration < TimeCurrent()) {         
         return(false);
      }
   }
   Print("Authentication OK");      
   return(true);
}

string numtostr(double num, int place, int precision = 0)
{
   string str = "";
   str = DoubleToStr(num,precision);
   while(StringLen(str)<place) {
      str = str+" ";
   }
   return(str);
}

bool authenticated = false;
bool authenticate_check_access(string licence_key)
{
   //Print("checking access license key: ",licence_key," secret_key:",secret_key," authenticated:",authenticated);
   if (authenticated) return(true);
   else {
      if (authenticate(licence_key)) {
         authenticated = true;
         //Print("authenticated:",authenticated);
         return(true);
      } else {
         //Print("authentication failed");
         /*addcomment("Atthentication Failed, response: ",auth_response);
         writecomment();
         delcomment();*/
         return(false);
      }
   }
}

string generate_license_key(
   int account_number,
   bool demo_enabled,
   bool real_enabled,
   bool test_enabled,
   bool optimization_enabled,
   datetime expiration )
{
   string licencestring = "";
   licencestring = numtostr(account_number,0)+" "+numtostr(demo_enabled,1)+numtostr(real_enabled,1)+numtostr(test_enabled,1)+numtostr(optimization_enabled,1)+numtostr(expiration,0)+" ";
   string checksum = MD5(licencestring+secret_key);
   licencestring = licencestring+checksum;
   string licencekey;
   Base64Encode(licencestring,licencekey);
   return(licencekey);
}