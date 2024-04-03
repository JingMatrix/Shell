#! python3

import sqlite3
from pathlib import Path


def _fileExists(fileName):
    return +(Path(fileName).is_file())


def cleanHistory():
    bookmarks = Path.home(
    ) / ".local" / "share" / "zathura" / "bookmarks.sqlite"
    if not bookmarks.is_file():
        return
    con = sqlite3.connect(bookmarks)
    con.create_function("valide_file", 1, _fileExists)
    con.execute("DELETE from fileinfo WHERE valide_file(file) = 0")
    con.execute("DELETE from jumplist WHERE valide_file(file) = 0")
    con.commit()
    con.close()


sqlite3.enable_callback_tracebacks(True)
cleanHistory()
