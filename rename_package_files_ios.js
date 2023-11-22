var fs = require('fs');
var args = process.argv.slice(2);
var old_app = args[0];
var new_app = args[1];
const currentDirectory = process.cwd();

//1) CHANGE PACKAGE ID
//2) CHANGE APP NAME
//3) CHANGE APP ICON/SPLASH
var doRenameFPackageFiles = async function () {    
    var packageRegExp = new RegExp("com.lfq.studies-" + old_app, "g");
    var capitalizedOldAppName = old_app.substring(0, 1).toUpperCase() + old_app.substring(1).toLowerCase() + " Cheatlists";    
    var capitalizedNewAppName = new_app.substring(0, 1).toUpperCase() + new_app.substring(1).toLowerCase() + " Cheatlists";
    var appNameRegExp = new RegExp(capitalizedOldAppName, "g");

    //RENAME APP IOS: Info.plist
    var plistText = await fs.readFileSync(currentDirectory + "/ios/Runner/Info.plist");
    plistText = String(plistText).replace(appNameRegExp, capitalizedNewAppName);
    await fs.writeFileSync(currentDirectory + "/ios/Runner/Info.plist", plistText, 'utf8');                    

    //RENAME PACKAGE IOS: 
    var iosProjText = await fs.readFileSync(currentDirectory + "/ios/Runner.xcodeproj/project.pbxproj");
    iosProjText = String(iosProjText).replace(packageRegExp, "com.lfq.studies-" + new_app);
    await fs.writeFileSync(currentDirectory + "/ios/Runner.xcodeproj/project.pbxproj", iosProjText, 'utf8');                    

}

doRenameFPackageFiles();