CALL SET "old_app=%1"
CALL SET "new_app=%2"
CALL ECHO "old_app: %old_app%, new_app: %new_app%"
CALL ECHO "Creating new lib/cheatlist_data..."
CALL rmdir /s /q .\lib\cheatlist_data
CALL mkdir .\lib\cheatlist_data
CALL ECHO "COPYING TO lib/cheatlist_data..."
CALL xcopy /Y /s /q .\env_vars\%new_app%_data\data .\lib\cheatlist_data\data
CALL COPY /Y .\env_vars\%new_app%_data\data.js .\lib\cheatlist_data\data.js
CALL COPY /Y .\env_vars\%new_app%_data\info.js .\lib\cheatlist_data\info.js
CALL ECHO "COPYING TO \assets\images..."
CALL rmdir /s /q .\assets\images
CALL xcopy /Y /s /q .\env_vars\%new_app%_data\images .\assets\images
CALL ECHO "COPYING .\env_vars\%new_app%_data\%new_app%_pubspec.yaml TO .\pubspec.yaml..."
CALL COPY /Y .\env_vars\%new_app%_data\%new_app%_pubspec.yaml .\pubspec.yaml
CALL ECHO "COPYING .\env_vars\%new_app%_data\%new_app%_AndroidManifest.xml TO .\android\app\src\main.AndroidManifest.xml..."
CALL COPY /Y .\env_vars\%new_app%_data\%new_app%__AndroidManifest.xml .\android\app\src\main.AndroidManifest.xml

CALL node rename_package_files.js %old_app% %new_app%

CALL ECHO "COPYING APP ICONS..."
CALL xcopy /Y /s /q .\env_vars\%new_app%_data\icons\android .\android\app\src\main\res

CALL flutter pub run flutter_native_splash:create


CALL flutter clean