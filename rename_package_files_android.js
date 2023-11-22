var fs = require('fs');
var args = process.argv.slice(2);
var old_app = args[0];
var new_app = args[1];
const currentDirectory = process.cwd();

//1) CHANGE PACKAGE ID
//2) CHANGE APP NAME
//3) CHANGE APP ICON/SPLASH
var doRenameFPackageFiles = async function () {    
    var packageRegExp = new RegExp("studies_" + old_app, "g");
    var capitalizedOldAppName = old_app.substring(0, 1).toUpperCase() + old_app.substring(1).toLowerCase() + " Cheatlists";    
    var capitalizedNewAppName = new_app.substring(0, 1).toUpperCase() + new_app.substring(1).toLowerCase() + " Cheatlists";
    var appNameRegExp = new RegExp(capitalizedOldAppName, "g");


    //RENAME PACKAGE ANDROID: build.gradle
    var BuildGradleText = await fs.readFileSync(currentDirectory + "/android/app/build.gradle");
    BuildGradleText = String(BuildGradleText).replace(packageRegExp, "studies_" + new_app);
    await fs.writeFileSync(currentDirectory + "/android/app/build.gradle", BuildGradleText, 'utf8');                


}

doRenameFPackageFiles();