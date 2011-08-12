<?php
require_once "PhpToHaxe_Code.php";
require_once "PhpToHaxe_Methods.php";
require_once "PhpToHaxe_Consts.php";

class PhpToHaxe
{
    const MODE_CODE = 0;
    const MODE_EXTERN_CODE = 1;
    const MODE_DOC_METHODS = 2;
    const MODE_DOC_CONSTS = 3;
    
    static function create($mode, $typeNamesMapping, $varNamesMapping, $functionNameMapping)
    {
        $p2h = null;
        if ($mode==PhpToHaxe::MODE_CODE)
        {
            $p2h = new PhpToHaxe_Code($typeNamesMapping, $varNamesMapping, $functionNameMapping, false);
        }
        else
        if ($mode==PhpToHaxe::MODE_EXTERN_CODE)
        {
            $p2h = new PhpToHaxe_Code($typeNamesMapping, $varNamesMapping, $functionNameMapping, true);
        }
        else
        if ($mode==PhpToHaxe::MODE_DOC_METHODS)
        {
            $p2h = new PhpToHaxe_Methods($typeNamesMapping);
        }
        else
        if ($mode==PhpToHaxe::MODE_DOC_CONSTS)
        {
            $p2h = new PhpToHaxe_Consts($typeNamesMapping);
        }
        return $p2h;
    }
    
    static function getExampleCodeToConvert($mode)
    {
        if ($mode==PhpToHaxe::MODE_CODE || $mode==PhpToHaxe::MODE_EXTERN_CODE)
        {
            return <<<END_OF_RETURN
class Test
{
    /**
     * This is variable.
     * @var string
     */
    public \$pub;
    
    private \$priv;

    /**
     * Create child component.
     * @param MyClass \$tag Tag is a short name.
     * @param string \$id
     * @return SyqComponent
     */
    function create(MyClass \$tag,\$id)
    {
        \$s = substr(\$id, 3);
    }
    
    private function innerFunc()
    {
        \$b = 10;
    }
}
END_OF_RETURN;
        }
        else
        if ($mode==PhpToHaxe::MODE_DOC_METHODS)
        {
            return <<<END_OF_RETURN
bool adaptiveBlurImage ( float \$radius , float \$sigma [, int \$channel = Imagick::CHANNEL_DEFAULT ] )
bool adaptiveResizeImage ( int \$columns , int \$rows [, bool \$bestfit = false ] )
bool adaptiveSharpenImage ( float \$radius , float \$sigma [, int \$channel = Imagick::CHANNEL_DEFAULT ] )
bool adaptiveThresholdImage ( int \$width , int \$height , int \$offset )
bool addImage ( Imagick \$source )
bool addNoiseImage ( int \$noise_type [, int \$channel = Imagick::CHANNEL_DEFAULT ] )
END_OF_RETURN;
        }
        else
        if ($mode==PhpToHaxe::MODE_DOC_CONSTS)
        {
            return <<<END_OF_RETURN
IMG_GIF (integer)
    Used as a return value by imagetypes() 
IMG_JPG (integer)
    Used as a return value by imagetypes() 

imagick::COLOR_BLACK (integer)
    Black color 
imagick::COLOR_BLUE (integer)
    Blue color 
END_OF_RETURN;
        }
        
    }
}
