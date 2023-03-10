//+------------------------------------------------------------------+
//|                                            ParamsInitializer.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include "IndZone\DrawObjects\DrawZones\DrawZoneParams.mqh"
#include "IndSwingTrends\DrawObjects\DrawSwingTrend\TrendLineParams.mqh"

//+------------------------------------------------------------------+
//| Класс инициализирует структуры для отрисовки графических объектов|
//| зона и свинг                                                     |
//+------------------------------------------------------------------+

class CParamsInitializer
  {
private:

public:
                     CParamsInitializer(){};
                    ~CParamsInitializer(){};
                    void InitZoneParams(int,color,bool,color,bool,color,bool,color,bool,color,bool,color,bool,ZoneParams&);
                    void InitTrendLineParams(int,color,color,color,color,TrendLineParams&);
  };

//+------------------------------------------------------------------+
//| Инициализирует параметры структуры для рисования зоны            |
//+------------------------------------------------------------------+
void CParamsInitializer::InitZoneParams(
                              int    width,
                              color  founded_up_zone_color,
                              bool   fill_founded_up_zone,
                              color  breakthrough_up_zone_color,
                              bool   fill_breakthrough_up_zone,
                              color  finalized_up_zone_color,
                              bool   fill_finalized_up_zone,                     
                              color  founded_down_zone_color,
                              bool   fill_founded_down_zone,
                              color  breakthrough_down_zone_color,
                              bool   fill_breakthrough_down_zone,
                              color  finalized_down_zone_color,
                              bool   fill_finalized_down_zone,
                              ZoneParams &z_params)
{
   z_params.chart_id                     = 0;
   z_params.sub_window                   = 0;
   z_params.line_style                   = STYLE_SOLID;
   z_params.line_width                   = width;
   z_params.founded_up_zone_color        = founded_up_zone_color;
   z_params.fill_founded_up_zone         = fill_founded_up_zone;
   z_params.breakthrough_up_zone_color   = breakthrough_up_zone_color;
   z_params.fill_breakthrough_up_zone    = fill_breakthrough_up_zone;
   z_params.finalized_up_zone_color      = finalized_up_zone_color;
   z_params.fill_finalized_up_zone       = fill_finalized_up_zone; 
   z_params.founded_down_zone_color      = founded_down_zone_color;
   z_params.fill_founded_down_zone       = fill_founded_down_zone;
   z_params.breakthrough_down_zone_color = breakthrough_down_zone_color;
   z_params.fill_breakthrough_down_zone  = fill_breakthrough_down_zone;
   z_params.finalized_down_zone_color    = finalized_down_zone_color;
   z_params.fill_finalized_down_zone     = fill_finalized_down_zone;
   z_params.on_back_plan                 = true;
   z_params.hidden                       = true;
}
//+------------------------------------------------------------------+
//| Инициализирует параметры структуры для рисования свинга          |
//+------------------------------------------------------------------+
void CParamsInitializer::InitTrendLineParams(int width,
                                             color upTrendColor,
                                             color downTrendColor,
                                             color noTrendColor,
                                             color entryPointColor, 
                                             TrendLineParams &params)
{
   params.line_width        = width;
   params.trend_up_color    = upTrendColor;
   params.trend_down_color  = downTrendColor;
   params.no_trend_color    = noTrendColor;
   params.entry_point_color = entryPointColor;
}