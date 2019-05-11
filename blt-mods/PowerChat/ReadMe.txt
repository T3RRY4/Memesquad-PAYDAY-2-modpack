PowerChat allows you to use ingame chat as a
command-line-like interface.
This short guide will give you an idea of how to use it.


COMMAND STRUCTURE

The command structure is:
    !command -opt1 -opt2 arg1 arg2
    
-The exclamation mark indicates that this is a
 command and not a chat message.
-There can be any number of options and arguments.
-Options modify the command's settings or the way it will work.
-Arguments are data to work with.

example:
    This prints into chat the amount of playtime of
    every player in the lobby:
    !hours -all
    
    And this only prints hours of the player with
    'andole' in the name:
    !hours andole

    
STANDARD COMMANDS

Utils
    CLEAR - clears the chat
    !clear

    HELP - prints a short description of given command(s).
    !help hours

    LIST - lists available commands.
    !list
    -You can use a pattern to filter the output:
    !list h*
    -This will print the commands that start with 'h'.
     The '*' symbol stands for any text.
    
    REPEAT - resends the previous chat message or command.
    !rep
     This resends the last chat message you sent.
    !crep
     This resends the last command.
    
    TO ALL - prints the last PowerChat message you received
    to everyone in the lobby
    !toall

    EVERY - sends given message every X seconds
    !every -10 annoyed yet?
     send 'annoyed yet?' message every 10 seconds
    !every -60 !bash
     send '!bash' command every 60 seconds
    -Use 'every-stop' to stop given messages
     !every-stop -10
      stop all of the messages sent every 10 seconds
     !every-stop bash
      stop all of the messages that contain 'bash'
     !every-stop -60 bash
      stop all sent every 60 seconds containing 'bash'
    -Use '-all' option to stop all of the messages
     !every-stop -all
    -Use 'every-delay' to send a message once after the time passes.
     !every-delay -10 10 seconds passed.

    HOOK - sends given message after a given function is called
    !hook -PlayerBleedOut:_enter I'm down
     send 'I'm down' every time PlayerBleedOut:_enter is called
    !hook -EnemyManager:on_enemy_died !count enemies
     send '!count enemies' when EnemyManager:on_enemy_died is called
    -Use 'unhook' to stop it
     !unhook -PlayerBleedOut:_enter
      stop any messages sent on PlayerBleedOut:_enter
     !unhook I'm down
      stop any messages containing 'I'm down'
     !unhook -PlayerBleedOut:_enter I'm down
      stop any containing 'I'm down' sent on PlayerBleedOut:_enter

    EVENT - sends given message after a given event happens
     this command is an easier interface for 'hook' command
    !event -EnemyDied !count enemies
     send '!count enemies' every time an enemy dies
    !event -CameraInteract Camera looped
     send 'Camera looped' every time you loop a camera
    -Use 'event-stop' to stop messages
     !event-stop -Tased
      stop any messages sent when you get tased
     !event-stop Camera
      stop any messages that contain 'Camera'
     !event-stop -CameraInteract Camera looped
      stop messages containing 'Camera looped' and sent
       after you interact with a camera
    -Use '-list' option to see available events
     !event -list

    EXEC - executes a file with commands
    !exec commands.txt
     The file must be located in 'saves' folder.
    

Game
    FPS - caps frames per second rate at a given value
    !fps 60
    
    COUNT - counts objects
    !count enemies
    !count persons
    -It can count the total amount of medic bag charges, 
     amount of ammo in all ammobags or body bag cases:
    !count meds
    -List of common arguments:
     pickups enemies persons all civilians 
     all_criminals meds ammo bodybags bags
    
    BIG OIL CALCULATOR - tells you which engine matches your intel
    !boc he 3 <
    !boc d2h
    -The second one is short form ('l' for 'lower' pressure,
	 'h' for 'higher').
    -For long form arguments are he, ni, de, 1, 2, 3, <, >.
    -You can use the command multiple times, adding pieces of
     intel one by one. Once there are all 3 pieces,
     you will receive a message about which engine is correct.
     
     PRIVATE MESSAGE - Sends private message to given player(s)
     !pm -andole
      add players with 'andole' in the name to the list of
      recipients
     !pm hello
      send 'hello' to every player in the recipients list
     !pm-clear
      clears the recipients list
    
