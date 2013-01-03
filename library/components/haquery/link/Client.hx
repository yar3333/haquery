package components.haquery.link;

class Client extends Base
{
    var href : String;
	
	function init()
	{
		href = template().href.val(); template().href.remove();
	}
	
	function link_click(t, e)
    {
        page.redirect(href);
        return false;
    }
}
