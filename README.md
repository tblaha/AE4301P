## Git introduction
- Git is a versioning management tool, written originally for the 
Linux kernel by the original developer of Linux.
- Github.com is the most popular hosting site for git **repositories**.

### Basic functioning of git:
- **everyone always has the complete version history** on his local machine in a folder called the "working directory (**wd**)"
    - this is called the **repository**
- incremental updates made by you in the wd can be packaged as a "**commit**"
    - a commit is a discrete update ontop of a previous commit
    - commits are uniquely identified by a long hash (or the first 7 characters of it)
    - generally, commits are immutable; once changes have been packaged, the cannot be un-packaged
    - it is possible to revert a commit by reversing the incremental changes in a new commit
    - For instance, here, I reverted commit 5b5fba3 and then reverted its revertion
```
2bb0626 Revert "Revert "added installation instructions for gurobipy""
bd6f7b1 Revert "added installation instructions for gurobipy"
5b5fba3 added installation instructions for gurobipy
a15b71d Initial Commit
```
- new commits made by you must be **pushed** to Github, for others to see them
    - this has to happen manually
- newer commits from others must be **pulled** from Github, for you to see them
    - this has to happen manually and before any attempt at **pushing**
- if there are new commits on github that was pushed there in the meantime:
    - you have to first **merge** those commits with your local one into a third commit that sits ontop of both
    - this **merging** is trivial if the two **parent** commits modified different files only
        - all changes are kept then of course
    - if the same file was modified in both parents, the you have to decide which lines to use from which version
        - this has to be done with care to avoid reverting changes by someone else

The repository can be made up of completely independend branches that can be 
merged with each other to form new branches or to add a new feature from say
a "development" into "full-application" branch. The "master" branch (at some 
point to be renamed "main" to avoid slavery connotations...) is the default
branch in github and it should contain the full application/project but not be
used directly; only through merges from other branches to avoid everyone 
working on the full project at the same time. In theory...

        
## Workflow of git in MATLAB Project:
Matlab/SL has a version management feature called "Project" and it interfaces
with git, nice!


### Preparation of Matlab/Simulink for this project

Install the following toolboxes from the "Get add-on"-explorer or from
re-running the matlab installer.
- Simulink
- Robust Control Toolbox               
- Control System Toolbox                           
- Optimization Toolbox
- C-Compiler for Windows: Search Add-on explorer for "MinGW-w64" and follow instructions


### Clone Repository

1. Install "commandline git" for Windows
    1. https://gitforwindows.org/    Download installer and run it.
    2. In the section on adjusting your PATH, choose the install option to <<Use Git from the Windows Command Prompt>>. This option adds Git to your PATH variable, so that MATLAB can communicate with Git.
    3. In the section on configuring the line-ending conversions, choose the option <<Checkout as-is, commit as-is>> to avoid converting any line endings in files.
2. Accept my invitation to the github repository AE4301P
3. Clone the repository: Home tab > New > Project > From Git
    1. Repository Path: https://github.com/tblaha/AE4301P.git
    2. Sandbox: [as you like it, but must be empty folder]
    3. Click "retrieve" and enter github credentials
    4. "Project" window or dock (https://www.mathworks.com/help/examples/matlab/win64/exampleproject.png) should open and some stuff should happen, like mex compilation
    5. Close the "project" window/dock

### Opening the Project
1. Everytime, before you start working, double-click on AE4301P.prj
    1. This runs "setup.m", which configures path, checks for mex file and more in the future.

### The Project window/dock
1. Keep it open at all times! And keep it in the "All" tab!
2. Forget about the "current folder" dock of MATLAB. All file operations 
(opening, new files, renaming, moving, deleting, etc) must happen through the Project window.
3. It shows 2 important file attributes
    1. Whether it is managed and tracked by Projects and Git ("Status" column)
    2. What is its status, has it been changed/added/deleted... ("Git" column)
4. **All items you add must have the green tick in the "Status" column**

### Using git
1. **Whenever you do anything with git (even just switching branches), first commit your work and make sure you have 0 modified files**
    1. This is referred to as a "clean" working directory (wd)
2. **Commit** the changes you made
    1. Click Commit
    2. Enter a short descriptive message of your changes; click submit
3. **Pull** new changes from the Github
    1. Commit your work
    2. Click on **Pull** and enter your github credentials
    3. If there were new commits, they should now be merged into your local wd
        1. if there are conflicting lines in files, fix them. 
    4. Check what happened by clicking on "Branches"
4. **Push** changes
    1. Commit your work.
    2. Pull from github to make sure you are up to date. Resolve any conflicts
    3. Click on **Push**
5. Switch **branch**
    1. Click "Branches"
    2. Select new branch, for instance "[...]/lin"
    3. Click switch and confirm:
        1. your local wd will now contain whatever is in the new branch
    4. This branch window also shows you a brief commit history
    
    
### Summary

It may look intimidating, but remember the following well:

If you follow the 2 **bold face** rules above, you will never lose any changes
for real, they may just be a bit of work to dig up.

