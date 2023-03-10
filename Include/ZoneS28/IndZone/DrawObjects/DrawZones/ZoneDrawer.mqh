//+------------------------------------------------------------------+
//|                                                   ZoneDrawer.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include "DrawZoneParams.mqh"
#include <ZoneS28\ParamsInitializer.mqh>


#include <ZoneS28\IndZone\Zone.mqh>

//+------------------------------------------------------------------+
//| Класс для рисования новых, и модификации старых зон              |
//+------------------------------------------------------------------+

class CZoneDrawer
  {
private:
   bool m_draw;

public:
                     CZoneDrawer(){m_draw = true;};
                    ~CZoneDrawer(){};
                    
                bool DrawZone(bool typeUp,ENUM_TIMEFRAMES timeframe, ZoneParams &z_params, CZone* &zone);
                bool ReDrawZone(ENUM_TIMEFRAMES timeframe, CZone* &zone);
                bool ChangeZoneColor(ENUM_TIMEFRAMES,color, CZone*&);
                bool ChangeZoneFill(ENUM_TIMEFRAMES,bool, CZone*&);
                bool DeleteZone(ENUM_TIMEFRAMES timeframe, CZone*&zone);
                void DeleteAllZones();
                void SetDraw(bool draw){m_draw = draw;};

  };

//+------------------------------------------------------------------+
//| Рисует зону на текущем графике                                   |
//+------------------------------------------------------------------+
bool CZoneDrawer::DrawZone(bool typeUp,ENUM_TIMEFRAMES timeframe, ZoneParams &z_params, CZone* &zone) 
{
   if(!m_draw)
      return(false);
   string   name        = "Zone " + EnumToString(timeframe) + " number " + IntegerToString(zone.GetNumber());
   datetime start_date  = zone.GetStartDate();
   double   start_price = zone.GetExtremumPrice();
   datetime end_date    = zone.GetEndDate();
   double   end_price   = zone.GetShadowPrice();  
   color    z_color     = (typeUp)? z_params.founded_up_zone_color : z_params.founded_down_zone_color;
   bool     z_fill      = (typeUp)? z_params.fill_founded_up_zone : z_params.fill_founded_down_zone;
   // Установить параметры в структуру
   z_params.name        = name;
   z_params.start_time  = start_date;
   z_params.start_price = start_price;
   z_params.end_time    = end_date;
   z_params.end_price   = end_price;
   
   if(ObjectCreate(z_params.chart_id,  // Создаем объект                                                
                   z_params.name,
                   OBJ_RECTANGLE,
                   z_params.sub_window,
                   z_params.start_time,
                   z_params.start_price,
                   z_params.end_time,
                   z_params.end_price))
   {              
      ObjectSetInteger(z_params.chart_id, z_params.name, OBJPROP_COLOR,z_color);
      ObjectSetInteger(z_params.chart_id, z_params.name, OBJPROP_STYLE,z_params.line_style);
      ObjectSetInteger(z_params.chart_id, z_params.name, OBJPROP_WIDTH,z_params.line_width);
      ObjectSetInteger(z_params.chart_id, z_params.name, OBJPROP_FILL,z_fill);
      ObjectSetInteger(z_params.chart_id, z_params.name, OBJPROP_BACK,z_params.on_back_plan);
      ObjectSetInteger(z_params.chart_id, z_params.name, OBJPROP_HIDDEN,z_params.hidden);
      return(true);
   }
   else
   {
      Print("Не удалось создать зону с именем ", z_params.name);
      return(false);
   }
}
//+------------------------------------------------------------------+
//|Изменяет цвет зоны                                                |
//+------------------------------------------------------------------+
bool CZoneDrawer::ChangeZoneColor(ENUM_TIMEFRAMES timeframe, color clr,CZone *&zone)
{  
   if(!m_draw)
      return(false);
   long     chart_id    = 0;

   string   name        = "Zone " + EnumToString(timeframe) + " number " + IntegerToString(zone.GetNumber());
   if(!ObjectSetInteger(chart_id, name, OBJPROP_COLOR,clr))
   {
      Print("Не удалось изменить цвет зоны.");
      return(false);
   }
   else
      return(true);
}
//+------------------------------------------------------------------+
//| Изменяет заливку зоны                                            |
//+------------------------------------------------------------------+
bool CZoneDrawer::ChangeZoneFill(ENUM_TIMEFRAMES timeframe,bool fill, CZone *&zone)
{
   if(!m_draw)
      return(false);
   long     chart_id    = 0;
   string   name        = "Zone " + EnumToString(timeframe) + " number " + IntegerToString(zone.GetNumber());
   if(!ObjectSetInteger(chart_id, name, OBJPROP_FILL,fill))
   {
      Print("Не удалось изменить заливку зоны.");
      return(false);
   }
   else
      return(true);
}
//+------------------------------------------------------------------+
//|  Продлевает зону                                                 |
//+------------------------------------------------------------------+
bool CZoneDrawer::ReDrawZone(ENUM_TIMEFRAMES timeframe, CZone *&zone)
{
   if(!m_draw)
      return(false);
   long     chart_id    = 0;
   int      point       = 1;
   string   name        = "Zone " + EnumToString(timeframe) + " number " + IntegerToString(zone.GetNumber());
   datetime end_date    = zone.GetEndDate();
   double   end_price   = zone.GetShadowPrice();
   
   ResetLastError();
   
   if(!ObjectMove(chart_id,name,point,end_date,end_price))
   {
      printf(" Зона с именем %s не продлена.", name);
      return(false);
   }
   else  
      return(true);
}

//+------------------------------------------------------------------+
//| Удаляет зону                                                     |
//+------------------------------------------------------------------+
bool CZoneDrawer::DeleteZone(ENUM_TIMEFRAMES timeframe, CZone *&zone)
{
   if(!m_draw)
      return(false);
   string   name        = "Zone " + EnumToString(timeframe) + " number " + IntegerToString(zone.GetNumber());
   int      chart_id    = 0;
   
   ResetLastError();
   
   if(!ObjectDelete(chart_id,name))
   {
      printf(" Зона с именем %s не удалена.", name);
      return(false);
   }
   else
      return(true);
}
//+------------------------------------------------------------------+
//| Удаляет все зоны                                                 |
//+------------------------------------------------------------------+
void CZoneDrawer::DeleteAllZones()
{
   if(!m_draw)
      return;
   int      chart_id    = 0;
   string   prefix = "Zone";
   int      sub_window = -1;
   ENUM_OBJECT type = OBJ_RECTANGLE;
   ResetLastError();
   
   ObjectsDeleteAll(chart_id,prefix,sub_window,type);
}

