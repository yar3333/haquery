package haquery.server;

import haquery.common.HaqUploadError;
import haquery.common.HaqUploadResult;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import stdlib.FileSystem;
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
		
		var nativeFiles : Map<String,php.NativeArray> = php.Lib.hashOfAssociativeArray(untyped __var__("_FILES"));
		for (id in nativeFiles.keys())
		{
			var nativeFile : php.NativeArray = nativeFiles.get(id);
			
			var fileID = newUploadFileID();
			var filePath = uploadsDir + "/" + fileID;
			untyped __call__("move_uploaded_file", nativeFile[untyped "tmp_name"], filePath);
			saveUploadedFile(files, uploadsDir, id, fileID, new HaqUploadedFile(
				  filePath
				, nativeFile[untyped "name"]
				, nativeFile[untyped "size"]
				, Type.createEnumIndex(HaqUploadError, nativeFile[untyped "error"])
			));
		}
		
		#elseif neko
		
		var dataSizeCanBeUploaded = maxPostSize;
		
		var lastPartName : String = null;
		var lastFileName : String = null;
		var lastFileID : String = null;
		var lastFilePath : String = null;
		var error : HaqUploadError = null;
		
		Web.parseMultipart(
			function(partName:String, fileName:String)
			{
				if (partName != lastPartName)
				{
					if (lastPartName != null)
					{
						if (lastFileName != null)
						{
							saveUploadedFile(files, uploadsDir, lastPartName, lastFileID, new HaqUploadedFile(
								  lastFilePath
								, lastFileName
								, FileSystem.stat(lastFilePath).size
								, error
							));
						}
					}
					
					lastPartName = partName;
					lastFileName = fileName;
					lastFileID = newUploadFileID();
					lastFilePath = uploadsDir + "/" + lastFileID;
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
						var h = File.append(lastFilePath);
						h.writeBytes(data, 0, length);
						h.close();
					}
					else
					{
						error = HaqUploadError.INI_SIZE;
						if (FileSystem.exists(lastFilePath))
						{
							FileSystem.deleteFile(lastFilePath);
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
					  lastFilePath
					, lastFileName
					, FileSystem.stat(lastFilePath).size
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
		files.set(inputID, { fileID:fileID, name:uploadedFile.name, size:uploadedFile.size, error:uploadedFile.error });
	}
}
