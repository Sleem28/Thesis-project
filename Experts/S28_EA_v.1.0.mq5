//+------------------------------------------------------------------+
//|                                                       S28_EA.mq5 |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"

#include <ZoneS28\Enums.mqh>
#include <Math\Stat\Math.mqh>

// IndZone classes
#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\IndZone\ZoneFinder.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawZones\ZoneDrawer.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawZones\DrawZoneParams.mqh>
#include <ZoneS28\ParamsInitializer.mqh>
#include <ZoneS28\IndZone\DrawObjects\DrawTrend\DrawTrend.mqh>
#include <ZoneS28\IndZone\ZoneExtension.mqh>
//IndSwingTrend classes
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\IndSwingTrends\SwingTrend.mqh>
#include <ZoneS28\IndSwingTrends\DrawObjects\DrawSwingTrend\TrendDrawer.mqh>
#include <ZoneS28\IndSwingTrends\DrawObjects\DrawSwingTrend\TrendLineParams.mqh>
#include <ZoneS28\IndSwingTrends\EntryPointsProcessor.mqh>
//Trading classes
#include <ZoneS28\Enums.mqh>
#include <ZoneS28\Trade\EntryPointsClasses\EntryPointFinder.mqh>
#include <ZoneS28\Trade\TradeProcessor.mqh>
#include <Trade\SymbolInfo.mqh>
#include <ZoneS28\Trade\TradeTimeChecker.mqh>



//+------------------------------------------------------------------+
//| Expert settings                                                  |
//+------------------------------------------------------------------+
input string          IS                           = "= Indicator ZONE settings =";
input bool            Show__zone_indicator         = true;
input bool            Show_current_global_trend    = true;
input bool            Show_entry_points            = true;
input int             Bars_to_calc_zones           = 150;
input ENUM_TIMEFRAMES Timeframe_zones              = PERIOD_H1;

input string          ISTS                         = "= Indicator Swing Trend settings =";
input bool            Show_swing_trend             = true;
input int             Bars_to_calc_ST              = 500;
input ENUM_TIMEFRAMES Timeframe_swings             = PERIOD_M1;

input string          UZ                           = "= Up zones' color settings =";
input int             ZoneWidth                    = 2;
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

input string          ST                           = "= Swing trend color settings =";
input int             LineWidth                    = 2;
input color           TrendUpColor                 = clrMagenta;
input color           TrendDownColor               = clrBrown;
input color           NoTrendColor                 = clrDarkGray;
input color           EntryPointColor              = clrOrange;

input string          EAS                          = "= Trade settings =";
input bool            TradeOn                      = true;
input EntryPointType  Type_entry_point             = TypeAfterBreakdownSlOnCorrection;  // Type of entry point
input double          LossUSD                      = 1;
input double          TPCoeff                      = 3;
input bool            RetradeIfGotSL               = true;
input ulong           MagicNumber                  = 123654;
input string          MS                           = "= Martin settings =";
input bool            MartinOn                     = false;
input uint            MartinMult                   = 2;
input MartinWorkType  MartinWork                   = MartinModeTrend;
input string          WTS                          = "= Trading time settings =";
input uint            StartHour                    = 6;
input uint            FinishHour                   = 20;


//+------------------------------------------------------------------+
//|   Global objects and variables                                   |
//+------------------------------------------------------------------+

//                       Global class objects

//----------------------------IndZones-------------------------------+
CArrayObj          c_array_zones;
CZoneDrawer        c_zone_drawer;
CZoneFinder        c_zone_finder;
ZoneParams         c_zone_params;
CParamsInitializer c_params_init;
CDrawTrend         c_draw_trend;
CZoneExtension     c_zone_extension;
//---------------------------SwingTrend------------------------------+
CArrayObj             c_array_points;
TrendLineParams       c_t_l_params;
CSwingProcessor       c_swing_processor;
CSwingTrend           c_swing_trend;
CEntryPointsProcessor c_entry_point_processor;
CTrendDrawer          c_trend_drawer(Timeframe_swings);
//----------------------===-----Trade----------==--------------------+
CTradeProcessor       c_trade_processor;
CEntryPointFinder     c_entry_point_finder;
CSymbolInfo           c_symbol_info;
CTradeTimeChecker     c_time_checker;
uint                  c_martin_multiplier;


