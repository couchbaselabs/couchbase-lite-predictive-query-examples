## Overview
These sample apps demonstrate the use of Couchbase Lite Prediction Queries using a simple object classifier machine learning  model. 
 The `ItemClassifier.mlmodel` is a custom ML model that is trained using the [Caltech 101](http://www.vision.caltech.edu/Image_Datasets/Caltech101/Caltech101.html) dataset. 
The app includes a prebuilt Couchbase Lite database that includes a bunch of items, each item includes  a "tag" property, which is the category to which the item belongs. 

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
cd /path/to/cloned/repo/ios/PredictiveQueriesWithCouchbaseLite/classifier/PredictiveModel

sh install_10.1.sh # this is for xcode 10.1 compatible build

```
- open  the .xcodeproj using Xcode . Build and run and project

## Description
The app does the following :
- Allows users to input an image (pick from photo album) 
- The uploaded image is then passed through the `ItemClassifier`  model to classify the image and to identify the category of the input image
-  Query for entries in the Couchbase Lite data that match the category of the uploaded image "predicted" by the ML model with a probability of > 0.7.



