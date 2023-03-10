//+------------------------------------------------------------------+
//|                                                  TrendDrawer.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include "TrendLineParams.mqh"
#include "SwingProcessor.mqh"
#include <ZoneS28\IndSwingTrends\EntryPointsProcessor.mqh>
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\Enums.mqh>

#include <Arrays\ArrayObj.mqh>



class CTrendDrawer {
private:
     string          m_base_swing_name; // Базовое имя свинга для отрисовки
     string          m_base_entry_point_name; // Базовое имя точки входа
     int             m_inside_point_counter;  
     STrend          m_trend; 
     int             m_drawed_index;
     bool            m_first_swing_builded;
     double          m_up_control_price;
     double          m_down_control_price;
     ENUM_TIMEFRAMES m_timeframe;
  
     CTPoint*        m_cur_point;
     CTPoint*        m_prev_point;
   
     double          m_first_price;
     datetime        m_first_time;
     double          m_second_price;
     datetime        m_second_time;     
     
     bool            m_show_trend;
     bool            m_show_entry;
     bool            m_first_run; 
     bool            m_prev_swing_up;   
   
                bool CreateTrendLine(int);
                bool CreateEntryPoint(); 
public:
                     CTrendDrawer(ENUM_TIMEFRAMES);
                    ~CTrendDrawer(){};
                void SetShowTrend(bool show_trend){m_show_trend = show_trend;};
                void SetShowEntry(bool show_entry){m_show_entry = show_entry;}; 
                void SetTrend(STrend &trend){m_trend = trend;};
                void Reset(); 
                
