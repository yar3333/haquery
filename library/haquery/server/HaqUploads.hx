package haquery.server;

#if php
private typedef NativeLib = php.Lib;
private typedef NativeWeb = php.Web;
#elseif neko
private typedef NativeLib = neko.Lib;
private typedef NativeWeb = neko.Web;
#end

import haquery.common.HaqDefines;
import haquery.common.HaqUploadResult;
import haquery.common.HaqUploadError;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import sys.io.File;

class HaqUploads 
{
	var uploadsDir : String;
	var maxPostSize : Int;
	
	public function new(uploadsDir:String, maxPostSize:Int)
	{
		this.uploadsDir = uploadsDir;
		this.maxPostSize = maxPostSize;
	}
	
	public function upload() : HaqUploadResult
	{
		var files = new HaqUploadResult();
		
		#if php
		
		var nativeFiles : Hash<php.NativeArray> = php.Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
		for (id in nativeFiles.keys())
		{
			var file : php.NativeArray = nativeFiles.iterator().next();
			saveUploadedFile(files, uploadsDir, id, newUploadFileID(), new HaqUploadedFile(
				  file[untyped "tmp_name"]
				, file[untyped "name"]
				, file[untyped "size"]
				, Type.createEnumIndex(HaqUploadError, file[untyped "error"])
			));
		}
		
		#elseif neko
		
		var dataSizeCanBeUploaded = maxPostSize;
		
		var lastPartName : String = null;
		var lastFileName : String = null;
		var lastFileID : String = null;
		var lastTempFileName : String = null;
		var error : HaqUploadError = null;
		
		NativeWeb.parseMultipart(
			function(partName:String, fileName:String)
			{
				if (partName != lastPartName)
				{
					if (lastPartName != null)
					{
						if (lastFileName != null)
						{
							saveUploadedFile(files, uploadsDir, lastPartName, lastFileID, new HaqUploadedFile(
								  lastTempFileName
								, lastFileName
								, FileSystem.stat(lastTempFileName).size
								, error
							));
						}
					}
					
					lastPartName = partName;
					lastFileName = fileName;
					lastFileID = newUploadFileID();
					lastTempFileName = uploadsDir + "/" + lastFileID;
					error = HaqUploadError.OK;
				}
			}
		   ,function(data:Bytes, offset:Int, length:Int)
			{
				if (lastFileName != null)
				{
					dataSizeCanBeUploaded -= length;
					if (dataSizeCanBeUploaded >= 0)
					{
						var h = File.append(lastTempFileName);
						h.writeBytes(data, 0, length);
						h.close();
					}
					else
					{
						error = HaqUploadError.INI_SIZE;
						if (FileSystem.exists(lastTempFileName))
						{
							FileSystem.deleteFile(lastTempFileName);
						}
					}
				}
			}
		);
		
		if (lastPartName != null)
		{
			if (lastFileName != null)
			{
				saveUploadedFile(files, uploadsDir, lastPartName, lastFileID, new HaqUploadedFile(
					  lastTempFileName
					, lastFileName
					, FileSystem.stat(lastTempFileName).size
					, error
				));
			}
		}
		
		#end
		
		return files;
	}
	
	public function get(fileID:String) : HaqUploadedFile
	{
		var file = uploadsDir + "/" + fileID + ".uploaded";
		return FileSystem.exists(file) 
			? Unserializer.run(File.getContent(file))
			: null;
	}
	
	function newUploadFileID() : String
	{
		var s = Std.string(Sys.time() * 1000);
		if (s.indexOf(".") >= 0) s = s.substr(0, s.indexOf("."));
		s += "_" + Std.random(1000000);
		s += "_" + Std.random(1000000);
		return s;
	}
	
	function saveUploadedFile(files:HaqUploadResult, uploadsDir:String, inputID:String, fileID:String, uploadedFile:HaqUploadedFile)
	{
		trace("Save uploaded file " + inputID + " = { inputID:" + inputID + ", name = " + uploadedFile.name + ", fileID:" + fileID + " }");
		File.saveContent(uploadsDir + "/" + fileID + ".uploaded", Serializer.run(uploadedFile));
		files.set(inputID, { fileID:fileID, size:uploadedFile.size, error:uploadedFile.error });
	}
}