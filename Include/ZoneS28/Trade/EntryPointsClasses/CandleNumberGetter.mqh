//+------------------------------------------------------------------+
//|                                           CandleNumberGetter.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
class CCandleNumberGetter {
private:

public:
                     CCandleNumberGetter(){};
                    ~CCandleNumberGetter(){};
                int  GetCandleNumber(datetime, string, ENUM_TIMEFRAMES);
};
//+------------------------------------------------------------------+
//| Метод ищет номер свечи по дате                                   |
//+------------------------------------------------------------------+
int CCandleNumberGetter::GetCandleNumber(datetime point_date, string symbol, ENUM_TIMEFRAMES timeframe)
{
   bool end = false;
   int  counter = 0;
   
   while(!end)
   {
      datetime date = iTime(symbol,timeframe,counter);
      if(date == point_date)
         end = true;
      else
          counter++;
   }
   return(counter);
}
//+------------------------------------------------------------------+
