### English
This project implements a JS editor and transform it into a Lua editor, which allows developers to write and execute scripts from within the Garry's Mod game.
Not all files are shown, because this project needs lots of base game files (from Garry's Mod) and also needs some other files from my team (wich are private)

What does it do:
lua_editor.lua: A web page is shown (from our team's web server), and this script transform it to allow Lua script editing.
lua_editor_panels.lua: This is the (V)GUI part. It communicate with the lua editor to manage files sessions and saves the opened files, and their order.

### Français
Ce projet implémente un éditeur JavaScript (Ace Editor) et le transforme en éditeur Lua, ce qui permet d'écrire et d'éxecuter des scripts depuis le jeu Garry's Mod.
Tous les fichiers ne sont pas inclus car ce project necessite beaucoup de fichiers de base du jeu (Garry's Mod) et de fichiers privé provenant de ma team (ils sont privé).

Que fait ce projet:
lua_editor.lua: Une page web est affiché (provenant du serveur de notre team, remplacable), et ce script permet d'y éxecuter du code lua.
lua_editor_panels.lua: C'est la partie (V)GUI. Ca permet de gérer plusieurs séssions de code et de sauvegarder les fichiers ouvert, et leur ordre.


### Preview / Apperçu

![Preview/Appercu](https://i.imgur.com/R5XaA0u.png)
Surrounded in red: lua_editor.lua, the interactive web page that allows to code in Lua from within the game.
Surrounded in blue: lua_editor_panels.lua, the tabs that allows to manage (create, change order, delete) the files sessions.

Entouré en rouge: lua_editor.lua, la page web intéractive qui permet de coder et d'éxecuter du Lua dans le jeu.
Entouré en bleu: lua_editor_panels.lua, les tabs qui permettent de gérer (créer, changer l'order, supprimer) les séssions (fichiers).