Tools
    HOURS - shows playtime of given player(s)
    !hours -all
    !hours andole
     You can use incomplete player's name. It will find him.
    !hours -2
     Shows playtime of player #2 (1-host, 2-blue , 3-red, 4-orange).
    
    SKILLS - shows skills and perk deck of given player(s)
    !skills -all
    !skills andole
    !skills -2
    
    DICTIONARY - translates words using Multitran.com
    options:
        -(l1)-(l2) 
         changes languages for 1 translation
        -set 
         used after the previous one, switches
          the command to those languages
        -lang 
         prints current languages
        -(num) 
         sets the number of translations for each word
    examples:
        dict -ru-en -set 
         sets current language pair to ru-en
        dict -en-ru house 
         transtales 'house' into russian, lang pair stays unchanged
        dict house
         this will translate 'house' from and into
          languages of the current lang pair
        dict -r 
         reverses the lang pair and sets it as current
    -Usually, you will only need to set the lang pair and then
     simply use '!dict word'
     
    WIKIPEDIA - searches Wikipedia for given word(s)
    options:
        -(lang)
         changes language of the wiki
        -(num)
         acesses the necessary page,
          when a choice is given
    examples:
        wiki -es
         switches to spanish wiki
        wiki flash
         you'll get several options
        wiki -3 flash
         picks option #3 of 'flash' request
    
    CALCULATOR - a simple calculator
    example:
        calc 4+(9-3*9)/(2^(25%3))

Other
    ONE-LINERS - prints one-liners into chat
    !1liners
     prints a random one-liner
    !1liners 32
     prints one-liner #32
    !1liners All*
     prints one-liners that start with 'All'
     the '*' symbol stands for any text

     BASH - prints quotes from bash.org
     !bash
      prints a random quote
     !bash 32
      prints quote #32
     
     
USEFUL THINGS, CONFIGURATION

-Normally, command's output will be only shown to you.
 If you want other players in the lobby to see it too then
 use double exclamation marks before the command (!!hours...)

-You can create a replacement (shortcut) for any text you want.
 Use 'set' command like this:
    !set hi hello everyone
    This sets 'hi' shortcut text to 'hello everyone'.
    Now, whenever you write '$hi' in chat, it will be
    replaced with 'hello everyone'. 
    The dollar sign means that you want a replacement.
    Use 'unset' command to nullify a replacement.

- The output of some commands can be used as replacement text.
    In this message:
     there are $!count enemies! enemies on the map
    The $!..! part will be replaced with the result of 'count'.
    Standard commands that support this: count, boc, calc, if.

- The 'if' command can only be used as a replacement.
  It compares two given values and returns option 1 in case
  the result is true and option 2 if the result is false.
  Any signs are supported: ==, <=, >=, ~=, <, >.
  The '==' sign also works with text.
  $!if 8==$!calc 2^3! -correct -incorrect!
   This will be replaced with 'correct'.
    
-You can create an additional name for any command.
 Use 'set-alias' command with '-opt arg' pairs,
 where 'opt' is the original command and 'arg' is the new name.
 !set-alias -list commands
  Now you can write '!commands' instead of '!list'.
 
-You can also configure PowerChat with 'set'.
 Do '!set -list' to see available settings.
 Then do 'set' with '-opt arg' pairs to change the settings.
 This changes '!' symbol to '@':
    !set -sym @
    Now you must write '@' for PowerChat to recognize the commands.
 Reset settings to default by doing '!set -reset'.
 Use 'get' to get the current values of the settings:
    !get sym
    
-Some commands may require the same arguments and options.
 To avoid writing the same things several times, you can
 run more than one command at once:
    !skills&hours andole
     this will execute 'skills andole' and then 'hours andole'
 You can create a name for a group of commands using 'set-alias'.
    
-If you want to use other chat monitorring mods but they do not
 work with PowerChat, then try changing 'hijack_chat' setting to 'false'.
 That will make PowerChat always forward commands to the chat.
 Or you can change the 'sym' setting.
     
-After initialization, PowerChat reads 'PowerChat_onlaunch.txt'
 file in 'saves' folder (if it exists). The file contains
 commands to execute when PowerChat starts.
 You can add and remove commands from that file with
 'onlaunch' and 'onlaunch-remove' commands:
    !onlaunch dict -fr-en -set
     now the dictionary languages will be set to fr-en on start
    !onlaunch-remove dict
     this removes any commands that contain 'dict'
     
     
FOR MODDERS
-You can create your own commands for PowerChat.
-Creating command scripts is easy and they can
 be loaded at any time, even if PowerChat has not
 loaded yet.
-Custom commands can go along with your mod or be
 a standalone mod on their own.
-PowerChat commands can extend your mod's functionality.
-You can add a command script to your mod and
 if the person using it has PowerChat then
 your command script will work.
-Open '_template.lua' in 'lua' folder to find some
 comments (that is 'hours' command script).
-The best way to start is to take an existing command
 which most closely mathes what you need and copy its
 script.
    
    
    
    
    
