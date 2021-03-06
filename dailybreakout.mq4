//+------------------------------------------------------------------+
//|                                      Strategy: dailybreakout.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "https://www.eabuilder.com"
#property version   "1.00"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>
    #include <log4mqlm.mqh>
enum Answer{Yes,No};


//---- input parameters news

       extern  ENUM_LICENSE_TYPE LicenseMode=LICENSE_DEMO;//EA License Mode
       extern string License="NOEL307";//  License Key
   //+------------------------------------------------------------------+
//| Inputs                                                           |
//|  add your inputs here                                            |
//+------------------------------------------------------------------+
input ENUM_LOG_LEVEL InpLoglevel=LOGLEVEL_INFO; // Log Level (Info = normal logging)

    
input bool Send_Email = true;
input bool Audible_Alerts = true;
input bool Push_Notifications = true;
extern int SR_Intervalyg = 12;
extern int SR_Intervalygt = 5;
extern int Period1 = 20;
extern int SR_Interval8 = 15;
extern double TR = 100;

int LotDigits; //initialized in OnInit

extern long           MagicNumber=99333;

extern string InpData="ACTIVITIES";//DATA FILES NAME

input int TOD_From_Hour = 09; //EA START HOUR
input int TOD_From_Min = 45; //EA START MIN
input int TOD_To_Hour = 16; //EA STOP HOUR
input int TOD_To_Min = 15; //EA START MIN

input double MM_Martingale_Start = 0.01;
input double MM_Martingale_ProfitFactor = 1;
input double MM_Martingale_LossFactor = 2;
input bool MM_Martingale_RestartProfit = false;
bool MM_Martingale_RestartLoss = false;

input int MM_Martingale_RestartLosses = 4;
input int MM_Martingale_RestartProfits = 4;
extern int MaxSlippage = 3; //slippage, adjusted in OnInit
input bool TradeMonday = true;
input bool TradeTuesday = true;
input bool TradeWednesday = true;
input bool TradeThursday = true;
input bool TradeFriday = true;
input bool TradeSaturday = false;
input bool TradeSunday = true;
bool crossed[2]; //initialized to true, used in function Cross
extern int MaxOpenTrades = 10;
extern int MaxLongTrades = 4;
extern int MaxShortTrades = 4;
int MaxPendingOrders = 10;
int MaxLongPendingOrders = 10;
int MaxShortPendingOrders = 10;
  input  string     mysymbol        ="ZARJPY,USDZAR,USDTHD,USDNOK,USDMXN,USDJPY,USDHKD,USDCZK,USDCZK,TRYJPY,SGDCHF,EURUSD,USDJPY,GBPUSD,AUDUSD,USDCAD,USDCHF,NZDUSD,EURJPY,EURGBP,EURCAD,EURCHF,EURAUD,EURNZD,AUDJPY,CHFJPY,CADJPY,NZDJPY,GBPJPY,GBPCHF,GBPAUD,GBPCAD,CADCHF,AUDCHF,GBPNZD,AUDNZD,AUDCAD,NZDCAD,NZDCHF";//List of Symbol
    
       input Answer UseAllsymbol=Yes;//Use All symbols  ?(Yes/No)
       input Answer InpSelectPairs_By_Basket_Schedule =No;//Select Pairs By Schedule Time
       input  string  symbolList1="USDCAD,EURUSD,AUDUSD";//BASKET LIST 1;
       input datetime start1=D'2021.01.19 04:00';
       input datetime stop1=D'2025.01.19 06:00';
       input const string symbolList2="EURGBP,AUDCAD";//BASKET LIST 2;
       input datetime start2=D'2022.03.19 09:00';
       input datetime stop2=D'2025.01.20 11:00';
       input  string symbolList3="USDJPY,AUDJPY";//BASKET LIST 3;
       input  datetime start3=D'2022.05.18 14:00';
       input datetime stop3=D'2025.11.18 15:00';
       string mysymbolList[];//list of stored symbols
extern bool Hedging = true;
       enum  ORDERS_TYPE { MARKET_ORDERS=0,// MARKET ORDER
                           LIMIT_ORDERS=1,//LIMIT ORDER
    
                           STOP_ORDERS=2//STOP ORDER
    
                         };
                         
 input  ORDERS_TYPE Order_Type=MARKET_ORDERS; //Orders Types;
input string ss;//====  CHART COLOR SETTING ============

input color Bear Candle=clrRed;
input color Bull Candle=clrGreen;
input  color Bear_Outline=clrRed;
input color Bull_Outline=clrGreen;
 input color BackGround=clrAzure;
 input color ForeGround=clrBlue;
