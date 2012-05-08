package components.calculator.calc;

import js.JQuery;
import haquery.client.Lib;
import haquery.client.HaqComponent;

using StringTools;
using js.jQueryPlugins.NumberFormat;

typedef StackItem = {
	var num : Float;
	var text : String;
}

typedef OperAndNS = {
	var oper : String;
	var ns : StackItem;
}

class Client extends HaqComponent
{
    var numberFieldSize : Int;
    var stack : Array<StackItem>;
    var lastOperAndNS : OperAndNS;
    var memory : Float;
    var fixed : Float; // fixed number (displayed until user start typo new number)
    var text : String;   // typo number
    var isError : Bool;
    
	function init()
    {
        numberFieldSize = 16;
		stack = [];
		lastOperAndNS = null;
		memory = 0;
		fixed = 0;
		text = "";
		isError = false;
		
		q("#calculator .~buttons").bind("selectstart mousedown", untyped function(e) return false); // ie + ff

        if (JQuery.browser.opera) bindKeysForOpera();
        else                      bindKeysForIEAndFF();

        update();
    }

    function bindKeysForIEAndFF()
    {
        q(Lib.document).keydown(function (e)
        {
            switch (e.keyCode)
            {
                case 48, 96:  bt_0_click();
                case 49, 97:  bt_1_click();
                case 50, 98:  bt_2_click();
                case 51, 99:  bt_3_click();
                case 52, 100: bt_4_click();
                case 53, 101: bt_5_click();
                case 54, 102: bt_6_click();
                case 55, 103: bt_7_click();
                case 56, 104: bt_8_click();
                case 57, 105: bt_9_click();

                case 107: bt_ADD_click();
                case 109: bt_SUB_click();
                case 106: bt_MUL_click();
                case 111, 191: bt_DIV_click();

                case 46, 110, 188, 190: bt_POINT_click();

                case 8: bt_BS_click();

                case 13: bt_EQU_click();

                default: return true;
            }
            return false;
        });
    }

    function bindKeysForOpera()
    {
		q(Lib.document).keypress(function (e)
        {
            switch (e.keyCode)
            {
                case 48: bt_0_click();
                case 49: bt_1_click();
                case 50: bt_2_click();
                case 51: bt_3_click();
                case 52: bt_4_click();
                case 53: bt_5_click();
                case 54: bt_6_click();
                case 55: bt_7_click();
                case 56: bt_8_click();
                case 57: bt_9_click();

                case 43: case 61: bt_ADD_click();
                case 45: bt_SUB_click();
                case 42: bt_MUL_click();
                case 47: bt_DIV_click();

                case 44: case 46: bt_POINT_click();

                case 8: bt_BS_click();

                case 13: bt_EQU_click();

                default:
                    return true;
            }
            return false;
        });

    }

    function bt_0_click() { addNum("0"); }
    function bt_1_click() { addNum("1"); }
    function bt_2_click() { addNum("2"); }
    function bt_3_click() { addNum("3"); }
    function bt_4_click() { addNum("4"); }
    function bt_5_click() { addNum("5"); }
    function bt_6_click() { addNum("6"); }
    function bt_7_click() { addNum("7"); }
    function bt_8_click() { addNum("8"); }
    function bt_9_click() { addNum("9"); }

    function bt_ADD_click() { doOper("+"); }
    function bt_SUB_click() { doOper("-"); }
    function bt_MUL_click() { doOper("*"); }
    function bt_DIV_click() { doOper("/"); }

    function bt_SQRT_click()    { doFunc("sqrt"); }
    function bt_OBR_click()     { doFunc("obr"); }
    function bt_PERCENT_click() { doFunc("%"); }

    function getOperPriority(oper)
    {
        if (oper == "*" || oper == "/") return 2;
        return 1;
    }

    var historyTextArea : JQuery;
	
    public function setHistoryTextArea(ta:JQuery)
    {
		historyTextArea = ta;
    }
    
	function saveToHistoryTextArea()
    {
        var history = stack[0].text;
        var i = 1;
		while (i < stack.length)
        {
            var needPar = i > 1 && getOperPriority(stack[i - 2].text) < getOperPriority(stack[i].text);
            if (needPar)
			{
				history = "(" + history + ")";
			}
            history += " " + stack[i].text;
            if (i + 1 < stack.length)
			{
				history += " " + stack[i + 1].text;
			}
			i += 2;
        }

        var old = historyTextArea.html();
        if (old != "")
		{
			old += JQuery.browser.msie ? "<br>" : "\r\n";
		}
		historyTextArea.html(old + history + " = " + number2text(fixed));
        historyTextArea.scrollTop(historyTextArea[0].scrollHeight);
    }

