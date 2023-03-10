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
#include "EntryPointsClasses\EntryPointFinder.mqh"
#include <ZoneS28\IndSwingTrends\TPoint.mqh>


class CTradeProcessor {
private:
   ulong                   m_magic_number;
   string                  m_symbol;
   ENUM_TIMEFRAMES         m_timeframe;
   CSymbolInfo             m_symbol_info;
   CPendingOrdersProcessor m_order_processor;
   uint                    m_martin_mult;
   double                  m_loss;
   double                  m_last_loss;
   double                  m_tp_coeff;
   CEntryPointFinder       m_entrypoint_finder;
public:
                     CTradeProcessor() {};
                    ~CTradeProcessor() {};
              void   Init(ulong, string,ENUM_TIMEFRAMES, uint,double&,double, CEntryPointFinder&);
              void   Trade(EntryPointType type, STrend trend,CArrayObj&,CArrayObj&); // проверяем на наличие торгового паттерна и ставим ордера
              void   DeleteAllPendingPositions();
              bool   CheckOpenPosition();
              void   SetLoss(double loss);
              void   OpenPosition(ENUM_POSITION_TYPE pos_type,double open_price,double stop_loss,double loss);
};
//+------------------------------------------------------------------+
//| Init class fields                                                |
//+------------------------------------------------------------------+
void CTradeProcessor::Init(ulong  magic_num,
                           string symbol,
                           ENUM_TIMEFRAMES timeframe,
                           uint martin_mult,
                           double &last_loss,
                           double tp_coeff,
                           CEntryPointFinder& entrypoint_finder) {
   m_magic_number = magic_num;
   m_symbol       = symbol;
   m_timeframe    = timeframe;
   m_martin_mult  = martin_mult;
   m_last_loss    = last_loss;
   m_tp_coeff     = tp_coeff;
   m_entrypoint_finder = entrypoint_finder;

   m_symbol_info.Name(symbol);

   m_order_processor.Init(m_symbol,m_magic_number,last_loss,m_martin_mult,m_symbol_info);
}
//+------------------------------------------------------------------+
//|Метод проверяет торговую ситуацию                                 |
//+------------------------------------------------------------------+
void CTradeProcessor::Trade(EntryPointType type, STrend trend, CArrayObj& points, CArrayObj& zones) {
   double          open_price;
   double          stop_loss;
   ENUM_ORDER_TYPE order_type;
   CTPoint        *open_point;
   CTPoint        *SL_point;

   int             length = points.Total();

   switch(type) {
      case TypeEntryFromZone: // Вход от зоны. 
      { 
         if(m_entrypoint_finder.FindEntryPoint(type,trend,points,zones,m_timeframe,m_symbol)) 
         {
            open_point = points.At(length-3);
            SL_point   = points.At(length-2);
            open_price = open_point.GetPrice();
            stop_loss  = SL_point.GetPrice();

            order_type = (trend == Trend_Up)? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
            
            m_order_processor.DeleteAllPendingOrders();
            m_order_processor.SetPendingOrder(order_type,open_price,stop_loss,m_loss,m_tp_coeff); // Поставим ордер
         }
      break;
      }
      case TypeEntryFromBreakoutLevel: // Вход от пробитого уровня. Заход лимиткой.
      { 
         if(m_entrypoint_finder.FindEntryPoint(type,trend,points,zones,m_timeframe,m_symbol)) 
         {  
            Print("Входим от пробитого уровня лимиткой");
            open_point = points.At(length-3);
            SL_point   = points.At(length-2);
            open_price = open_point.GetPrice();
            stop_loss  = SL_point.GetPrice();

            order_type = (trend == Trend_Up)? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
            
            m_order_processor.DeleteAllPendingOrders();
            m_order_processor.SetPendingOrder(order_type,open_price,stop_loss,m_loss,m_tp_coeff); // Поставим ордер
         }
      break;
      }
      case TypeTrendTrade: // Вход по тренду 
      { 
         if(m_entrypoint_finder.FindEntryPoint(type,trend,points,zones,m_timeframe,m_symbol)) 
         {
            Print("Входим по тренду стоп ордером.");
            open_point = points.At(length-1);
            SL_point   = points.At(length-2);
            open_price = open_point.GetPrice();
            stop_loss  = SL_point.GetPrice();
            
            order_type = (trend == Trend_Up)? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
            
            m_order_processor.DeleteAllPendingOrders();
            m_order_processor.SetPendingOrder(order_type,open_price,stop_loss,m_loss,m_tp_coeff); // Поставим ордер
         }
      break;
      }
      case TypeAfterBreakdownSlOnCorrection: // Вход стоп ордером после импульсного пробоя уровня со стопом на коррекции
      {
         if(m_entrypoint_finder.FindEntryPoint(type,trend,points,zones,m_timeframe,m_symbol))
         {
            Print("Входим стоп ордером после импульсного пробоя уровня со стопом на коррекции");
            open_point = points.At(length-2);
            SL_point   = points.At(length-1);
            open_price = open_point.GetPrice();
            stop_loss  = SL_point.GetPrice();
            
            order_type = (trend == Trend_Up)? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
            
            m_order_processor.DeleteAllPendingOrders();
            m_order_processor.SetPendingOrder(order_type,open_price,stop_loss,m_loss,m_tp_coeff); // Поставим ордер
         }
       break;
      }
      case TypeAfterBreakdownSlOnImpulse: // Вход стоп ордером после импульсного пробоя уровня со стопом на импульсе
      {
         if(m_entrypoint_finder.FindEntryPoint(type,trend,points,zones,m_timeframe,m_symbol))
         {
            Print("Входим стоп ордером после импульсного пробоя уровня со стопом на импульсе");
            open_point = points.At(length-2);
            SL_point   = points.At(length-3);
            open_price = open_point.GetPrice();
            stop_loss  = SL_point.GetPrice();
            
            order_type = (trend == Trend_Up)? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
            
            m_order_processor.DeleteAllPendingOrders();
            m_order_processor.SetPendingOrder(order_type,open_price,stop_loss,m_loss,m_tp_coeff); // Поставим ордер
         }
       break;
      }
      case TypeTwoOrdersOnSwing: // Вход на флэте 2мя стоп ордерами на свинге.
      {
         if(m_entrypoint_finder.FindEntryPoint(type,trend,points,zones,m_timeframe,m_symbol))
         {
            Print("Входим на флэте 2мя стоп ордерами на свинге.");
            CTPoint *open_point1 = points.At(length-1);
            CTPoint *SL_point1   = points.At(length-2);
            double   open_price1 = open_point1.GetPrice();
            double   stop_loss1  = SL_point1.GetPrice();
            
            CTPoint *open_point2 = points.At(length-2);
            CTPoint *SL_point2   = points.At(length-1);
            double   open_price2 = open_point2.GetPrice();
            double   stop_loss2  = SL_point2.GetPrice();
            
            
            
            m_order_processor.DeleteAllPendingOrders();
            
            if(open_price1 > open_price2) // Если первая точка выше 2 точки
            {
               if(open_price1 < SymbolInfoDouble(_Symbol,SYMBOL_ASK) || open_price2 > SymbolInfoDouble(_Symbol,SYMBOL_BID)) // Цены внутри спрэда
               {
                  Print("Во время установки ордеров на свинг цены внутри спрэда.");
                  return;
               }
               m_order_processor.SetPendingOrder(ORDER_TYPE_BUY_STOP,open_price1,stop_loss1,m_loss,m_tp_coeff);
               m_order_processor.SetPendingOrder(ORDER_TYPE_SELL_STOP,open_price2,stop_loss2,m_loss,m_tp_coeff);
            }
            else
            {
               if(open_price1 > SymbolInfoDouble(_Symbol,SYMBOL_BID) || open_price2 < SymbolInfoDouble(_Symbol,SYMBOL_ASK)) // Цены внутри спрэда
               {
                  Print("Во время установки ордеров на свинг цены внутри спрэда.");
                  return;
               }
               m_order_processor.SetPendingOrder(ORDER_TYPE_SELL_STOP,open_price1,stop_loss1,m_loss,m_tp_coeff);
               m_order_processor.SetPendingOrder(ORDER_TYPE_BUY_STOP,open_price2,stop_loss2,m_loss,m_tp_coeff);
            }
         }
       break;
      }
   }
}
//+------------------------------------------------------------------+
//| удаляет все отложненные ордера                                   |
//+------------------------------------------------------------------+
void CTradeProcessor::DeleteAllPendingPositions(void)
{
   m_order_processor.DeleteAllPendingOrders();
}
//+------------------------------------------------------------------+
//| Проверяет наличие открытой позиции                               |
//+------------------------------------------------------------------+
bool CTradeProcessor::CheckOpenPosition(void)
{
   uint positions = PositionsTotal();
   ulong ticket = 0;
   
   for(uint i=0;i<positions;i++)
     {
         ticket = PositionGetTicket(i);
         PositionSelectByTicket(ticket);
         
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetInteger(POSITION_MAGIC) == m_magic_number)
            return(false);
     }
   return(true);
}
//+------------------------------------------------------------------+
//|Устанавливает размер прибыли                                      |
//+------------------------------------------------------------------+
void CTradeProcessor::SetLoss(double loss)
{
   m_loss = loss;
}
//+------------------------------------------------------------------+
//|Открывает позицию                                                 |
//+------------------------------------------------------------------+
void CTradeProcessor::OpenPosition(ENUM_POSITION_TYPE pos_type,double open_price,double stop_loss,double lot)
{  
   CTrade* trade = m_order_processor.GetTradeClass();
   CAccountInfo    acc_info;
   
   ENUM_ORDER_TYPE order_type    = (pos_type == POSITION_TYPE_BUY)? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double          take_profit   = (pos_type == POSITION_TYPE_BUY )? open_price + MathAbs(open_price-stop_loss): open_price - MathAbs(open_price-stop_loss);
   double          max_lot_check = acc_info.MaxLotCheck(m_symbol_info.Name(),order_type,open_price,90);
   double          work_lot      = (lot <= max_lot_check)? lot : max_lot_check;
    
   if(pos_type == POSITION_TYPE_BUY)
   {
    trade.Buy(work_lot,_Symbol,0.0,stop_loss,take_profit);
   }
   else if(pos_type == POSITION_TYPE_SELL)
   {
    trade.Sell(work_lot,_Symbol,0.0,stop_loss,take_profit);
   }
}