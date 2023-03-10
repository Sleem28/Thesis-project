//+------------------------------------------------------------------+
//|                                               TypeTrendTrade.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <ZoneS28\Enums.mqh>
#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\IndSwingTrends\TPoint.mqh>


class CTypeTrendTrade {
private:

public:
                     CTypeTrendTrade(){};
                    ~CTypeTrendTrade(){};
                bool Find(STrend trend, CArrayObj &points, ENUM_TIMEFRAMES timeframe, string symbol);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTypeTrendTrade::Find(STrend trend, CArrayObj &points, ENUM_TIMEFRAMES timeframe, string symbol)
{
   
   int length = points.Total();
   
   if(length < 2)
   {
      Print("Недостаточно точек для установки ордера по тренду!!!");
      return(false);
   }
   // Получим 2 точки из коллекции с найденными точками
   CTPoint *point1 = points.At(length-1);
   CTPoint *point2 = points.At(length-2);
   
   //Возьмем цены из точек
   double   p1_price   = point1.GetPrice();
   double   p2_price   = point2.GetPrice();
   
   //Получим последнюю цену закрытия на нулевой свече
   double   last_close = iClose(symbol,timeframe,0);
   
   
   if(trend == Trend_Up) // Поиск для тренда вверх
   {
      
      //Описание паттерна для покупок
      if(p1_price > p2_price)
      {
         Print("Найден паттерн для установки ордера buy_stop по тренду.");
         return(true);
      }
         
   }
   //+------------------------------------------------------------------+
   else if(trend == Trend_Down) // Поиск для тренда вниз
   {
 
      //Описание паттерна для продаж
      if(p1_price < p2_price )
      {
         Print("Найден паттерн для установки ордера sell_stop по тренду.");
         return(true);
      }
   }
   
   return(false);
}

//+------------------------------------------------------------------+
