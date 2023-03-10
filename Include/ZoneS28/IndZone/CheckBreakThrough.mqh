//+------------------------------------------------------------------+
//|                                            CheckBreakThrough.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include "Zone.mqh"
#include "DrawObjects\DrawZones\ZoneDrawer.mqh"
#include "DrawObjects\DrawZones\DrawZoneParams.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCheckBreakThrough
  {
private:

public:
                     CCheckBreakThrough(){};
                    ~CCheckBreakThrough(){};
   void              Check(int bar,CZoneDrawer&,bool&, ENUM_TIMEFRAMES, bool, bool &, bool &,CArrayObj &, ZoneParams&);
  };


//+------------------------------------------------------------------+
//|           Проверяет зоны в массиве на пробой                     |
//+------------------------------------------------------------------+
/// bar              - номер свечи, которую проверяем на пробой зоны
/// zoneDrawer       - объект класса рисующий и перерисовывающий зоны
/// timeframe        - таймфрейм на которм расчитываются зоны
/// isUpZone         - флаг зоны: true верхняя; false нижняя
/// breakThroughUp   - ссылка на флаг верхнего пробоя
/// breakThroughDown - ссылка на флаг нижнего пробоя
/// arrayZones       - ссылка на коллекцию с зонами
/// params           - ссылка на структуру с параметрами отрисовки зон 
void CCheckBreakThrough::Check(int bar,
                               CZoneDrawer &zoneDrawer,
                               bool &isTrendUp, 
                               ENUM_TIMEFRAMES timeframe, 
                               bool isUpZone, 
                               bool &breakThroughUp, 
                               bool &breakThroughDown, 
                               CArrayObj &arrayZones,
                               ZoneParams &params)
  {
   int length = arrayZones.Total()-1;

   for(int i=length; i>=0; i--)
     {
      CZone* tmp = arrayZones.At(i);
      if(tmp.GetPierced() == false)
        {
         if(isUpZone && (tmp.GetTypeUp() == true))
           {
            double low = iLow(_Symbol,timeframe,bar);
            if(low > tmp.GetExtremumPrice())
              {
               tmp.PiercedZone();
               zoneDrawer.ChangeZoneColor(timeframe,params.breakthrough_up_zone_color,tmp);
               zoneDrawer.ChangeZoneFill(timeframe,params.fill_breakthrough_up_zone,tmp);
               isTrendUp          = true;
               breakThroughUp   = true;
               breakThroughDown = true;
              }
           }
         else
            if(!isUpZone && (tmp.GetTypeUp() == false))
              {
               double high = iHigh(_Symbol,timeframe,bar);
               if(high < tmp.GetExtremumPrice())
                 {
                  tmp.PiercedZone();
                  zoneDrawer.ChangeZoneColor(timeframe,params.breakthrough_down_zone_color,tmp);
                  zoneDrawer.ChangeZoneFill(timeframe,params.fill_breakthrough_down_zone,tmp);
                  isTrendUp          = false;
                  breakThroughUp   = true;
                  breakThroughDown = true;
                 }
              }
        }
     }
  }
//+------------------------------------------------------------------+
