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


class CEntryPointFinder {
private:
      CTypeEntryAfterBreakdown entry_ABD;
      
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
      case (TypeAfterBreakdownSlOnCorrection || TypeAfterBreakdownSlOnImpulse): // Если выбран паттерн на вход после импульсного уровня стоп ордером
         return(entry_ABD.Find(trend,points,timeframe,symbol));
         break; 
      case TypeTwoOrdersOnSwing: // Если выбран тип установки 2х ордеров на свинг
         return(true);
         break;
      case TypeEntryFromBreakoutLevel: // Если выбран паттерн на вход на отбой от пробитого импульсного уровня лимитным ордером
         return(true);
         break;  
      case TypeEntryFromZone: // Если выбран разворотный паттерн на вход на отбой от зоны лимитным ордером 
         return(true);
         break;
      case TypeTrendTrade: // Если выбран паттерн на вход на продолжение тренда стоп ордерами
         return(true);
         break;
      //+------------------------------------------------------------------+
      //| Приоритет паттернов:                                             |
      //|  1: Вход на разворот от зоны                                     |
      //|  2: Вход на отбой от пробитого уровня лимитным ордером           |
      //|  3: Вход на пробой со стопом на коррекции                        |
      //|  4: Вход по тренду на пробой                                     |
      //|  5: Вход если нет тренда 2мя стоп ордерами на пробой.            |         
      //+------------------------------------------------------------------+
      case UseAllEntryTypes: // Используем все паттерны по приоритету
         return(true);
         break;
   }
   Print("Паттерны для установки ордеров не обнаружены.");  
   return(false);      
}