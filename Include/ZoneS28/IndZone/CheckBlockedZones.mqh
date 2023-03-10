//+------------------------------------------------------------------+
//|                                            CheckBlockedZones.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Object.mqh>
#include "Zone.mqh"
#include <Arrays\ArrayObj.mqh>
#include "DrawObjects\DrawZones\DrawZoneParams.mqh"
#include "DrawObjects\DrawZones\ZoneDrawer.mqh"


//+------------------------------------------------------------------+
//| Класс проверяет зону на перекрытие после пробоя                  |
//+------------------------------------------------------------------+
class CCheckBlockedZones
  {
private:

public:
                     CCheckBlockedZones(){};
                    ~CCheckBlockedZones(){};
                bool Check(string,ENUM_TIMEFRAMES,int,ZoneParams&,CZoneDrawer&,CArrayObj&,bool&,bool&);
  };


//+------------------------------------------------------------------+
//|  Поиск перекрытия зон                                            |
//+------------------------------------------------------------------+
bool CCheckBlockedZones::Check(string symbol,
                               ENUM_TIMEFRAMES timeframe,
                               int bar,
                               ZoneParams &params,
                               CZoneDrawer &zoneDrawer,
                               CArrayObj &arrayZone,
                               bool &breakThroughUp, 
                               bool &breakThroughDown)
  {
   int length = arrayZone.Total() - 1;

   for(int i=length; i>=0; i--)
     {
      CZone *tmpZone = arrayZone.At(i);
      double open    = NormalizeDouble(iOpen(symbol, timeframe, bar), _Digits);
      double close   = NormalizeDouble(iClose(symbol, timeframe, bar), _Digits);
      double shadow  = tmpZone.GetShadowPrice();

      if(tmpZone.GetPierced() && !tmpZone.GetBlocked()) // Если зона пробита но не перекрыта
        {
         if(tmpZone.GetTypeUp())                        // Если зона верхняя
           {
            if((open < shadow)||(close < shadow))       // Если закрытие или открытие выше экстремума
              {
               tmpZone.BlockedZone();
               zoneDrawer.ChangeZoneColor(timeframe,params.finalized_up_zone_color,tmpZone);
               zoneDrawer.ChangeZoneFill(timeframe,params.fill_finalized_up_zone,tmpZone);
              }
           }
         else
           {
            if((open > shadow)||(close > shadow))
              {
               tmpZone.BlockedZone();
               zoneDrawer.ChangeZoneColor(timeframe,params.finalized_down_zone_color,tmpZone);
               zoneDrawer.ChangeZoneFill(timeframe,params.fill_finalized_down_zone,tmpZone);
              }
           }
        }
     }
   return true;
  } 
//+------------------------------------------------------------------+
