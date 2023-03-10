//+------------------------------------------------------------------+
//|                                                   SearchZone.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
class CSearchZone
  {
private:

public:
                     CSearchZone(){};
                    ~CSearchZone(){};
   bool              SearchZone(int,ENUM_TIMEFRAMES,int,bool);
  };

//+------------------------------------------------------------------+
//|    Ищет максимум-минимум на средней свече паттерна               |
//+------------------------------------------------------------------+
/// @bar - номер бара, скоторого начнем поиск
/// @candles - количество свечей для поиска паттерна
/// @isUpPattern - верхний паттерн: true ; нижний паттерн: false
bool CSearchZone::SearchZone(int bar, ENUM_TIMEFRAMES timeframe, int candles, bool isUpPattern)
  {
   if(candles!=3)
     {
      if(candles!=5)
        {
         Print("Параметр candles должен быть равен 3 или 5!!!!");
         return false;
        }
     }

   int    how        = bar + candles;
   int    index      = 0;
   int    target_bar = (candles == 5)? bar+2:bar+1;
   double min_max    = (isUpPattern)? -1:1000000;

   for(int i=bar; i<how; i++)
     {
      double high = NormalizeDouble(iHigh(_Symbol,timeframe,i),_Digits);
      double low  = NormalizeDouble(iLow(_Symbol,timeframe,i),_Digits);
      if(isUpPattern) // Поиск верхнего паттерна
        {
         if(high > min_max)
           {
            min_max = high;
            index = i;
           }
        }
      else            // Поиск нижнего паттерна
        {
         if(low < min_max)
           {
            min_max = low;
            index = i;
           }
        }
     }
   bool result = (index == target_bar)? true : false;
   
   if(!result)  //Доп проверка на
   {
      if(index == target_bar +1) //Если 2 и 3 бары на экстреммумах равны
      {
         if(isUpPattern) // Если поиск для верхнего паттерна
         {
            double sec_high   = NormalizeDouble(iHigh(_Symbol,timeframe,target_bar + 1),_Digits);
            double third_high = NormalizeDouble(iHigh(_Symbol,timeframe,target_bar),_Digits);
            if(sec_high == third_high)
               return(true);
            else
               return(false);
         }
         else
         {
            double sec_low   = NormalizeDouble(iLow(_Symbol,timeframe,target_bar + 1),_Digits);
            double third_low = NormalizeDouble(iLow(_Symbol,timeframe,target_bar),_Digits);
            if(sec_low == third_low)
               return(true);
            else
               return(false);
         }
      }
      return(false);
   }
   else
      return(true);
  }