int OrderRetry = 5; //# of retries if sending order returns error
int OrderWait = 5; //# of seconds to wait if sending order returns error
double myPoint; //initialized in OnInit
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
Log4mql L4mq(InpLoglevel);

        int      iCount      =  0;
          double   Lotbuyy      =  0;
          double   Lotselll      =  0;
          double   LastOPBuy      =  0;
          double   LastOPSell      =  0;
          double   OrderSLbuy    =  0;
          double   OrderSLsell    =  0;
          double   LastLotsBuy    =  0;
          double   LastLotsSell    =  0;
          datetime      LastTimeBuy    =  0;
          datetime      LastTimeSell    =  0;
       ///////////////////////////////////////VARIABLES/////////////////////////////////
        bool LongTradingts261M30=false;
             bool      ShortTradingts261M30=true;
             bool  LongTradingts261H1=true;
                  bool ShortTradingts261H1=false;
                 bool  LongTradingts261M5=true;
                  bool ShortTradingts261M5=false;
       //--- internals
         string indName0 ="OFF";
          string indName1="OFF";
          string indName2="OFF";
          string indName3="OFF";
          string mytrade="tradePic";
       int timer_ms;
    
       int  TBa=0;//Total buy ordes counter
       bool _isBuy[];                //--- buy state array for each symbol
       bool _isSell[];               //--- sell state array for each symbol
       int SymbolButtonSelected = 0; //--- index of symbol button pressed
    
       string messages="no message";
       string a111="a111", b111="b111",p111="p111",v111="v111";
       string  EXPERT_VERSION="4.0";//expert version
    

       // SL if strength for pair is crossing or crossed
    
       int                       x_axis                    =0;
       int                       y_axis                    =20;
         ENUM_ORDER_TYPE expected_signal = OP_BUY;
       bool                      UseDefaultPairs            = true;              // Use the default 28 pairs
       string                    OwnPairs                   = "";                // Comma seperated own pair list
    
       double Px = 0, Sx = 0, Rx = 0, S1x = 0, R1x = 0, S2x = 0, R2x = 0, S3x = 0, R3x = 0;//support and resistance pivot variables
    
    
   //---- Get new daily prices & calculate pivots
       double cur_day  = 0;
       double yesterday_close = 0,
              today_open = 0,
              yesterday_high = 0,//day_high;
              yesterday_low = 0,//day_low;
              day_high = 0,
              day_low  =0;
       double prev_day = cur_day;
       int TargetReachedForDay=-1;
       int ThisDayOfYear=0;
       datetime TMN=0;
       datetime NewCandleTime=0;
       string postfix="",prefix="";
       bool Os,Om,Od,Oc;
       bool CloseOP=false;
       int vdigits=4;
    
    
    
       int ttlbuy=0,ttlsell=0;
       ///
//+------------------------------------------------------------------+
//| Some function to demonstrate logging                             |
//+------------------------------------------------------------------+
void SomeFunction(double bid,double ask,double stoploss)
  {
   PRINTF("bid:%g ask:%g",bid,ask);              // 2021.01.18 00:01:00  log4mqlm_sample EURUSD,M1: SomeFunction: bid:1.2082 ask:1.20828
   DEBUGF("sl:%g",stoploss);                     // 2021.01.18 00:01:00  log4mqlm_sample EURUSD,M1: SomeFunction(log4mqlm_sample.mq4:65): sl:1.20816
   if(MathAbs(bid-stoploss)<10*_Point)
      WARNF("stoploss too tight: %g",stoploss);  // 2021.01.18 00:01:00  log4mqlm_sample EURUSD,M1: WARN SomeFunction(log4mqlm_sample.mq4:67): stoploss too tight: 1.20816
  }
       bool alarm_fibo_level_1=false;
       bool alarm_fibo_level_2=false;
       bool alarm_fibo_level_3=false;
       bool alarm_fibo_level_4=false;
       bool alarm_fibo_level_5=false;
       bool alarm_fibo_level_6=false;
       bool alarm_fibo_level_7=false;
       bool alarm_fibo_level_8=false;
       bool alarm_fibo_level_9=false;
       bool alarm_fibo_level_10=false;
    
       int fibo_levels=11;
       double current_high;
       double current_low;
       double price_delta;
    
       string headerString = "AutoFibo_";
    
    double ProfitValue=0;
    
    
    
       //-------- Debit/Credit total -------------------
       //+------------------------------------------------------------------+
       //|                        StopTarget                                          |
       //+------------------------------------------------------------------+
    
    
       bool StopTarget(double P1s)
         {
          if((P1s/(AccountBalance()+1)) *100 >= ProfitValue){ return (true);}
          return (false);
         }
    

              string _split=mysymbol;
       string _sep=",";                                                 // A separator as a character
    
        ushort   _u_sep=StringGetCharacter(_sep,0);
    
    
        //--- Set the number of symbols in SymbolArraySize
        ushort  u_sep=StringGetCharacter(_sep,0);
          int kss=StringSplit(mysymbol,u_sep,mysymbolList);
    
         int  NumOfSymbols = ArraySize(mysymbolList);
    
bool inTimeInterval(datetime t, int From_Hour, int From_Min, int To_Hour, int To_Min)
  {
   string TOD = TimeToString(t, TIME_MINUTES);
   string TOD_From = StringFormat("%02d", From_Hour)+":"+StringFormat("%02d", From_Min);
   string TOD_To = StringFormat("%02d", To_Hour)+":"+StringFormat("%02d", To_Min);
   return((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, TOD_To) <= 0)
     || (StringCompare(TOD_From, TOD_To) > 0
       && ((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, "23:59") <= 0)
         || (StringCompare(TOD, "00:00") >= 0 && StringCompare(TOD, TOD_To) <= 0))));
  }

