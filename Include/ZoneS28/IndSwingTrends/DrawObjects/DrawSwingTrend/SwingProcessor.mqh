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



//+------------------------------------------------------------------+
//| Класс для создания и модификации объектов типа трендовая линия   |
//+------------------------------------------------------------------+

class CSwingProcessor {
private:
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
                void ResetSwingCounter(){m_swing_counter = 0;};
                bool DrawSwing(int,int,CArrayObj&,TrendLineParams&);
                
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
//| Рисует свинг                                                     |
//+------------------------------------------------------------------+
bool CSwingProcessor::DrawSwing(int cur_point_index,int trend,CArrayObj &array_points,TrendLineParams &params)
{
   string name    = params.swing_name + IntegerToString(cur_point_index); 
          m_color = (trend == -1)? params.no_trend_color : (trend == 0)? params.trend_up_color : params.trend_down_color;
          
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
