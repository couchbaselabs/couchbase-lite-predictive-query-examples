## Overview
These sample apps demonstrate the use of Couchbase Lite Prediction Queries using a face recognition deep neural network. 
 The `OpenFace.mlmodel` is a coreML version of the free, open source [deep neural network ](http://cmusatyalab.github.io/openface/). The model's prediction function generates a "fingerprint" for the image. This fingerprint is an image is a 128 double vector that is a unique representation of the image. 
The app includes a prebuilt Couchbase Lite database that includes a bunch of items, each item includes an "image" property and a "name" property.

## Version
-Xcode 10.1+ /swift 5
-Couchbase Lite 2.5 EE

## Repo structure
There are two versions of the app
### CoreMLPredictiveModel 
This uses  `CoreMLPredictiveModel`, which is the concrete implementation of Couchbase Lite's Predictive Model interface using coreML 

### PredictiveModel 
This implements  Couchbase Lite's `PredictiveModel` interface . The implementation of  `predict` function of the `PredictiveModel` interface  invokes the coreML model


## Installation
- Clone the repo
```
git clone https://github.com/rajagp/PredictiveQueriesWithCouchbaseLite.git
```
- Go to the appropriate app directory and install Couchbase Lite.
Run `install_10.1.sh` for xcode 10.1 compatible build of Couchbase Lite. Run `install_10.2.sh` for xcode 10.2 compatible build of Couchbase Lite

```
cd /path/to/cloned/repo/ios/PredictiveQueriesWithCouchbaseLite/facerecognition/PredictiveModel

sh install_10.1.sh # this is for xcode 10.1 compatible build

```
- open  the .xcodeproj using Xcode . Build and run and project

## Description
The app does the following :
- On initial launch
    - Loads a prebuilt Couchbase Lite database of person images and names. The  database is loaded with some images from the [LFW dataset](http://vis-www.cs.umass.edu/lfw/person/Sylvester_Stallone.html)
    - Builds a *Prediction Index* by running all the images in the database through the `OpenFace` model's prediction function.  The prediction function generates a "fingerprint" for the image. The predictions are cached in a `Prediction cache`.
- Allows users to input an image ( pick from photo album) 
- The uploaded image is then passed through the `OpenFace` face recognition model to generate the  "fingerprint" for the uploaded image
- The fingerprint of the uploaded image is compared with the fingerprints of all the images in the `Prediction cache` using *distance vector comparison function* to identify the closest match
- The name corresponding to the image with closest match is  queried from the database. 



## Known Issues
The app simply passes the uploaded image directly through the `OpenFace` model without any preprocessing. Instead, the image must be passed through a face detector stage that will detect face, then transform it , crop it  to desired size and the cropped face must be then passed through the neural network that will generate the fingerprint.
For this reason, the matches are not predicted accurately unless we do a lookup with an image that is exactly the one in the database. This is a limitation of the app implementation and not  the Couchbase Lite Prediction API. 

