//+------------------------------------------------------------------+
//|                                               DrawZoneParams.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
//+------------------------------------------------------------------+
//| Структура для параметров индикатора                              |
//+------------------------------------------------------------------+

struct ZoneParams{
   long            chart_id;
   string          name;
   int             sub_window;
   datetime        start_time;
   double          start_price;
   datetime        end_time;
   double          end_price;
   ENUM_LINE_STYLE line_style;
   int             line_width;
   color           founded_up_zone_color;
   bool            fill_founded_up_zone;
   color           breakthrough_up_zone_color;
   bool            fill_breakthrough_up_zone;
   color           finalized_up_zone_color;
   bool            fill_finalized_up_zone;
   color           founded_down_zone_color;
   bool            fill_founded_down_zone;
   color           breakthrough_down_zone_color;
   bool            fill_breakthrough_down_zone;
   color           finalized_down_zone_color;
   bool            fill_finalized_down_zone;
   bool            on_back_plan;
   bool            hidden;
};


