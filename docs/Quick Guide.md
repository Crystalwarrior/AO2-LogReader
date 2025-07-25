# This log-reading tool will make GMing so much easier.

Keeping track of people's movements live during session has always been kind of a pain - you have to rely on a tiny OOC window and constantly use `/getareas` to get where people are, and visually speaking it's really hard to process what's even going on.

That's where the LogReader comes in - this tool can connect to your log file, listen for any changes that happen, and move character icons around a map of your design, giving you clear, concise visual feedback to everyone's movements - at all times. It even works for post-session logs, too!

# Prerequisites

1. This tool currently only works on [KFO-Server](https://github.com/Crystalwarrior/KFO-Server) codebase, which includes the Killing Fever Online server that I host. Support for other codebases is considered, though it will need significant code overhauls.
2. You must have a GM client that has the option `/remote_listen ALL` enabled. Using that will give you full, complete logs of the entire session in every area. You can find your logs in `Client Program Folder/logs/Server Name/2025-07-21 22-12-49 UTC.log`, as an example - the log date and time is from when that client was first opened in UTC time zone.

# Usage Guide

1. First, you need to `Link Assets` - click on the button, navigate to your `Client Program Folder`, and select the `base` folder or the asset pack relevant to your roleplay
<img width="705" height="634" alt="image" src="https://github.com/user-attachments/assets/5828871a-f68e-4223-afee-31fb6883e93e" />

2. Once your assets are linked, click on `Open Logfile`, navigate find your `Client Program Folder/logs/Server Name/*.log` file, and open it
![Godot_v4 4 1-stable_win64_HKVgmf4wWN](https://github.com/user-attachments/assets/4d78eeaa-221a-4c30-9360-a56c4a7b4267)

3. This will generate a list of characters and areas, and the characters should have their `char_icon.png`s from your content!
<img width="806" height="221" alt="image" src="https://github.com/user-attachments/assets/8cfede46-36a3-4a81-a1fb-5a8be5efe9a2" />

4. You can drag these map objects around and even resize them from the bottom right corner of its box. Characters will appear at the center of the box. Place Holder icon will be used for characters for whom an icon couldn't be found.
<img width="290" height="396" alt="image" src="https://github.com/user-attachments/assets/9caaa494-b7df-4426-86d1-44a10d64ef95" />

5. Optionally, select a `Map Image` by clicking on the button and picking an image file. This is what will be used as a backdrop for your map!
<img width="771" height="545" alt="image" src="https://github.com/user-attachments/assets/d7264132-8752-4017-a6e7-e89274ea12d1" />

6. You can even change its `modulate` option, which is the color of the map!
![brave_au91klhOO1](https://github.com/user-attachments/assets/a9e4fd96-b61d-4273-87d4-e890b565f3e3)

And now that you've linked your log, it will be automatically updated when it detects any changes! For navigating the log, you can use the `<<` `<` `>` `>>` buttons, `LIVE` button will put you at the end and synchronize the log with any ongoing changes (for example, the RP is being hosted right now).
The `0.5 sec` spinbox can be used to adjust the time scale when playing the log file back - 1.0 sec is live session speed, 0.1 sec is one tenth of a second, increasing playback speed 10 times.

7. Finally, the most important step for repeated log viewing: **YOU CAN SAVE YOUR MAP LAYOUT WITH `Save Layout` BUTTON, AND LOAD IT WITH `Load Layout`!**
<img width="222" height="45" alt="image" src="https://github.com/user-attachments/assets/d32ef361-4b65-4178-8176-4ab09190471a" />

I heavily recommend you do this so you don't have to re-construct your map every time!
