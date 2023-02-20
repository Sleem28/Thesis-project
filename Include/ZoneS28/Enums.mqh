//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"

enum EntryPointType
{
   TypeAfterBreakdownSlOnCorrection,
   TypeAfterBreakdownSlOnImpulse,
   TypeTrendTrade,
   TypeTwoOrdersOnSwing,
   TypeEntryFromBreakoutLevel,
   TypeEntryFromZone,
   UseAllEntryTypes
};

enum LocalTrend
{
   TrendUp,
   TrendDown,
   NoTrend
};

enum STrend
{
   Trend_Up,
   Trend_Down,
   No_Trend
};