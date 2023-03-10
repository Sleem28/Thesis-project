//+------------------------------------------------------------------+
//|                                                       S28_EA.mq5 |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"

#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\IndZone\ZoneFinder.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawZones\ZoneDrawer.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawZones\DrawZoneParams.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawZones\ParamsInitializer.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawTrend\DrawTrend.mqh>
#include <ZoneS28\IndZone\ZoneExtension.mqh>


//+------------------------------------------------------------------+
//| Expert settings                                                  |
//+------------------------------------------------------------------+
input string          IS                           = "= Indicator ZONE settings =";
input bool            Show__zone_indicator         = true;
input bool            Show_current_global_trend    = true;
input int             Bars_to_calc                 = 150;
input ENUM_TIMEFRAMES Timeframe                    = PERIOD_H1;
input int             ZoneWidth                    = 2;

input string          UZ                           = "= Up zones' color settings =";
input color           Founded_up_zone_color        = clrGreen;
input bool            Fill_founded_up_zone         = true;
input color           Breakthrough_up_zone_color   = clrDarkGreen;
input bool            Fill_breakthrough_up_zone    = false;
input color           Finalized_up_zone_color      = clrSpringGreen;
input bool            Fill_finalized_up_zone       = true;

input string          DZ                           = "= Down zones' color settings =";
input color           Founded_down_zone_color      = clrRed;
input bool            Fill_founded_down_zone       = true;
input color           Breakthrough_down_zone_color = clrDarkRed;
input bool            Fill_breakthrough_down_zone  = false;
input color           Finalized_down_zone_color    = clrPink;
input bool            Fill_finalized_down_zone     = true;
//+------------------------------------------------------------------+
//|   Global objects and variables                                   |
//+------------------------------------------------------------------+
// Global class objects
CArrayObj          c_array;
CZoneDrawer        c_zone_drawer;
CZoneFinder        c_zone_finder;
ZoneParams         c_zone_params;
CParamsInitializer c_params_init;
CDrawTrend         c_draw_trend;
CZoneExtension     c_zone_extension;
// Global variables
int         c_zone_counter;
bool        c_breakThroughUp;
bool        c_breakThroughDown;             
bool        c_trendUp;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
    c_params_init.Init(ZoneWidth,
                       Founded_up_zone_color,
                       Fill_founded_up_zone,
                       Breakthrough_up_zone_color,
                       Fill_breakthrough_up_zone,
                       Finalized_up_zone_color,
                       Fill_finalized_up_zone,
                       Founded_down_zone_color,
                       Fill_founded_down_zone,
                       Breakthrough_down_zone_color,
                       Fill_breakthrough_down_zone,
                       Finalized_down_zone_color,
                       Fill_finalized_down_zone,
                       c_zone_params);
    c_breakThroughUp   = true;
    c_breakThroughDown = true; 
    c_zone_counter     = 0;
    c_trendUp          = false;
    c_zone_drawer.SetDraw(Show__zone_indicator);
    c_array.Clear();
//    c_zone_drawer.DeleteAllZones();
    c_zone_finder.FindZones(Bars_to_calc, c_trendUp, Timeframe, c_breakThroughUp, c_breakThroughDown, c_zone_counter, c_zone_drawer, c_zone_params, c_array,c_zone_extension);
    
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
   c_zone_drawer.DeleteAllZones();
   c_draw_trend.DeleteSign();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    datetime zone_current_time = iTime(_Symbol,Timeframe,1);
    static datetime zone_control_time = 0;
    
    datetime redraw_current_time = iTime(_Symbol,PERIOD_CURRENT,1);
    static datetime redraw_control_time = 0;
    
    if(Show_current_global_trend) // рисует индикатор тренда
      c_draw_trend.Show(c_trendUp);
    
    if(zone_current_time != zone_control_time) // считаем и рисуем зоны
    {
      c_zone_finder.FindZones(1,c_trendUp,Timeframe,c_breakThroughUp, c_breakThroughDown, c_zone_counter, c_zone_drawer, c_zone_params, c_array,c_zone_extension);
      zone_control_time = zone_current_time;      
    }
    
    if(redraw_current_time != redraw_control_time) // Продлеваем зоны на текущем графике
    {
      c_zone_extension.Extension(1,Timeframe,c_zone_drawer,c_array);
      redraw_control_time = redraw_current_time;
    }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