    function getScienticNumberFormat(n:Float)
    {
        var por = 0;
        var an = Math.abs(n);
        while (an > 10) { an = an / 10; por++; }
        while (an < 1 && an != 0) { an = an * 10; por--; }
        return { b : (n>=0 ? an : -an), p : por };
    }

    function number2text(n:Float)
    {
        var r : String;
        var sciNum = this.getScienticNumberFormat(n);
        if (sciNum.p >= -9 && sciNum.p <= 99)
        {
			r = new JQuery().numberFormat(n, cast { numberOfDecimals:numberFieldSize - Std.string(Math.floor(Math.abs(sciNum.b))).length, thousandSeparator:'' } );

            if (r.indexOf(',')!=-1)
            {
                while (r.substr(r.length-1,1)=="0") r = r.substr(0, r.length-1);
                if (r.substr(r.length-1,1)==",") r = r.substr(0, r.length-1);
            }
        }
        else
        {
            r = new JQuery().numberFormat(sciNum.b, cast { numberOfDecimals:numberFieldSize - 2 - Std.string(Math.floor(Math.abs(sciNum.b))).length - Std.string(sciNum.p).length, thousandSeparator:"." }) + 'e' + sciNum.p;
        }
        return r;

    }

    function text2number(s:String) : Float
    {
        return Std.parseFloat(s.replace(",","."));
    }

    function getNumber() : Float
    {
        return text!=""
            ? text2number(this.text)
            : fixed;
    }
	
	function getNS() : StackItem
    {
        return this.text!=""
            ? { num: this.text2number(this.text), text: this.text }
            : { num: this.fixed,                  text: this.number2text(this.fixed) };
    }

    function getStackResult() : Float
    {
        if (this.stack.length==0) return 0;
        var r :Float = this.stack[0].num;
        var i = 1;
		while (i < this.stack.length)
        {
            if (i+1<this.stack.length)
            {
                var op = this.stack[i].text;
                var n = this.stack[i+1].num;
                if (op=="+") r += n;
                else
                if (op=="-") r -= n;
                else
                if (op=="*") r *= n;
                else
                if (op=="/") r /= n;
            }
			i += 2;
        }
        return r;
    }

    function throwError(text)
    {
        this.text = text;
        this.isError = true;
        this.update();
    }

    function showBlocked()
    {
        q('#number').fadeOut('fast').fadeIn('fast');
    }

    function addNum(n)
    {
        if (this.isError) {this.showBlocked();return;}

        if (this.text.length < this.numberFieldSize)
        {
            if (this.stack.length==1) this.stack = [];
            if (this.text=="0") this.text = "";
            this.text += n;
            this.update();
        }
    }

    function bt_CE_click()
    {
        this.text = "0";
        if (this.isError)
        {
            this.stack = [];
            this.fixed = 0;
            this.isError = false;
        }
        this.update();
    }

    function bt_C_click()
    {
        this.stack = [];
        this.lastOperAndNS = null;
        this.text = "0";
        this.fixed = 0;
        this.isError = false;
        this.update();
    }

