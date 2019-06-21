<!--- Codes from Raymond Camden --->

<cfset sourceImage = expandPath("./test.jpg")>

<cfscript>
function fncFileSize(size) { 
	if ((size gte 1024) and (size lt 1048576)) { 
		var result = round(size / 1024) & 'Kb';
		return result;
	} 
	else if (size gte 1048576) { 
		var result = decimalFormat(size/1048576) & 'Mb';
		return result;
	} 
	else { 
		return '#size# b';
	} 
}
</cfscript>

<cfsetting requestTimeOut = "3000">
<cfset methods = "highestQuality,lanczos,highquality,mitchell,mediumPerformance,quadratic,mediumquality,hamming,hanning,hermite,highPerformance,blackman,bessel,highestPerformance,nearest,bicubic,bilinear">
<cfset results = queryNew("method,size,time")>
<cfset finfo = getFileInfo(sourceImage)>
<cfset img = imageRead(sourceImage)>
<cfset iinfo = imageInfo(img)>
<cfdump var="#iinfo#" label="File Size in Bytes: #finfo.size#">

<cfimage action="writeToBrowser" source="#sourceImage#">
<hr/>

<cfloop index="m" list="#methods#">
<cfoutput>
	<h2>Resize Method: #m#</h2>
	<cfset newImage = duplicate(img)>
	<cfset timer = getTickCount()>
	<cfset imageScaleToFit(newImage, 700, 700, m)>
	<cfset total = getTickCount() - timer>
	<cfset filename ="#m#-" & getFileFromPath(sourceImage)>
	<cfset imageWrite(newImage,expandPath(filename),1)>
	<cfset finfo = getFileInfo(expandPath(filename))>
	<p>#fncFileSize(finfo.size)# bytes at #total/1000# seconds</p>
	<img src="./#filename#">
</cfoutput>
<cfset queryAddRow(results)>
<cfset querySetCell(results, "method", m)>
<cfset querySetCell(results, "size", fncFileSize(finfo.size))>
<cfset querySetCell(results, "time", total/1000)>
<cfflush>
</cfloop>

<cftable query="results" border colHeaders htmlTable>
	<cfcol header="Method" text="#method#">
	<cfcol header="Size" text="#size#">
	<cfcol header="Time (Seconds)" text="#time#">
</cftable>