double MM_Size() //martingale / anti-martingale
  {
   double lots = MM_Martingale_Start;
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   if(SelectLastHistoryTrade())
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * MM_Martingale_ProfitFactor;
      else if(orderprofit + boprofit < 0 && !MM_Martingale_RestartLoss)
         lots = orderlots * MM_Martingale_LossFactor;
      else if(orderprofit + boprofit == 0)
         lots = orderlots;
     }
   if(ConsecutivePL(false, MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(ConsecutivePL(true, MM_Martingale_RestartProfits))
      lots = MM_Martingale_Start;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   
   for(int ik=0;ik<OrdersTotal();ik++){
   if( OrderSelect(ik,SELECT_BY_TICKET,MODE_TRADES) && lots==OrderLots() &&OrderSymbol()==Symbol()) {
   lots=lots*2;}
   }
   return(lots);
  }

bool TradeDayOfWeek()
  {
   int day = DayOfWeek();
   return((TradeMonday && day == 1)
   || (TradeTuesday && day == 2)
   || (TradeWednesday && day == 3)
   || (TradeThursday && day == 4)
   || (TradeFriday && day == 5)
   || (TradeSaturday && day == 6)
   || (TradeSunday && day == 0));
  }

bool Cross(int i, bool condition) //returns true if "condition" is true and was false in the previous call
  {
   bool ret = condition && !crossed[i];
   crossed[i] = condition;
   return(ret);
  }

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | dailybreakout @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     } 
   return(lastOrder >= 0);
  }

double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+IntegerToString(ticket)+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutivePL(bool profits, int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if((!profits && orderprofit + boprofit >= 0) || (profits && orderprofit + boprofit <= 0))
            break;
         count++;
        }
     }
   return(count >= n);
  }

