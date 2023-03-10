//+------------------------------------------------------------------+
//|                                                   SwingTrend.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include "DrawObjects\DrawSwingTrend\TrendDrawer.mqh"
#include "DrawObjects\DrawSwingTrend\TrendLineParams.mqh"
#include "EntryPointsProcessor.mqh"
#include "DrawObjects\DrawSwingTrend\SwingProcessor.mqh"
#include "EntryPointsProcessor.mqh"
#include <ZoneS28\Enums.mqh>

#include "TPoint.mqh"

#include <Arrays\ArrayObj.mqh>

//+------------------------------------------------------------------+
//|Класс расчитыает и рисует трендовую свинг линию и точки входа     |
//+------------------------------------------------------------------+

class CSwingTrend {
private:
   double   up_control_line;
   double   down_control_line;
   bool     first_run;
   double   last_high;
   double   last_low;
   datetime last_time;
public:
                     CSwingTrend();
                    ~CSwingTrend() {};
                void Reset();    
                    
                void Calculate(int                   bars,
                               LocalTrend            &trend,
                               ENUM_TIMEFRAMES       timeframe,
                               int                   &point_number,
                               CTrendDrawer          &drawer,
                               TrendLineParams       &params,
                               CArrayObj             &arrayPoints,
                               CSwingProcessor       &swing_processor,
                               CEntryPointsProcessor &entry_point_processor);
};
//+------------------------------------------------------------------+
//|Конструктор                                                       |
//+------------------------------------------------------------------+
CSwingTrend::CSwingTrend(void) 
{
   up_control_line     = -1; 
   down_control_line   = -1;
   first_run           = false;
   last_high           = 0;
   last_low            = 0;
   last_time           = 0;
}
void CSwingTrend::Reset(void)
{
   up_control_line     = -1; 
   down_control_line   = -1;
   first_run           = false;
   last_high           = 0;
   last_low            = 0;
   last_time           = 0;
}
//+------------------------------------------------------------------+
//| Расчитывает и рисует трендовую свинг линию и точки входа         |
//+------------------------------------------------------------------+
/// @bars - количество баров для расчета
/// @trend - направление тренда, передаем по ссылке
/// @timeframe - таймфрейм
/// @point_number - номер точки отрисовки, передаем по ссылке
/// @drawer - объект класса отрисовщика свингов, передаем по ссылке
/// @params - структура параметров для отрисовки свингов и точкек входа, передаем по ссылке
/// @arrayPoints - коллекция с указателями на экземпляры класса TPoint, передаем по ссылке
/// @swing_processor - объект класса для создания и работы с объектами тапа свинг, передаем по ссылке
/// @entry_point_processor - объект класса для создания и работы с объектами тапа точка входа, передаем по ссылке
void CSwingTrend::Calculate(int                   bars,
                            LocalTrend           &trend,
                            ENUM_TIMEFRAMES       timeframe,
                            int                   &point_number,
                            CTrendDrawer          &drawer,
                            TrendLineParams       &params,
                            CArrayObj             &arrayPoints,
                            CSwingProcessor       &swing_processor,
                            CEntryPointsProcessor &entry_point_processor)
{
   
   int      total_points = arrayPoints.Total();
   CTPoint* tmp          = NULL;
          

   for(int i=bars; i>0; i--) { //главный цикл

      double   high  = NormalizeDouble(iHigh(_Symbol,timeframe,i),_Digits);
      double   low   = NormalizeDouble(iLow(_Symbol,timeframe,i),_Digits);
      double   open  = NormalizeDouble(iOpen(_Symbol,timeframe,i),_Digits);
      double   close = NormalizeDouble(iClose(_Symbol,timeframe,i),_Digits);
      datetime time  = iTime(_Symbol,timeframe,i);


      if(!first_run) { // Если это первый запуск
         up_control_line   = high;
         down_control_line = low;
         last_high = high;
         last_low = low;
         last_time = time;
         first_run = true;
         continue;
      }
      
      if(trend == NoTrend) 
      { // Если тренд еще не определили
         if(close > up_control_line) 
         { //Закрытие выше верхнего контроля
            trend               = TrendUp;
            double   prevLow    = NormalizeDouble(iLow(_Symbol,timeframe,i+1),_Digits);
            datetime prevTime   = iTime(_Symbol,timeframe,i+1);
            tmp                 = new CTPoint(point_number,prevLow,prevTime,0);          
            up_control_line     = high;
            down_control_line   = low;
            point_number ++;
            arrayPoints.Add(tmp);
            continue;
         } 
         else if(close < down_control_line) 
         { //Закрытие ниже нижего контроля
            trend               = TrendDown;
            double   prevHigh   = NormalizeDouble(iHigh(_Symbol,timeframe,i+1),_Digits);
            datetime prevTime   = iTime(_Symbol,timeframe,i+1);
            tmp                 = new CTPoint(point_number,prevHigh,prevTime,1);            
            up_control_line     = high;
            down_control_line   = low;
            point_number ++;
            arrayPoints.Add(tmp);

            continue;
         }
      } 
      else 
      {        // Если тренд оопределен
         if(trend == TrendUp) 
         { // тренд вверх
            if(close < down_control_line) 
            { // закрытие ниже контрольного уровня (случился разворот)
               if(high > up_control_line) 
               { // свеча полностью перекрывает при развороте
                  tmp = new CTPoint(point_number,high,time,0);
                  arrayPoints.Add(tmp);                 
                  point_number ++;
                  
                  up_control_line     = high;
                  down_control_line   = low;
                  last_high           = high;
                  last_time           = time;
                  last_low            = low;
                  trend               = TrendDown;
                  continue;
               } 
               else 
               {     
                  tmp = new CTPoint(point_number,last_high,last_time,0);
                  arrayPoints.Add(tmp);                
                  point_number++;

                  up_control_line     = high;
                  down_control_line   = low;
                  last_high           = high;
                  last_time           = time;
                  last_low            = low;
                  trend               = TrendDown;
                  continue;
               }
            } 
            else 
            { // разворот не произошел
               if(high > up_control_line) 
               { // хай выше верхнего контроля
                  up_control_line   = high;
                  down_control_line = low;
                  last_high         = high;
                  last_time         = time;
                  last_low          = low;
                  continue;
               } 
               else 
                  continue;          
            }
         } 
         else if(trend == TrendDown) 
         { // Тренд вниз
            if(close > up_control_line) 
            { // закрытие выше верхнего контроля
               if(low < down_control_line) 
               { // лоу ниже нижнего контроля
                  tmp = new CTPoint(point_number,low,time,1);
                  arrayPoints.Add(tmp);                 
                  point_number ++;

                  up_control_line   = high;
                  down_control_line = low;
                  last_high         = high;
                  last_time         = time;
                  last_low          = low;
                  trend             = TrendUp;
                  continue;
               } 
               else 
               {              
                  tmp = new CTPoint(point_number,last_low,last_time,0);
                  arrayPoints.Add(tmp);            
                  point_number++;

                  up_control_line   = high;
                  down_control_line = low;
                  last_high         = high;
                  last_time         = time;
                  last_low          = low;
                  trend             = TrendUp;
                  continue;
               }
            } 
            else 
            {
               if(low < down_control_line) 
               { 
                  up_control_line     = high;
                  down_control_line   = low;
                  last_high           = high;
                  last_time           = time;
                  last_low            = low;
                  continue;
               } 
               else 
                  continue;
            }
         }
      }
   }
//-----------------------------Рисуем--------------------------------+
// Если появилась новая точка
if(total_points < arrayPoints.Total())drawer.DrawTrend(arrayPoints,params,swing_processor,entry_point_processor); 
}
//+------------------------------------------------------------------+
