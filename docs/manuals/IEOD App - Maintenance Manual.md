# IEOD App - Maintenance Manual

<img src="https://www.dropbox.com/s/tiub7se1qxekdka/IconLauncher.png?raw=1" alt="IconLauncher" width=500 />







[TOC]



## Intro

**Important Note**: This manual is for to help future developers to maintain this project, but it still contains a lot of terms that are from the demining world. this manual is assuming you know these terms. Before reading this files make sure to read the following files:

* [Application Requirements Document](https://docs.google.com/document/d/16wmAvJLrtPDcjFIm4-CckbLBcD2r-sBiNd5kQaUfIVA/edit?usp=sharing)
* [Application Design Document](https://docs.google.com/document/d/1x-NG319cTTV7OzaAs06OufpNAinXaEnMzV2XrBh8wcg/edit?usp=sharing)



 This App was develop for IEOD , and It's main purpose it's to help manage all the data flow in de-mining projects by the company. for  The Main Features of the app are:

1. Fill the project reports, storing them for future reference and sharing them as files according to the company format.
2. Manage the strips that are being demined manually.
3. Manage employees in different projects.
4. Save and Share images that were taken in site.
5. Publish work and drive Schedules 

This App was first created by Shani Samson, Amir Stadler, Avi Buckman and Tomer Gonen as part of an Final Project in Software Engineering degree in Ben-Gurion University of the Negev. 

* This Project is Currently not Maintained!  if it is, (change this line)



## Technical Stuff

### Supporting Platforms

IEOD App is currently available only for Android devices. **However**, it is build for expansion to IOS and Web without much of a hassle.

### Dependencies and Versions

The entire source code is for the client side, which handles the app logic, and the communications for external services.

This Project is Currently written in Flutter (version 1.22.6) in the client side, and uses Firebase as the server side. All the dependencies of the project and their versions are described in the `pubspec.yaml` file. 

**Note:** All the dependencies are ready for upgrade to Flutter 2. To be able to deploy this project to the web it is a necessary step to upgrade all dependencies to flutter 2.



### Git Management

There are a lot of Branches in the repository, but only two of them really matters:

1. `develop` - Branch for developing and testing new features. In GitHub repository it is considered to be the main branch to push to (only after admin approval and code review). The code in this branch is configured to work with the development database.
2. `Versions` - Branch of the code that currently runs in **production**. The work assumptions is that the latest check point in this branch is the version that currently installed on the devices of the employees of IEOD. The code in this branch is configured to run with the production database.

### Prerequisites

1. You should install Flutter and android SDK according to the guide in the following links:
   * Windows: https://flutter.dev/docs/get-started/install/windows
   * Mac: https://flutter.dev/docs/get-started/install/macos
   * Linux: https://flutter.dev/docs/get-started/install/linux
   * Chrome OS: https://flutter.dev/docs/get-started/install/chromeos

2. If the project is still in Flutter 1, remember to use the command `flutter downgrade 1.22.6` and `y` what the `are you sure` question is up. after installation make sure that the command
    `flutter doctor`
    is working.

3. Ask from the man In charge of the app in IEOD to be added as a admin in the Firebase project to be able to look at the database,authentication , and storage state ( currently it's Yotam Paran from IEOD)

4. Clone project from the [Project site](https://github.com/yodatk/IEODApp)




### First Run

**Important Notice:** make sure your local git repository is on the `develop` branch , so you will not affect the App in production!

After cloning the project, you have two options for running the project: By emulator, or by physical device.

Either way, after the device is connected, you can run the app by running `flutter run` and see the app working on the device.

**Important Notice:**  Again, very important that you will do all the testing in the `develop` branch, so nothing will affect the production branch that is on the `Versions` branch.



## Components Overview



The Project is written in a 3-tier architecture, as presented in the following diagram

![Component Diagram](https://www.dropbox.com/s/9zeuj4vqh46tigb/Component%20Diagram.png?raw=1)

From this Diagram we can conclude the general design of the app:

*  There are 3 main external Services in the app :

  1. Data Service - For saving data online and sync it between all users of the app
  2. Storage Service - For uploading / downloading images (profile pictures, project images, field finding etc.)
  3. Authentication Service - For Registering / Logging in Users to the app.

  All of those services are going to be explained thoroughly in the Service Layer Chapter. currently all of those services are implemented by Firebase services.

  Also, there is a connection to the Collector app which is establish by link (navigate to the Collector app or to the play store if the app is not installed)

* There is one central component for logic layer, which will be detailed later.

* The Presentation layer is Separated by Use cases in the app, and each component contains all the Screens, widgets, and view models needed for running the app. (which will also be explained later.)

In this manual we will research each layer , describe it's main classes, and explain how they work. we will start from the service layer, and move "up" to the presentation layer

But first  - lets talk about the data object - entities in this project

## Models / Data Objects / Entities

In the following diagram we can see all the Entities in the project. all of those are saved and extracted from the database, and are the main source of data manipulation in the IEOD App.

![DataObjectsDiagram (2)](https://www.dropbox.com/s/bsn615jhftruduq/DataObjectsDiagram%20%282%29.png?raw=1)

**Notice:** each of the entities is extending the Entity class which contain:

1.  **Id** - id of the entity in the database(`String`)
2. **createdTime**  - Time the entity was created. Saved as time in milliseconds since Epoch in database (`DateTime`)
3. **modifiedTime** -  Time the entity was last modified. Saved as time in milliseconds since Epoch in database(`DateTime`)

important methods in the Entity class:

1. `Entity.fromJson(String id,)`

Let's explain each one of the the entities in the project:

### Employee 

Represents an Employee of IEOD.

#### Main Attributes 

* **name** - Name of the Employee (`String`)
* **phoneNumber** - Phone Number of the Employee
* **permission** - `Permission` Enum  that determines the actions the Employee can do in the app. the available Permissions are 
  * `ADMIN` - can edit all aspects in the app and have access to the Admin menu
  * `MANAGER` - can edit all aspects in the app **but** it cannot edit employees, plots, sites, and project. 
  * `REGULAR` - have access only to the daily info screen , with view permission only
* **email** - email of the employee used for authentication and for password reset if necessary
* **isHandWorker** - flag to define if the employee can demine manually or not (`bool`)
* **projects** - Set of `Project` ids which represents all the project this employee is in (`Set<String>`).
* **imageUrl** - url for the employee profile picture.  if it doesn't have a profile picture, it will be empty (`String`)



### Project

Represents a single project of demining  in IEOD.

#### Main Attributes

* **name** - Name of the project(`String`)

* **employer** -  `Comapany` Enum  for the company that runs the project. currently it's either `IMAG` or `IEOD`
* **projectManagerId** - Id of the Employee that is the manager of this project (`String`)
* **isActive** - Determines if the project is active and editable, or in-active, and cannot be edit(`bool`)
* **employees** - Set of Employees id's of employee ids that are participating in this project (`Set<String>`)
* **imageUrl** - url for the profile image of this project. if there is no image, the field will be empty or null



### Arrangement

There are two types of arrangements , both have same attributes. for easier Database management, they both have their own entities,  with the `ArrangementType` to differentiate between them (`WORK` for work schedule arrangement or `DRIVE` for drive arrangement)

#### Main Attributes

* **date** - Time of this arrangement(`DateTime`)
* **freeTextInfo** - The description  arrangement itself (`String`)
* **lastEditor** - last employee to edit this arrangement (`EmployeeForDocs`)

#### DriveArrangement 

Represents a Drive Arrangement  for a certain day in the project.  defined by the Enum of `ArrangementType.DRIVE`

#### WorkArrangement

Represents a work schedule for a certain day  in the project. defined by the   `ArrangementType.WORK`

### ImageFolder(or MapFolder)

Represents a folder of images that were taken from a certain day in the project.

#### Main Attributes

* **date** - Date of all the images that are in the folder (`DateTime`)
* **numberOfImages** - Number of images that are in the folder (`int`)



### ImageReference 

Represents a single image that were taken in a day of work at the project. notice that `ImageReference` is organized as a inner collection inside `ImageFolder`. 

#### Main Attributes

* **fullPath** - Full path of this image in the storage service (`String`)
* **imageUrl** - Downloadable url of the image(`String`)
* **lastEditor** - Last Employee to edit this image(`EmployeeForDocs`)

### Site

Represents the Largest Field Area where Machine Employees or Manual Employees are demining in multiple plots. IEOD is dividing the Field of the project by Sites to handle logistics of multiple plots together.

#### Main Attributes

* **name** - Name of this site

### Plot

Represents Large Field Area where Machine Employees or Manual Employees are demining. Usually there is either a Manual Demining or Mechanical, but not both.

#### Main Attributes

* **name** - Name of this site (`String`)
* **siteId** - Id of the containing Site (`String`)


### Strip

Represents a thin line of field for manual demining . 

#### StripJob

record of who is working in each one of the actions first, second, review(third) 

* **employeeId** - Id of the employee who have don the job (`String`)
* **employeeName** - Name of the employee who has done the job(`String`)
* **isDone** - indicator whether the job is done or not(`bool`)
* **lastModifiedDate** - last time the job was modified(`DateTime`)

#### Main Attributes

* **name** - Name of this site (`String`)
* **plotId** - Id of the containing Plot(`String`)
* **currentStatus** - the current status of the Strip. there are **7** possible valid statuses for the strip (`StripStatus`):
  * `NONE` - No employee stated working in this area. still dangerous to walk there.
  * `IN_FIRST` - There is an Employee which currently is working on this Strip
  * `FIRST_DONE` - Some Employee scanned that strip once. safer to walk in 
  * `IN_SECOND` - Some Employee is doing double check on the first employee job
  * `SECOND_DONE` - Double check is also done
  * `IN_REVIEW` - Employee with more experience is now sampling part of this strip
  * `DONE` - The Strip is done, and free of mines
* **first** - Record who and when someone did the first review of the strip, and whether it's done or not (`StripJob`)
* **second** - Record who and when someone did the second review of the strip, and whether it's done or not (`StripJob`)
* **third**  - Record who and when someone did the final review of the strip, and whether it's done or not (`StripJob`)
* **notes** - Any additional notes that needed to be recorded about the strip
* **mineCount** - Number of mines\targets found in the strip
* **depthTargetCount** - Number of target the the employees couldn't dig them selves and are counted for later



#### Important Methods 

`StripStatus updateStripStatus()`  - making sure the current `Strip` has a valid data. for example - it's not possible to declare that a strip is done, before all of it's strip jobs are done. or it's not possible to skip steps (create second stripJob before the first one etc.)



### Report

Represents a report that being written in the field for documentation. the report is part of the "Brick Wall" Pattern (that will be explained later) for creating interactive forms, that can easily be converted to pdf files, with reusable components (Bricks).

#### Main Attributes

* **name** - Name of the report(`String`)
* **template** - `Template` of the report , the report using the template to when it need to be used as a digital form, or when it's to be generated as PDF file using the `attributeValues` map to fill the blanks
* **attributeValues** - map of attribute key (which matches to a `TemplateBrick` in the `Template`) to the value to put in the attribute. 
* **creator** - The Employee that created this Report (`EmployeeForDocs`)
* **lastEditor** - Last Employee to Edit this Report(`EmployeeForDocs`)



### Template

Represents a type Of Report, and the way it should be built on screen and as PDF file. it is build using the `TemplateBrick`

#### Main Attributes

* **name** - Name of the report(`String`)
* **template** - `Template` of the report , the report using the template to when it need to be used as a digital form, or when it's to be generated as PDF file using the `attributeValues` map to fill the blanks
* **templateBricks** - List of TemplateBricks , which defines the way the report of this template are going to look like



**Notice**:  The relation of the report with it's template are going to be explained later in much detail







## Service Layer

As explained before, there are 3 main external services in the app. each one of them has a general interface, and an implementation with firebase services (currently) lets dive in :

<img src="https://www.dropbox.com/s/hnlj629d84d1zef/Class%20Diagram-Service%20and%20DAO%20focus.png?raw=1"  />

![image-20210606234824637](https://www.dropbox.com/s/gx93umdv7sxme8y/image-20210606234824637.png?raw=1)

### Data Service

In charge of saving and loading data from the database. 

The data of the IEOD app in a **Document based NoSQL** database. Each model in the the app has a `toJson()` and `fromJson(String id, Map<String,dynamic> data)` methods for saving and loading models from the database. also each of those models (will be explained later in the logic layer) has it's own DAO interface and implementation, Currently in Firebase Firestore.

There are 3 modes to the Data Service ,each of them connecting to a different branch of the database:

1. `Test` - Configured for running automatic tests of the app
2. `Development` -   Configured for running the app in while testing new features and debugging the app.
3. `Production` - Configured for running the app by IEOD Employees.

Important methods in the Data Service:
![image-20210607010716279](https://www.dropbox.com/s/r73d9n3k4v0g6yq/image-20210607010716279.png?raw=1)





In the Implementation with Firebase Firestore there are two major points to notice:

* `environment`- this variable determines if the data service is running in test modem development mode, or production mode. **TREAT IT WITH CARE**. 
  ![image-20210607012914244](https://www.dropbox.com/s/bobanajkj4xuycv/image-20210607012914244.png?raw=1)
* `DocumentReference getRoot()` - This function retrieve the right database branch from firestore according to the `enviorment` variable.
  ![image-20210607012929429](https://www.dropbox.com/s/zoipumd64e380yn/image-20210607012929429.png?raw=1)

The way the Database Branches looks in Firestore:

![image-20210607013021800](https://www.dropbox.com/s/y2h9k78qqazzefc/image-20210607013021800.png?raw=1)

Each of the branches (`Development`,`Test`,`Production`) contain the same document structure.

#### Database Modeling

<img src="https://www.dropbox.com/s/laq7enlmgg888sy/Document%20Based%20Database%20Modeling.png?raw=1" alt="Document Based Database Modeling"  />

There Are 3 base collections: Employees, Templates, and Projects. in each Project there are 7 sub collections: Sites,Plots,Strips,Reports,WorkArrangements,DriveArrangements and MapFolder. in the MapFolder(ImageFolder) there is another sub collection of ImageReferences. in a bullets diagram it looks like this:

* Employees
* Templates
* Projects
  * Sites
  * Plots
  * Strips
  * Reports
  * WorkArrangements 
  * DriveArrangements
  * MapFolders (ImageFolders)
    * ImageReferences

**The Logic behind the modeling:**    Employees and Templates can be shared across multiple projects. each of the sub collection inside a Project is Project specific(same plot can't be shared across multiple projects for example). each MapFolder (ImageFolder) contain collection of individual Images references.

Each of the models has its own DAO in the service layer. (except for the Report and Template which share the same DAO, and ImageFolders and ImageReferences are sharing the same DAO as well )

all of those DAO are extending the `EntityDAO` class  (as shown in the diagram in the beginning of this [section](#Service-Layer) ). in the EntityDAO class there are all the generic functions for  for extracting / writing / editing / deleting data in a certain document/collection. Most of the DAO's doesn't need more than those functions to operate successfully In the app. Entities that required more logic , or special queries, write those queries in the specific DAO of the entity (described in the Interface DAO , and implemented in the Implementation DAO (currently Firebase)  )

Each Firebase DAO is also In charge of converting the `DocumentSnapshot` that it gets from the Firestore server to  it's matching model by using the `fromJson` method. example:

![image-20210607024109319](https://www.dropbox.com/s/pi4zrf464osnve7/image-20210607024109319.png?raw=1)

#### Flexible Refactoring 

In an you want to use a different Data Service (let's say- MongoDB for example) the steps you need to do are the following:

0. Build same database modeling as it was in firestore in the new database provider, including the different environment branches

1. Create a new implementation for the Data Service interface using Mongo
2. Make sure there is a way to change the Database branch dynamically like the `enviorment` branch.
3. For each model, create an Implementation of it's DAO that uses mongo

#### Possible changes

##### Adding New Entity

If a new Model is introduced, to add it to the database you need to follow the following steps:

0. Add it smartly to the current database modeling.
1. Create a Model in the Models folder, and extends the new model with Entity class, and implements all the necessary methods, with emphasis on the `toJson` and `fromJson` methods.
2. Create an Interface in the `interfacesDAO` folder for the new Model, and write all the necessary methods. **Notice** that it is recommended to extend the Entity DAO for future flexibility.
3. Implement the interface for the Implementation of choice(currently firebase)
4. Connect the new model to the UI using the handler of your choice according to it's context in the app and its use cases. (the logic handlers) will be explained later



#### Important Notice - Offline Usage

One of the main reasons the current version is running Firestore is it's native support in offline mode - which is very important to the client. if you deside to move to another database supplier, **You should make sure that you support offline mode **





### Storage Service

The Storage Service in the app is mainly for uploading Images , and downloading images for :

1. Profile pictures of `Employee`
2. Profile pictures of `Project`
3. Daily Images (`ImagesReferences`)

Each one of those is implementing the interface of `WithImage`

![image-20210607174149567](https://www.dropbox.com/s/mqkcyp4wp63sfqm/image-20210607174149567.png?raw=1)

The point of this interface is to help generalize the procedure of uploading and downloading an image. 

The Storage Service Interface is pretty straight forward

![image-20210607174953626](https://www.dropbox.com/s/zjui3zlc7r9v3su/image-20210607174953626.png?raw=1)



The current Implementation is with Firebase Storage.

 **Notice** that the download time and upload time depends on the current network bandwidth, be mindful of that when using progress indicators



### Authentication Service

Used to Authenticate Users of the app . main uses cases:

1. Register new Employees
2. Login existing Employees

**Notice**: when deleting Employee from Firestore, there is a trigger that deletes it automatically the Employee from firebase Auth. 

 ![image-20210607181747483](https://www.dropbox.com/s/773qb0wxyi8mtum/image-20210607181747483.png?raw=1)

The Implementation currently with Firebase Auth. 

**Notice** - `sendResetPasswordLinkToEmail(String email)` will send an email only if it is exists in the system . Otherwise it will not send one.

## Logic Layer

The logic Layer is Composed from 5 main Handlers, and 1 class that initializing them all .as can be seen in the Diagram:

![Class Diagram - Logic Focus](https://www.dropbox.com/s/bczgmd7n5z6gslx/Class%20Diagram%20-%20Logic%20Focus.png?raw=1)

![image-20210607233437240](https://www.dropbox.com/s/8o9paqygpswp8bo/image-20210607233437240.png?raw=1)

###  Word On StateNotifiers

State Notifiers is a Direct Link of communication which notifies all the relevant listeners on a change in a certain Entity or value.

any change in model data in the data base, get pushed to the the notifier, and then the notifier alert all it's listeners to the current change.

It works in a similar way to an Observer pattern.

We used this feature with the [rivepod](https://pub.dev/packages/riverpod) library to  make an responsive realtime UI

some of the Logic handlers are responsible on those state notifiers.



### Stream Vs Futures and Data Extracting

all of the Handlers are using data that is extracted from the service layer. but there is an important distinction between data that is imported as Future and the data that is imported as Stream :

* Future are good for tasks that require one time extract of data, without sync, and without live update.
* Streams are good for situation when you want to get updated as fast as possible (since there communication with the data base remains open)

**Important Notice** - Streams does sound better, but they require disposal (where future are self disposed since they don't have a live connection to the database). when using streams, make sure you are disposing thier controllers in the end of their use (stuff that happens automatically when using Stream Provider by [riverpod](https://pub.dev/packages/riverpod))



### EmployeeHandler 

In Charge Of all Functions of Employees data Manipulation. it's also in charge of registering users(using auth & data services) , logging in users(Auth service), extracting specific users data, etc.

#### Needed Services

* Auth Service - For Registering users and logging in Users to the App 
* EmployeeDAO
* Storage Service - To save Profile images of users

#### State notifiers

##### CurrentEmployeeController

In charge of saving the data of the current employee that is logged in to the app. it is changed 

this notifier is used **a lot** since each screen in the app has it's own permission settings, and it uses this controller (via [riverpod](https://pub.dev/packages/riverpod)) to determines if to show certain screen \ ui element or not to a certain user.



### FieldHandler

In Charge of all Functions of Sites,Plots and Strips data manipulation. 

#### Needed Services

* StripDAO 
* PlotDAO
* SiteDAO

#### State Notifiers

The notifiers in the Field Handler is Used Mainly to automate the report filling . The notifiers are:

##### currentPlotController

In charge of the plot the user currently navigated to.

##### currentSiteController

In charge of the Site the user currently navigated to.

### ReportHandler

In charge of Reports and Templates models. updating reports, or get the metching template version for a certain report  is with this Logic Handler

later in this manual, the process of the creating report and template will be further explained

### DailyInfoHandler

In charge of all functions of WorkArrangements, DriveArrangements, and ImageFolders.

#### Needed Services

- WorkArrangementDAO
- DriveArrangementDAO
- ImageFolderDAO
- Storage Service - For uploading images to Image Folder



### ProjectHandler

In Charge of Projects data manipulation.

#### State Notifiers

**currentProjectController** - to determine which project the user is currently in.  if null , it means the user is currently did not choose a current project.

when it's not null, it is used to extract the mtaching data of the project the user is currently in.

for example , if you have two project p1, p2.  when user choose p1 as the project, the app will extract only the plots, site, report etc.  - that are relevant to project p1. 

also - if an Employee is being added \ removed from a certain project, the current Project Controller is in charge to notify the UI to "Kick out" the current user back to the main menu 



### Initializer

In charge of initializing all the other Handlers: their external services, and DAO if necessary. it's the closest we have for dependency injection.

#### Important Methods

`InitializeImages(BuildContext context)` - loads all static images in the app to cache for future use. 

`init(BuildContext context)` - initializing all handlers, loading all images, and specifically for firebase services - it is initializing the firebase core - which is necessary for all of the services needed by firebase. 



### Offline Support

The App support offline mode, currently using the native Firestore build in cache capabilities.

to be capable on working in areas with low cellular reception, once a User selects a Project to work in, the handlers are pre-loading all relevant data of the project . This is for the case the phone loses it's reception,  the employee could still work with the data that has been gathered so far.

![image-20210608130411686](https://www.dropbox.com/s/5ou9pjqm21qoy65/image-20210608130411686.png?raw=1)

## Presentation Layer

![MenuTree1st- updated](https://www.dropbox.com/s/dtylsiip2397yef/MenuTree1st-%20updated.png?raw=1)



Presentation Layer is Separated into 5 Main Sections, and 1 general section. we will explain the way we structure the UI , and the way we connect the UI to the logic layer.



### Widgets 

![image-20210608101913577](https://www.dropbox.com/s/ais7t3lez7xfhq2/image-20210608101913577.png?raw=1)

There are 3 Important familiy widgets:

#### Permission Widgets

Wrappers for other visible widgets, wich shows them only if the current User has the right permission, and\or the current user belong to the current project. there are three main permission widgets:

1. `PermissionWidget({@required this.permissionLevel,@required this.withPermission,this.withoutPermission,})`  - Shows the Widget with `withPermission` only if the user from `currentEmployeeController`  has a permission that is at least as high as `permissionLevel`. if `withoutPermission`was given, it will show it otherwise. if it was not given, it will shows nothing.
2. `PermissionScreen({@required this.permissionLevel, @required this.title,@required this.body,this.withProject = true,})` -
   same as `PermissionWidget`, wrap the `withPermission ` with scaffold. `withProject` is a flag that determines if also checks the employee is belonging to the current project. default is True.
3. `PermissionScreenWithAppBar` - same as `PermissionScreen` , but which also have AppBar

**Notice** - The use of the Permission widget should be according to the permissions that each Employee should have in a given screen in the app. it's details in the requirement 

#### Navigation Widgets

Widgets for navigation in the app :

1. AppDrawer - Drawer that is added to all Possible Screens and allows navigation to main menu, admin menu, loggin out etc.
2. NavigationRow - Default Button in menu screens.



#### Other Useful Widgets

##### ImagePickerAndShower

`ImagePickerAndShower` widget to use to take image from camera or gallary when it's needed. currently it is in Daily images ,Employee forms ad Project forms.

There are more Widgets, but most of them self explanatory 



### Screens

![image-20210608102115888](https://www.dropbox.com/s/1v4c3h6syo0wooc/image-20210608102115888.png?raw=1)

The screens are orginized by menus and thier subject:

1. Daily Info

   ![image-20210608103904412](https://www.dropbox.com/s/jhtg3nm9wmthu69/image-20210608103904412.png?raw=1)

2. Employee Management

   ![image-20210608104020438](https://www.dropbox.com/s/54tyvg7yr2pycja/image-20210608104020438.png?raw=1)

3. login - login screen

   

4. manage sites and Plots

   ![image-20210608104041176](https://www.dropbox.com/s/6ir0ru3b8mncv7f/image-20210608104041176.png?raw=1)

5. Project menu screens -

   ![image-20210608104351213](https://www.dropbox.com/s/usquwgeui9qms64/image-20210608104351213.png?raw=1)

6. General Screens

   ![image-20210608104418473](https://www.dropbox.com/s/3fv74s99yz1s8wa/image-20210608104418473.png?raw=1)

#### View Model

Each screen that have a ui logic to it (all screen except ones that are for navigation only ) is organized in the following way: 

![image-20210608105322389](https://www.dropbox.com/s/099afckc926p5ko/image-20210608105322389.png?raw=1)

##### Screen Folder 



###### Controllers 

=Folder for the view model class of the screen, it's needed providers, and supporting files.

###### Widgets

All the needed widgets for **for that specific screen** (for general widget, use the general widgets folders in the main lib folder.)

The View Model Class in each screen folder is the class that handles all the ui logic (loading indicators switch, visual logic and so on) and also connects the screen with the logic layer for data related request (list of data, data manipulation and so on.)



##### ScreenUtils  

Main field in Each  View Model class . it's in charge of scaffold context control (mainly for pop up dialogs or snackbars), loading indicators controllers, and so on. there are two types of Screen Controllers:

###### ScreenUtils(Regular)

For generic screen utils, and loading controlls

###### ScreenUtilsControllerForList

Same as ScreenUtils, with Generics (gets type T) which helps for searching  and show messages on delete, add, edit on screen.

##### Use Of View Model in Screen

we connect the UI with it's matching VIewModel with the Riverpod hooks method :

Definition of the provider:

![image-20210608110852498](https://www.dropbox.com/s/u2su9gou1k6ak9a/image-20210608110852498.png?raw=1)



Usage of the provider using hooks:

![image-20210608110751200](https://www.dropbox.com/s/33ygflb08vqtv7e/image-20210608110751200.png?raw=1)

Calling a function from View Model form an inner widget

![image-20210608111403908](https://www.dropbox.com/s/3m0xqkdvbk8ikir/image-20210608111403908.png?raw=1)

The View Model usage with RiverPod Hooks allows us to data transfer and function flow without passing it to the inner widgets.  this reduces **A LOT** of clutter  and mess around the code. it also helps as manage widget context more easily.

##### AsyncValue

another use of the View Model is to get data from the logic layer. sometimes this data takes time to get fully. in those time, we use the StreamProvider or FutureProvider to help us showing some loading indicator until the data arrives. the result of those providers is **AsyncValue**, and it have 3 modes, each one of those requires different handling function

1. **data** - When data arrives. need a function  that get data of required data (T) and returns a Widget(List or somthing like that)
2. **loading**- When data did not arrive yet. need a function that gets no parameters, and returns a Widget(Progress indicator of some kind)
3. **error** - When data failed to load. needs a function that gets the exception, and the stacktrace, and returns a Widget

you can resolve each one of the scenarios using `when` function:

![image-20210608112834245](https://www.dropbox.com/s/0hxuhyzw25c9ur5/image-20210608112834245.png?raw=1)

![image-20210608112938413](https://www.dropbox.com/s/rb76d36tqa5rsa4/image-20210608112938413.png?raw=1)

**We encourage all future developer to embrace the same pattern to keep thing organized an unified around the app**



### Main Widget Flow

when the app runs, it starts with this widget: 

![image-20210608113216397](https://www.dropbox.com/s/9zj2ug5e5ibyowe/image-20210608113216397.png?raw=1)

We can see two Things:

1. This widget contains all the Routes to navigate to . IEOD APP uses routes navigation. **Make sure that each screen that you need to add, is added to the routes dictionary as well.** to keep things simple, each screen (widget that contains scaffold) has static constant RouteName in its class.

2. The home page is routing in it's default to the `AppWidget`:

   ![image-20210608113745627](https://www.dropbox.com/s/85710dix578z1jw/image-20210608113745627.png?raw=1)

   This widget is activating an initialization chain: it's using a `FutureProvider`, that calls the `init` method of the Initializer.

   after the process is done, it's  moving on to state check:

   ![image-20210608114021159](https://www.dropbox.com/s/tn45wtiaovliyf2/image-20210608114021159.png?raw=1)

   The app checks if there is a user connected to the app. if not, it shows the login Page.(using the is connected by the Auth Service)

   otherwise - it will check for project state:

   ![image-20210608114326133](https://www.dropbox.com/s/k38tnd84ceuu7go/image-20210608114326133.png?raw=1)

   Pretty large widget! let's look at the documentation

   ![image-20210608114406289](https://www.dropbox.com/s/09uagw3fq60zlp4/image-20210608114406289.png?raw=1)

   as we can see, this widget is using multiple providers:

   1. first of all, it checks if there is a "last project" that the user visited. if so, it will try to open it.
   2. otherwise, it will see if the user have single or multiple project:
      * If it has multiple project, it will show the choose project widget so the user could choose.
      * If it has only one active project, it will automatically connect the user to it
   3. If the user does not have any project, it will show him a message that there are no project available right now.

   This work flow is working in the back ground after the first login it will open the Project menu screen of the last project (as the user would expect). It uses the CurrentUserController and CurrentProjectController to do that.







### "Brick Wall" Pattern

![Template_Brick_Design (1)](https://www.dropbox.com/s/ibencjfejlve2g2/Template_Brick_Design.png?raw=1)



This is one of the most important mechanism in the app. It's in charge of building multiple report type, versions of each report type, and do it in dynamically, with reusable components.



#### Current Templates

1. Mechanical Report
2. Quality Control Mechanical Report
3. Quality Control Manual Report
4. Bunkers Clearance Report
5. Deep Targets Report
6. Emergency Practice Report
7. Daily Clearance Report
8. Manual Report * - This type of Report is not using the pattern, only it's `PDFBuilder` since it's forms are handled differently

#### Current Bricks

![image-20210608120106263](https://www.dropbox.com/s/k700mzxwjuxgz9a/image-20210608120106263.png?raw=1)

#### Template Building

There are example of Templates in the `constants/ExampleTemplates.dart` file. the templates over there are also the current status of the templates in production branch. 

![image-20210608122127645](https://www.dropbox.com/s/7fccumgvvf1quod/image-20210608122127645.png?raw=1)

as you can see, the building of a templates is fairly easy task. notice the the `templateBricks` field behaves as a Column - each brick will be places on below the other.

We encourage you to look over each bricks and see all the customizable options they offer

#### Function Resolver

For The `ReadOnlyTextBrick` and for the `FunctionDropDownBrick` , the data is not entered by typing of the user, it tries to auto-fill the brick with the right value \ relevant options.  It does that using the Function Resolver.

It has two Options : Resolve by Entity, or resolve by list of entities. from it, it takes the relevant field, and display it / them in the report immediately. 

It uses `enum` to map the data to the relevant brick: `SingleResolvedEntityEnum` for single value , `ResolvedEntityListEnum` for multiple values.



![image-20210608121718856](https://www.dropbox.com/s/el1gewn85z7byio/image-20210608121718856.png?raw=1)

The functions themselves are from the logic layer from the relevant handler:

![image-20210608122843495](https://www.dropbox.com/s/vxz0zo789xxe3ns/image-20210608122843495.png?raw=1)

If you want to another option, all you need to do is create another enum to point is, and add it to the map in the constructor.

#### Builders

##### TemplateFormBuilder 

Interface for the form builder part of the "Brick Wall" pattern. Each implementation need to support converting all the bricks that described in this class to Flutter Widget

##### WidgetFormBuilder

Current implementation of `TemplateFormBuilder` it uses the the [flutter_form_builder](https://pub.dev/packages/flutter_form_builder) library to build to matching widget.



##### OutputBuilder

Interface for the output file part of the "Brick Wall" pattern. Each Implementation needs to support converting all the bricks that described here, to output in the output file of chosen format

###### PDFBuilder 

Current Implementation of `OutputBuilder` , converting report to a PDF file, using the [pdf](https://pub.dev/packages/pdf) library .

**Notice** - the library does not support Hebrew yet, there is a lot of wrappers in the `PDFBuilder ` to make it work. mainly the methods `hebrewLineDecorator` and `paragraphHandler` . use that class carefully. 

##### Adding new Brick Type

1. Build the brick according to the TemplateBrick interface(which include the AcceptOutputBuilders and AcceptFormBuilders)
2. Implement `build<BRICK_NAME>Brick` method in all relevant `FormBuilders`, and `OutputBuilders`

##### Adding new output format

1. Build a New Builder that implement all  methods in the `OutputBuilder`
2. Switch the Builder in the Report screens to the new one created.



#### Templates Versioning

We added version control to each template type, using the database:

![image-20210608125505172](https://www.dropbox.com/s/8fhbnjc38beyy3i/image-20210608125505172.png?raw=1)

each template collection, contains a field called :`Latest` which contains the id of the latest version of a certain template.

**This way -** **You can change the way the report will look, without breaking older reports in migration**





#### Templates - Report Cycle : Create New Report 

1. The user ask to create a new report of Template `x`
2. `ReportHandler` asks from the Database the latest version of that Template according to the `Latest` field in the collection.
3. The new `Report` is created with the Template that was extracted
4. WidgetFormBuilder is converting the report and template to a UI Form.

#### Templates - Report Cycle : Edit Existing Report 

1. The user ask to create an existing `Report`, which contains its template version
2. WidgetFormBuilder is converting the report and template to a UI Form.



##### Mapping each `TemplateType` to it's `BuildTemplate` Method

Taken from `ExampleTemplates.dart`

![image-20210608131331205](https://www.dropbox.com/s/kfvgw2pimzdut8f/image-20210608131331205.png?raw=1)

#### How to Add New Template

1. **Adding new Type of Template**
   1. Add a new Template type enum for that temaplate.
   2. In `ExampleTemplates.dart`  add a`build<NEW_TEMPLATE_NAME>Template` function, which returns a Template object in the way the you want it to look.
   3. add the enum : function mapping to the `templateToFunctionMap` 
   4. add Button to navigate to Specific Report screen with that type
2. **New Version of Existing Template**
   1. Override the current build template function in `ExampleTemplates.dart`
   2. Go to firestore, go to the Collection of `Templates/<TEMPLATE_NAME>/All <TEMPLATE_NAME>` and delete the current Latest field.







## Tests

Currently, there are 3 types of tests:

### Unit Tests


Checking mainly the Entities logic.

you can run those tests with `flutter test` from the root folder of the test.

### Logic Tests

Checking all logic in the logic layers, and connectivity to the database. 

Each Test class is implementing the following interface: 

![image-20210608132558961](https://www.dropbox.com/s/9lukhkuc0nb3n9q/image-20210608132558961.png?raw=1)

Main objective of this class is to make sure that the database is on test mode before running it.

The logic tests is separated into multiple classes according to their subject of testing:

![image-20210608132724094](https://www.dropbox.com/s/37zl5l2auvn66cl/image-20210608132724094.png?raw=1)

All of the tests can be found in the `all_logic_tests.dart` file , and you can run them by the following command : 

`flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/LogicTests/all_logic_tests.dart --dart-define='password=<ENTER PASSWORD>'`

Where the password should be the password of the admin in the tests.

**Notice:** you need to activate an emulator for those tests. also - you need to uninstall the current app in the device you running the test on before running them

### UI Tests

Checks all the features in the app from the user perspective.  each tests suite is implementing the same Integration Test Class as the logic tests.

and here they are also separated by subject of testing.

![image-20210608133045992](https://www.dropbox.com/s/nk5oili7r3473ex/image-20210608133045992.png?raw=1)

`flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/UITests/all_ui_tests.dart --dart-define='password=<ENTER PASSWORD>'`







**Notice:** you need to activate an emulator for those tests. also - you need to uninstall the current app in the device you running the test on before running them

The UI test can take between 7-8 minutes.



### QA Tests

are described in the following [link](https://docs.google.com/spreadsheets/d/1WL9d4YpgQ3diZOBnuIzM3g8JcBAqsDfqY0Fke4dZfAQ/edit#gid=0)



## Deployment

**MAKE SURE YOU RUN THE TESTS FIRST, AND TEST THE APP  THOROUGHLY**

After you finish testing the current version, merge the new features with the `Versions` branch in git. 

**Make sure that in the `Versions` branch, the database is on production ENV**

### Android

Write the following lines (one after the other)

1. `flutter clean`
2. `flutter build apk --debug`
3. `flutter build apk --profile`
4. `flutter build apk --release`

The release APK file will be in the following path:

`build/app/flutter-apk/app-release.apk`;

and be ready to install.

:)



## Further Documentation

1. Dart documentation - [download](https://github.com/yodatk/IEODApp/blob/develop/docs/IEODApp_code_documentation.zip) from the repository, extract, and open the `index.html` file.
2. Google Drive with ARD,ADD, and Diagrams can be found in this [link](https://drive.google.com/drive/folders/1ucV3NPX7HiBsK60tQEh2uaS6tqeahMix?usp=sharing).



## Contributors

Shani Samson

Avi Buckman

Amir Stadler

Tomer Gonen



[TOC]

![IEOD_LOGO](https://www.dropbox.com/s/gnett6z0ufvmtkl/IEOD_LOGO.jpeg?raw=1)
