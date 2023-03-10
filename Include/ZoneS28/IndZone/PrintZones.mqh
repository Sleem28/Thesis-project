//+------------------------------------------------------------------+
//|                                                   PrintZones.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include "Zone.mqh"

class CPrintZones
  {
private:

public:
                     CPrintZones();
                    ~CPrintZones();
              void   PrintZone(CZone*&);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPrintZones::CPrintZones()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPrintZones::~CPrintZones()
  {
  }
//+------------------------------------------------------------------+
void CPrintZones::PrintZone(CZone* &zone)
{
   Print("Номер зоны: ", zone.GetNumber());
   Print("Цена экстремума: ", zone.GetExtremumPrice());
   Print("Цена начала тени: ", zone.GetShadowPrice());
   Print("Дата начала отрисовки: ", zone.GetStartDate());
   Print("Дата конца отрисовки: ", zone.GetEndDate());
   Print("Тип зоны: ", (zone.GetTypeUp())? "Верхняя" : "Нижняя");
   Print("Пробита? : ", zone.GetPierced());
   Print("Перекрыта? : ", zone.GetBlocked());
   Print("Финализирована? : ", zone.GetFinalize());
}