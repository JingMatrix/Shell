#! /bin/python3

# Download wikiquote for newsboat
import wikiquote
from feedgen.feed import FeedGenerator
from datetime import datetime
import os.path
import calendar

today = datetime.now()
date = calendar.month_name[int(
    today.strftime('%m'))] + today.strftime('_%d,_%Y')
en_qotd = wikiquote.quote_of_the_day(lang='en')

en_quote_rss = FeedGenerator()
en_quote_rss.id('https://en.wikiquote.org/wiki/Main_Page')
en_quote_rss.link(href='https://en.wikiquote.org/wiki/Main_Page')
en_quote_rss.title('Wikiquote')
en_quote_rss.description('Quote of the day in English')
en_quote_rss.language('en')
en_quote_rss.author({'name': en_qotd[1]})

qotd = en_quote_rss.add_entry()
qotd.id(date)
qotd.title('Quote by ' + en_qotd[1])
qotd.description(en_qotd[0])
qotd.link(href='https://en.wikiquote.org/wiki/Wikiquote:Quote_of_the_day/' +
          date)

en_quote_rss.rss_file(os.path.expanduser('~/.config/newsboat/wikiquote.xml'))
