#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

CPositionInfo a_position;
CTrade        a_trade;
CSymbolInfo   a_symbol;
//+------------------------------------------------------------------+
//|                                                      Martini.mq5 |
//|                                    Copyright 2019, TradeLikeAPro |
//|                                         https://tradelikeapro.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, TradeLikeAPro"
#property link      "https://tradelikeapro.ru"
#property version   "1.00"

input string          MM         = "= Money management = ";
input double          Lots       = 0.01;
input double          Multiplier = 2;
input ushort          Step       = 70;
input double          Profit     = 10;
//--------------------------------------------------------------------
input string          ST         = "= Stochastic =";
input int             Kperiod    = 26;
input int             Dperiod    = 20;
input int             Slowing    = 16;
input ENUM_MA_METHOD  MaMethod   = MODE_SMA;
input ENUM_STO_PRICE  PriceField = STO_LOWHIGH;
input double          BuyLevel   = 12;
input double          SellLevel  = 88;
//--------------------------------------------------------------------
input ulong           MagicNumber = 123;
input ulong           Slippage    = 10;

double eStep = 0;
int    hStoch;
double points;

double last_price    = 0;
int    last_pos_type = -1;
double last_lots     = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if (!a_symbol.Name(Symbol()))
      return(INIT_FAILED);
      
   RefreshRates();
   
   a_trade.SetExpertMagicNumber(MagicNumber);
   a_trade.SetMarginMode();
   a_trade.SetTypeFillingBySymbol(a_symbol.Name());
   a_trade.SetDeviationInPoints(Slippage);
   
   int digits = 1;
   
   if (a_symbol.Digits() == 3 || a_symbol.Digits() == 5)
      digits = 10;
      
   points = a_symbol.Point() * digits;
   eStep  = Step * points;
   
   hStoch = iStochastic(a_symbol.Name(), Period(), Kperiod, Dperiod, Slowing, MaMethod, PriceField);
   
   if (hStoch == INVALID_HANDLE)
   {
      Print("Не удалось создать описатель индикатора Стохастик!");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if (!RefreshRates())
      return;
      
   if (CalcProfit(POSITION_TYPE_BUY) >= Profit)
       CloseAll(POSITION_TYPE_BUY);
          
   if (CalcProfit(POSITION_TYPE_SELL) >= Profit)
       CloseAll(POSITION_TYPE_SELL);
          
   int count = PosCount();
   
   if (count < 1)
   {
       double mLine = GetStochastic(MAIN_LINE, 1);
       double sLine = GetStochastic(SIGNAL_LINE, 1);
       
       if (mLine > sLine && sLine > BuyLevel)
       {
           OpenBuy(Lots);
           return;
       }
       
       if (mLine < sLine && sLine < SellLevel)
       {
           OpenSell(Lots);
           return;
       }
   }
   
   if (last_price != 0 && last_pos_type >= 0 && last_lots != 0)
   {
       if (last_pos_type == POSITION_TYPE_BUY)
       {
           if (a_symbol.Ask() <= last_price - eStep)
           {
               double next_lots = CalcLots(last_lots * Multiplier);
               
               if (next_lots != 0)
               {
                  OpenBuy(next_lots);
                  return;
               }
           }
       }
   }
   
   if (last_price != 0 && last_pos_type >= 0 && last_lots != 0)
   {
       if (last_pos_type == POSITION_TYPE_SELL)
       {
           if (a_symbol.Ask() >= last_price + eStep)
           {
               double next_lots = CalcLots(last_lots * Multiplier);
               
               if (next_lots != 0)
               {
                  OpenSell(next_lots);
                  return;
               }
           }
       }
   }
   
}
//+------------------------------------------------------------------+
bool OpenBuy(double alot)
{
    if (alot == 0)
    {
        Print("Ошибка объёма для открытия позиции на покупку!");
        return(false);
    }
    
    if (a_trade.Buy(alot, a_symbol.Name(), a_symbol.Ask(), 0, 0))
    {
        if (a_trade.ResultDeal() == 0)
        {
            Print("Ошибка открытия позиции на покупку!");
            return(false);
        }
    }
    
    return(true);
}
//+------------------------------------------------------------------+
bool OpenSell(double alot)
{
    if (alot == 0)
    {
        Print("Ошибка объёма для открытия позиции на продажу!");
        return(false);
    }
    
    if (a_trade.Sell(alot, a_symbol.Name(), a_symbol.Bid(), 0, 0))
    {
        if (a_trade.ResultDeal() == 0)
        {
            Print("Ошибка открытия позиции на продажу!");
            return(false);
        }
    }
    
    return(true);
}
//+------------------------------------------------------------------+
void CloseAll(ENUM_POSITION_TYPE pos_type)
{
    for(int i=PositionsTotal() - 1; i>=0; i--)
    {
       if (a_position.SelectByIndex(i))
       {
           if (a_position.PositionType() == pos_type && a_position.Magic() == MagicNumber && a_position.Symbol() == a_symbol.Name())
              a_trade.PositionClose(a_position.Ticket());
       }
    }
}
//+------------------------------------------------------------------+
double CalcProfit(ENUM_POSITION_TYPE pos_type)
{
    double profit = 0;
    
    for(int i=PositionsTotal() - 1; i>=0; i--)
    {
       if (a_position.SelectByIndex(i))
       {
           if (a_position.PositionType() == pos_type && a_position.Magic() == MagicNumber && a_position.Symbol() == a_symbol.Name())
              profit += a_position.Profit();
       }
    }
    
    return(profit);
}
//+------------------------------------------------------------------+
double CalcLots(double lots)
{
    double new_lots  = NormalizeDouble(lots, 2);
    double step_lots = a_symbol.LotsStep();
    
    if (step_lots > 0)
       new_lots = step_lots * MathFloor(new_lots / step_lots);
       
    double minlot = a_symbol.LotsMin();
    
    if (new_lots < minlot)
        new_lots = minlot;
        
    double maxlot = a_symbol.LotsMax();
    
    if (new_lots > maxlot)
       new_lots = maxlot;
       
    return(new_lots);
}
//+------------------------------------------------------------------+
double GetStochastic(const int buffer, const int index)
{
    double Stochastic[1];
    ResetLastError();
    
    if (CopyBuffer(hStoch, buffer, index, 1, Stochastic) < 0)
    {
        Print("Ошибка получения данных с индикатора Стохастик!");
        return(0);
    } 
    
    return(Stochastic[0]);
}
//+------------------------------------------------------------------+
int PosCount()
{
   int count = 0;
   for (int i = PositionsTotal()-1; i>=0; i--)
   {
       if (a_position.SelectByIndex(i))
       {
           if (a_position.Symbol() == a_symbol.Name() && a_position.Magic() == MagicNumber)
              count++;
       }
   }
   
   return(count);
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
    if (trans.type == TRADE_TRANSACTION_DEAL_ADD)
    {
        long deal_type = -1;
        long deal_entry = -1;
        long deal_magic = 0;
        
        double deal_volume = 0;
        double deal_price  = 0;
        string deal_symbol = "";
        
        if (HistoryDealSelect(trans.deal))
        {
            deal_type    = HistoryDealGetInteger(trans.deal, DEAL_TYPE);
            deal_entry   = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
            deal_magic   = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            
            deal_volume  = HistoryDealGetDouble(trans.deal, DEAL_VOLUME);
            deal_price   = HistoryDealGetDouble(trans.deal, DEAL_PRICE);
            deal_symbol  = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
        }
        else return;
    
       if (deal_symbol == a_symbol.Name() && deal_magic == MagicNumber)
       {
          if (deal_entry == DEAL_ENTRY_IN && (deal_type == DEAL_TYPE_BUY || deal_type == DEAL_TYPE_SELL))
          {
              last_price    = deal_price;
              last_pos_type = (deal_type == DEAL_TYPE_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
              last_lots     = deal_volume;
          }
          else if (deal_entry == DEAL_ENTRY_OUT)
          {
             last_lots     = 0;
             last_pos_type = -1;
             last_price    = 0;
          }
       }
    }
}
//+------------------------------------------------------------------+
bool RefreshRates()
{
   if (!a_symbol.RefreshRates())
   {
      Print("не удалось обновить котировки валютной пары!");
      return(false);
   } 
   
   if (a_symbol.Ask() == 0 || a_symbol.Bid() == 0)
      return(false);
      
   return(true);   
}
//+------------------------------------------------------------------+



