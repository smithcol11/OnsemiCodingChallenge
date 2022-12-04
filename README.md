# OnsemiCodingChallenge README
> This is my coding challenge for ON Semiconductor Summer 2021 Internship. 

## How to build and run
> Building and running is very simple. 
> After downloading the repo, it is good to get the required node packages; NodeJS is required. A simple terminal command will get every dependancy needed.

```terminal
npm install ws uuid mongoose websocket
```
> To get the server going, you can type 'node index.js' in the terminal when in the nodejs folder.
> Now, in the Qt Creator, you can open the .pro file for the project and it will load all the necessary files.
> Simply run the project and the first client connection will be established.
> You can connect as many clients as you would like by clicking on Build in the toolbar and 'Run without deployment'.

## MongoDB
> For this, I included a .env file. It will connect and load my database from the index.js automatically when 'node index.js' is ran.
> The .env does not contain my database info so no database will be connected. You can insert your own username and password for MongoDB to get this working.
> So, you don't need to do anything extra for this; the dependancies are all handled by installing mongoose as shown above.
