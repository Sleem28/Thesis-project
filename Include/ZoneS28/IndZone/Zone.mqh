//+------------------------------------------------------------------+
//|                                                         Zone.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Object.mqh>

class CZone : public CObject
  {
private:
   int               m_number;
   double            m_extremum_price;
   double            m_shadow_price;
   datetime          m_start_date;
   datetime          m_end_date;
   bool              m_pierced;
   bool              m_blocked;
   bool              m_finilize;
   bool              m_type_up;


public:
                     CZone(int,double,double,datetime,datetime);
                    ~CZone();
   int               GetNumber();
   double            GetExtremumPrice();
   double            GetShadowPrice();
   datetime          GetStartDate();
   datetime          GetEndDate();
   bool              GetPierced();
   bool              GetBlocked();
   bool              GetFinalize();
   bool              GetTypeUp();

   void              PiercedZone();
   void              BlockedZone();
   void              FinalizeZone();
   void              SetEndDate(datetime);
  };
//+------------------------------------------------------------------+
//| Класс описывает параметры зоны                                   |
//+------------------------------------------------------------------+
CZone::CZone(int      number,
             double   extremum_price,
             double   shadow_price,
             datetime start_date,
             datetime end_date)
  {
   m_number         = number;
   m_extremum_price = extremum_price;
   m_shadow_price   = shadow_price;
   m_start_date     = start_date;
   m_end_date       = end_date;
   m_pierced        = false;
   m_blocked        = false;
   m_finilize       = false;
   m_type_up        = (extremum_price >= shadow_price)? true : false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CZone::~CZone()
  {
  }
//+------------------------------------------------------------------+
//|                   Zone number getter                             |
//+------------------------------------------------------------------+
int CZone::GetNumber(void)
  {
   return m_number;
  }
//+------------------------------------------------------------------+
//|                   Extremum price getter                          |
//+------------------------------------------------------------------+
double CZone::GetExtremumPrice(void)
  {
   return NormalizeDouble(m_extremum_price, _Digits);
  }
//+------------------------------------------------------------------+
//|                   Shadow price getter                            |
//+------------------------------------------------------------------+
double CZone::GetShadowPrice(void)
  {
   return NormalizeDouble(m_shadow_price, _Digits);
  }
//+------------------------------------------------------------------+
//|                     Strart time getter                           |
//+------------------------------------------------------------------+
datetime CZone::GetStartDate(void)
{
   return m_start_date;   
}
//+------------------------------------------------------------------+
//|                     End time getter                              |
//+------------------------------------------------------------------+
datetime CZone::GetEndDate(void)
{
   return m_end_date;   
}
//+------------------------------------------------------------------+
//|                     Type getter                                  |
//+------------------------------------------------------------------+
bool CZone::GetTypeUp(void)
{
   return m_type_up;   
}
//+------------------------------------------------------------------+
//|                     Pierced zone                                 |
//+------------------------------------------------------------------+
void CZone::PiercedZone()
{
   m_pierced = true;   
}
//+------------------------------------------------------------------+
//|                     Blocked zone                                |
//+------------------------------------------------------------------+
void CZone::BlockedZone()
{
   m_blocked = true;   
}
//+------------------------------------------------------------------+
//|                     Finalize zone                                |
//+------------------------------------------------------------------+
void CZone::FinalizeZone()
{
   m_finilize = true;   
}
//+------------------------------------------------------------------+
//|                     Get blocked                                  |
//+------------------------------------------------------------------+
bool CZone::GetBlocked()
{
   return (m_blocked);   
}
//+------------------------------------------------------------------+
//|                    Get pierced zone                              |
//+------------------------------------------------------------------+
bool CZone::GetPierced()
{
   return(m_pierced);   
}
//+------------------------------------------------------------------+
//|                    Get finalize zone                             |
//+------------------------------------------------------------------+
bool CZone::GetFinalize(void)
{
   return(m_finilize);   
}
//+------------------------------------------------------------------+
//|                     End date setter                              |
//+------------------------------------------------------------------+
void CZone::SetEndDate(datetime new_date)
{
   m_end_date = new_date;   
}
//+------------------------------------------------------------------+