                void SetFirstRun(bool&first_run){m_first_run = first_run;};   
                void DrawTrend(CArrayObj &,TrendLineParams &,CSwingProcessor &,CEntryPointsProcessor &);
                
};
//+------------------------------------------------------------------+
//|  Конструктор                                                     |
//+------------------------------------------------------------------+
CTrendDrawer::CTrendDrawer(ENUM_TIMEFRAMES timeframe)
{
   m_drawed_index            = -1;
   m_inside_point_counter    = 0;
   m_timeframe               = timeframe;
   m_up_control_price        = 0;
   m_down_control_price      = 0;
   m_first_swing_builded     = false;
   m_first_run               = true;
}
//+------------------------------------------------------------------+
//|  Reset params                                                    |
//+------------------------------------------------------------------+
void CTrendDrawer::Reset(void)
{
   m_drawed_index            = -1;
   m_inside_point_counter    = 0;
   m_up_control_price        = 0;
   m_down_control_price      = 0;
   m_first_swing_builded     = false;
   m_first_run               = true;
}
//-------------------------------------------------------------------+
//|Метод рисует трендовые линии свингами                             |
//+------------------------------------------------------------------+
void CTrendDrawer::DrawTrend(CArrayObj &array,TrendLineParams &params,CSwingProcessor &swing_processor,CEntryPointsProcessor &entry_points_processor)
{  
   
   m_base_swing_name         = StringFormat("Swing %s number ", swing_processor.ConvertTimeframe(_Period));
   m_base_entry_point_name   = StringFormat("Entry point %s number ", swing_processor.ConvertTimeframe(_Period));
   params.entry_point_name   = m_base_entry_point_name;
   params.swing_name         = m_base_swing_name;
   swing_processor.SetBaseName(m_base_swing_name);
   
   int lenth = array.Total();
   
   int index = (m_first_run)? 1 : (m_drawed_index >= 0)? m_drawed_index+1 : 1;
   m_first_run = false;
   
   if(lenth < 2)
   {
      Print("Не достаточно точек для построения тренда.");
      return;
   }
   
   for(int i=index;i<lenth;i++) // главный цикл
     {   
         m_drawed_index   = i;
         m_cur_point      = array.At(i);   // получим вторую точку
         m_prev_point     = array.At(i-1); // получим первую точку
         //получим данные из точек
         m_first_price  = m_prev_point.GetPrice();
         m_first_time   = m_prev_point.GetDate();
         m_second_price = m_cur_point.GetPrice();
         m_second_time  = m_cur_point.GetDate();
         //заполним структуру с параметрами отрисовки
         params.first_price = m_first_price;
         params.first_date  = m_first_time;
         params.second_price = m_second_price;
         params.second_date  = m_second_time;
         
         if(!m_first_swing_builded) // Если первый свинг не построен
         {
            if(m_show_trend)
            {
               if(!swing_processor.DrawSwing(i,m_trend,array,params))
               {
                  Print("Ошибка при построении первого свинга.");
                  return;
               }
               else
               {
                  m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                  m_trend         = (m_prev_swing_up)? Trend_Up : Trend_Down;
               }
            }
            m_up_control_price    = (m_first_price > m_second_price)? m_first_price : m_second_price;
            m_down_control_price  = (m_first_price < m_second_price)? m_first_price : m_second_price;
            m_first_swing_builded = true;
         }
         else // Если первый свинг построен
         {
            entry_points_processor.FindEntryPoint(m_show_trend); // заготовка поиска и отрисовки точки входа
            
            if(m_prev_swing_up) // если предыдущий свинг вверх
            {
               if(m_second_price < m_down_control_price) // точка ниже нижнего контроля
               {
                 m_trend = Trend_Down;
                 m_inside_point_counter = 0;
                 
                 if(m_show_trend)
                  {
                     if(!swing_processor.DrawSwing(i,m_trend,array,params))
                     {
                         Print("Ошибка при построении свинга.");
                         return;
                     }
                     else
                     {
                         m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                     }
                  }
                  m_up_control_price    = (m_first_price > m_second_price)? m_first_price : m_second_price;
                  m_down_control_price  = (m_first_price < m_second_price)? m_first_price : m_second_price; 
               }
               else   // Если точка внутри свинга
               {
                  m_inside_point_counter++;
                  
                  if(m_inside_point_counter == 4) // если 4 внутренних свинга
                  {
                     m_trend = No_Trend;
                     
                     if(m_show_trend)
                     {
                        if(!swing_processor.DrawSwing(i,m_trend,array,params))
                        {
                         Print("Ошибка при построении свинга.");
                         return;
                        }
                        else
                        {
                            m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                        }
                     } 
                  }
                  else // если количество внутренних свингов меньше 4
                  {
                     if(m_show_trend)
                     {
                        if(!swing_processor.DrawSwing(i,m_trend,array,params))
                        {
                         Print("Ошибка при построении свинга.");
                         return;
                        }
                        else
                        {
                            m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                        }
                     } 
                  }
               }
            }
            else if(!m_prev_swing_up) // если предыдущий свинг вниз
            {
                if(m_second_price > m_up_control_price) // точка выше верхнего контроля
               {
                 m_trend = Trend_Up;
                 m_inside_point_counter = 0;
                 
                 if(m_show_trend)
                  {
                     if(!swing_processor.DrawSwing(i,m_trend,array,params))
                     {
                         Print("Ошибка при построении свинга.");
                         return;
                     }
                     else
                     {
                         m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                     }
                  }
                  m_up_control_price    = (m_first_price > m_second_price)? m_first_price : m_second_price;
                  m_down_control_price  = (m_first_price < m_second_price)? m_first_price : m_second_price; 
               }
               else   // Если точка внутри свинга
               {
                  m_inside_point_counter++;
                  
                  if(m_inside_point_counter == 4) // если 4 внутренних свинга
                  {
                     m_trend = No_Trend;
                     
                     if(m_show_trend)
                     {
                        if(!swing_processor.DrawSwing(i,m_trend,array,params))
                        {
                         Print("Ошибка при построении свинга.");
                         return;
                        }
                        else
                        {
                          m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                        }
                     } 
                  }
                  else // если количество внутренних свингов меньше 4
                  {
                     if(m_show_trend)
                     {
                        if(!swing_processor.DrawSwing(i,m_trend,array,params))
                        {
                         Print("Ошибка при построении свинга.");
                         return;
                        }
                        else
                        {
                          m_prev_swing_up = (m_first_price < m_second_price)? true:false;
                        }
                     } 
                  }
               }
            }
         }
     }// конец главного цикла
}
