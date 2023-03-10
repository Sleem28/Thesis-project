//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
// Enum для типов точек входа
enum EntryPointType
{
   TypeAfterBreakdownSlOnCorrection,
   TypeAfterBreakdownSlOnImpulse,
   TypeTrendTrade,
   TypeTwoOrdersOnSwing,
   TypeEntryFromBreakoutLevel,
   TypeEntryFromZone,
   TypeCombineEntryTypes
};
// Enum для расчета свингового тренда 
enum LocalTrend
{
   TrendUp,
   TrendDown,
   NoTrend
};
// Enum для свингового тренда с индикатора
enum STrend
{
   Trend_Up,
   Trend_Down,
   No_Trend
};

// Enum Типы режима торговли в мартине
enum MartinWorkType
{
   MartinModeTrend,
   MartinModeContrTrend
};

