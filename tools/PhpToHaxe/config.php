<?php
$typeNamesMapping = array(
     'int' => 'Int'
    ,'integer' => 'Int'
    ,'float' => 'Float'
    ,'bool' => 'Bool'
    ,'boolean' => 'Bool'
    ,'string' => 'String'
    ,'array' => 'NativeArray'
    ,'mixed' => 'Dynamic'
    ,'mixes' => 'Dynamic'
    ,'object' => 'Dynamic'
    ,'void' => 'Void'
);

$varNamesMapping = array(
     '_POST' => '/*$_POST*/php.Web.getParams()'
    ,'_GET' => '/*$_GET*/php.Web.getParams()'
    ,'__FILE__' => "untyped __php__('__FILE__')"
);

$functionNameMapping = array(
     '__construct'              => 'new'

    ,'str_starts_with'          => array('(',0,')', '.', 'startsWith', '(', 1, ')')
    ,'str_ends_with'            => array('(',0,')', '.', 'endsWith', '(', 1, ')')

    ,'ltrim'                    => array('(',0,')', '.', 'ltrim', '(', 1, ')')
    ,'rtrim'                    => array('(',0,')', '.', 'rtrim', '(', 1, ')')
    ,'trim'                     => array('(',0,')', '.', 'trim', '(', 1, ')')
    ,'strip_tags'               => 'StringTools.stripTags'
    ,'sprintf'                  => 'StringTools.format'
    ,'str_pad'                  => 'StringTools.pad'

    ,'htmlspecialchars'         => 'StringTools.htmlEscape'
    ,'htmlspecialchars_decode'  => 'StringTools.htmlUnescape'

    ,'serialize'                => 'php.Lib.serialize'
    ,'unserialize'              => 'php.Lib.unserialize'

    ,'header'                   => 'php.Web.setHeader'

    ,'dirname'                  => 'php.io.Path.directory'
    ,'file_get_contents'        => 'php.io.File.getContent'
    ,'file_put_contents'        => 'php.io.File.putContent'
    ,'file_exists'              => 'php.FileSystem.exists'
    ,'is_file'                  => '!php.FileSystem.isDirectory' // OR MAY BE: array('php.FileSystem.kind(',0,')==php.FileKind.kfile')
    ,'is_dir'                   => 'php.FileSystem.isDirectory'
    ,'realpath'                 => 'php.FileSystem.fullPath'
    ,'unlink'                   => 'php.FileSystem.deleteFile'
    ,'mkdir'                    => 'php.FileSystem.createDirectory'
    ,'filemtime'                => array('php.FileSystem.stat(',0,').mtime.getTime()')

    ,'min'                      => 'Math.min'
    ,'max'                      => 'Math.max'

    ,'microtime'                => array('Date.now().getTime()')

    ,'substr'                   => array('(',0,')', '.', 'substr', '(', 1, ', ', 2, ')')
    ,'strlen'                   => array('(',0,')', '.', 'length')
    ,'str_replace'              => array('(',2,')', '.', 'replace', '(', 0, ', ', 1, ')')
    ,'strpos'                   => array('(',0,')', '.', 'indexOf', '(', 1, ', ', 2, ')')
    ,'strrpos'                  => array('(',0,')', '.', 'lastIndexOf', '(', 1, ', ', 2, ')')
    ,'strtolower'               => array('(',0,')', '.', 'toLowerCase', '(', ')')
    ,'strtoupper'               => array('(',0,')', '.', 'toUpperCase', '(', ')')
    ,'json_encode'              => 'StringTools.jsonEncode'
    ,'json_decode'              => 'StringTools.jsonDecode'


    ,'count'                    => array('(',0,')', '.', 'length')
    ,'explode'                  => array('(',1,')', '.', 'split', '(', 0, ')')
    ,'implode'                  => array('(',1,')', '.', 'join', '(', 0, ')')
    ,'array_slice'              => array('(',0,')', '.', 'slice', '(', 1, ',', 2, ')')
    ,'array_splice'             => array('(',0,')', '.', 'splice', '(', 1, ', ', 2, ')')
    ,'array_push'               => array('(',0,')', '.', 'push', '(', 1, ')')
    ,'array_pop'                => array('(',0,')', '.', 'pop', '(', 1, ')')
    ,'array_shift'              => array('(',0,')', '.', 'shift', '(', 1, ')')
    ,'array_unshift'            => array('(',0,')', '.', 'unshift', '(', 1, ')')

    ,'array_search'            => array('(',1,')', '.', 'indexOf', '(', 0, ')')
    ,'array_key_exists'        => array('(',1,')', '.', 'exists', '(', 0, ')')

    ,'array_keys'              => array('(',0,')', '.', 'keys()')

    ,'method_exists'           => array('Reflect.hasMethod(Type.resolveClass_getClass(',0,'), ',1,')')
    ,'class_exists'            => 'Type.resolveClass'

    ,'exit'                    => 'php.Sys.exit'
);
