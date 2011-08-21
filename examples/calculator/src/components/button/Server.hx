package components.button;

class Server extends haquery.components.button.Server
{
	override function preRender()
	{
		if (text!=null) q('#t').html(text);
		if (clas!=null) q('#b').addClass(clas);
		if (style!=null) q('#t').attr('style',style);
		if (hidden) q('#b').css('visibility','hidden');
	}
}
