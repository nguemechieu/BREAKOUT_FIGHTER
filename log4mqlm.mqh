//+------------------------------------------------------------------+
//|                                                     log4mqlm.mqh |
//|                                    Copyright 2021, Jens Lippmann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Jens Lippmann"
#property link      "https://www.mql5.com/en/users/lippmaje"
#property version   "1.00"
#property strict

/*
 Copyright notice:

    This file is part of Log4mql(mini).

    Log4mql(mini) is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Log4mql(mini) is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Log4mql(mini).  If not, see "https://www.gnu.org/licenses/".


 Location of the project:
    Report bugs and feedback here.
    MQL5 Codebase https://www.mql5.com/en/code/33129 Log4mql(mini) MT4
    MQL5 Codebase https://www.mql5.com/en/code/33130 Log4mql(mini) MT5
*/

#define LOG(level)  L4mq.logged=(level<=L4mq.Level()) && L4mq.ForLevel(level,__FUNCTION__,__FILE__,__LINE__).Log
#define LOGF(level) L4mq.logged=(level<=L4mq.Level()) && L4mq.ForLevel(level,__FUNCTION__,__FILE__,__LINE__).LogFormat
#define FATAL  LOG(LOGLEVEL_FATAL)
#define ERROR  LOG(LOGLEVEL_ERROR)
#define WARN   LOG(LOGLEVEL_WARN)
#define PRINT  LOG(LOGLEVEL_INFO)
#define DEBUG  LOG(LOGLEVEL_DEBUG)
#define TRACE  LOG(LOGLEVEL_TRACE)
#define FATALF LOGF(LOGLEVEL_FATAL)
#define ERRORF LOGF(LOGLEVEL_ERROR)
#define WARNF  LOGF(LOGLEVEL_WARN)
#define PRINTF LOGF(LOGLEVEL_INFO)
#define DEBUGF LOGF(LOGLEVEL_DEBUG)
#define TRACEF LOGF(LOGLEVEL_TRACE)

//+------------------------------------------------------------------+
//| enum ENUM_LOG_LEVEL                                              |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVEL
  {
   LOGLEVEL_OFF   =   0,             // Off
   LOGLEVEL_FATAL = 100,             // Fatal
   LOGLEVEL_ERROR = 200,             // Error
   LOGLEVEL_WARN  = 300,             // Warn
   LOGLEVEL_INFO  = 400,             // Info
   LOGLEVEL_DEBUG = 500,             // Debug
   LOGLEVEL_TRACE = 600,             // Trace
   LOGLEVEL_ALL   = INT_MAX          // All
  };
