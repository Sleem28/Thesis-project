//+------------------------------------------------------------------+
//|                                      TypeEntryAfterBreakdown.mqh |
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



class CTypeEntryAfterBreakdown{
private:
              int  GetCandleNumber(datetime, string, ENUM_TIMEFRAMES);
public:
                   CTypeEntryAfterBreakdown(){};
                  ~CTypeEntryAfterBreakdown(){};
              bool Find(STrend trend, CArrayObj &points, ENUM_TIMEFRAMES timeframe, string symbol);               
};

//+------------------------------------------------------------------+
//|Метод ищет наличие возможности установки стоп ордера на вход      |
//|на импульсном уровне после образования коррекции                  |
//+------------------------------------------------------------------+
/*
// trend - тренд с индикатора свингов
// points - коллекция с разворотными точками индикатора свингов
*/
bool CTypeEntryAfterBreakdown::Find(STrend trend, CArrayObj &points, ENUM_TIMEFRAMES timeframe, string symbol)
{
   CCandleNumberGetter m_candle_getter;
   int      length = points.Total();
   if(length < 4)
   {
      Print("Недостаточно точек для поиска паттерна на пробой и вход на пробой!!!");
      return(false);
   }
   // Получим 4 точки из коллекции с найденными точками
   CTPoint *point1 = points.At(length-1);
   CTPoint *point2 = points.At(length-2);
   CTPoint *point3 = points.At(length-3);
   CTPoint *point4 = points.At(length-4);
   //Получим последнюю цену закрытия на нулевой свече
   double   last_close = iClose(symbol,timeframe,0);
   //Возьмем цены из точек
   double   p1_price   = point1.GetPrice();
   double   p2_price   = point2.GetPrice();
   double   p3_price   = point3.GetPrice();
   double   p4_price   = point4.GetPrice();
   //Получим номер свечи экстреммума 2й точки 
   datetime time_second_point    = point2.GetDate();
   int      num_sec_point_candle = m_candle_getter.GetCandleNumber(time_second_point, symbol, timeframe);
   
   if(trend == Trend_Up) // Поиск для тренда вверх
   {
      double candle_low = iLow(symbol,timeframe,num_sec_point_candle);
      //Описание паттерна для покупок
      if(p1_price   < p2_price && 
         p2_price   > p3_price && 
         candle_low > p4_price && 
         last_close < p2_price)
      {
         Print("Найден паттерн после импульсного пробоя уровня для установки ордера buy_stop.");
         return(true);
      }
         
   }
   //+------------------------------------------------------------------+
   else if(trend == Trend_Down) // Поиск для тренда вниз
   {
      double candle_high = iHigh(symbol,timeframe,num_sec_point_candle);
      //Описание паттерна для продаж
      if(p1_price    > p2_price && 
         p2_price    < p3_price && 
         candle_high < p4_price && 
         last_close  > p2_price)
      {
         Print("Найден паттерн после импульсного пробоя уровня для установки ордера sell_stop.");
         return(true);
      }
   }
   
   return(false);
}

