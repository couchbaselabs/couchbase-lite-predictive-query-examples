## Overview
These sample apps demonstrate the use of Couchbase Lite Prediction Queries using a simple object classifier machine learning  model. 
 The `ItemClassifier.mlmodel` is a ML model that is trained using the [Caltech 101](http://www.vision.caltech.edu/Image_Datasets/Caltech101/Caltech101.html) dataset. 
The app includes a prebuilt Couchbase Lite database that includes a bunch of items, each item includes  a "tag" property, which is the category to which the item belongs. 

The app does two things
- It allows users to upload in image and query for entries in the Couchbase Lite data that match the category of the uploaded image "predicted" by the ML model with a probability of > 0.7. 
- It allows users to save an uploaded image with a name, uses the model to predict it's category and adds a new document corresponding to the item. Note that prediction of category in this case is done directly using the model and does not use the `PredictiveModel` interface. This is primarly used as a way to enter new items into the database.


There are two versions of this app.

### CoreMLPredictiveModel 
This uses  `CoreMLPredictiveModel`, which is the concrete implementation of Couchbase Lite's Predictive Model interface using coreML 

### PredictiveModel 
This implements  Couchbase Lite's `PredictiveModel` interface . The implementation of  `predict` function of the `PredictiveModel` interface  invokes the coreML model

