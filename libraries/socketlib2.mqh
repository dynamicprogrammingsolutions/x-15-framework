#property strict

#include "../ptr.mqh"
#include "../logger.mqh"
#import "SocketLib2.dll"

void delete_all_socket(int ignored);

uint open_socket(int& error);
void disconnect_socket(uint sock);

//bool bind(uint handle, uchar addr[], int port, int& error);
//bool listen(uint handle, int queue_size, int& error);
uint create_server(uchar& addr[], int port, int queue_size, int& err);

//bool connect(uint handle, uchar addr[], int port, int& error);
uint create_client(uchar& addr[], int port, int& error);

uint create_accept_process(uint socket);
//void delete_accept(uint accept_handle);
bool poll_accept(uint accept_handle, int wait_for, bool restart);
bool get_accept_result(uint accept_handle, uint& client_sock, uchar& addr_buf[], uint addr_buf_size, ushort& port, int& error);

uint create_send_queue(uint sock, uint max_queue_size, uint buffer_size);
//void delete_send_queue(uint queue_handle);
//int get_queue_error(uint queue_handle);
void send_msg(uint queue_handle, uchar& msg[]);

uint create_receive_buffer(uint sock, uint size);
//void delete_receive_buffer(uint buffer);
bool poll_msg(uint buffer, int wait_ms, bool restart);
bool get_msg(uint buffer, uchar& msg_buf[], int buf_size, int& err);
   
#import

bool create_server(string saddr, ushort port, int queue_size, uint& socket) {
   uchar addr[32];
   StringToCharArray(saddr,addr,0,WHOLE_ARRAY,CP_UTF8);
   int err;
   socket = create_server(addr,port,queue_size,err);
   if (socket == 0) {
      print(("Couldn't create server, error: ",err));
      return false;
   }
   return true;
}

bool create_client(string saddr, ushort port, uint& socket) {
   uchar addr[32];
   StringToCharArray(saddr,addr,0,WHOLE_ARRAY,CP_UTF8);
   int err;
   socket = create_client(addr,port,err);
   if (socket == 0) {
      print(("Couldn't create client, error: ",err));
      return false;
   }
   return true;
}

bool poll_accept(uint accept_handle, uint& client_socket, string& client_addr, int error_sleep = 0) {
   if (poll_accept(accept_handle, 0, true)) {
      int error;
      ushort port;
      uchar addr[32];
      if (get_accept_result(accept_handle, client_socket, addr, 32, port, error)) {
         client_addr = CharArrayToString(addr,0,WHOLE_ARRAY,CP_UTF8);
         return true;
      } else {
         debug(("Debug log: Error during accept connection: ",error));
         if (error_sleep > 0) Sleep(error_sleep);
         return false;
      }
   }
   return false;
}

bool poll_msg_with_retries(uint receive_handle, int wait_ms, string& msg, int& err, int retries) {
   int cnt = 0;
   bool success = false;
   while (cnt <= retries) {
      bool is_error = false;
      success = poll_msg(receive_handle, wait_ms, msg, err, is_error);
      if (err == 0) break;
      cnt++;
   }
   return success;
}

bool poll_msg(uint receive_handle, int wait_ms, string& msg, int& err, bool& is_error) {
   is_error = false;
   if (poll_msg(receive_handle,wait_ms,true)) {
      uchar msg_buf[1024];
      err = 0;
      if (get_msg(receive_handle,msg_buf,1024,err)) {
         msg = CharArrayToString(msg_buf,0,WHOLE_ARRAY,CP_UTF8);
         return true;
      } else {
         is_error = true;
         return false;
      }
   }
   return false;
}

bool send_msg(uint send_handle, const string msg) {
   if (StringLen(msg) >= 1024) {
      print(("Message too large"));
      return false;
   }
   uchar msg_buf[1024];
   StringToCharArray(msg,msg_buf,0,WHOLE_ARRAY,CP_UTF8);
   msg_buf[1023] = 0;
   send_msg(send_handle,msg_buf);
   return true;
}