    function bt_BS_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        if (this.text!="")
        {
            this.text = this.text.substr(0, this.text.length-1);
            if (this.text=="") this.text = "0";
            this.update();
        }
    }

    function bt_SIGN_click()
    {
        if (this.isError) {this.showBlocked();return;}

        if (this.text!="")
        {
            if (this.text!="0")
            {
                this.text = this.text.substr(0,1)=="-"
                    ? this.text.substr(1)
                    : this.text = "-" + this.text;
                this.q("#number").html(this.text);
            }
        }
        else
        {
            this.doFunc("negate");
        }
    }

    function bt_POINT_click()
    {
        if (this.isError) {this.showBlocked();return;}

        if (this.text.indexOf(",")==-1)
        {
            if (this.stack.length==1) this.stack = [];
            if (this.text=="") this.text = "0";
            this.text += ",";
            this.q("#number").html(this.text);
        }
    }


    function bt_MS_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        this.memory = this.fixed = this.getNumber();
        this.text = "";
        this.update();
    }

    function bt_MC_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        this.memory = 0;
        this.fixed = this.getNumber();
        this.text = "";
        this.update();
    }

    function bt_MP_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        this.fixed = this.getNumber();
        this.memory += this.fixed;
        this.text = "";
        this.update();
    }

    function bt_MM_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        this.fixed = this.getNumber();
        this.memory -= this.fixed;
        this.text = "";
        this.update();
    }

    function bt_MR_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        this.fixed = this.memory;
        this.text = "";
        this.update();
    }

    function update()
    {
        if (stack.length==0) q("#history").html("&nbsp;");
        else
        {
            var history = stack[0].text;
            var i = 1;
			while (i<stack.length)
            {
                history += " " + stack[i].text;
                if (i + 1 < stack.length) history += " " + this.stack[i + 1].text;
				i += 2;
            }
            q("#history").html(history);
        }

        q("#memory").css('visibility', memory != 0 ? "visible" : "hidden");

        var s = text!="" ? text : number2text(fixed);

        if (s.length<=12 && !isError) q("#number").removeClass("~number-small ~number-tiny");
        else
        {
            q("#number").addClass(s.length<=20 ? "~number-small" : "~number-tiny");
        }
        q("#number").html(s);
    }

    //--------------------------------------------------------------------------


    function doOper(oper:String)
    {
        if (this.isError) { this.showBlocked(); return; }

        if (this.stack.length>0 && this.stack.length%2==0 && this.text=="")
        {
            this.stack.pop();
        }
        else
        {
            if (this.stack.length%2==0) this.stack.push(this.getNS());
        }
        this.stack.push({num:0.0, text:oper});
        this.text = "";
        this.fixed = this.getStackResult();
        this.update();
    }

    function doFunc(func)
    {
        if (this.isError) { this.showBlocked(); return; }

        var ns : StackItem;
        if (this.stack.length%2==0) ns = this.getNS();
        else
        {
            if (this.text=="") ns = this.stack.pop();
            else
            {
                this.stack = [];
                ns = { num: this.text2number(this.text), text: this.text };
            }
        }

        var rn:Float = 0; 
		var rs:String = '';
        if (func=="sqrt")
        {
            rs = "sqrt("+ns.text+")";
            if (ns.num<0)
            {
                this.stack.push({num: 0.0, text: rs });
                this.throwError("Недопустимый ввод");
                return;
            }
            rn = Math.sqrt(ns.num);
        }
        else
        if (func=="obr")
        {
            rs = "reciproc("+ns.text+")";
            if (ns.num!=0) rn = 1.0 / ns.num;
            else
            {
                this.stack.push({num: 0.0, text: rs });
                this.throwError("Деление на ноль невозможно");
                return;
            }
        }
        else
        if (func=="negate")
        {
            rn = -ns.num;
            rs = "negate("+ns.text+")";
        }
        else
        if (func=="%")
        {
            rn = this.fixed * ns.num / 100;
            rs = this.number2text(rn);
        }

        this.stack.push({ num: rn, text: rs });
        this.fixed = rn;
        this.text = "";
        this.update();
    }

    function bt_EQU_click()
    {
        if (this.isError) { this.showBlocked(); return; }

        if (this.stack.length%2==0)
        {
            this.stack.push(this.getNS());
            if (this.stack.length==1)
            {
                if (this.lastOperAndNS==null)
                {
                    this.fixed = this.getNumber();
                    this.text = "";
                    this.stack = [];
                    this.update();
                    return;
                }
                this.stack.push({num: 0.0, text: this.lastOperAndNS.oper});
                this.stack.push(this.lastOperAndNS.ns);
            }

            if (this.stack.length>2 && this.stack[this.stack.length-2].text=="/" && this.stack[this.stack.length-1].num==0)
            {
                this.stack.pop();
                this.throwError("Деление на ноль невозможно");
                return;
            }
        }
        else
        {
            if (this.text!="")
            {
                this.stack = [ {num: this.text2number(this.text), text: this.text} ];
            }
        }

        this.lastOperAndNS = { oper: this.stack[this.stack.length-2].text, ns: this.stack[this.stack.length-1] };
        this.fixed = this.getStackResult();

        this.saveToHistoryTextArea();

        this.stack = [];
        this.text = "";
        this.update();
    }
}