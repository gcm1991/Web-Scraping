# Web-Scraping
This is a list of professional and personal projects in which I utilize web-scraping techniques to collect data.

Use the links below to view the R notebook in HTML format

Donald Trump Tweets:

In this project I am interested in whether individuals engage in dehumanization of their political opponents. In order to answer this, I scrape tweets that were directed at Donald Trump. I chose Trump because he is a controversial figure and thus a likely candidate for dehumanization and he was also president at the time, so he was receiving a lot of tweets. 

Texas Election Results:

This project required election data in Texas. What was tricky about scraping this website is that the data wasn't just sitting on the page; Instead the user needed to provide information (county) and click 'search' to update the website. The necessitated more complex code that looped through all Texas counties and dynamically filled out forms, reading each search result to it's own table and later merging the tables. 

School Voting Place:

One of my professors was interested in how voting location might relate to vote choice. The Harris County citizens were assigned a school to vote at based on their home address. In order to find their assigned voting location a citizen would need to go to a website and enter their address. My professor had a list of everyone who voted and their addresses, and he needed me to automate the process of identifying which school they voted at based on their address. To accomplish this I had to use a special JSON URL that I located in the network section of inspect element.   

Webscraping the Office:
https://htmlpreview.github.io/?https://github.com/gcm1991/Web-Scraping/blob/main/Office%20Episodes.nb.html

The Office with Steve Carrell is one of my favorite shows. For this project I scraped IMBD ratings of every episode from the web. I am interested in how the ratings of the show changed over time, particularly with repsect to Steve Carrell leaving in the later seasons. 
