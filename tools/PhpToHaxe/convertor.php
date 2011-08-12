<?php
require "config.php";

require_once "PhpCodeToHaxe.php";
require_once "PhpDocMethodsToHaxe.php";
require_once "PhpDocConstsToHaxe.php";

define('MODE_PHP_CODE_TO_HAXE_CODE', 0);
define('MODE_PHP_CODE_TO_HAXE_EXTERN_CODE', 1);
define('MODE_PHP_DOC_METHODS_TO_HAXE_METHODS', 2);
define('MODE_PHP_DOC_CONSTS_TO_HAXE_CONSTS', 3);

function convertor($mode)
{
    global $typeNamesMapping;
    global $varNamesMapping;
    global $functionNameMapping;
    
    require 'header.php';

    $menuLinks = array(
         'index.php'  => 'Php code to haxe code'
        ,'index1.php' => 'Php code to haxe extern code'
        ,'index2.php' => 'Phpdoc c-like methods to haxe methods'
        ,'index3.php' => 'Phpdoc consts to haxe consts'
    );
    $menu = array();
    $n = 0;
    foreach ($menuLinks as $k => $v)
    {
        $menu[] = "<a href='$k'".($n==$mode ? " class='active'" : "").">$v</a>";
        $n++;
    }
    echo "<div class='menu'>" . implode(' | ', $menu) . "</div>\n";
?>
<table width="100%">
    <tr>
        <td>
            Source php code to convert<br />
            <form method="POST">
                <textarea name="text" wrap="off">
<?php
if (isset($_POST['text']))
{
    echo $_POST['text'];
}
else
{
if ($mode==MODE_PHP_CODE_TO_HAXE_CODE || $mode==MODE_PHP_CODE_TO_HAXE_EXTERN_CODE)
{
?>
class Test
{
    /**
     * This is variable.
     * @var string
     */
    public $pub;
    
    private $priv;

    /**
     * Create child component.
     * @param MyClass $tag Tag is a short name.
     * @param string $id
     * @return SyqComponent
     */
    function create(MyClass $tag,$id)
    {
        $s = substr($id, 3);
    }
    
    private function innerFunc()
    {
        $b = 10;
    }
}
<?php
}
else
if ($mode==MODE_PHP_DOC_METHODS_TO_HAXE_METHODS)
{
?>
bool adaptiveBlurImage ( float $radius , float $sigma [, int $channel = Imagick::CHANNEL_DEFAULT ] )
bool adaptiveResizeImage ( int $columns , int $rows [, bool $bestfit = false ] )
bool adaptiveSharpenImage ( float $radius , float $sigma [, int $channel = Imagick::CHANNEL_DEFAULT ] )
bool adaptiveThresholdImage ( int $width , int $height , int $offset )
bool addImage ( Imagick $source )
bool addNoiseImage ( int $noise_type [, int $channel = Imagick::CHANNEL_DEFAULT ] )
<?php
}
else
if ($mode==MODE_PHP_DOC_CONSTS_TO_HAXE_CONSTS)
{
?>
IMG_GIF (integer)
    Used as a return value by imagetypes() 
IMG_JPG (integer)
    Used as a return value by imagetypes() 

imagick::COLOR_BLACK (integer)
    Black color 
imagick::COLOR_BLUE (integer)
    Blue color 
<?php
}
}
?>
                </textarea>
                <div style="text-align: center; padding-top: 10px;">
                    <input type="submit" value="Convert" />
                </div>
            </form>
        </td>
        <td>
            Result haxe code<br />
            <textarea readonly='readonly' wrap="off">
<?php
if (isset($_POST['text']))
{
    if ($mode==MODE_PHP_CODE_TO_HAXE_CODE)
    {
        $p2h = new PhpCodeToHaxe($typeNamesMapping, $varNamesMapping, $functionNameMapping, false);
    }
    else
    if ($mode==MODE_PHP_CODE_TO_HAXE_EXTERN_CODE)
    {
        $p2h = new PhpCodeToHaxe($typeNamesMapping, $varNamesMapping, $functionNameMapping, true);
    }
    else
    if ($mode==MODE_PHP_DOC_METHODS_TO_HAXE_METHODS)
    {
        $p2h = new PhpDocMethodsToHaxe($typeNamesMapping);
    }
    else
    if ($mode==MODE_PHP_DOC_CONSTS_TO_HAXE_CONSTS)
    {
        $p2h = new PhpDocConstsToHaxe($typeNamesMapping);
    }
    
    echo $p2h->getHaxeCode($_POST['text']);    
}
?>
            </textarea>
        </td>
    </tr>
</table>
<?php
    require 'footer.php';
}