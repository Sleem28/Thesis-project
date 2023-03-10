//+------------------------------------------------------------------+
//|                                           CheckExistingZones.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include "Zone.mqh"
#include <Arrays\ArrayObj.mqh>


//+-------------------------------------------------------------------------+
//| Класс проверяет параметры будущей зоны на вписанность в предыдущие зоны |
//+-------------------------------------------------------------------------+
/// Check - принимает на вход экстремум и тень, и проверяет зоны на вписанность
class CCheckExistingZones
  {
private:

public:
                     CCheckExistingZones(){};
                    ~CCheckExistingZones(){};
                bool Check(double, double,CArrayObj&);
  };

//+------------------------------------------------------------------+
//| Проверяет параметры на вписанность в предыдущие зоны             |
//+------------------------------------------------------------------+
bool CCheckExistingZones::Check(double extremum,double shadow,CArrayObj &arrayZones)
{
   int length = arrayZones.Total()-1;
   
   for(int i=length;i>=0;i--)
     {
         CZone* tmp = arrayZones.At(i);   
         if(tmp == NULL) break;
         bool is_break = tmp.GetPierced();
         
         if(!is_break)
         {  double zone_extr    = tmp.GetExtremumPrice();
            double zone_shadow  = tmp.GetShadowPrice();
            bool   zone_type_up = tmp.GetTypeUp();
            
            if(zone_type_up) // Ели верхняя зона
            {
               if((extremum <= zone_extr) && (shadow >= zone_shadow))
                  return(false);
            }
            else
            {
               if((extremum >= zone_extr) && (shadow <= zone_shadow))
                  return(false);
            }
         }
     }
     return(true);
}
