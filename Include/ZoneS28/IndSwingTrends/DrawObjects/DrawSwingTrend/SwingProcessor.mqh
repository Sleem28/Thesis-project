//+------------------------------------------------------------------+
//|                                               SwingProcessor.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include "TrendLineParams.mqh"
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\Enums.mqh>



//+------------------------------------------------------------------+
//| Класс для создания и модификации объектов типа трендовая линия   |
//+------------------------------------------------------------------+

class CSwingProcessor {
private:
   STrend   m_cur_trend;
   string   m_base_name;
   int      m_swing_counter;
   double   m_first_price;
   double   m_second_price;
   datetime m_first_time;
   datetime m_second_time;
   color    m_color;
public:
                     CSwingProcessor();
                    ~CSwingProcessor(){};
                //+------------------------------------------------------------------+
                //|Устанавливает базовое имя объекта                                 |
                //+------------------------------------------------------------------+    
                void SetBaseName(string base_name){m_base_name = base_name;};
                //+------------------------------------------------------------------+
                //|Удаляет все свинги с базовым именем                               |
                //+------------------------------------------------------------------+
                void DeleteSwings(){ObjectsDeleteAll(0,m_base_name,0,OBJ_TREND);};
                //+------------------------------------------------------------------+
                //|Сбрасывает на ноль счетчик свигов                                 |
                //+------------------------------------------------------------------+
                void Reset();
                //+------------------------------------------------------------------+
                //|Рисует трендовую линию                                            |
                //+------------------------------------------------------------------+   
                bool DrawSwing(int,STrend,CArrayObj&,TrendLineParams&);
                //+------------------------------------------------------------------+
                //|Возвращает таймфрейм строкой из инама                             |
                //+------------------------------------------------------------------+               
              string ConvertTimeframe(ENUM_TIMEFRAMES timeframe);
                //+------------------------------------------------------------------+
                //|Возвращает текущий тренд                                          |
                //+------------------------------------------------------------------+
              STrend GetCurrentTrend(){return(m_cur_trend);};
                
};
//+------------------------------------------------------------------+
//|Конструктор                                                       |
//+------------------------------------------------------------------+
CSwingProcessor::CSwingProcessor() {
   m_swing_counter = 0;
   m_base_name = "";
   m_first_price = -1;
   m_second_price = -1;
   m_first_time = -1;
   m_second_time = -1;
}
//+------------------------------------------------------------------+
//| Reset params                                                     |
//+------------------------------------------------------------------+
void CSwingProcessor::Reset(void)
{
   m_swing_counter = 0;
   m_base_name = "";
   m_first_price = -1;
   m_second_price = -1;
   m_first_time = -1;
   m_second_time = -1;
}
//+------------------------------------------------------------------+
//|Конвертирует ТФ из ENUM в строку                                  |
//+------------------------------------------------------------------+
string CSwingProcessor::ConvertTimeframe(ENUM_TIMEFRAMES timeframe)
{
   string tf = "";
   switch(timeframe)
   {
      case PERIOD_M1:
         tf = "M1";
         break;
      case PERIOD_M5:
         tf = "M5";
         break;
      case PERIOD_M15:
         tf = "M15";
         break;
      case PERIOD_M30:
         tf = "M30";
         break;
      case PERIOD_H1:
         tf = "H1";
         break;
      case PERIOD_H4:
         tf = "H4";
         break;
      case PERIOD_D1:
         tf = "D1";
         break;
      case PERIOD_W1:
         tf = "W1";
         break;
      default:
         tf = EnumToString(timeframe);
         break;
   }
   return(tf);
}
//+------------------------------------------------------------------+
//| Рисует свинг                                                     |
//+------------------------------------------------------------------+
bool CSwingProcessor::DrawSwing(int cur_point_index,STrend trend,CArrayObj &array_points,TrendLineParams &params)
{  
   string name    = params.swing_name + IntegerToString(cur_point_index); 
          m_color = (trend == No_Trend)? params.no_trend_color : (trend == Trend_Up)? params.trend_up_color : params.trend_down_color;
          m_cur_trend = trend;
          
   if(cur_point_index < 1)
   {
      Print("Неверный индекс точки в классе CSwingProcessor в методе DrawSwing.");
      return(false);
   }
            
   if(ObjectCreate(0,name,OBJ_TREND,0,params.first_date,params.first_price,params.second_date,params.second_price))
   {
      m_swing_counter++;
      ObjectSetInteger(0,name,OBJPROP_WIDTH,params.line_width);
      ObjectSetInteger(0,name,OBJPROP_COLOR,m_color);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   }
   else
   {
      Print("Свинг ",cur_point_index," не был нарисован.");
      return(false);
   }
   return true;
}
//+------------------------------------------------------------------+
