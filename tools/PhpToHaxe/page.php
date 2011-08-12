<?php
    header('Content-Type: text/html; charset=utf-8');
    require_once "PhpToHaxe.php";
    require "config.php";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html>
    <head>
        <title>HaXe to PHP convertor</title>
        <style>
            body,tr,td, form { margin:0; padding:0; border:0; border-collapse:collapse; vertical-align: top; }
            input, textarea { margin:0; padding:0; }
            textarea
            {
                height:700px; 
                width:99%; 
                overflow:scroll;
            }
            
            .menu
            {
                text-align: center;
                padding: 5px 0 10px;
            }
            
            a,a:hover,a:visited,a:link { color: blue; }
            a.active { color: red; }
        </style>
    </head>
    <body>
        <?php
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
                        <textarea name="text" wrap="off"><?php echo isset($_POST['text']) ? $_POST['text'] : PhpToHaxe::getExampleCodeToConvert($mode); ?></textarea>
                        <div style="text-align: center; padding-top: 10px;">
                            <input type="submit" value="Convert" />
                        </div>
                    </form>
                </td>
                <td>
                    Result haxe code<br />
                    <textarea readonly='readonly' wrap="off"><?php if (isset($_POST['text'])) { $p2h = PhpToHaxe::create($mode, $typeNamesMapping, $varNamesMapping, $functionNameMapping); echo $p2h->getHaxeCode($_POST['text']); } ?></textarea>
                </td>
            </tr>
        </table>
    </body>
</html>
