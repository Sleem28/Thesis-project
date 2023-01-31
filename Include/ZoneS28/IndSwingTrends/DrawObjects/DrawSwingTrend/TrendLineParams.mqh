//+------------------------------------------------------------------+
//|                                              TrendLineParams.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"

struct TrendLineParams
{
   string   swing_name;
   string   entry_point_name;
   int      line_width;
   color    trend_up_color;
   color    trend_down_color;
   color    no_trend_color;
   color    entry_point_color;
   double   first_price;
   datetime first_date;
   double   second_price;
   datetime second_date;
};
