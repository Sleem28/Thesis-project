//+------------------------------------------------------------------+
//|                                            TypeEntryFromZone.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\Enums.mqh>
#include <ZoneS28\IndSwingTrends\TPoint.mqh>
#include <ZoneS28\Trade\EntryPointsClasses\CandleNumberGetter.mqh>
#include <ZoneS28\IndZone\Zone.mqh>

class CTypeEntryFromZone {
private:
                bool PatternInZone(CArrayObj &zones,double &price_arr[],STrend trend);
                bool findPointsIntoZone(double extremum_price,double shadow_price,double &price_arr[], bool zone_up);
                bool findPointsIntersectionAcrossZone(double extremum_price,double shadow_price,double &price_arr[], bool zone_up);
public:
                     CTypeEntryFromZone(){};
                    ~CTypeEntryFromZone(){};
                bool Find(STrend trend, CArrayObj &points, CArrayObj &zones, ENUM_TIMEFRAMES timeframe, string symbol);
};
//+------------------------------------------------------------------+
//|Метод ищет разворотный паттерн от зоны                            |
//+------------------------------------------------------------------+
bool CTypeEntryFromZone::Find(STrend trend,CArrayObj &points,CArrayObj &zones,ENUM_TIMEFRAMES timeframe,string symbol)
{  
   CCandleNumberGetter m_candle_getter;
   int    length          = points.Total();
   double price_arr[4];
   bool   pattern_found   = false;
   bool   pattern_in_zone = false;
   if(length < 4)
   {
      Print("Недостаточно точек для поиска паттерна на Разворот от зоны!!!");
      return(false);
   }
   // Получим 4 точки из коллекции с найденными точками
   CTPoint *point1 = points.At(length-1);
   CTPoint *point2 = points.At(length-2);
   CTPoint *point3 = points.At(length-3);
   CTPoint *point4 = points.At(length-4);
   //Получим последнюю цену закрытия на нулевой свече
   double   last_close = iClose(symbol,timeframe,0);
   //Возьмем цены из точек
   double   p1_price   = point1.GetPrice();
   double   p2_price   = point2.GetPrice();
   double   p3_price   = point3.GetPrice();
   double   p4_price   = point4.GetPrice();
   //Сложим цены точек в массив
   price_arr[0] = p1_price;
   price_arr[1] = p2_price;
   price_arr[2] = p3_price;
   price_arr[3] = p4_price;
   //Получим номер свечи экстреммума 1й точки 
   datetime time_first_point    = point1.GetDate();
   int      num_first_point_candle = m_candle_getter.GetCandleNumber(time_first_point, symbol, timeframe);
   
   if(trend == Trend_Up) // Поиск для тренда вверх
   {
      double candle_low = iLow(symbol,timeframe,num_first_point_candle);
      
      //Описание паттерна для покупок
      if(p1_price    > p2_price && 
         p2_price    < p3_price && 
         p2_price    < p4_price &&
         candle_low  > p3_price && 
         last_close  > p3_price)
      {
        // Print("Найден паттерн на разворот от зоны для установки ордера buy_stop.");
         pattern_found = true;
      }
         
   }
   //+------------------------------------------------------------------+
   else if(trend == Trend_Down) // Поиск для тренда вниз
   {
      double candle_high = iHigh(symbol,timeframe,num_first_point_candle);
      
      //Описание паттерна для продаж
      if(p1_price    < p2_price && 
         p2_price    > p3_price && 
         p2_price    > p4_price &&
         candle_high < p3_price && 
         last_close  < p3_price)
      {
         //Print("Найден паттерн на разворот от зоны для установки ордера sell_stop.");
         pattern_found = true;;
      }
   }
   
   // Проверим нахождения паттерна внутри зоны если паттерн найден
   if(pattern_found) pattern_in_zone = PatternInZone(zones,price_arr,trend);
   
   
   if(pattern_found && pattern_in_zone)
   {
      string txt = (trend == Trend_Up)? " на покупку.":" на продажу";
      Print("Найден паттерн на вход от зоны" + txt);
      return(true);
   }
   else
      return(false);
}
//+------------------------------------------------------------------+
//| Метод ищет касание паттерна зоны                                 |
//+------------------------------------------------------------------+
//Если хотя бы одна точка в зоне или одна точка выше зоны а вторая ниже, то паттерн в зоне