//                        Global variables
//----------------------------IndZones-------------------------------+
int         c_zone_counter;
bool        c_breakThroughUp;
bool        c_breakThroughDown;             
bool        c_trendUp;
//---------------------------SwingTrend------------------------------+
STrend      c_trend_points; //тренд для нарисованных свингов
LocalTrend  c_trend_swing;  // тренд для расчета свингов
int         c_point_number;
bool        c_show_trend;
bool        c_show_entry;
bool        c_first_run;
//---------------------------Trade-----------------------------------+
double      c_last_loss; 
double      c_last_volume;       // последний объем
double      c_last_open_price; // последняя цена открытия

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
// Init drawing structures
    c_params_init.InitZoneParams(ZoneWidth,
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
    c_params_init.InitTrendLineParams(LineWidth,TrendUpColor,TrendDownColor,NoTrendColor,EntryPointColor,c_t_l_params);
    
// Проверим корректность ввода времени работы
if( StartHour > 23 &&  FinishHour > 23 && StartHour >= FinishHour)
{
   Print("Неверно указано время работы экcперта!!!");
   return INIT_FAILED;
}
// Init indicator zones     
    c_breakThroughUp   = true;
    c_breakThroughDown = true; 
    c_zone_counter     = 0;
    c_trendUp          = false;
    c_zone_drawer.SetDraw(Show__zone_indicator);
    c_array_zones.Clear();
    c_zone_finder.FindZones(Bars_to_calc_zones, c_trendUp, Timeframe_zones, c_breakThroughUp, c_breakThroughDown,
                            c_zone_counter, c_zone_drawer, c_zone_params, c_array_zones,c_zone_extension);

// Init indicator trend        
    c_trend_points     = No_Trend;
    c_trend_swing      = NoTrend;
    c_point_number     = 0;
    c_swing_processor.Reset();
    c_trend_drawer.Reset();
    c_array_points.Clear();
    c_trend_drawer.SetTrend(c_trend_points);
    c_trend_drawer.SetFirstRun(c_first_run);
    c_trend_drawer.SetShowEntry(Show_entry_points);
    c_trend_drawer.SetShowTrend(Show_swing_trend);
    c_swing_processor.DeleteSwings();
    c_swing_trend.Reset();
    c_swing_trend.Calculate(Bars_to_calc_ST,c_trend_swing,Timeframe_swings,c_point_number,c_trend_drawer,c_t_l_params,c_array_points,c_swing_processor,c_entry_point_processor);
// Init Trade classes
    c_last_loss       = 0;
    c_last_open_price = 0;
    c_last_volume     = 0;
    c_martin_multiplier = (MartinOn)? MartinMult : 1;
    c_trade_processor.Init(MagicNumber,_Symbol,Timeframe_swings,c_martin_multiplier,c_last_loss,TPCoeff,c_entry_point_finder);
    c_trade_processor.SetLoss(LossUSD);
    c_symbol_info.Name(_Symbol);
    
        
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {  
   c_zone_drawer.DeleteAllZones();
   c_draw_trend.DeleteSign();
   c_swing_processor.DeleteSwings();
   c_array_points.Clear();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    datetime zone_current_time = iTime(_Symbol,Timeframe_zones,1);
    static datetime zone_control_time = 0;
    
    datetime redraw_current_time = iTime(_Symbol,Timeframe_swings,1);
    static datetime redraw_control_time = 0;
    
    if(Show_current_global_trend) // рисует индикатор тренда
      c_draw_trend.Show(c_trendUp);
    
    if(zone_current_time != zone_control_time) // считаем и рисуем зоны
    {
      c_zone_finder.FindZones(1,c_trendUp,Timeframe_zones,c_breakThroughUp, c_breakThroughDown, c_zone_counter, c_zone_drawer, c_zone_params, c_array_zones,c_zone_extension);
      zone_control_time = zone_current_time;      
    }
    
    if(redraw_current_time != redraw_control_time) // Продлеваем зоны на текущем графике и проверяем торговые условия
    {
      c_zone_extension.Extension(1,Timeframe_zones,c_zone_drawer,c_array_zones);
      redraw_control_time = redraw_current_time;
      
      int cur_num_point = c_point_number; // Присвоим переменной номер последней точки
      // Ищем и рисуем последний свинг
      c_swing_trend.Calculate(1,c_trend_swing,Timeframe_swings,c_point_number,c_trend_drawer,c_t_l_params,c_array_points,c_swing_processor,c_entry_point_processor);
      //+------------------------------------------------------------------+
      //|Торговый блок                                                     |
      //+------------------------------------------------------------------+   
      // Если была найдена новая точка и построен новый свинг и торговля разрешена, и время подходит то можно пробовать ставить ордер
      if(c_point_number > cur_num_point && TradeOn && c_time_checker.CheckTradeTime(StartHour,FinishHour)) 
      {
         c_trade_processor.DeleteAllPendingPositions();
         STrend cur_trend = c_swing_processor.GetCurrentTrend();
         if(!RetradeIfGotSL)
         {
            if(c_last_loss == 0)
               c_trade_processor.SetLoss(LossUSD);
            else
               c_trade_processor.SetLoss(c_last_loss * c_martin_multiplier);
         }
         else
            c_trade_processor.SetLoss(LossUSD);
         
         if(c_trade_processor.CheckOpenPosition())
         {
            switch(Type_entry_point)
            {
               case TypeEntryFromZone:
                  c_trade_processor.Trade(TypeEntryFromZone,cur_trend,c_array_points,c_array_zones);
                  break;
               case TypeAfterBreakdownSlOnCorrection:
                  c_trade_processor.Trade(TypeAfterBreakdownSlOnCorrection,cur_trend,c_array_points,c_array_zones);
                  break;
               case TypeAfterBreakdownSlOnImpulse:
                  c_trade_processor.Trade(TypeAfterBreakdownSlOnImpulse,cur_trend,c_array_points,c_array_zones);
                  break;
               case TypeEntryFromBreakoutLevel:
                  c_trade_processor.Trade(TypeEntryFromBreakoutLevel,cur_trend,c_array_points,c_array_zones);
                  break;
               case TypeTrendTrade:
                  c_trade_processor.Trade(TypeTrendTrade,cur_trend,c_array_points,c_array_zones);
                  break;
               case TypeTwoOrdersOnSwing:
                  c_trade_processor.Trade(TypeTwoOrdersOnSwing,cur_trend,c_array_points,c_array_zones);
                  break;           
      //+------------------------------------------------------------------+
      //| Приоритет паттернов для комбинированного входа                   |
      //|  1: Вход на разворот от зоны                                     |
      //|  2: Вход на отбой от пробитого уровня лимитным ордером           |
      //|  3: Вход на пробой со стопом на коррекции                        |
      //|  4: Вход по тренду на пробой                                     |
      //|  5: Вход если нет тренда 2мя стоп ордерами на пробой.            |         
      //+------------------------------------------------------------------+
               case TypeCombineEntryTypes: // Комбинированный поиск
                  {
                     c_trade_processor.Trade(TypeEntryFromZone,cur_trend,c_array_points,c_array_zones); // Ищем вход от зоны
                     if(!c_trade_processor.CheckOpenPosition())break;
                     
                     c_trade_processor.Trade(TypeEntryFromBreakoutLevel,cur_trend,c_array_points,c_array_zones); // Ищем вход лимиткой от пробитого уровня
                     if(!c_trade_processor.CheckOpenPosition())break;
                     
                     c_trade_processor.Trade(TypeAfterBreakdownSlOnCorrection,cur_trend,c_array_points,c_array_zones); // Ищем вход на пробой стоп ордером со стопом на коррекции
                     if(!c_trade_processor.CheckOpenPosition())break;
                     
                     //c_trade_processor.Trade(TypeTrendTrade,cur_trend,c_array_points,c_array_zones); // Ищем вход по тренду лимиткой
                     //if(!c_trade_processor.CheckOpenPosition())break;
                     
                     c_trade_processor.Trade(TypeTwoOrdersOnSwing,cur_trend,c_array_points,c_array_zones); // Ищем вход 2 ордерами если тренда нет
                     if(!c_trade_processor.CheckOpenPosition())break;
                  }                
            }
         }
      }
      //-------------------------------------------------------------------+
    }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD && MartinOn)
   {
      ulong            ticket    = trans.deal;
      ulong            magic_num = 0;
      string           symbol    = "";
      ENUM_DEAL_REASON reason    = -1;
      ENUM_DEAL_ENTRY  entry     = -1;
      double           pr_ls     = 0;
      
      
      if(HistoryDealSelect(ticket))
      {
         magic_num = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         symbol    = HistoryDealGetString(ticket,DEAL_SYMBOL);
         entry     = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         
         
         
          if(magic_num == MagicNumber && symbol == _Symbol && (trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL))
         {
            if(entry == DEAL_ENTRY_OUT) // Если сделку закрыло
            {
                reason    = HistoryDealGetInteger(ticket,DEAL_REASON);            
                pr_ls     = HistoryDealGetDouble(ticket,DEAL_PROFIT);
                pr_ls     = MathRound(pr_ls,2);
               
               if(reason == DEAL_REASON_SL)
               {
                  PrintFormat("Сделка закрыта с убытком %f USD. \n",pr_ls );
                  pr_ls = MathAbs(pr_ls);
                  if(!RetradeIfGotSL) // Если ретрейд выключен то применим мартин к следующему трейду
                     c_last_loss = pr_ls; 
                  else                // Если ретрейд включен, то заходим по мартину на стопах
                  {
                     double vol = c_last_volume * c_martin_multiplier;
                     if(trans.deal_type == DEAL_TYPE_BUY) // Если лосевая сделка была на покупку
                     {
                        if(MartinWork == MartinModeContrTrend) // Режим мартина - контртренд
                        {
                           double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                           c_trade_processor.OpenPosition(POSITION_TYPE_SELL, bid,bid + (bid - c_last_open_price),vol); // Откроем продажу
                        }
                        else if(MartinWork == MartinModeTrend) // Режим мартина - тренд
                        {
                           double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                           c_trade_processor.OpenPosition(POSITION_TYPE_BUY, ask,c_last_open_price,vol); // Откроем покупку
                        }
                     }
                     else if(trans.deal_type == DEAL_TYPE_SELL) // Если лосевая сделка была на продажу
                     {
                        if(MartinWork == MartinModeContrTrend) // Режим мартина - контртренд
                        {
                            double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
                            c_trade_processor.OpenPosition(POSITION_TYPE_BUY, ask,ask - (c_last_open_price - ask),vol); // Откроем покупку
                        }
                        else if(MartinWork == MartinModeTrend) // Режим мартина - тренд
                        {
                           double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                           c_trade_processor.OpenPosition(POSITION_TYPE_SELL, bid,c_last_open_price,vol); // Откроем продажу
                        }
                     }
                  }  
               }
               else if(reason == DEAL_REASON_TP)
               {
                  PrintFormat("Сделка закрыта с прибылью %f USD. \n",pr_ls );
                  c_last_loss = 0; // Если получили профит, то заходим лотом по умолчанию
                  
               }
            }
            else if(entry == DEAL_ENTRY_IN) // Если сделку открыло то возьмем с нее цену открытия и лот
            {  
               string deal_type = (trans.deal_type == DEAL_TYPE_BUY)? "покупку ": "продажу ";
               
               printf("Открыта сделка на %s по цене %f. Стоп лосс %f, тэйк профит %f.\n",deal_type, trans.price, trans.price_sl, trans.price_tp);
               c_last_open_price  = HistoryDealGetDouble(ticket,DEAL_PRICE);
               c_last_volume      = HistoryDealGetDouble(ticket,DEAL_VOLUME);
            }
         }
         
      }
   } 
   
   }
//+------------------------------------------------------------------+
