<?php

class PhpToHaxe_Consts
{
    private $typeNamesMapping;
    
    function __construct($typeNamesMapping)
    {
        $this->typeNamesMapping = $typeNamesMapping;
    }
    
    function getHaxeCode($text)
    {
        $classConsts = array();

        $re = "/"
                . "(?:^|\n|\r)+" 
                . "(?:(?P<class>[_a-zA-Z0-9]+)::)?" . "(?P<name>[_a-zA-Z0-9]+)" 
                . "\\s*[(]\\s*" 
                    . "(?P<type>[_a-zA-Z0-9]+)"
                . "\\s*[)][ ]*"
                . "(?:"
                    ."(?:\n|\r)+" . "[ \t]+" . "(?P<comment>[^\n\r]+)"
                . ")?"
            ."/m";
        $matches = array();
        if (preg_match_all($re, $text, $matches, PREG_SET_ORDER))
        {
            foreach ($matches as $match)
            {
                $class = $match['class'];
                $name = $match['name'];
                $type = $match['type'];
                $comment = isset ($match['comment']) ? $match['comment'] : '';

                if (!isset($classConsts[$class])) $classConsts[$class] = array();
                $classConsts[$class][$name] = array('type'=>$type, 'comment'=>$comment);
            }
        }

        $r = '';
        foreach ($classConsts as $class => $consts)
        {
            $r .= "class $class\n{\n";
            foreach ($consts as $name=>$const)
            {
                $type = $const['type'];
                $haxeType = isset($this->typeNamesMapping[$type]) ? $this->typeNamesMapping[$type] : $this->typeNamesMapping[''];
                $comment = $type = $const['comment'];
                if ($comment!='')
                {
                    $r .= "\n\t/**\n\t * $comment\n\t */\n";
                }
                $r .= "\tpublic static inline var $name({$name}_getter, null) : $haxeType;"
                    . " static inline function {$name}_getter() : $haxeType { return untyped __php__(\"" . ($class!='' ? $class.'::' : '') ."{$name}\"); }\n";
            }
            $r .= "}\n\n";
        }

        return $r;
    }
}


