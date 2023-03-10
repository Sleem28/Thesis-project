//+------------------------------------------------------------------+
//|                                                ZoneExtension.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include "Zone.mqh"
#include <Arrays\ArrayObj.mqh>
#include "DrawObjects\DrawZones\ZoneDrawer.mqh"


class CZoneExtension
  {
private:

public:
                     CZoneExtension(){};
                    ~CZoneExtension(){};
               void  Extension(int,ENUM_TIMEFRAMES timeframe,CZoneDrawer&,CArrayObj&);
  };
//+------------------------------------------------------------------+
//| Продлевает зоны если они не финализированы                       |
//+------------------------------------------------------------------+
/// @bar - количество баров
/// @timeframe - таймфрейм
/// @zoneDraver - объект класса CZoneDrawer, рисует зоны
/// @arrayZones - коллекция указателей на экземпляры класса CZone
void CZoneExtension::Extension(int bar, ENUM_TIMEFRAMES timeframe, CZoneDrawer &zoneDrawer, CArrayObj &arrayZones)
{
   int length = arrayZones.Total()-1;
   int num_bar = (bar > 1)? bar: bar-1;
   ENUM_TIMEFRAMES tf = (bar > 1)? timeframe : PERIOD_CURRENT;
   datetime curDate = iTime(_Symbol,tf,num_bar);
   
   for(int i=length;i>=0;i--)
     {
         CZone* tmp = arrayZones.At(i);
         
         if(tmp.GetBlocked()) // Если зона перекрыта
         {
            if(!tmp.GetFinalize()) //Если зона не финализирована
            {
               tmp.SetEndDate(curDate);
               tmp.FinalizeZone();
               zoneDrawer.ReDrawZone(timeframe,tmp);
            }
               
         }
         else if(!tmp.GetFinalize())
         {
            tmp.SetEndDate(curDate);
            zoneDrawer.ReDrawZone(timeframe,tmp);
         }          
     }
}