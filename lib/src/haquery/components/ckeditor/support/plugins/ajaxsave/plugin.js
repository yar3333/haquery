/*
Copyright (c) 2010, Sivakov Yaroslav. All rights reserved.
*/

/**
 * @ajaxsave plugin.
 */

(function()
{
	var pluginName = 'ajaxsave';

    var saveCmdParams =
	{
		modes : { wysiwyg:1, source:1 },
		exec : function (editor)
		{
            if (typeof editor.config.saveFunction == 'function')
                editor.config.saveFunction(editor.getData());
		}
	};

	var closeCmdParams =
	{
		modes : { wysiwyg:1, source:1 },
		exec : function (editor)
		{
            if (typeof editor.config.closeFunction == 'function')
                editor.config.closeFunction();
		}
	};

	CKEDITOR.plugins.add(pluginName, {
		init : function (editor)
		{
			var saveCmd = editor.addCommand('AjaxSave', saveCmdParams);
			saveCmd.modes = { wysiwyg: typeof editor.config.saveFunction=='function' };
			editor.ui.addButton('AjaxSave', {
                label : editor.lang.save,
                command : 'AjaxSave',
                icon: this.path+"save.png"
            });

			var closeCmd = editor.addCommand('Close', closeCmdParams);
			closeCmd.modes = { wysiwyg: typeof editor.config.closeFunction=='function' };
            editor.ui.addButton( 'Close', {
                label : "Закрыть",
                command : 'Close',
                icon: this.path+"close.png"
            });
		}
	});
})();
