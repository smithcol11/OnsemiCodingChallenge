# ON_CodingChallenge README
> This build is in a pretty good spot for testing, I am still currently adding features. But I think it will demonstrate my skill level. I hope you enjoy!

## How to build and run
> Building and running is very simple. 
> After downloading the repo, it is good to get the required node packages; NodeJS is required. A simple terminal command will get every dependancy needed.

```javascript
npm install ws uuid mongoose websocket
```
> To get the server going, you can simply type 'node index.js' in the terminal when in the nodejs folder.
> Now, in the Qt Creator, you can simply open the .pro file for the project and it will load all the necessary files.
> Simply run the project and the first client connection will be established.
> You can connect as many clients as you would like by clicking on Build in the toolbar and 'Run without deployment'.

## MongoDB
> For this, I included a .env file. It will connect and load my database from the index.js automatically when 'node index.js' is ran.
> So, you don't need to do anything extra for this; the dependancies are all handled by installing mongoose as shown above.
