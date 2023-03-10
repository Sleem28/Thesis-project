//+------------------------------------------------------------------+
//|                                                LotCalculator.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Math\Stat\Normal.mqh>


class CLotCalculator {
private:
   CSymbolInfo m_symbol_info;
public:
                     CLotCalculator(){};
                    ~CLotCalculator(){};
                    void   Init(CSymbolInfo &symbol_info){m_symbol_info = symbol_info;};
                    double CalcLot(double price_open,double sl,double profit,double &last_loss, uint multiplier, ENUM_ORDER_TYPE type);
};
//+------------------------------------------------------------------+
//|  Расчет лота                                                     |
//+------------------------------------------------------------------+
double CLotCalculator::CalcLot(double price_open,double sl,double profit,double &last_loss, uint multiplier, ENUM_ORDER_TYPE type)
{
   CAccountInfo    acc_info;
   double          target_profit = (last_loss == 0)? profit : last_loss * multiplier;
   double          lot           = (target_profit/MathAbs((price_open - sl)/_Point));
   ENUM_ORDER_TYPE order_type    = (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP)? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double          max_lot_check = acc_info.MaxLotCheck(m_symbol_info.Name(),order_type,price_open,90); 
   double          step_lot      = m_symbol_info.LotsStep();
   double          min_lot       = m_symbol_info.LotsMin();
                   max_lot_check = MathRound(max_lot_check,2);
   
   if(lot < min_lot)
      return(min_lot);
   else if(lot > max_lot_check)
      return(max_lot_check);
   else
   {
      lot = MathRound(lot,2);
      return(lot);
   }
}
//+------------------------------------------------------------------+