int myOrderSend(int type, double price, double volume, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   if(!IsTradeAllowed()) return(-1);
   int ticket = -1;
   int retries = 0;
   int err = 0;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   //test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert("print", "Order"+ordername_+" not sent, hedging not allowed");
      return(-1);
     }
   //test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
   || (type % 2 == 1 && short_trades >= MaxShortTrades)
   || (long_trades + short_trades >= MaxOpenTrades)
   || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders)
   || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders)
   || (type > 1 && long_pending + short_pending >= MaxPendingOrders)
   )
     {
      myAlert("print", "Order"+ordername_+" not sent, maximum reached");
      return(-1);
     }
   //prepare to send order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(type == OP_BUY)
      price = Ask;
   else if(type == OP_SELL)
      price = Bid;
   else if(price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
   int clr = (type % 2 == 1) ? clrRed : clrBlue;
   while(ticket < 0 && retries < OrderRetry+1)
     {
      ticket = (int)OrderSend(Symbol(), type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, 0, 0, ordername, MagicNumber, 0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(ticket < 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+Symbol()+" Magic #"+IntegerToString(MagicNumber));
   return(ticket);
  }
 
       //+------------------------------------------------------------------+
       //|                 Check Demo Period                                |
       //+------------------------------------------------------------------+
       bool CheckDemoPeriod(int day,int month,int year)
         {
          if(
             (TimeDay(TimeCurrent())>=day && TimeMonth(TimeCurrent())==month && TimeYear(TimeCurrent())==year) ||
             (TimeMonth(TimeCurrent())>month && TimeYear(TimeCurrent())==year) ||
             (TimeYear(TimeCurrent())>year)
          )
            {
    
    
             Print("@TradeExpert: EA"+EnumToString(LicenseMode)+" version expired..!");
             MessageBox("TradeExpert EA "+EnumToString(LicenseMode)+" Version expired....!|Contact Seller: NGUEMECHIEU@LIVE.COM","Error:");
             //  EABlocked=true;
             return false;
            }
          else
             return(true);
    
         }
    
int myOrderModify(int ticket, double SL, double TP) //modify SL and TP (absolute price), zero targets do not modify
  {
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = NormalizeDouble(SL, Digits());
   TP = NormalizeDouble(TP, Digits());
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(ticket, NormalizeDouble(OrderOpenPrice(), Digits()), NormalizeDouble(SL, Digits()), NormalizeDouble(TP, Digits()), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+IntegerToString(ticket);
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
   myAlert("modify", alertstr);
   return(0);
  }

int myOrderModifyRel(int ticket, double SL, double TP) //modify SL and TP (relative to open price), zero targets do not modify
  {
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = NormalizeDouble(SL, Digits());
   TP = NormalizeDouble(TP, Digits());
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   //convert relative to absolute
   if(OrderType() % 2 == 0) //buy
     {
      if(NormalizeDouble(SL, Digits()) != 0)
         SL = OrderOpenPrice() - SL;
      if(NormalizeDouble(TP, Digits()) != 0)
         TP = OrderOpenPrice() + TP;
     }
   else //sell
     {
      if(NormalizeDouble(SL, Digits()) != 0)
         SL = OrderOpenPrice() + SL;
      if(NormalizeDouble(TP, Digits()) != 0)
         TP = OrderOpenPrice() - TP;
     }
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(ticket, NormalizeDouble(OrderOpenPrice(), Digits()), NormalizeDouble(SL, Digits()), NormalizeDouble(TP, Digits()), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+IntegerToString(ticket);
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
   myAlert("modify", alertstr);
   return(0);
  }

void DrawLine(string objname, double price, int count, int start_index) //creates or modifies existing object if necessary
  {
   if((price < 0) && ObjectFind(objname) >= 0)
     {
      ObjectDelete(objname);
     }
   else if(ObjectFind(objname) >= 0 && ObjectType(objname) == OBJ_TREND)
     {
      ObjectSet(objname, OBJPROP_TIME1, Time[start_index]);
      ObjectSet(objname, OBJPROP_PRICE1, price);
      ObjectSet(objname, OBJPROP_TIME2, Time[start_index+count-1]);
      ObjectSet(objname, OBJPROP_PRICE2, price);
     }
   else
     {
      ObjectCreate(objname, OBJ_TREND, 0, Time[start_index], price, Time[start_index+count-1], price);
      ObjectSet(objname, OBJPROP_RAY, false);
      ObjectSet(objname, OBJPROP_COLOR, C'0x00,0x00,0xFF');
      ObjectSet(objname, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(objname, OBJPROP_WIDTH, 2);
     }
  }

double Support(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = Low[iLowest(NULL, 0, MODE_LOW, count, start_index)];
   if (draw) DrawLine("Support", ret, count, start_index);
   return(ret);
  }

double Resistance(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = High[iHighest(NULL, 0, MODE_HIGH, count, start_index)];
   if (draw) DrawLine("Resistance", ret, count, start_index);
   return(ret);
  }

void TrailingStopSet(int type, double price) //set Stop Loss at "price"
  {
   int total = OrdersTotal();
   for(int i = total-1; i >= 0; i--)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      if(OrderStopLoss() == 0
      || (type == OP_BUY && (NormalizeDouble(OrderStopLoss(), Digits()) <= 0 || price > OrderStopLoss()))
      || (type == OP_SELL && (NormalizeDouble(OrderStopLoss(), Digits()) <= 0 || price < OrderStopLoss())))
         myOrderModify(OrderTicket(), price, 0);
     }
  }

bool NewBar()
  {
   static datetime LastTime = 0;
   bool ret = Time[0] > LastTime && LastTime > 0;
   LastTime = Time[0];
   return(ret);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   ChartColorSet();
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
      MaxSlippage *= 10;
     }
     
     
   
   string  license_code[100]={ } ;
 int i= MathRand()%100;
  string temp[100]={};
  
  temp[i]="Qh3"+(string)i;
   temp[0]="N"+(string)i+"k34"; temp[1]="Qh3W"; temp[2]="34"+(string)i+"F"; temp[3]="TYO4"; temp[4]="YNO"+(string)i;
  
  int handle = FileOpen("BreakoutFighter", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         
         for(int k=0;k<5;k++){
         license_code[k]=temp[3]+"-"+temp[4]+"-"+temp[0]+"-"+temp[1];
  
         FileWrite(handle, "CODE: "+ (string)license_code[k]+ "TimeStamp :"+(string)TimeCurrent());
         }
         FileClose(handle);
        }
  
 
   if((LicenseMode==LICENSE_DEMO||LicenseMode==LICENSE_FREE)&& License=="NOEL307"&&CheckDemoPeriod(1,3,2022)==true){
   
   
   printf("Your license is valid");
   
   }else  if(LicenseMode==LICENSE_FULL && License==license_code[2] ){
   
   
   printf("Your license is valid");
   
   }else  if(LicenseMode==LICENSE_TIME &&License==license_code[0]&& CheckDemoPeriod(12,1,2022)){
   
   
   printf("Your license is valid");
   
   }else { 
   Comment("LICENSE KEY EXPIRED \n PLEASE CONTACT SUPPORT AT : NGUEMECHIEU@LIVE.COM TO GET A NEW LICENSE ");
  MessageBox( "LICENSE KEY EXPIRED : PLEASE CONTACT SUPPORT AT : NGUEMECHIEU@LIVE.COM TO GET A NEW SUBSCRIPTION","INVALID LICENSE ",1);
   
   return INIT_FAILED;
   }
   //initialize LotDigits
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if(NormalizeDouble(LotStep, 3) == round(LotStep))
      LotDigits = 0;
   else if(NormalizeDouble(10*LotStep, 3) == round(10*LotStep))
      LotDigits = 1;
   else if(NormalizeDouble(100*LotStep, 3) == round(100*LotStep))
      LotDigits = 2;
   else LotDigits = 3;
  
   
   
Comment("\nContact : https://t.me/tradeexpert_infos\n\nEmail:nguemechieu@live.com"  );
   //initialize crossed
   for (i = 0; i < ArraySize(crossed); i++){
      crossed[i] = true;}
   return(INIT_SUCCEEDED);
  }

       //+------------------------------------------------------------------+
       //|                       TradeScheduleSymbol                        |
       //+------------------------------------------------------------------+
       string  TradeScheduleSymbol(int symbolindex, Answer selectByBasket)  //execute trade base on schedule symbols
         {
          if(selectByBasket==Yes)
            {
    
    
    
             int schedulselect=0;
             if(TimeCurrent()<start1 &&TimeCurrent()<stop1)
               {
    
                schedulselect=1;
    
               }
             else
                if(TimeCurrent()<start2 &&TimeCurrent()<stop2)
                  {
    
    
                   schedulselect=2;
    
                  }
                else
                   if(TimeCurrent()<start3 &&TimeCurrent()<stop3)
                     {
    
                      schedulselect=3;
                     }
    
             if(schedulselect==1&&symbolList1!=NULL) //time interval 1
               {
                string symbolList11[];
                _split=symbolList1;
    
                _u_sep=StringGetCharacter(_sep,0);
              int Per_k=StringSplit(_split,_u_sep,symbolList11);
    
                //--- Set the number of symbols in SymbolArraySize
                NumOfSymbols = ArraySize(symbolList11);
    
    
                return symbolList11[symbolindex];
    
               }
             else
                if(schedulselect==2&&symbolList2!=NULL) //time interval 2
                  {
                   string symbolList22[];
    
                   _split=symbolList2;
    
                   _u_sep=StringGetCharacter(_sep,0);
                  int Per_k=StringSplit(_split,_u_sep,symbolList22);
    
                   //--- Set the number of symbols in SymbolArraySize
                   NumOfSymbols = ArraySize(symbolList22);
    
    
                   return symbolList22[symbolindex];
                  }
                else
                   if(schedulselect==3&&symbolList3!=NULL) //time interval 3
                     {
                      string symbolList33[];
                     _split=symbolList3;
                      _u_sep=StringGetCharacter(_sep,0);
                  int Per_k=StringSplit(_split,_u_sep,symbolList33);
    
                      //--- Set the number of symbols in SymbolArraySize
                      NumOfSymbols = ArraySize(symbolList33);
    
    
                      return symbolList33[symbolindex];
    
                     }else if((symbolList1==NULL||symbolList2==NULL||symbolList3==NULL)){
    
                     MessageBox("Basket list cannot be empty","Warning",1);
                     printf("Basket list cannot be empty");
                     };
    
            }
    
          else if(UseAllsymbol==Yes&&selectByBasket==No)
            {
    
    
       string sep=",";                // A separator as a character
    
        u_sep=StringGetCharacter(sep,0);
        int Per_k=StringSplit(mysymbol,u_sep,mysymbolList);
    
                //--- Set the number of symbols in SymbolArraySize
                NumOfSymbols = ArraySize(mysymbolList);
    
             return mysymbolList[symbolindex];
             }
            ; //Go back to normal Trading time
          return  Symbol();
         }
     
     string overboversellSymbol[1];
    
       
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

          
            //---TELEGRAM BOTCONTROL
          if(reason==REASON_CLOSE ||
                reason==REASON_PROGRAM ||
                reason==REASON_PARAMETERS ||
                reason==REASON_REMOVE ||
                reason==REASON_RECOMPILE ||
                reason==REASON_ACCOUNT ||
                reason==REASON_INITFAILED)
          {
    
            
          }
       //--- destroy timer
          TRACE("closing, reason: ",L4mq.GetUninitReason());
   string file=InpData;
   int fh=FileOpen(file,FILE_READ);
   if(fh==INVALID_HANDLE){
      ERRORF("open '%s' failed",file);           // 2021.01.18 00:01:00  log4mqlm_sample EURUSD,M1: ERROR OnDeinit(log4mqlm_sample.mq4:88): open 'some file' failed,  error 5004 - Cannot open file
   TRACE("exit");
    }  
          EventKillTimer();
    
  }
    
         
       //+------------------------------------------------------------------+
       //|                       CloseAll                                            |
       //+------------------------------------------------------------------+
    
    
       void CloseAll()
         {
          int totalOP  = OrdersTotal(),tiket=0;
          for(int cnt = totalOP-1 ; cnt >= 0 ; cnt--)
            {
             Os=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
             if(OrderType()==OP_BUY && OrderMagicNumber() == MagicNumber)
               {
                Oc=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), MaxSlippage, clrViolet);
                Sleep(300);
                continue;
               }
             if(OrderType()==OP_SELL && OrderMagicNumber() == MagicNumber)
               {
                Oc=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), MaxSlippage, clrYellow);
                Sleep(300);
               }
            }
         }
  
