//+------------------------------------------------------------------+
//|                                   TypeEntryFromBreakoutLevel.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <ZoneS28\Enums.mqh>
#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\Trade\EntryPointsClasses\CandleNumberGetter.mqh>

class CTypeEntryFromBreakoutLevel {
private:

public:
                     CTypeEntryFromBreakoutLevel(){};
                    ~CTypeEntryFromBreakoutLevel(){};
                bool Find(STrend trend, CArrayObj &points, ENUM_TIMEFRAMES timeframe, string symbol);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTypeEntryFromBreakoutLevel::Find(STrend trend, CArrayObj &points, ENUM_TIMEFRAMES timeframe, string symbol)
{
   CCandleNumberGetter m_candle_getter;
   int      length = points.Total();
   if(length < 3)
   {
      Print("Недостаточно точек для поиска паттерна на пробой и вход на отбой от пробитого импульсного уровня!!!");
      return(false);
   }
   // Получим 3 точки из коллекции с найденными точками
   CTPoint *point1 = points.At(length-1);
   CTPoint *point2 = points.At(length-2);
   CTPoint *point3 = points.At(length-3);
   
   //Возьмем цены из точек
   double   p1_price   = point1.GetPrice();
   double   p2_price   = point2.GetPrice();
   double   p3_price   = point3.GetPrice();
   
   //Получим последнюю цену закрытия на нулевой свече
   double   last_close = iClose(symbol,timeframe,0);
   
   //Получим номер свечи экстреммума 2й точки 
   datetime time_first_point       = point1.GetDate();
   int      num_first_point_candle = m_candle_getter.GetCandleNumber(time_first_point, symbol, timeframe);
   
   if(trend == Trend_Up) // Поиск для тренда вверх
   {
      double candle_low = iLow(symbol,timeframe,num_first_point_candle);
      //Описание паттерна для покупок
      if(p1_price   > p2_price &&
         p1_price   > p3_price && 
         p2_price   < p3_price && 
         candle_low > p3_price &&
         last_close > p3_price)
      {
         Print("Найден паттерн на пробой и вход на отбой от пробитого импульсного уровня для установки ордера buy_limit.");
         return(true);
      }
         
   }
   //+------------------------------------------------------------------+
   else if(trend == Trend_Down) // Поиск для тренда вниз
   {
      double candle_high = iHigh(symbol,timeframe,num_first_point_candle);
      //Описание паттерна для продаж
      if(p1_price    < p2_price &&
         p1_price    < p3_price && 
         p2_price    > p3_price && 
         candle_high < p3_price &&
         last_close  < p3_price)
      {
         Print("Найден паттерн на пробой и вход на отбой от пробитого импульсного уровня для установки ордера sell_limit.");
         return(true);
      }
   }
   
   return(false);
}
//+------------------------------------------------------------------+
