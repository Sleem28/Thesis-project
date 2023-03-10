//+------------------------------------------------------------------+
//|                                                    DrawTrend.mqh |
//|                                                   Kirill Pashkin |
//|                                            sleembelbox@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kirill Pashkin"
#property link      "sleembelbox@gmail.com"
#property version   "1.00"
class CDrawTrend
  {
private:
   
public:
                     CDrawTrend(){};
                    ~CDrawTrend(){};
                void Show(bool);
                void DeleteSign();
  };
//+------------------------------------------------------------------+
//|Рисует стрелку глобального тренда на нулевой свече                |
//+------------------------------------------------------------------+
void CDrawTrend::Show(bool isTrendUp)
{
   long              chart_id   = 0;
   string            name       = "Trend";
   ENUM_OBJECT       object     = (isTrendUp)? OBJ_ARROW_UP : OBJ_ARROW_DOWN;
   int               sub_window = 0;
   datetime          time       = TimeCurrent();
   double            price      = (isTrendUp)? iHigh(_Symbol,PERIOD_CURRENT,0) + 10 * Point() : iLow(_Symbol,PERIOD_CURRENT,0) - 10 * Point();
   ENUM_ARROW_ANCHOR anchor     = (isTrendUp)? ANCHOR_BOTTOM : ANCHOR_TOP;
   color             clr        = (isTrendUp)? clrGreen : clrRed;
   ENUM_LINE_STYLE   style      = STYLE_SOLID;
   int               size       = 3;
   bool              back_plan  = false;
   bool              hidden     = false;
   
   ResetLastError();
   
   ObjectDelete(chart_id,name);
   
   if(!ObjectCreate(chart_id,name,object,sub_window,time,price))
   {
      Print("Не удалось создать знак тренда.");
      return;
   }
   
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,back_plan);
   ObjectSetInteger(chart_id,name,OBJPROP_HIDDEN,hidden);
}
//+------------------------------------------------------------------+
//|   Удаляет знак тренда                                            |
//+------------------------------------------------------------------+
void CDrawTrend::DeleteSign(void)
{
   ObjectDelete(0,"Trend");
}