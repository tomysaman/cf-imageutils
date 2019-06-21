Image Utility CFC
========================================

CFC that does some image operations such as resizing (more to be added)

## Create the object
```
  imageUtils = createObject("component","imageUtils").init( imageInterpolation="highPerformance", imageQuality=80 );
```
- **imageInterpolation**: The interpolation method for resampling - default to "highPerformance" - see http://help.adobe.com/en_US/ColdFusion/9.0/CFMLRef/WSc3ff6d0ea77859461172e0811cbec22c24-7961.html for full list of options
- **imageQuality**: Image quality for saving JPEG file - default to 80

#### Speed test of interpolation methods
Run /speedtest to compare the speed of different resampling interpolation methods

## Resize image
```
  testImage = expandPath('./source.jpg');
  saveTo = expandPath('./');
  resizeResult = imageUtils.resizeImage( sourceImage=testImage, width='800', height='600', targetFilename='result.jpg', targetPath=saveTo, crop='scaleToFit', allowEnlarge=false);
```
- **sourceImage**: {string} [required] Relative or absolute path and filename to the source image
- **width**: {string} Resize width - default to "auto"
- **height**: {string} Resize height - default to "auto"
- **targetFilename**: {string} The resized image filename - default to "self", options are:
    - "self": overwrite the source file at its current location
    - "uuid": use CF uuid as filename
    - "timestamp": use timestamp yyyymmddhhmmss as filename
    - all other values: use the supplied string as filename
- **targetPath**: {string} Relative or absolute path to save the resized image - default to "" (will use the path of the source image)
- **crop**: {string} The crop / scale to fit option - default to "scaleToFit", options are:
    - "scaleToFit": scale image to fit width x height
    - "crop": crop the image at size width x height
- **allowEnlarge**: {boolean} Allow image to be enlarged (hence lose image quality) to meet the resizing dimension or not - default to false

#### Return result
The resizeImage function returns a structure.

Resize successful

![success](/assets/result_success.png?raw)

Note: The path in IMAGE and IMAGEPATH are absolute physical path (i.e. the one you get by using expandPath function)

Error

![error](/assets/result_error.png?raw)

#### Examples
Resize image to width 800px (height = auto)
```
  testImage = expandPath('./source.jpg');
  resizeResult = imageUtils.resizeImage( sourceImage=testImage, width='800', height='auto' );
```

Resize image to height 600px (width = auto)
```
  testImage = expandPath('./source.jpg');
  resizeResult = imageUtils.resizeImage( sourceImage=testImage, width='auto', height='600' );
```

Resize image to fit 300 x 300 (won't resize if image is smaller than 300x300)
```
  testImage = expandPath('./source.jpg');
  resizeResult = imageUtils.resizeImage( sourceImage=testImage, width='300', height='300' );
```
- If the image is 900x300, the result image will be 300x100
- If the image is 300x600, the result image will be 150x300

Resize image to fit 1000 x 1000 (will resize regardless of image dimension, if the image is 10x10 it will become 1000x1000)
```
  testImage = expandPath('./source.jpg');
  resizeResult = imageUtils.resizeImage( sourceImage=testImage, width='1000', height='1000', allowEnlarge=true );
```

Crop image from the centre to fit 300 x 300 (won't crop if image is smaller 300x300)
```
  testImage = expandPath('./source.jpg');
  resizeResult = imageUtils.resizeImage( sourceImage=testImage, width='300', height='300', crop='crop' );
```