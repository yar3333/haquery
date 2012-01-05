<?php

class haquery_server_UploadError extends Enum {
	public static $UPLOAD_ERR_CANT_WRITE;
	public static $UPLOAD_ERR_EXTENSION;
	public static $UPLOAD_ERR_FORM_SIZE;
	public static $UPLOAD_ERR_INI_SIZE;
	public static $UPLOAD_ERR_NO_FILE;
	public static $UPLOAD_ERR_NO_TMP_DIR;
	public static $UPLOAD_ERR_OK;
	public static $UPLOAD_ERR_PARTIAL;
	public static $__constructors = array(6 => 'UPLOAD_ERR_CANT_WRITE', 7 => 'UPLOAD_ERR_EXTENSION', 2 => 'UPLOAD_ERR_FORM_SIZE', 1 => 'UPLOAD_ERR_INI_SIZE', 4 => 'UPLOAD_ERR_NO_FILE', 5 => 'UPLOAD_ERR_NO_TMP_DIR', 0 => 'UPLOAD_ERR_OK', 3 => 'UPLOAD_ERR_PARTIAL');
	}
haquery_server_UploadError::$UPLOAD_ERR_CANT_WRITE = new haquery_server_UploadError("UPLOAD_ERR_CANT_WRITE", 6);
haquery_server_UploadError::$UPLOAD_ERR_EXTENSION = new haquery_server_UploadError("UPLOAD_ERR_EXTENSION", 7);
haquery_server_UploadError::$UPLOAD_ERR_FORM_SIZE = new haquery_server_UploadError("UPLOAD_ERR_FORM_SIZE", 2);
haquery_server_UploadError::$UPLOAD_ERR_INI_SIZE = new haquery_server_UploadError("UPLOAD_ERR_INI_SIZE", 1);
haquery_server_UploadError::$UPLOAD_ERR_NO_FILE = new haquery_server_UploadError("UPLOAD_ERR_NO_FILE", 4);
haquery_server_UploadError::$UPLOAD_ERR_NO_TMP_DIR = new haquery_server_UploadError("UPLOAD_ERR_NO_TMP_DIR", 5);
haquery_server_UploadError::$UPLOAD_ERR_OK = new haquery_server_UploadError("UPLOAD_ERR_OK", 0);
haquery_server_UploadError::$UPLOAD_ERR_PARTIAL = new haquery_server_UploadError("UPLOAD_ERR_PARTIAL", 3);
