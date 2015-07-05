# Noise Discrimination Software Github Repository

This is a *private* repository for Pelli Lab's project on noise discrimination. All files under this repository is **NOT** public, and will remain so until stated otherwise. 

# How to use

## Visible only for lab members (Register a Github account)

Register a Github account, and please contact hyiltiz@gmail.com providing your accound id asking for permisison to view this code base, and push your edits into the repository.

## Installing a git client

Install one of the clients in [this](http://git-scm.com/downloads/guis) list. All these are GUI clients. You could also install the vanilla `git` from [here](http://git-scm.com/downloads) which could only be used form the command line *if you prefer*. Note that most of the features of the command-line interface is also available from the GUI, and the GUI clients also *ships with the command-line* client. *SmartGit* and/or *Github for Mac/Windows* are strongly recommended. (I have personally used vanilla git as well as SmartGit). 

**In short**, install SmartGit from [here](http://www.syntevo.com/smartgit/).

## Clone the repository (from the client to your computer)

In your Git Client (preferably SmartGit or Github for Windows/Mac), click `Clone Repository`, and provide this `https` [](https://github.com/hyiltiz/NoiseDiscrimination.git) link of this repository (visible on the right of this webpage). You will be asked to login to your Github account, and then point your client to a local folder in your computer. This is where the code will be downloaded, and is your version of the repository.

## How to interact with the client

### How does it work

Just edit the code files as you normally would (e.g. from within MATLAB or your favourite editor). After you finish some of your edits, then you can `commit` your edits to your `local` repository. When you have an Internet access, you can then `Push` those `commits` to the Github repository so that it is updated with all your committed edits. In order to see others commits, `Pull` from the Github repository. 

**In short**, you only need to use *three buttons* on your GUI client:
 - Commit (during commit, you could enter some comments describing your edits, which could later be viewed from `Log`; during commit, you can also select which files changes should be committed; this is exactly the same as `Stage`)
 - Push (you can always commit your edits, even without Netwrok connection. When you are ready to update the Github repository with several of your commits, then click `Push`. After that, going back to re-edit your previous edits are very hard, since it is already published in the server).
 - Pull (use Pull to update your local repository in your computer using the Github repository; this can pull down other's pushed commits; this is what's normally called *updating*).

In addition to Commit/Push/Pull, `Log` feature could also be very useful.

