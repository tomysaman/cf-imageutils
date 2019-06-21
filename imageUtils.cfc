<!---
Image utility
Author: tomywutoto@gmail.com
--->
<cfcomponent output="false" accessors="true">

	<cffunction name="init" returntype="any">
		<cfargument name="imageInterpolation" default="highPerformance">
		<cfargument name="imageQuality" default="80">
		<cfset this.imageInterpolation = arguments.imageInterpolation>
		<cfset this.imageQuality = arguments.imageQuality>
		<cfreturn this>
	</cffunction>

	<cffunction name="resizeImage" output="false" returntype="any">
		<cfargument name="sourceImage" required="true" type="string" hint="relative or absolute path and filename to the source image">
		<cfargument name="width" type="string" default="auto">
		<cfargument name="height" type="string" default="auto">
		<cfargument name="targetFilename" type="string" default="self" hint="[self]=overwrite source file; [uuid]=use uuid as filename; [timestamp]=use timestamp as filename; [other_values]=use the supplied string as filename">
		<cfargument name="targetPath" type="string" default="" hint="relative or absolute path to save the resized image">
		<cfargument name="crop" type="string" default="scaleToFit" hint="used only if both width and height are set to a number; [crop]=crop the image at size width x height; [scaleToFit]=scale image to fit width x height">
		<cfargument name="allowEnlarge" type="boolean" default="false" hint="allow system to enlarge (hence lose image quality) image to meet the resizing dimension or not, set to true to ensure the resized image is in the dimension you want">

		<cfset var source = arguments.sourceImage>
		<cfset var thisImage = "">
		<cfset var thisImagePath = "">
		<cfset var thisImageFile = "">
		<cfset var thisImageFilename = "">
		<cfset var thisImageExt = "">
		<cfset var saveTo = "">
		<cfset var saveToPath = arguments.targetPath>
		<cfset var saveToFile = "">
		<cfset var ImageAspectRatio = 0>
		<cfset var NewAspectRatio = 0>
		<cfset var CropX = 0>
		<cfset var CropY = 0>
		<cfset var result = structNew()>

		<cfset result.error = 0>

		<!--- Arguments checking --->
		<cfif arguments.targetFilename neq "self" and arguments.targetPath eq "">
			<cfset result.error = 1>
			<cfset result.errorMsg = "arguments.targetPath must be supplied if arguments.targetFilename is not [self]">
			<cfreturn result>
		</cfif>

		<!--- Check source image file --->
		<cfif not fileExists(source)>
			<cfset source = expandPath(source)>
			<cfif not fileExists(source)>
				<cfset result.error = 1>
				<cfset result.errorMsg = "Source file not found">
				<cfreturn result>
			</cfif>
		</cfif>

		<!--- Check target directory, create it if needed --->
		<cfif not listFind( "/,\", right(saveToPath,1) )>
			<cfset saveToPath = saveToPath & "/">
		</cfif>
		<cfif not directoryExists(saveToPath)>
			<cfset saveToPath = expandPath(saveToPath)>
			<cfif not directoryExists(saveToPath)>
				<cftry>
					<cfdirectory directory="#saveToPath#" action="create">
					<cfcatch>
						<cfset result.error = 1>
						<cfset result.errorMsg = "Unable to create target directory">
						<cfreturn result>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>

		<cfset thisImagePath = getDirectoryFromPath(source)>
		<cfset thisImageFile = replace(source, thisImagePath, "")>
		<cfset thisImageExt = listLast(thisImageFile, ".")>
		<cfset thisImageFilename = replace(thisImageFile, ".#thisImageExt#", "")>

		<cfif arguments.targetFilename eq "self">
			<cfset saveToFile = thisImageFile>
			<cfset saveToPath = thisImagePath>
		<cfelseif arguments.targetFilename eq "uuid">
			<cfset saveToFile = "#createUUID()#.#thisImageExt#">
		<cfelseif arguments.targetFilename eq "timestamp">
			<cfset saveToFile = "#dateFormat(now(),'yyyymmdd')##timeFormat(now(),'hhmmss')#.#thisImageExt#">
		<cfelseif not find(".", arguments.targetFilename)>
			<cfset saveToFile = "#arguments.targetFilename#.#thisImageExt#">
		<cfelse>
			<cfset saveToFile = arguments.targetFilename>
		</cfif>
		<cfset saveTo = saveToPath & saveToFile>

		<cfset thisImage = imageRead(source)>

		<cfif isNumeric(arguments.width) and isNumeric(arguments.height)>
			<cfif lcase(arguments.crop) eq "scaletofit">
				<!--- resize the image to fit a size --->
				<cfif thisImage.width gt arguments.width or thisImage.height gt arguments.height or (thisImage.width lt arguments.width and thisImage.height lt arguments.height and arguments.allowEnlarge)>
					<cfset imageScaleToFit(thisImage, arguments.width, arguments.height, this.imageInterpolation)>
				</cfif>
			<cfelse>
				<!--- crop the image --->
				<cfset ImageAspectRatio = thisImage.width / thisImage.height>
				<cfset NewAspectRatio = arguments.width / arguments.height>
				<cfif ImageAspectRatio eq NewAspectRatio>
					<cfif thisImage.width gt arguments.width or (thisImage.width lt arguments.width and arguments.allowEnlarge)>
						<cfset imageResize(thisImage, arguments.width, '', this.imageInterpolation)>
					</cfif>
				<cfelseif ImageAspectRatio lt NewAspectRatio>
					<cfif thisImage.width gt arguments.width or (thisImage.width lt arguments.width and arguments.allowEnlarge)>
						<cfset imageResize(thisImage, arguments.width, '', this.imageInterpolation)>
						<cfset CropY = (thisImage.height - arguments.height)/2 />
						<cfset imageCrop(thisImage, 0, CropY, arguments.Width, arguments.height)>
					</cfif>
				<cfelseif ImageAspectRatio gt NewAspectRatio>
					<cfif thisImage.height gt arguments.height or (thisImage.height lt arguments.height and arguments.allowEnlarge)>
						<cfset ImageResize(thisImage, '', arguments.height, this.imageInterpolation)>
						<cfset CropX = (thisImage.width - arguments.width)/2 />
						<cfset imageCrop(thisImage, CropX, 0, arguments.width, arguments.height)>
					</cfif>
				</cfif>
			</cfif>
		<cfelseif arguments.width eq "auto" and isNumeric(arguments.height)>
			<cfif thisImage.height gt arguments.height or (thisImage.height lt arguments.height and arguments.allowEnlarge)>
				<cfset ImageResize(thisImage, '', arguments.height, this.imageInterpolation)>
			</cfif>
		<cfelseif arguments.height eq "auto" and isNumeric(arguments.width)>
			<cfif thisImage.width gt arguments.width or (thisImage.width lt arguments.width and arguments.allowEnlarge)>
				<cfset ImageResize(thisImage, arguments.width, '', this.imageInterpolation)>
			</cfif>
		</cfif>

		<cfset result = saveImage(thisImage, saveTo)>

		<cfreturn result>
	</cffunction>

	<cffunction name="saveImage" output="false" returntype="any">
		<cfargument name="image" required="yes" type="object" hint="cf image object">
		<cfargument name="saveTo" required="yes" type="string" hint="absolute path and filename of the image file">

		<cfset var result = structNew()>
		<cfset result.error = 0>
		<cftry>
			<cfset ImageWrite(arguments.image, arguments.saveTo, true, this.imageQuality)>
			<cfcatch>
				<cfset result.error = 1>
				<cfset result.errorMsg = cfcatch.message>
				<cfreturn result>
			</cfcatch>
		</cftry>

		<cfset result.image = arguments.saveTo>
		<cfset result.imagePath = getDirectoryFromPath(arguments.saveTo)>
		<cfset result.imageFile = replace(arguments.saveTo, result.imagePath, "")>
		<cfset result.imageExt = listLast(result.imageFile, ".")>
		<cfset result.imageFilename = replace(result.imageFile, ".#result.imageExt#", "")>

		<cfreturn result>
	</cffunction>

</cfcomponent>
