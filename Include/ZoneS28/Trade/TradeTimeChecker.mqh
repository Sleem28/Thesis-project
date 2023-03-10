//+------------------------------------------------------------------+
//|                                             TradeTimeChecker.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
class CTradeTimeChecker {
private:

public:
                     CTradeTimeChecker(){};
                    ~CTradeTimeChecker(){};
                    bool CheckTradeTime(uint start_hour, uint finish_hour);
};
//+------------------------------------------------------------------+
//| Проверяет текущее время на возможность работы в нем              |
//+------------------------------------------------------------------+
bool CTradeTimeChecker::CheckTradeTime(uint start_hour,uint finish_hour)
{
   MqlDateTime cur_time;
   TimeCurrent(cur_time);
   
   uint cur_hour = (uint) cur_time.hour;
   
   if(start_hour > cur_hour || finish_hour < cur_hour)
      return(false);
   else
      return(true);  
}
//+------------------------------------------------------------------+
