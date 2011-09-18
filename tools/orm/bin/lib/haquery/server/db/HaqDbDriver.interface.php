<?php

interface haquery_server_db_HaqDbDriver {
	//;
	function query($sql);
	function quote($s);
	function lastInsertId();
	function affectedRows();
	function getTables();
	function getFields($table);
	function getForeignKeys($table);
	function getUniqueFields($table);
}
