package components.button;

class Client extends haquery.components.button.Client
{
	/**
	 * Optimization: disabling server method call.
     * If no optimization need - this file is not need too.
	 */
    override function b_click()
    {
		super.b_click();
        return false;
    }
}