void myOrderClose(string symbol,int type, double volumepercent, string ordername) //close open orders for current symbol, magic number and "type" (OP_BUY or OP_SELL)
  {
   if(!IsTradeAllowed()) return;
   if (type > 1)
     {
      myAlert("error", "Invalid type in myOrderClose");
      return;
     }
   bool success = false;
   int err = 0;
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != symbol || OrderType() != type) continue;
         orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      double price = (type == OP_SELL) ? SymbolInfoDouble(symbol,SYMBOL_ASK) : SymbolInfoDouble(symbol,SYMBOL_BID);
      double volume = NormalizeDouble(OrderLots()*volumepercent * 1.0 / 100, LotDigits);
      if (NormalizeDouble(volume, LotDigits) == 0) continue;
      success = OrderClose(OrderTicket(), volume, NormalizeDouble(price, (int)MarketInfo(symbol,MODE_DIGITS)), MaxSlippage, clrWhite);
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderClose"+ordername_+" failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
        }
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   if(success) myAlert("order", "Orders closed"+ordername_+": "+typestr[type]+" "+symbol+" Magic #"+IntegerToString(MagicNumber));
  }
  //+------------------------------------------------------------------+
       //|                    CheckStochts261m30                                              |
       //+------------------------------------------------------------------+
       string CheckStochts261m30(string symb)
         {
          double ts261m30=0;
          double OverSold=0;
          double OverBought=0;
          for(int i=1;i>=0;i--){
             ts261m30=iCustom(symb,Period(),"1mfsto",30,30,30,3,i);
    
             OverSold=-45;
             OverBought=45;
             overboversellSymbol[0]=symb;
             if(bar!=Bars)
               {
                if(ts261m30<OverSold)
                  {
                   LongTradingts261M30=true;
                   return "OverBought";
                   ShortTradingts261M30=false;
                  }
                if(ts261m30>OverBought)
    
                  {
                   LongTradingts261M30=false;
                    ShortTradingts261M30=true;
                    return "OverSold";
                  }
    
    
    
    
               }
            }
    
            return "NONE";
    
         }
         
         int bar=Bars;

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  { int count=0;double P1=0,Persentase1=0;double TSa=0,TB=0,TS=0,  TO=0,PB=0
                ,PS=0,
                LTS=0,LTB=0;
         kss=StringSplit(mysymbol,u_sep,mysymbolList);
    
        NumOfSymbols = ArraySize(mysymbolList);
    
  int i=MathRand()%NumOfSymbols;
  
  
        if(! IsExpertEnabled()){
      MessageBox("Expert is not enable!","EA ERROR",1);
    return;
    
         }else if(!IsConnected()){
    
         MessageBox("EA IS NOT CONNECTED!","CONNEXION ERROR",1);
         return;
         
         }
    
     double One_Lot=0,minbalance=50;
     string symbol=TradeScheduleSymbol(i,InpSelectPairs_By_Basket_Schedule);
          datetime start_= StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " 00:00");
          bool TARGET=false;
      ThisDayOfYear=DayOfYear();
    
         string status2="Copyright © 2022, NOEL M NGUEMECHIEU";
       ObjectCreate("M5", OBJ_LABEL, 0, 0, 0);
       ObjectSetText("M5",status2,10,"Arial",clrBlue);
       ObjectSet("M5", OBJPROP_CORNER, 2);
       ObjectSet("M5", OBJPROP_XDISTANCE, 0);
       ObjectSet("M5", OBJPROP_YDISTANCE, 0);
       
          
               bool insuBal=false;//init insulBal
             if(One_Lot!=0)
               {
                 if(MM_Size()>floor(AccountFreeMargin()/One_Lot*100)/100)
                  {
                   Print("Insuffisant balance!");
    
               Alert(" Insuffisant balance! ");
                 insuBal=true; //condition matched for open stop orders
                  }
                else if(MM_Size()<0.01){
                MessageBox(" lot is below min lot 0.01","Lot error",1);
                   return;}
               }
             if (AccountBalance()<minbalance){
              Alert("ACCOUNT BALANCE LOWER IS THAN THE MINIMUM SET EA WILL NOT TRADE","BALANCE ERROR",1);
               return;
               }else
    
                  if(AccountBalance()>0)
            {
             Persentase1=(P1/AccountBalance())*100;
    
            }
    
            // Calculer les floating profits pour le magic
           for(i=0; i<OrdersTotal(); i++)
            {
             int xx=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
             if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
               {
                PB+=OrderProfit()+OrderCommission()+OrderSwap();
               }
             if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
               {
                PS+=OrderProfit()+OrderCommission()+OrderSwap();
               }
            }
        // Profit floating pour toutes les paires , variable TPM
    
          // if(TPm>0&&PB+PS>=TPm)
           if(1<0)
            {
            MessageBox("Profit TP closing all trades.PB,PS "+string(PB+PS),"PROFIT TP",1);
                      CloseAll();
             
            
            }
    
          // Si les floating profit + ce qui est déjà fermé, pour le magic,  atteint le daily profit, on vire les trades pour le magic
          // Si non on reparcourt les ordres pour gérer les martis
          double DailyProfit=P1+PB+PS;
    
          if(ProfitValue>0 && ((P1+PB+PS)/(AccountEquity()-(P1+PB+PS)))*100 >=ProfitValue &&  TargetReachedForDay!=ThisDayOfYear )
               {
    
                 TargetReachedForDay=ThisDayOfYear;
                  CloseAll();
           MessageBox( "Daily Target reached. Closed running trades No More trading","TARGET REACHED",1);
                return;
               }
           else
               {
           for(i=0; i<OrdersTotal(); i++)
            {
             int xx=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
             if(!xx)continue;
             if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
               {
                TO++;
                TB++;
                PB+=OrderProfit()+OrderCommission()+OrderSwap();
                LTB+=OrderLots();
           //if(closeAskedFor!= "BUY"+OrderSymbol())
                   myOrderClose(OrderSymbol(),OP_BUY,100,"Market sell closed");
               }
             if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
               {
                TO++;
                TS++;
                PS+=OrderProfit()+OrderCommission()+OrderSwap();
                LTS+=OrderLots();
                //if(closeAskedFor!= "SELL"+OrderSymbol())
                    myOrderClose(OrderSymbol(),OP_SELL,100,"Market buy closed");
               }
            }
          }
          int y_offset = 0;//--- GUI Debugging utils used in GetOpeningSignals,GetClosingSignals
            
    string results="";
         if(CheckStochts261m30(symbol)=="OverBought")
            {
             messages= StringFormat("%s\n%s %s\n------------------------", overboversellSymbol[0],"___ is_OverBought______ "  ,EnumToString(PERIOD_M30));
             results="OverBought";
                          }
          else
             if(CheckStochts261m30(symbol)=="OverSold")
               {results="OverSold";
                messages= StringFormat("%s\n%s %s\n------------------------", overboversellSymbol[0],"____is__OverSold______ "  ,EnumToString(PERIOD_M30));
               }
   
   //storing data into inpdata csv file
  
    //Open file read and write unicode  format 
      
   int filestoreHandle=  FileOpen(InpData,FILE_READ|FILE_WRITE|FILE_IS_CSV|FILE_UNICODE);
     
    if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)&&OrderMagicNumber()==MagicNumber &&OrderSymbol()==symbol){
 
    //go to end of file
     FileSeek(filestoreHandle,0,SEEK_END);
    // write file content
    
      double pf=0, pl=0;
      if(OrderProfit()>0)
     { pf+=OrderProfit();
      }else {
      pl+=OrderProfit();
      
      }
    string result;
    result+=StringFormat(" %s    Price :%2.4f  Open:%2.4f  Close  :%2.4f Lot :%2.4f profit:%2.4f Losses :%2.4f  Date  :%2.4f" ,symbol,Ask ,OrderOpenPrice(),OrderClosePrice(),OrderLots(),pf,pl,TimeCurrent());
    FileWrite(filestoreHandle,result );
    //close file
    FileClose(filestoreHandle);
     
        } 
        
          double pb=0,ps=0;
          for(iCount=0; iCount<OrdersTotal(); iCount++)
            {
             int xx=OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES);
             if((OrderType()==OP_BUY || OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT) && OrderSymbol()==symbol && OrderMagicNumber()==MagicNumber )
               {
                pb+=OrderProfit()+OrderCommission()+OrderSwap();
                Lotbuyy+=OrderLots();
                OrderSLbuy = OrderStopLoss();
                if(LastTimeBuy==0)
                  {
                   LastTimeBuy=OrderOpenTime();
                  }
                if(LastTimeBuy>OrderOpenTime())
                  {
                   LastTimeBuy=OrderOpenTime();
                  }
                if(LastOPBuy==0)
                  {
                   LastOPBuy=OrderOpenPrice();
                  }
                if(LastOPBuy>OrderOpenPrice())
                  {
                   LastOPBuy=OrderOpenPrice();
                  }
                if(LastLotsBuy==0)
                  {
                   LastLotsBuy=OrderLots();
                  }
                if(LastLotsBuy>OrderLots())
                  {
                   LastLotsBuy=OrderLots();
                  }
                TB++;
               }
             if((OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP) && OrderSymbol()==symbol&& OrderMagicNumber()==MagicNumber)
               {
                ps+=OrderProfit()+OrderCommission()+OrderSwap();
                Lotselll+=OrderLots();
                OrderSLsell = OrderStopLoss();
                if(LastTimeSell==0)
                  {
                   LastTimeSell=OrderOpenTime();
                  }
                if(LastTimeSell>OrderOpenTime())
                  {
                   LastTimeSell=OrderOpenTime();
                  }
                if(LastOPSell==0)
                  {
                   LastOPSell=OrderOpenPrice();
                  }////////
                if(LastOPSell<OrderOpenPrice())
                  {
                   LastOPSell=OrderOpenPrice();
                  }
                if(LastLotsSell==0)
                  {
                   LastLotsSell=OrderLots();
                  }
                if(LastLotsSell>OrderLots())
                  {
                   LastLotsSell=OrderLots();
                  }
                TS++;
               }
            }
          if( TargetReachedForDay != ThisDayOfYear  && !StopTarget(P1) && AccountBalance() > minbalance)
            {
               double prs=0,prb=0;
    
             for(int pos=0; pos<=OrdersTotal(); pos++)
               {
                if(!OrderSelect(pos,SELECT_BY_POS))
                  {
                   continue;
                  }
                if(OrderMagicNumber()==MagicNumber && OrderSymbol()==symbol&& OrderType()==OP_BUY)
                  {
                   TBa++;
                  }
                if(OrderMagicNumber()==MagicNumber && OrderSymbol()==symbol && OrderType()==OP_SELL)
                  {
                   TSa++;
                  }
                if(OrderMagicNumber()==MagicNumber&& OrderType()==OP_BUY)
                  {
                   ttlbuy ++;
                  }
                if(OrderMagicNumber()==MagicNumber&& OrderType()==OP_SELL)
                  {
                   ttlsell ++;
                  }
               }
             }
          //-- SetXYAxis
   MqlTick tick;
   SymbolInfoTick(symbol,tick);
   SomeFunction(tick.bid,tick.ask,tick.bid-4*myPoint);
  if(NumOfSymbols==i){i=0;}
   int ticket = -1;
   double price;   
   double SL;
   double TP;double size;
   bool isNewBar = NewBar();
   count ++;
   while(true){
   if(count>1){
   size=0.01;
   }
   if(isNewBar) TrailingStopSet(OP_BUY, Resistance(12 * PeriodSeconds(), true, 10, 00, true, 0)); //Trailing Stop = Resistance
   if(isNewBar) TrailingStopSet(OP_SELL, Support(12 * PeriodSeconds(), true, 10, 00, true, 0)); //Trailing Stop = Support
   
   //Open Buy Order, instant signal is tested first
   RefreshRates();
   if( results=="OverBought"&&Cross(0,  SymbolInfoDouble(symbol,SYMBOL_BID) > Support(12 * PeriodSeconds(), true, 10, 00, true, 0)) //Price crosses above Support
   )
     {
      RefreshRates();
       price = SymbolInfoDouble(symbol,SYMBOL_ASK);
      SL = 100 * myPoint; //Stop Loss = value in points (relative to price)
      TP = 40 * myPoint; //Take Profit = value in points (relative to price)
      if(!inTimeInterval(TimeCurrent(), TOD_From_Hour, TOD_From_Min, TOD_To_Hour, TOD_To_Min)) return; //open trades only at specific times of the day
      if(!TradeDayOfWeek()) return; //open trades only on specific days of the week   
      if(IsTradeAllowed())
        {  switch(Order_Type){
        case MARKET_ORDERS:
         ticket = myOrderSend(OP_BUY, price, MM_Size(), "");
         break;
         
         case STOP_ORDERS: ticket = myOrderSend(OP_BUYSTOP, price, MM_Size(), "");
         
         break;
         case LIMIT_ORDERS: ticket = myOrderSend(OP_BUYLIMIT, price, MM_Size(), "");
         break;
         default:break;
         }
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      myOrderModifyRel(ticket, SL, 0);
      myOrderModifyRel(ticket, 0, TP);
     }
   
   //Open Sell Order, instant signal is tested first
   RefreshRates();
   if(results=="OverSold"&&Cross(1,  SymbolInfoDouble(symbol,SYMBOL_BID) < Resistance(12 * PeriodSeconds(), true, 10, 00, true, 0)) //Price crosses below Resistance
   )
     {
      RefreshRates();
      price = SymbolInfoDouble(symbol,SYMBOL_BID);
      SL = 100 * myPoint; //Stop Loss = value in points (relative to price)
      TP = 40 * myPoint; //Take Profit = value in points (relative to price)
      if(!inTimeInterval(TimeCurrent(), TOD_From_Hour, TOD_From_Min, TOD_To_Hour, TOD_To_Min)) return; //open trades only at specific times of the day
      if(!TradeDayOfWeek()) return; //open trades only on specific days of the week   
      if(IsTradeAllowed())
        {
         switch(Order_Type){
        case MARKET_ORDERS:
         ticket = myOrderSend(OP_SELL, price, MM_Size(), "");
         break;
         
         case STOP_ORDERS: ticket = myOrderSend(OP_SELLSTOP, price, MM_Size(), "");
         
         break;
         case LIMIT_ORDERS: ticket = myOrderSend(OP_SELLLIMIT, price, MM_Size(), "");
         break;
         default:break;
         }
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      myOrderModifyRel(ticket, SL, 0);
      myOrderModifyRel(ticket, 0, TP);
     }
     
     
     break;
     
     }
  }
  
bool ChartColorSet()//set chart colors
  {
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,Bear Candle);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,Bull Candle);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,Bear_Outline);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,Bull_Outline);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID,0);
   ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,false);
   ChartSetInteger(ChartID(),CHART_MODE,1);
   ChartSetInteger(ChartID(),CHART_SHIFT,1);
   ChartSetInteger(ChartID(),CHART_SHOW_ASK_LINE,1);
   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,BackGround);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,ForeGround);
   return(true);
  }  
//+------------------------------------------------------------------+