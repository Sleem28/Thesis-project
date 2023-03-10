//+------------------------------------------------------------------+
//|                                             EntryPointFinder.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <ZoneS28\Enums.mqh>
#include <Arrays\ArrayObj.mqh>
#include "EntryPointTypes\TypeEntryAfterBreakdown.mqh"
#include "EntryPointTypes\TypeEntryFromZone.mqh"
#include "EntryPointTypes\TypeEntryFromBreakoutLevel.mqh"
#include "EntryPointTypes\TypeTrendTrade.mqh"


class CEntryPointFinder {
private:
      CTypeEntryAfterBreakdown    entry_ABD;
      CTypeEntryFromZone          entry_from_zone;
      CTypeEntryFromBreakoutLevel entry_from_breakout_level;
      CTypeTrendTrade             entry_on_trend; 
      
public:
                     CEntryPointFinder(){};
                    ~CEntryPointFinder(){};
                     
                    bool FindEntryPoint(EntryPointType type, STrend trend,CArrayObj &points, CArrayObj &zones, ENUM_TIMEFRAMES timeframe, string symbol);
};

//+------------------------------------------------------------------+
bool CEntryPointFinder::FindEntryPoint(EntryPointType type, STrend trend,CArrayObj &points, CArrayObj &zones, ENUM_TIMEFRAMES timeframe, string symbol)
{
   
   switch(type)
   {
      case (TypeAfterBreakdownSlOnImpulse): // Если выбран паттерн на вход после импульсного уровня стоп ордером со стопом на импульсе
         return(entry_ABD.Find(trend,points,timeframe,symbol));
         break;
      case (TypeAfterBreakdownSlOnCorrection): // Если выбран паттерн на вход после импульсного уровня стоп ордером на коррекции
         return(entry_ABD.Find(trend,points,timeframe,symbol));
         break;
      case TypeTwoOrdersOnSwing: // Если выбран тип установки 2х ордеров на свинг при флэте
         if(trend == No_Trend)
            return(true);
         break;
      case TypeEntryFromBreakoutLevel: // Если выбран паттерн на вход на отбой от пробитого импульсного уровня лимитным ордером
         return(entry_from_breakout_level.Find(trend,points,timeframe,symbol));
         break;  
      case TypeEntryFromZone: // Если выбран разворотный паттерн на вход на отбой от зоны лимитным ордером 
         return(entry_from_zone.Find(trend,points,zones,timeframe,symbol));
         break;
      case TypeTrendTrade: // Если выбран паттерн на вход на продолжение тренда стоп ордерами
         return(entry_on_trend.Find(trend,points,timeframe,symbol));
         break;
   }
   //Print("Паттерны для установки ордеров не обнаружены.");  
   return(false);      
}