bool CTypeEntryFromZone::PatternInZone(CArrayObj &zones,double &price_arr[],STrend trend)
{
   int    length = zones.Total();
   bool   finalyze;
   bool   zone_up;
   bool   pierced;
   double extremum_price;
   double shadow_price;
   CZone *tmp;
   
   bool   result = false;
   
   for(int i=length-1; i >= 0; i--)// переберем массив с зонами c конца
   {
      tmp      = zones.At(i);
      finalyze = tmp.GetFinalize();
      if(!finalyze) // Если зона не финализирована
      {
         pierced        = tmp.GetPierced();
         zone_up        = tmp.GetTypeUp();
         extremum_price = tmp.GetExtremumPrice();
         shadow_price   = tmp.GetShadowPrice();
         
         if(!pierced) // Если зона не пробита
         {
            if(trend == Trend_Down && zone_up) // Если текущий тренд вниз(паттерн разворота вниз сформирован) и зона верхняя
            {
               result = findPointsIntoZone(extremum_price, shadow_price, price_arr, zone_up);// Если хотя бы одна точка внутри зоны то считаем, что паттерн в зоне и возвращаем true
               
               if(!result)// Если точки не попали в зону проверим проверим на пересечение точек выше и ниже зоны
               {
                  result = findPointsIntersectionAcrossZone(extremum_price, shadow_price, price_arr, zone_up);
               } 
               
            }
            else if(trend == Trend_Up && !zone_up) // Если текущий тренд вверх(паттерн разворота ввверх сформирован) и зона нижняя
            {
               result = findPointsIntoZone(extremum_price, shadow_price, price_arr, zone_up);// Если хотя бы одна точка внутри зоны то считаем, что паттерн в зоне и возвращаем true
               
               if(!result)// Если точки не попали в зону проверим проверим на пересечение точек выше и ниже зоны
               {
                  result = findPointsIntersectionAcrossZone(extremum_price, shadow_price, price_arr, zone_up);
               }
            }
         }
         else // Если зона пробита
         {
            if(trend == Trend_Up && zone_up) // Если текущий тренд вверх(паттерн разворота вверх сформирован) и пробитая зона верхняя
            {
               result = findPointsIntoZone(extremum_price, shadow_price, price_arr, zone_up);// Если хотя бы одна точка внутри зоны то считаем, что паттерн в зоне и возвращаем true
               
               if(!result)// Если точки не попали в зону проверим проверим на пересечение точек выше и ниже зоны
               {
                  result = findPointsIntersectionAcrossZone(extremum_price, shadow_price, price_arr, zone_up);
               }
                 
               
            }
            else if(trend == Trend_Down && !zone_up) // Если текущий тренд вниз(паттерн разворота вниз сформирован) и пробитая зона нижняя
            {
               result = findPointsIntoZone(extremum_price, shadow_price, price_arr, zone_up);// Если хотя бы одна точка внутри зоны то считаем, что паттерн в зоне и возвращаем true
               
               if(!result)// Если точки не попали в зону проверим проверим на пересечение точек выше и ниже зоны
               {
                  result = findPointsIntersectionAcrossZone(extremum_price, shadow_price, price_arr, zone_up);
               }
            }
         }
      }
      if(result) break;
   }
   return(result);
}
//+------------------------------------------------------------------+
//| Метод ищет нахождение хоть одной точки меду ценами зоны          |
//+------------------------------------------------------------------+
bool CTypeEntryFromZone::findPointsIntoZone(double extremum_price,double shadow_price,double &price_arr[], bool zone_up)
{
   uint length = price_arr.Size();
   bool result = false;
   
   for(uint i=0;i<length;i++)
     {
         double tmp_price = price_arr[i];
         if(zone_up) // Если проверка для верхней зоны
         {
            if(extremum_price >= tmp_price && shadow_price <= tmp_price) // Если точка внутри верхней зоны
            {
               result = true;
               break;
            }
         }
         else// Если проверка для нижней зоны
         {
            if(extremum_price <= tmp_price && shadow_price >= tmp_price) // Если точка внутри нижней зоны
            {
               result = true;
               break;
            }
         }
     }
   return result;
}
//+------------------------------------------------------------------+
//|Метод ищет нахождение точек вне зоны с противоположных сторон     |
//|точки выше и ниже зоны                                            |
//+------------------------------------------------------------------+
bool CTypeEntryFromZone::findPointsIntersectionAcrossZone(double extremum_price,double shadow_price,double &price_arr[],bool zone_up)
{
   uint length = price_arr.Size();
   bool found = false;
   
   for(uint i=0;i<length;i++)
     {
       double tmp_price = price_arr[i];
       if(zone_up) // Поиск для верхних зон
       {
         if(tmp_price > extremum_price) // Если текущая цена выше верхней зоны
         {
            for(uint j=0;j<length;j++) // Проверим все цены на расположение ниже зоны
              {
                if(j!=i) // Если точка не проверяемая
                {
                  if (price_arr[j] < shadow_price)
                  {
                     found = true;
                     break;
                  }
                }
              }
              if(found)
               break;      
         }
         else if(tmp_price < shadow_price)// Если текущая цена ниже верхней зоны
         {
            for(uint j=0;j<length;j++) // Проверим все цены на расположение выше зоны
              {
                if(j!=i) // Если точка не проверяемая
                {
                  if (price_arr[j] > extremum_price)
                  {
                     found = true;
                     break;
                  }
                }
              }
              if(found)
               break;   
         }
       }
       else // Если зона нижняя
       {
         if(tmp_price < extremum_price) // Если текущая цена ниже нижней зоны
         {
            for(uint j=0;j<length;j++) // Проверим все цены на расположение выше зоны
              {
                if(j!=i) // Если точка не проверяемая
                {
                  if (price_arr[j] > shadow_price)
                  {
                     found = true;
                     break;
                  }
                }
              }
              if(found)
               break;      
         }
         else if(tmp_price > shadow_price)// Если текущая цена выше нижней зоны
         {
            for(uint j=0;j<length;j++) // Проверим все цены на расположение ниже зоны
              {
                if(j!=i) // Если точка не проверяемая
                {
                  if (price_arr[j] < extremum_price)
                  {
                     found = true;
                     break;
                  }
                }
              }
              if(found)
               break;   
         }
       } 
     }
  return(found);
}