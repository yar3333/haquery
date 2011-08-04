<?php

class OrmGenerator {
	public function __construct(){}
	static function getClassName($table) {
		$GLOBALS['%s']->push("OrmGenerator::getClassName");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = Lambda::map(_hx_explode("_", strtolower($table)), array(new _hx_lambda(array(&$table), "OrmGenerator_0"), 'execute'))->join("");
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function make($basePath) {
		$GLOBALS['%s']->push("OrmGenerator::make");
		$�spos = $GLOBALS['%s']->length;
		if(!haquery_server_db_HaqDb::connect(null, null, null, null, null)) {
			php_Lib::println("Подключение к БД не установлено.");
			{
				$GLOBALS['%s']->pop();
				return;
			}
		}
		$basePath = rtrim(str_replace("\\", "/", $basePath), "/") . "/";
		$modelFolder = $basePath . "models/";
		if(!is_dir($modelFolder)) {
			@mkdir($modelFolder, 493);
		}
		if(!is_dir($modelFolder . "autogenerated")) {
			@mkdir($modelFolder . "autogenerated", 493);
		}
		$tables = haquery_server_db_HaqDb::$connection->getTables();
		{
			$_g = 0;
			while($_g < $tables->length) {
				$table = $tables[$_g];
				++$_g;
				$className = OrmGenerator::getClassName($table);
				OrmModelGenerator::make($table, $basePath, "models." . $className, "models.autogenerated." . $className);
				OrmManagerGenerator::make($table, $basePath, "models." . $className, "models." . $className . "Manager", "models.autogenerated." . $className . "Manager");
				unset($table,$className);
			}
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'OrmGenerator'; }
}
function OrmGenerator_0(&$table, $w) {
	{
		$GLOBALS['%s']->push("OrmGenerator::getClassName@14");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$�tmp = OrmTools::capitalize($w);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
