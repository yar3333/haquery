<?php
class haquery_server_HaqProfiler
{
    private static $blocks = array();
    private static $opened = array();

    static function begin($name)
    {
        array_push(self::$opened, array($name, microtime(true)));
    }

    static function end()
    {
        list ($name, $time) = array_pop(self::$opened);
        $dt = microtime(true) - $time;

        if (!isset(self::$blocks[$name]))
            self::$blocks[$name] = array(1,$dt);
        else
        {
            self::$blocks[$name][0]++;
            self::$blocks[$name][1] += $dt;
        }

        // след. строка вычитает из времени блоков время их подблоков
        foreach (self::$opened as &$block) $block[1] += $dt;
    }

    static function getResults()
    {
        $maxLen = 0;
        foreach (self::$blocks as $name=>$block) $maxLen = max($maxLen, strlen($name));

        $r = str_pad("total time | name ", $maxLen+14, ' ') . "#count\n";
        $r.= str_pad("-----------+", $maxLen+14, '-') . "+-----\n";
        foreach (self::$blocks as $name=>$block) $r .= sprintf("%10.3f | %-{$maxLen}s #%-5d\n",$block[1],$name,$block[0]);
        return $r;
    }

    static function saveTotalResults()
    {
        $f = HaqSystem::getUserSitePath().'temp/profiler.data';
        
        $count = 0;
        $blocks = array();
        
        if (!is_file($f)) file_put_contents($f, serialize(array(0, array())));
            
        $fp = fopen($f, "r+");

        $start = microtime(true);
        do
        {
            $isLock = flock($fp, LOCK_EX);
            if (!$isLock) usleep(10000);
        } while (!$isLock && microtime(true)-$start < 0.5);

        if (!$isLock) { @fclose($fp); return false; }

        list ($count, $blocks) = unserialize(stream_get_contents($fp));

        foreach (self::$blocks as $name=>$block)
        {
            if (!isset($blocks[$name])) $blocks[$name] = array(0,0);
            $blocks[$name][0]+=$block[0];
            $blocks[$name][1]+=$block[1];
        }

        rewind($fp);
        ftruncate($fp, 0); // truncate file
        fwrite($fp, serialize(array($count+1, $blocks)));
        //flock($fp, LOCK_UN); // release the lock
        fclose($fp);
    }

    static function getTotalResults()
    {
        $f = HaqSystem::getUserSitePath().'temp/profiler.data';
        if (!is_file($f)) return array(0,array());
        return unserialize(file_get_contents($f));
    }

    static function resetTotalResults()
    {
        $f = HaqSystem::getUserSitePath().'temp/profiler.data';
        @unlink($f);
    }
}
