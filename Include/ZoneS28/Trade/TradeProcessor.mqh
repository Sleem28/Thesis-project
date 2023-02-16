//+------------------------------------------------------------------+
//|                                               TradeProcessor.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include <ZoneS28\Enums.mqh>
#include "PendingOrdersClasses\PendingOrdersProcessor.mqh"
#include <Trade\SymbolInfo.mqh>


class CTradeProcessor {
private:
   ulong                   m_magic_number;
   string                  m_symbol;
   CArrayObj               m_points;
   CSymbolInfo             m_symbol_info;
   CPendingOrdersProcessor m_order_processor;
   EntryPointType          m_type;
   uint                    m_martin_mult;
   double                  m_profit;
   int                     m_trend;
   double                  m_last_loss;
public:
                     CTradeProcessor(){};
                    ~CTradeProcessor(){};
                void Init(ulong, string, CArrayObj&,EntryPointType,uint,double,int&,double&);    
                void Trade(EntryPointType type); // проверяем на наличие торгового паттерна и ставим ордера
};
//+------------------------------------------------------------------+
//| Init class' fields                                               |
//+------------------------------------------------------------------+
void CTradeProcessor::Init(ulong magic_num,string symbol,CArrayObj & points,EntryPointType type,uint martin_mult,double profit,int &trend,double &last_loss)
{
   m_magic_number = magic_num;
   m_symbol       = symbol;
   m_points       = points;
   m_type         = type;
   m_martin_mult  = martin_mult;
   m_profit       = profit;
   m_trend        = trend;
   m_last_loss    = last_loss;
   
   m_symbol_info.Name(symbol);
   
   m_order_processor.Init(m_symbol,m_magic_number,m_profit,last_loss,m_martin_mult,m_symbol_info);
}
//+------------------------------------------------------------------+
//|Метод проверяет торговую ситуацию                                 |
//+------------------------------------------------------------------+
//TODO Делаем метод торговли. Пишем класс для торговых ситуаций.
