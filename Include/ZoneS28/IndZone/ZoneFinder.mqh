//+------------------------------------------------------------------+
//|                                                   ZoneFinder.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include "CheckBlockedZones.mqh"
#include "CheckBreakThrough.mqh"
#include "SearchZone.mqh"
#include "Zone.mqh"
#include "ZoneExtension.mqh"
#include "DrawObjects\DrawZones\ZoneDrawer.mqh"
#include "DrawObjects\DrawZones\DrawZoneParams.mqh"
#include "CheckExistingZones.mqh"



//+------------------------------------------------------------------+
//| Класс предназначен для поиска и отрисовки зон по условию.        |
//+------------------------------------------------------------------+

class CZoneFinder
  {
private:
  
public:
                     CZoneFinder(){};
                    ~CZoneFinder(){};
   void              FindZones(int bar,
                               bool &isTrendUp,
                               ENUM_TIMEFRAMES  timeframe,
                               bool &breakThroughUp,
                               bool &breakThroughDown,
                               int &zone_number,
                               CZoneDrawer&,
                               ZoneParams&,
                               CArrayObj &arrayZones,
                               CZoneExtension&);
   
  };
//+------------------------------------------------------------------+
//| Ищем параметры для дальнейшей отрисовки по ним зон на графике    |
//+------------------------------------------------------------------+
void CZoneFinder::FindZones(int              bars,
                            bool            &isTrendUp,
                            ENUM_TIMEFRAMES  timeframe,
                            bool            &breakThroughUp,
                            bool            &breakThroughDown,
                            int             &zone_number,
                            CZoneDrawer     &zone_drawer,
                            ZoneParams      &zone_params,
                            CArrayObj       &arrayZones,
                            CZoneExtension  &zone_extension)
  {
   CCheckBlockedZones  check_blocked_zones;
   CCheckBreakThrough  check_break_through;
   CSearchZone         search_zone;
   CCheckExistingZones zone_checker;


   for(int i=bars; i>0; i--)
     {
      if(arrayZones.Total()>0)// Если найдена хоть одна зона
        {
         check_blocked_zones.Check(_Symbol,timeframe,i,zone_params,zone_drawer,arrayZones,breakThroughUp,breakThroughDown); // проверим имеющиеся зоны на перекрытие
         zone_extension.Extension(i, timeframe, zone_drawer, arrayZones); // Продлим зоны
        }
      //-------------------------------------------------------------------------------------------------------------------------------------+

      check_break_through.Check(i,zone_drawer,isTrendUp, timeframe, true, breakThroughUp, breakThroughDown, arrayZones, zone_params); // Проверим пробой верхних зон


      if(breakThroughUp) //Контроль верхнего пробоя
        {
         if(search_zone.SearchZone(i,timeframe,5,true)) // Если найден верхний паттерн из 5 свечей
           {
            double   extrem     = NormalizeDouble(iHigh(_Symbol,timeframe,i+2),_Digits);
            double   open       = NormalizeDouble(iOpen(_Symbol,timeframe,i+2),_Digits);
            double   close      = NormalizeDouble(iClose(_Symbol,timeframe,i+2),_Digits);
            double   shadow     = (open > close)? open:close;
            datetime start_time = iTime(_Symbol,timeframe,i+2);
            datetime end_time   = iTime(_Symbol,timeframe,i-1);

            
            if(zone_checker.Check(extrem,shadow,arrayZones))
              {
               CZone* new_zone = new CZone(zone_number,extrem,shadow,start_time,end_time);
               arrayZones.Add(new_zone);
               zone_drawer.DrawZone(true,timeframe,zone_params,new_zone);
               breakThroughUp = false;
               zone_number++;
              }
           }
        }
      //-------------------------------------------------------------------------------------------------------------------------------------+

      check_break_through.Check(i,zone_drawer,isTrendUp, timeframe, false, breakThroughUp, breakThroughDown, arrayZones,zone_params); // Проверим пробой нижних зон

      if(breakThroughDown)
        {
         if(search_zone.SearchZone(i,timeframe,5,false)) // Если найден паттерн из 5 свечей
           {
            double   extrem     = NormalizeDouble(iLow(_Symbol,timeframe,i+2),_Digits);
            double   open       = NormalizeDouble(iOpen(_Symbol,timeframe,i+2),_Digits);
            double   close      = NormalizeDouble(iClose(_Symbol,timeframe,i+2),_Digits);
            double   shadow     = (open < close)? open:close;
            datetime start_time = iTime(_Symbol,timeframe,i+2);
            datetime end_time   = iTime(_Symbol,timeframe,i-1);

            if(zone_checker.Check(extrem,shadow,arrayZones))
              {
               CZone* new_zone     = new CZone(zone_number,extrem,shadow,start_time,end_time);
               arrayZones.Add(new_zone);
               zone_drawer.DrawZone(false,timeframe,zone_params,new_zone);
               breakThroughDown = false;
               zone_number++;
              }
           }
        }
     }
  }
