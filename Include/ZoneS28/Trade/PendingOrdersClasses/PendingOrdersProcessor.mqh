//+------------------------------------------------------------------+
//|                                       PendingOrdersProcessor.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

#include "LotCalculator.mqh"



class CPendingOrdersProcessor {
private:
     CTrade         m_trade;
     CSymbolInfo    m_symbol_info;
     CLotCalculator m_lot_calculator;
     string         m_symbol;
     ulong          m_magic_num;
     double         m_profit; 
     double         m_last_loss; 
     uint           m_multiplier;
public:
                     CPendingOrdersProcessor(){};
                    ~CPendingOrdersProcessor(){};
                void Init(string symbol, ulong magic_num, double &last_loss, uint &multiplier, CSymbolInfo &symbol_info);
                bool SetPendingOrder(ENUM_ORDER_TYPE order_type,double open_price, double sl,double loss, double TPCoeff);
                void DeleteAllPendingOrders();
              CTrade* GetTradeClass(){return(&m_trade);};
      CLotCalculator* GetLotCalculator(){return(&m_lot_calculator);};
                    
};
//+------------------------------------------------------------------+
//| Init class' fields                                               |
//+------------------------------------------------------------------+
void CPendingOrdersProcessor::Init(string symbol,ulong magic_num,double &last_loss,uint &multiplier, CSymbolInfo &symbol_info)
{
   m_symbol     = symbol;
   m_magic_num  = magic_num;
   m_last_loss  = last_loss;
   m_multiplier = multiplier;
   // Инициализировал торговый класс
   m_trade.SetExpertMagicNumber(m_magic_num);
   m_trade.SetDeviationInPoints(2);
   m_trade.SetMarginMode();
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   m_symbol_info = symbol_info;
   m_lot_calculator.Init(symbol_info);
}
//+------------------------------------------------------------------+
//| Устанавливает отложенный ордер любого типа                       |
//+------------------------------------------------------------------+
bool CPendingOrdersProcessor::SetPendingOrder(ENUM_ORDER_TYPE order_type,double open_price,double sl, double loss, double tp_coeff)
{
   
   double volume = m_lot_calculator.CalcLot(open_price,sl,loss,m_last_loss,m_multiplier,order_type);
   double tp     = (order_type == ORDER_TYPE_BUY_STOP || order_type == ORDER_TYPE_BUY_LIMIT)? open_price + (MathAbs(open_price-sl)*tp_coeff): open_price - (MathAbs(open_price-sl)*tp_coeff);
   
   m_trade.OrderOpen(m_symbol,order_type,volume,0,open_price,sl,tp,ORDER_TIME_GTC,0);
   if(m_trade.ResultOrder() > 0)
      return true;
   else
      return false;
}
//+------------------------------------------------------------------+
//| Удаляем все отложки                                              |
//+------------------------------------------------------------------+
void CPendingOrdersProcessor::DeleteAllPendingOrders(void)
{
   int orders = OrdersTotal();
   ulong ticket;
   
   for(int i=0;i<orders;i++)
     {
       ticket = OrderGetTicket(i);
       if(ticket > 0)
       {
          if(m_magic_num == OrderGetInteger(ORDER_MAGIC) && m_symbol == OrderGetString(ORDER_SYMBOL))
             m_trade.OrderDelete(ticket);
       }   
     }
}