//+------------------------------------------------------------------+
//| class Log4mql                                                    |
//+------------------------------------------------------------------+
class Log4mql
  {
protected:
   string            m_func;
   string            m_file;
   int               m_line;
   int               m_lastlevel;
   string            m_lastmsg;
   int               m_level;
   int               m_maxlevel;
   ulong             m_seqnr;
   bool              Logs(string msgs)
     {
      m_lastlevel=m_level;
      if(m_level<=m_maxlevel)
        {
         ++m_seqnr;
         if(m_level>=LOGLEVEL_DEBUG)
           {
            m_lastmsg=StringFormat("%s(%s:%d): %s",m_func,m_file,m_line,msgs);
           }
         else
            if(m_level>=LOGLEVEL_INFO)
              {
               m_lastmsg=StringFormat("%s: %s",m_func,msgs);
              }
            else
               if(m_level>=LOGLEVEL_WARN)
                 {
                  m_lastmsg=StringFormat("WARN %s(%s:%d): %s",m_func,m_file,m_line,msgs);
                 }
               else
                 {
                  m_lastmsg=StringFormat("%s %s(%s:%d): %s",(m_level>=LOGLEVEL_ERROR?"ERROR":"FATAL"),m_func,m_file,m_line,msgs);
                  if(_LastError)
                     m_lastmsg+=StringFormat(",  error %d - %s",_LastError,GetErrorDescription(_LastError));
                 }
         Print(m_lastmsg);
         return true;
        }
      m_lastmsg=NULL;
      return false;
     }
public:
   bool              logged;
                     Log4mql(int level=0) : m_maxlevel(level),m_lastmsg(NULL),m_seqnr(0) {}
   Log4mql           *ForLevel(int level,string func,string file,int line)
     {
      m_level=level;
      m_func=func;
      m_file=file;
      m_line=line;
      return &this;
     }
   int               LastLevel() { return m_lastlevel; }
   string            LastMessage() { return m_lastmsg; }
   int               Level() { return m_maxlevel; }
   string            LevelAsString(int level=-1) { return LoglevelToString(level<0?m_maxlevel:level); }
   void              SetLevel(int level) { m_maxlevel=level; }
   ulong             SeqNr() { return m_seqnr; }
#ifdef __MQL4__
   template<typename T>
   bool              Log(T p) { return Logs(StringConcatenate(p)); }
   template<typename T1,typename T2>
   bool              Log(T1 p1,T2 p2) { return Logs(StringConcatenate(p1,p2)); }
   template<typename T1,typename T2,typename T3>
   bool              Log(T1 p1,T2 p2,T3 p3) { return Logs(StringConcatenate(p1,p2,p3)); }
   template<typename T1,typename T2,typename T3,typename T4>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4) { return Logs(StringConcatenate(p1,p2,p3,p4)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5) { return Logs(StringConcatenate(p1,p2,p3,p4,p5)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6) { return Logs(StringConcatenate(p1,p2,p3,p4,p5,p6)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7) { return Logs(StringConcatenate(p1,p2,p3,p4,p5,p6,p7)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7,T8 p8) { return Logs(StringConcatenate(p1,p2,p3,p4,p5,p6,p7,p8)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7,T8 p8,T9 p9) { return Logs(StringConcatenate(p1,p2,p3,p4,p5,p6,p7,p8,p9)); }
   template<typename T>
   bool              LogFormat(T p) { return Logs(StringConcatenate(p)); }
#else
   template<typename T>
   bool              Log(T p) { string s; StringConcatenate(s,p,""); return Logs(s); }
   template<typename T1,typename T2>
   bool              Log(T1 p1,T2 p2) { string s; StringConcatenate(s,p1,p2); return Logs(s); }
   template<typename T1,typename T2,typename T3>
   bool              Log(T1 p1,T2 p2,T3 p3) { string s; StringConcatenate(s,p1,p2,p3); return Logs(s); }
   template<typename T1,typename T2,typename T3,typename T4>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4) { string s; StringConcatenate(s,p1,p2,p3,p4); return Logs(s); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5) { string s; StringConcatenate(s,p1,p2,p3,p4,p5); return Logs(s); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6) { string s; StringConcatenate(s,p1,p2,p3,p4,p5,p6); return Logs(s); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7) { string s; StringConcatenate(s,p1,p2,p3,p4,p5,p6,p7); return Logs(s); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7,T8 p8) { string s; StringConcatenate(s,p1,p2,p3,p4,p5,p6,p7,p8); return Logs(s); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9>
   bool              Log(T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7,T8 p8,T9 p9) { string s; StringConcatenate(s,p1,p2,p3,p4,p5,p6,p7,p8,p9); return Logs(s); }
   template<typename T>
   bool              LogFormat(T p) { string s; StringConcatenate(s,p,""); return Logs(s); }
#endif
   template<typename T>
   bool              LogFormat(string format,T p) { return Logs(StringFormat(format,p)); }
   template<typename T1,typename T2>
   bool              LogFormat(string format,T1 p1,T2 p2) { return Logs(StringFormat(format,p1,p2)); }
   template<typename T1,typename T2,typename T3>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3) { return Logs(StringFormat(format,p1,p2,p3)); }
   template<typename T1,typename T2,typename T3,typename T4>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3,T4 p4) { return Logs(StringFormat(format,p1,p2,p3,p4)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3,T4 p4,T5 p5) { return Logs(StringFormat(format,p1,p2,p3,p4,p5)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6) { return Logs(StringFormat(format,p1,p2,p3,p4,p5,p6)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7) { return Logs(StringFormat(format,p1,p2,p3,p4,p5,p6,p7)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7,T8 p8) { return Logs(StringFormat(format,p1,p2,p3,p4,p5,p6,p7,p8)); }
   template<typename T1,typename T2,typename T3,typename T4,typename T5,typename T6,typename T7,typename T8,typename T9>
   bool              LogFormat(string format,T1 p1,T2 p2,T3 p3,T4 p4,T5 p5,T6 p6,T7 p7,T8 p8,T9 p9) { return Logs(StringFormat(format,p1,p2,p3,p4,p5,p6,p7,p8,p9)); }

   static string     GetErrorDescription(int error_code=-1)
     {
      if(error_code==-1) error_code=_LastError;
      if(error_code>=ERR_USER_ERROR_FIRST)
        {
         return "User error "+string(error_code-ERR_USER_ERROR_FIRST);
        }
      switch(error_code)
        {
#ifdef __MQL4__
         //--- codes returned from trade server
         case ERR_NO_ERROR:
            return "No error";
         case ERR_NO_RESULT:
            return "No error, but the result is unknown";
         case ERR_COMMON_ERROR:
            return "Common error";
         case ERR_INVALID_TRADE_PARAMETERS:
            return "Invalid trade parameters";
         case ERR_SERVER_BUSY:
            return "Trade server is busy";
         case ERR_OLD_VERSION:
            return "Old version of the client terminal";
         case ERR_NO_CONNECTION:
            return "No connection with trade server";
         case ERR_NOT_ENOUGH_RIGHTS:
            return "Not enough rights";
         case ERR_TOO_FREQUENT_REQUESTS:
            return "Too frequent requests";
         case ERR_MALFUNCTIONAL_TRADE:
            return "Malfunctional trade operation";
         case ERR_ACCOUNT_DISABLED:
            return "Account disabled";
         case ERR_INVALID_ACCOUNT:
            return "Invalid account";
         case ERR_TRADE_TIMEOUT:
            return "Trade timeout";
         case ERR_INVALID_PRICE:
            return "Invalid price";
         case ERR_INVALID_STOPS:
            return "Invalid stops";
         case ERR_INVALID_TRADE_VOLUME:
            return "Invalid trade volume";
         case ERR_MARKET_CLOSED:
            return "Market is closed";
         case ERR_TRADE_DISABLED:
            return "Trade is disabled";
         case ERR_NOT_ENOUGH_MONEY:
            return "Not enough money";
         case ERR_PRICE_CHANGED:
            return "Price changed";
         case ERR_OFF_QUOTES:
            return "Off quotes";
         case ERR_BROKER_BUSY:
            return "Broker is busy";
         case ERR_REQUOTE:
            return "Requote";
         case ERR_ORDER_LOCKED:
            return "Order is locked";
         case ERR_LONG_POSITIONS_ONLY_ALLOWED:
            return "Long positions only allowed";
         case ERR_TOO_MANY_REQUESTS:
            return "Too many requests";
         case ERR_TRADE_MODIFY_DENIED:
            return "Modification denied because order is too close to market";
         case ERR_TRADE_CONTEXT_BUSY:
            return "Trade context is busy";
         case ERR_TRADE_EXPIRATION_DENIED:
            return "Expirations are denied by broker";
         case ERR_TRADE_TOO_MANY_ORDERS:
            return "Amount of open and pending orders has reached the limit";
         case ERR_TRADE_HEDGE_PROHIBITED:
            return "Hedging is prohibited";
         case ERR_TRADE_PROHIBITED_BY_FIFO:
            return "Prohibited by FIFO rules";
         //--- mql4 errors
         case ERR_NO_MQLERROR:
            return "No error (never generated code)";
         case ERR_WRONG_FUNCTION_POINTER:
            return "Wrong function pointer";
         case ERR_ARRAY_INDEX_OUT_OF_RANGE:
            return "Array index is out of range";
         case ERR_NO_MEMORY_FOR_CALL_STACK:
            return "No memory for function call stack";
         case ERR_RECURSIVE_STACK_OVERFLOW:
            return "Recursive stack overflow";
         case ERR_NOT_ENOUGH_STACK_FOR_PARAM:
            return "Not enough stack for parameter";
         case ERR_NO_MEMORY_FOR_PARAM_STRING:
            return "No memory for parameter string";
         case ERR_NO_MEMORY_FOR_TEMP_STRING:
            return "No memory for temp string";
         case ERR_NOT_INITIALIZED_STRING:
            return "Non-initialized string";
         case ERR_NOT_INITIALIZED_ARRAYSTRING:
            return "Non-initialized string in array";
         case ERR_NO_MEMORY_FOR_ARRAYSTRING:
            return "No memory for array string";
         case ERR_TOO_LONG_STRING:
            return "Too long string";
         case ERR_REMAINDER_FROM_ZERO_DIVIDE:
            return "Remainder from zero divide";
         case ERR_ZERO_DIVIDE:
            return "Zero divide";
         case ERR_UNKNOWN_COMMAND:
            return "Unknown command";
         case ERR_WRONG_JUMP:
            return "Wrong jump (never generated error)";
         case ERR_NOT_INITIALIZED_ARRAY:
            return "Non-initialized array";
         case ERR_DLL_CALLS_NOT_ALLOWED:
            return "Dll calls are not allowed";
         case ERR_CANNOT_LOAD_LIBRARY:
            return "Cannot load library";
         case ERR_CANNOT_CALL_FUNCTION:
            return "Cannot call function";
         case ERR_EXTERNAL_CALLS_NOT_ALLOWED:
            return "Expert function calls are not allowed";
         case ERR_NO_MEMORY_FOR_RETURNED_STR:
            return "Not enough memory for temp string returned from function";
         case ERR_SYSTEM_BUSY:
            return "System is busy (never generated error)";
         case ERR_DLLFUNC_CRITICALERROR:
            return "Dll-function call critical error";
         case ERR_INTERNAL_ERROR:
            return "Internal error";
         case ERR_OUT_OF_MEMORY:
            return "Out of memory";
         case ERR_INVALID_POINTER:
            return "Invalid pointer";
         case ERR_FORMAT_TOO_MANY_FORMATTERS:
            return "Too many formatters in the format function";
         case ERR_FORMAT_TOO_MANY_PARAMETERS:
            return "Parameters count is more than formatters count";
         case ERR_ARRAY_INVALID:
            return "Invalid array";
         case ERR_CHART_NOREPLY:
            return "No reply from chart";
         case ERR_INVALID_FUNCTION_PARAMSCNT:
            return "Invalid function parameters count";
         case ERR_INVALID_FUNCTION_PARAMVALUE:
            return "Invalid function parameter value";
         case ERR_STRING_FUNCTION_INTERNAL:
            return "String function internal error";
         case ERR_SOME_ARRAY_ERROR:
            return "Some array error";
         case ERR_INCORRECT_SERIESARRAY_USING:
            return "Incorrect series array usage";
         case ERR_CUSTOM_INDICATOR_ERROR:
            return "Custom indicator error";
         case ERR_INCOMPATIBLE_ARRAYS:
            return "Arrays are incompatible";
         case ERR_GLOBAL_VARIABLES_PROCESSING:
            return "Global variables processing error";
         case ERR_GLOBAL_VARIABLE_NOT_FOUND:
            return "Global variable not found";
         case ERR_FUNC_NOT_ALLOWED_IN_TESTING:
            return "Function is not allowed in testing mode";
         case ERR_FUNCTION_NOT_CONFIRMED:
            return "Function is not allowed for call";
         case ERR_SEND_MAIL_ERROR:
            return "Send mail error";
         case ERR_STRING_PARAMETER_EXPECTED:
            return "String parameter expected";
         case ERR_INTEGER_PARAMETER_EXPECTED:
            return "Integer parameter expected";
         case ERR_DOUBLE_PARAMETER_EXPECTED:
            return "Double parameter expected";
         case ERR_ARRAY_AS_PARAMETER_EXPECTED:
            return "Array as parameter expected";
         case ERR_HISTORY_WILL_UPDATED:
            return "Requested history data is in update state";
         case ERR_TRADE_ERROR:
            return "Internal trade error";
         case ERR_RESOURCE_NOT_FOUND:
            return "Resource not found";
         case ERR_RESOURCE_NOT_SUPPORTED:
            return "Resource not supported";
         case ERR_RESOURCE_DUPLICATED:
            return "Duplicate resource";
         case ERR_INDICATOR_CANNOT_INIT:
            return "Cannot initialize custom indicator";
         case ERR_INDICATOR_CANNOT_LOAD:
            return "Cannot load custom indicator";
         case ERR_NO_HISTORY_DATA:
            return "No history data";
         case ERR_NO_MEMORY_FOR_HISTORY:
            return "Not enough memory for history data";
         case ERR_NO_MEMORY_FOR_INDICATOR:
            return "Not enough memory for indicator";
         case ERR_END_OF_FILE:
            return "End of file";
         case ERR_SOME_FILE_ERROR:
            return "Some file error";
         case ERR_WRONG_FILE_NAME:
            return "Wrong file name";
         case ERR_TOO_MANY_OPENED_FILES:
            return "Too many opened files";
         case ERR_CANNOT_OPEN_FILE:
            return "Cannot open file";
         case ERR_INCOMPATIBLE_FILEACCESS:
            return "Incompatible access to a file";
         case ERR_NO_ORDER_SELECTED:
            return "No order selected";
         case ERR_UNKNOWN_SYMBOL:
            return "Unknown symbol";
         case ERR_INVALID_PRICE_PARAM:
            return "Invalid price parameter for trade function";
         case ERR_INVALID_TICKET:
            return "Invalid ticket";
         case ERR_TRADE_NOT_ALLOWED:
            return "Trade is not allowed in the expert properties";
         case ERR_LONGS_NOT_ALLOWED:
            return "Longs are not allowed in the expert properties";
         case ERR_SHORTS_NOT_ALLOWED:
            return "Shorts are not allowed in the expert properties";
         case ERR_TRADE_EXPERT_DISABLED_BY_SERVER:
            return "Automated trading by Expert Advisors/Scripts disabled by trade server";
         case ERR_OBJECT_ALREADY_EXISTS:
            return "Object already exists";
         case ERR_UNKNOWN_OBJECT_PROPERTY:
            return "Unknown object property";
         case ERR_OBJECT_DOES_NOT_EXIST:
            return "Object does not exist";
         case ERR_UNKNOWN_OBJECT_TYPE:
            return "Unknown object type";
         case ERR_NO_OBJECT_NAME:
            return "No object name";
         case ERR_OBJECT_COORDINATES_ERROR:
            return "Object coordinates error";
         case ERR_NO_SPECIFIED_SUBWINDOW:
            return "No specified subwindow";
         case ERR_SOME_OBJECT_ERROR:
            return "Graphical object error";
         case ERR_CHART_PROP_INVALID:
            return "Unknown chart property";
         case ERR_CHART_NOT_FOUND:
            return "Chart not found";
         case ERR_CHARTWINDOW_NOT_FOUND:
            return "Chart subwindow not found";
         case ERR_CHARTINDICATOR_NOT_FOUND:
            return "Chart indicator not found";
         case ERR_SYMBOL_SELECT:
            return "Symbol select error";
         case ERR_NOTIFICATION_ERROR:
            return "Notification error";
         case ERR_NOTIFICATION_PARAMETER:
            return "Notification parameter error";
         case ERR_NOTIFICATION_SETTINGS:
            return "Notifications disabled";
         case ERR_NOTIFICATION_TOO_FREQUENT:
            return "Notification send too frequent";
         case ERR_FTP_NOSERVER:
            return "Ftp server is not specified";
         case ERR_FTP_NOLOGIN:
            return "Ftp login is not specified";
         case ERR_FTP_CONNECT_FAILED:
            return "Ftp connect failed";
         case ERR_FTP_CLOSED:
            return "Ftp connection closed";
         case ERR_FTP_CHANGEDIR:
            return "Ftp path not found on server";
         case ERR_FTP_FILE_ERROR:
            return "Ftp file error";
         case ERR_FTP_ERROR:
            return "Ftp common error";
         case ERR_FILE_TOO_MANY_OPENED:
            return "Too many opened files";
         case ERR_FILE_WRONG_FILENAME:
            return "Wrong file name";
         case ERR_FILE_TOO_LONG_FILENAME:
            return "Too long file name";
         case ERR_FILE_CANNOT_OPEN:
            return "Cannot open file";
         case ERR_FILE_BUFFER_ALLOCATION_ERROR:
            return "Text file buffer allocation error";
         case ERR_FILE_CANNOT_DELETE:
            return "Cannot delete file";
         case ERR_FILE_INVALID_HANDLE:
            return "Invalid file handle (file closed or was not opened)";
         case ERR_FILE_WRONG_HANDLE:
            return "Wrong file handle (handle index is out of handle table)";
         case ERR_FILE_NOT_TOWRITE:
            return "File must be opened with FILE_WRITE flag";
         case ERR_FILE_NOT_TOREAD:
            return "File must be opened with FILE_READ flag";
         case ERR_FILE_NOT_BIN:
            return "File must be opened with FILE_BIN flag";
         case ERR_FILE_NOT_TXT:
            return "File must be opened with FILE_TXT flag";
         case ERR_FILE_NOT_TXTORCSV:
            return "File must be opened with FILE_TXT or FILE_CSV flag";
         case ERR_FILE_NOT_CSV:
            return "File must be opened with FILE_CSV flag";
         case ERR_FILE_READ_ERROR:
            return "File read error";
         case ERR_FILE_WRITE_ERROR:
            return "File write error";
         case ERR_FILE_BIN_STRINGSIZE:
            return "String size must be specified for binary file";
         case ERR_FILE_INCOMPATIBLE:
            return "Incompatible file (for string arrays-TXT, for others-BIN)";
         case ERR_FILE_IS_DIRECTORY:
            return "File is directory, not file";
         case ERR_FILE_NOT_EXIST:
            return "File does not exist";
         case ERR_FILE_CANNOT_REWRITE:
            return "File cannot be rewritten";
         case ERR_FILE_WRONG_DIRECTORYNAME:
            return "Wrong directory name";
         case ERR_FILE_DIRECTORY_NOT_EXIST:
            return "Directory does not exist";
         case ERR_FILE_NOT_DIRECTORY:
            return "Specified file is not directory";
         case ERR_FILE_CANNOT_DELETE_DIRECTORY:
            return "Cannot delete directory";
         case ERR_FILE_CANNOT_CLEAN_DIRECTORY:
            return "Cannot clean directory";
         case ERR_FILE_ARRAYRESIZE_ERROR:
            return "Array resize error";
         case ERR_FILE_STRINGRESIZE_ERROR:
            return "String resize error";
         case ERR_FILE_STRUCT_WITH_OBJECTS:
            return "Structure contains strings or dynamic arrays";
         case ERR_WEBREQUEST_INVALID_ADDRESS:
            return "Invalid URL";
         case ERR_WEBREQUEST_CONNECT_FAILED:
            return "Failed to connect to specified URL";
         case ERR_WEBREQUEST_TIMEOUT:
            return "HTTP timeout exceeded";
         case ERR_WEBREQUEST_REQUEST_FAILED:
            return "HTTP request failed";
#else
         //--- Constant Description
         case ERR_SUCCESS:
            return "The operation completed successfully";
         case ERR_INTERNAL_ERROR:
            return "Unexpected internal error";
         case ERR_WRONG_INTERNAL_PARAMETER:
            return "Wrong parameter in the inner call of the client terminal function";
         case ERR_INVALID_PARAMETER:
            return "Wrong parameter when calling the system function";
         case ERR_NOT_ENOUGH_MEMORY:
            return "Not enough memory to perform the system function";
         case ERR_STRUCT_WITHOBJECTS_ORCLASS:
            return "The structure contains objects of strings and/or dynamic arrays and/or structure of such objects and/or classes";
         case ERR_INVALID_ARRAY:
            return "Array of a wrong type, wrong size, or a damaged object of a dynamic array";
         case ERR_ARRAY_RESIZE_ERROR:
            return "Not enough memory for the relocation of an array, or an attempt to change the size of a static array";
         case ERR_STRING_RESIZE_ERROR:
            return "Not enough memory for the relocation of string";
         case ERR_NOTINITIALIZED_STRING:
            return "Not initialized string";
         case ERR_INVALID_DATETIME:
            return "Invalid date and/or time";
         case ERR_ARRAY_BAD_SIZE:
            return "Requested array size exceeds 2 GB";
         case ERR_INVALID_POINTER:
            return "Wrong pointer";
         case ERR_INVALID_POINTER_TYPE:
            return "Wrong type of pointer";
         case ERR_FUNCTION_NOT_ALLOWED:
            return "System function is not allowed to call";
         //--- Charts
         case ERR_CHART_WRONG_ID:
            return "Wrong chart ID";
         case ERR_CHART_NO_REPLY:
            return "Chart does not respond";
         case ERR_CHART_NOT_FOUND:
            return "Chart not found";
         case ERR_CHART_NO_EXPERT:
            return "No Expert Advisor in the chart that could handle the event";
         case ERR_CHART_CANNOT_OPEN:
            return "Chart opening error";
         case ERR_CHART_CANNOT_CHANGE:
            return "Failed to change chart symbol and period";
         //case ERR_CHART_WRONG_TIMER_PARAMETER:
         //   return "Wrong parameter for timer";
         case ERR_CHART_CANNOT_CREATE_TIMER:
            return "Failed to create timer";
         case ERR_CHART_WRONG_PROPERTY:
            return "Wrong chart property ID";
         case ERR_CHART_SCREENSHOT_FAILED:
            return "Error creating screenshots";
         case ERR_CHART_NAVIGATE_FAILED:
            return "Error navigating through chart";
         case ERR_CHART_TEMPLATE_FAILED:
            return "Error applying template";
         case ERR_CHART_WINDOW_NOT_FOUND:
            return "Subwindow containing the indicator was not found";
         case ERR_CHART_INDICATOR_CANNOT_ADD:
            return "Error adding an indicator to chart";
         case ERR_CHART_INDICATOR_CANNOT_DEL:
            return "Error deleting an indicator from the chart";
         case ERR_CHART_INDICATOR_NOT_FOUND:
            return "Indicator not found on the specified chart";
         //--- Graphical Objects
         case ERR_OBJECT_ERROR:
            return "Error working with a graphical object";
         case ERR_OBJECT_NOT_FOUND:
            return "Graphical object was not found";
         case ERR_OBJECT_WRONG_PROPERTY:
            return "Wrong ID of a graphical object property";
         case ERR_OBJECT_GETDATE_FAILED:
            return "Unable to get date corresponding to the value";
         case ERR_OBJECT_GETVALUE_FAILED:
            return "Unable to get value corresponding to the date";
         //--- MarketInfo
         case ERR_MARKET_UNKNOWN_SYMBOL:
            return "Unknown symbol";
         case ERR_MARKET_NOT_SELECTED:
            return "Symbol is not selected in MarketWatch";
         case ERR_MARKET_WRONG_PROPERTY:
            return "Wrong identifier of a symbol property";
         case ERR_MARKET_LASTTIME_UNKNOWN:
            return "Time of the last tick is not known (no ticks)";
         case ERR_MARKET_SELECT_ERROR:
            return "Error adding or deleting a symbol in MarketWatch";
         //--- History Access
         case ERR_HISTORY_NOT_FOUND:
            return "Requested history not found";
         case ERR_HISTORY_WRONG_PROPERTY:
            return "Wrong ID of the history property";
         //--- Global_Variables
         case ERR_GLOBALVARIABLE_NOT_FOUND:
            return "Global variable of the client terminal is not found";
         case ERR_GLOBALVARIABLE_EXISTS:
            return "Global variable of the client terminal with the same name already exists";
         case ERR_MAIL_SEND_FAILED:
            return "Email sending failed";
         case ERR_PLAY_SOUND_FAILED:
            return "Sound playing failed";
         case ERR_MQL5_WRONG_PROPERTY:
            return "Wrong identifier of the program property";
         case ERR_TERMINAL_WRONG_PROPERTY:
            return "Wrong identifier of the terminal property";
         case ERR_FTP_SEND_FAILED:
            return "File sending via ftp failed";
         case ERR_NOTIFICATION_SEND_FAILED:
            return "Error in sending notification";
         //--- Custom Indicator Buffers
         case ERR_BUFFERS_NO_MEMORY:
            return "Not enough memory for the distribution of indicator buffers";
         case ERR_BUFFERS_WRONG_INDEX:
            return "Wrong indicator buffer index";
         //--- Custom Indicator Properties
         case ERR_CUSTOM_WRONG_PROPERTY:
            return "Wrong ID of the custom indicator property";
         //--- Account
         case ERR_ACCOUNT_WRONG_PROPERTY:
            return "Wrong account property ID";
         case ERR_TRADE_WRONG_PROPERTY:
            return "Wrong trade property ID";
         case ERR_TRADE_DISABLED:
            return "Trading by Expert Advisors prohibited";
         case ERR_TRADE_POSITION_NOT_FOUND:
            return "Position not found";
         case ERR_TRADE_ORDER_NOT_FOUND:
            return "Order not found";
         case ERR_TRADE_DEAL_NOT_FOUND:
            return "Deal not found";
         case ERR_TRADE_SEND_FAILED:
            return "Trade request sending failed";
         //--- Indicators
         case ERR_INDICATOR_UNKNOWN_SYMBOL:
            return "Unknown symbol";
         case ERR_INDICATOR_CANNOT_CREATE:
            return "Indicator cannot be created";
         case ERR_INDICATOR_NO_MEMORY:
            return "Not enough memory to add the indicator";
         case ERR_INDICATOR_CANNOT_APPLY:
            return "The indicator cannot be applied to another indicator";
         case ERR_INDICATOR_CANNOT_ADD:
            return "Error applying an indicator to chart";
         case ERR_INDICATOR_DATA_NOT_FOUND:
            return "Requested data not found";
         case ERR_INDICATOR_WRONG_HANDLE:
            return "Wrong indicator handle";
         case ERR_INDICATOR_WRONG_PARAMETERS:
            return "Wrong number of parameters when creating an indicator";
         case ERR_INDICATOR_PARAMETERS_MISSING:
            return "No parameters when creating an indicator";
         case ERR_INDICATOR_CUSTOM_NAME:
            return "The first parameter in the array must be the name of the custom indicator";
         case ERR_INDICATOR_PARAMETER_TYPE:
            return "Invalid parameter type in the array when creating an indicator";
         case ERR_INDICATOR_WRONG_INDEX:
            return "Wrong index of the requested indicator buffer";
         //--- Depth of Market
         case ERR_BOOKS_CANNOT_ADD:
            return "Depth Of Market can not be added";
         case ERR_BOOKS_CANNOT_DELETE:
            return "Depth Of Market can not be removed";
         case ERR_BOOKS_CANNOT_GET:
            return "The data from Depth Of Market can not be obtained";
         case ERR_BOOKS_CANNOT_SUBSCRIBE:
            return "Error in subscribing to receive new data from Depth Of Market";
         //--- File Operations
         case ERR_TOO_MANY_FILES:
            return "More than 64 files cannot be opened at the same time";
         case ERR_WRONG_FILENAME:
            return "Invalid file name";
         case ERR_TOO_LONG_FILENAME:
            return "Too long file name";
         case ERR_CANNOT_OPEN_FILE:
            return "File opening error";
         case ERR_FILE_CACHEBUFFER_ERROR:
            return "Not enough memory for cache to read";
         case ERR_CANNOT_DELETE_FILE:
            return "File deleting error";
         case ERR_INVALID_FILEHANDLE:
            return "A file with this handle was closed, or was not opening at all";
         case ERR_WRONG_FILEHANDLE:
            return "Wrong file handle";
         case ERR_FILE_NOTTOWRITE:
            return "The file must be opened for writing";
         case ERR_FILE_NOTTOREAD:
            return "The file must be opened for reading";
         case ERR_FILE_NOTBIN:
            return "The file must be opened as a binary one";
         case ERR_FILE_NOTTXT:
            return "The file must be opened as a text";
         case ERR_FILE_NOTTXTORCSV:
            return "The file must be opened as a text or CSV";
         case ERR_FILE_NOTCSV:
            return "The file must be opened as CSV";
         case ERR_FILE_READERROR:
            return "File reading error";
         case ERR_FILE_BINSTRINGSIZE:
            return "String size must be specified, because the file is opened as binary";
         case ERR_INCOMPATIBLE_FILE:
            return "A text file must be for string arrays, for other arrays - binary";
         case ERR_FILE_IS_DIRECTORY:
            return "This is not a file, this is a directory";
         case ERR_FILE_NOT_EXIST:
            return "File does not exist";
         case ERR_FILE_CANNOT_REWRITE:
            return "File can not be rewritten";
         case ERR_WRONG_DIRECTORYNAME:
            return "Wrong directory name";
         case ERR_DIRECTORY_NOT_EXIST:
            return "Directory does not exist";
         case ERR_FILE_ISNOT_DIRECTORY:
            return "This is a file, not a directory";
         case ERR_CANNOT_DELETE_DIRECTORY:
            return "The directory cannot be removed";
         case ERR_CANNOT_CLEAN_DIRECTORY:
            return "Failed to clear the directory (probably one or more files are blocked and removal operation failed)";
         case ERR_FILE_WRITEERROR:
            return "Failed to write a resource to a file";
         //--- String Casting
         case ERR_NO_STRING_DATE:
            return "No date in the string";
         case ERR_WRONG_STRING_DATE:
            return "Wrong date in the string";
         case ERR_WRONG_STRING_TIME:
            return "Wrong time in the string";
         case ERR_STRING_TIME_ERROR:
            return "Error converting string to date";
         case ERR_STRING_OUT_OF_MEMORY:
            return "Not enough memory for the string";
         case ERR_STRING_SMALL_LEN:
            return "The string length is less than expected";
         case ERR_STRING_TOO_BIGNUMBER:
            return "Too large number, more than ULONG_MAX";
         case ERR_WRONG_FORMATSTRING:
            return "Invalid format string";
         case ERR_TOO_MANY_FORMATTERS:
            return "Amount of format specifiers more than the parameters";
         case ERR_TOO_MANY_PARAMETERS:
            return "Amount of parameters more than the format specifiers";
         case ERR_WRONG_STRING_PARAMETER:
            return "Damaged parameter of string type";
         case ERR_STRINGPOS_OUTOFRANGE:
            return "Position outside the string";
         case ERR_STRING_ZEROADDED:
            return "0 added to the string end, a useless operation";
         case ERR_STRING_UNKNOWNTYPE:
            return "Unknown data type when converting to a string";
         case ERR_WRONG_STRING_OBJECT:
            return "Damaged string object";
         //--- Operations with Arrays
         case ERR_INCOMPATIBLE_ARRAYS:
            return "Copying incompatible arrays. String array can be copied only to a string array, and a numeric array - in numeric array only";
         case ERR_SMALL_ASSERIES_ARRAY:
            return "The receiving array is declared as AS_SERIES, and it is of insufficient size";
         case ERR_SMALL_ARRAY:
            return "Too small array, the starting position is outside the array";
         case ERR_ZEROSIZE_ARRAY:
            return "An array of zero length";
         case ERR_NUMBER_ARRAYS_ONLY:
            return "Must be a numeric array";
         case ERR_ONEDIM_ARRAYS_ONLY:
            return "Must be a one-dimensional array";
         case ERR_SERIES_ARRAY:
            return "Timeseries cannot be used";
         case ERR_DOUBLE_ARRAY_ONLY:
            return "Must be an array of type double";
         case ERR_FLOAT_ARRAY_ONLY:
            return "Must be an array of type float";
         case ERR_LONG_ARRAY_ONLY:
            return "Must be an array of type long";
         case ERR_INT_ARRAY_ONLY:
            return "Must be an array of type int";
         case ERR_SHORT_ARRAY_ONLY:
            return "Must be an array of type short";
         case ERR_CHAR_ARRAY_ONLY:
            return "Must be an array of type char";
         //--- Operations with OpenCL
         case ERR_OPENCL_NOT_SUPPORTED:
            return "OpenCL functions are not supported on this computer";
         case ERR_OPENCL_INTERNAL:
            return "Internal error occurred when running OpenCL";
         case ERR_OPENCL_INVALID_HANDLE:
            return "Invalid OpenCL handle";
         case ERR_OPENCL_CONTEXT_CREATE:
            return "Error creating the OpenCL context";
         case ERR_OPENCL_QUEUE_CREATE:
            return "Failed to create a run queue in OpenCL";
         case ERR_OPENCL_PROGRAM_CREATE:
            return "Error occurred when compiling an OpenCL program";
         case ERR_OPENCL_TOO_LONG_KERNEL_NAME:
            return "Too long kernel name (OpenCL kernel)";
         case ERR_OPENCL_KERNEL_CREATE:
            return "Error creating an OpenCL kernel";
         case ERR_OPENCL_SET_KERNEL_PARAMETER:
            return "Error occurred when setting parameters for the OpenCL kernel";
         case ERR_OPENCL_EXECUTE:
            return "OpenCL program runtime error";
         case ERR_OPENCL_WRONG_BUFFER_SIZE:
            return "Invalid size of the OpenCL buffer";
         case ERR_OPENCL_WRONG_BUFFER_OFFSET:
            return "Invalid offset in the OpenCL buffer";
         case ERR_OPENCL_BUFFER_CREATE:
            return "Failed to create and OpenCL buffer";
#endif
        }
      return "Unknown error "+string(error_code);
     }
   static string     GetUninitReason(int reason=-1)
     {
      if(reason==-1) reason=_UninitReason;
      switch(reason)
        {
         case REASON_ACCOUNT:
            return "account changed";
         case REASON_CHARTCHANGE:
            return "symbol or timeframe changed";
         case REASON_CHARTCLOSE:
            return "chart closed";
         case REASON_CLOSE:
            return "terminal closed";
         case REASON_INITFAILED:
            return "init failed";
         case REASON_PARAMETERS:
            return "input parameter changed";
         case REASON_RECOMPILE:
            return "program '"+MQLInfoString(MQL_PROGRAM_NAME)+"' has been recompiled";
         case REASON_REMOVE:
            return "program '"+MQLInfoString(MQL_PROGRAM_NAME)+"' has been removed from chart";
         case REASON_TEMPLATE:
            return "new template has been applied to chart";
         default:
            return "program '"+MQLInfoString(MQL_PROGRAM_NAME)+"' terminated";
        }
     }
   static string     LoglevelToString(int level)
     {
      return StringSubstr(EnumToString((ENUM_LOG_LEVEL)level),9);
     }
  };
//+------------------------------------------------------------------+
