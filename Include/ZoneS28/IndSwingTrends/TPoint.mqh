//+------------------------------------------------------------------+
//|                                                        Point.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Object.mqh>

//+------------------------------------------------------------------+
//| Класс точка. Нужен для отрисовки по ним свингов                  |
//+------------------------------------------------------------------+

class CTPoint : public CObject{
private:
   int      m_number;
   double   m_price;
   datetime m_date;
   int      m_type;
   
public:
                     CTPoint(int,double, datetime,int);
                    ~CTPoint(){}
                 int GetNumber()                  {return(m_number);}
              double GetPrice()                   {return(m_price);}
            datetime GetDate()                    {return(m_date);}
                 int GetType()                    {return(m_type);}
};

//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
/// @number - номер точки
/// @price - цена устоновки точки
/// @date - дата установки точки
/// @type - тип точки
CTPoint::CTPoint(int number,double price, datetime date, int type) {
   m_number = number;
   m_price  = price;
   m_date   = date;
   m_type   = type;
}
