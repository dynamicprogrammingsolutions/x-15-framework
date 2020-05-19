#import "SocketLibClient.dll"

   int test_send_str(uchar& str[]);
   int test_recv_str(uchar& str[]);
   
   int test_send_str(ushort& str[]);
   int test_recv_str(ushort& str[]);
   
   void wsa_startup(int unused);
   
   void wsa_cleanup(int unused);
   
   long test_long1(int unused);
   ulong test_long3(int unused);
   
   //long create_client(uchar& addr[], int port, int buffer_size);
   
   ulong create_local_client(int port, int buffer_size);
   
   void close_client(ulong handle);
   
   bool client_connected(ulong handle);
   
   /*int poll_msg_w(long handle, ushort& msg_buffer[], int buffer_size, int wait_millisec);*/
   
   int  poll_msg(ulong handle, uchar& msg_buffer[], int buffer_size, int wait_millisec);
   
#import
