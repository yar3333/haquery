package haquery.common;

enum HaqUploadError
{
	/**
	 * Value: 0; There is no error, the file uploaded with success.
	 */
	OK;

	/**
	 * Value: 1; The uploaded file exceeds the upload_max_filesize directive in php.ini.
	 */
	INI_SIZE;

	/**
	 * Value: 2; The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form.
	 */
	FORM_SIZE;

	/**
	 * Value: 3; The uploaded file was only partially uploaded.
	 */
	PARTIAL;

	/**
	 * Value: 4; No file was uploaded.
	 */
	NO_FILE;

	/**
	 * Value: 6; Missing a temporary folder. Introduced in PHP 4.3.10 and PHP 5.0.3.
	 */
	NO_TMP_DIR;

	/**
	 * Value: 7; Failed to write file to disk. Introduced in PHP 5.1.0.
	 */
	CANT_WRITE;

	/**
	 * Value: 8; A PHP extension stopped the file upload. PHP does not provide a way to ascertain which extension caused the file upload to stop; examining the list of loaded extensions with phpinfo() may help. Introduced in PHP 5.2.0.
	 */
	EXTENSION;
}
