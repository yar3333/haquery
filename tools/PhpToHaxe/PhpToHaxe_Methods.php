<?php

class PhpToHaxe_Methods
{
    private $typeNamesMapping;
    
    function __construct($typeNamesMapping)
    {
        $this->typeNamesMapping = $typeNamesMapping;
    }
    
    function getHaxeCode($text)
    {
        $id = '[_a-zA-Z][_a-zA-Z0-9]*';

        $patterns = array(
             "/[.]/" => '+'
            ,"/::/" => '.'
            ,"/\\s+[(]/" => '('
            ,"/\\s+,/" => ','
            ,"/[(]\\s+/" => '('
            ,"/[(]\\s*void\\s*[)]/" => '()'
            ,"/^public\\b\\s*/" => ""
            ,"/\\s*[[],\s*/" => ", ?"
            ,"/\\s*[[]\s*/" => "?"
            ,"/]/" => ""

            ,"/\\b__construct\\b/" => "new"

            /*,"/\\bbool\\b/" => "Bool"
            ,"/\\bint\\b/" => "Int"
            ,"/\\bfloat\\b/" => "Float"
            ,"/\\bstring\\b/" => "String"
            ,"/\\barray\\b/" => "NativeArray"
            ,"/\\bmixed\\b/" => "Dynamic"*/

            ,"/^($id)\\s+([^\n\r]*)\\s*$/" => "public function \\2 : \\1;"
            ,"/\\b($id)\\s+[$]($id)\\b/" => "\\2:\\1"

            ,"/\\s+[)]/" => ')'
        );

        foreach ($patterns as $k => $v)
        {
            $text = preg_replace($k."m", $v, $text);
        }

        foreach ($this->typeNamesMapping as $k => $v)
        {
            if ($k!='') $text = preg_replace("/\\b".$k."\\b/", $v, $text);
        }
        
        return $text;
    }
}


