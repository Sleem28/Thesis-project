//+------------------------------------------------------------------+
//|                                            TypeEntryFromZone.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\Enums.mqh>
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\Trade\EntryPointsClasses\CandleNumberGetter.mqh>

class CTypeEntryFromZone {
private:
                bool PatternInZone(CArrayObj &zones,double p1_price,double p2_price,double p3_price,double p4_price,STrend trend);
public:
                     CTypeEntryFromZone(){};
                    ~CTypeEntryFromZone(){};
                bool Find(STrend trend, CArrayObj &points, CArrayObj &zones, ENUM_TIMEFRAMES timeframe, string symbol);
};
//+------------------------------------------------------------------+
//|Метод ищет разворотный паттерн от зоны                            |
//+------------------------------------------------------------------+
bool CTypeEntryFromZone::Find(STrend trend,CArrayObj &points,CArrayObj &zones,ENUM_TIMEFRAMES timeframe,string symbol)
{  
   CCandleNumberGetter m_candle_getter;
   int length = points.Total();
   if(length < 4)
   {
      Print("Недостаточно точек для поиска паттерна на Разворот от зоны!!!");
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
   //Получим номер свечи экстреммума 1й точки 
   datetime time_first_point    = point1.GetDate();
   int      num_first_point_candle = m_candle_getter.GetCandleNumber(time_first_point, symbol, timeframe);
   
   if(trend == Trend_Up) // Поиск для тренда вверх
   {
      double candle_low = iLow(symbol,timeframe,num_first_point_candle);
      // Проверим паттерн на нахождение в зоне
      bool pattern_in_zone = PatternInZone(zones,p1_price,p2_price,p3_price,p4_price,trend);
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
      double candle_high = iHigh(symbol,timeframe,num_first_point_candle);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTypeEntryFromZone::PatternInZone(CArrayObj &zones,double p1_price,double p2_price,double p3_price,double p4_price,STrend trend)
{
   int length = zones.Total();
   
   for(int i=length-1; i >= 0: i--)// переберем массив с зонами
   {
      // TODO  Продолжить делать класс отбоя от зоны. Пишем цикл поиска паттерна в зоне.
   }
}
