# pylint: disable = C0111
from qutebrowser.config.configfiles import ConfigAPI  # noqa: F401
from qutebrowser.config.config import ConfigContainer  # noqa: F401

config: ConfigAPI = config  # noqa: F821 pylint: disable = E0602,C0103
c: ConfigContainer = c  # noqa: F821 pylint: disable = E0602,C0103

# import sys, os

# Load autoconfig before the rest of python config
config.load_autoconfig(False)

config.bind(',p', 'spawn --userscript qute-pass')
config.bind('ce', 'config-edit')
# config.bind('o', 'spawn --userscript qutedmenu open')
# config.bind('O', 'spawn --userscript qutedmenu tab')
config.bind('<Ctrl+p>',
            'config-cycle -t content.proxy socks5://localhost:9050/ none')
# config.bind('<Ctrl+r>', 'config-cycle colors.webpage.darkmode.enabled ;; restart')
config.bind('zo', 'set-cmd-text :open file:///home/jing/')

c.zoom.default = '150%'
c.aliases['mpv'] = 'spawn --userscript view_in_mpv'
# c.aliases['burp'] = 'set content.proxy http://127.0.0.1:8080/'
c.aliases['tor'] = 'set content.proxy sock5://127.0.0.1:9050/'
c.aliases['no-proxy'] = 'set content.proxy none'
c.aliases['readability'] = 'spawn --userscript readability-js'
c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
    'https://raw.githubusercontent.com/easylist/easylistchina/master/easylistchina.txt',
    # 'https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt',
    # 'https://www.i-dont-care-about-cookies.eu/abp/',
    # 'https://secure.fanboy.co.nz/fanboy-cookiemonster.txt',
    'file:///home/jing/Documents/Code/Web/adblock.txt'
]
c.content.blocking.hosts.lists = [
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
    'https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt',
    'https://raw.githubusercontent.com/x0uid/SpotifyAdBlock/master/hosts'
]
c.content.blocking.method = 'both'
c.content.autoplay = False
c.content.pdfjs = True
c.downloads.remove_finished = 7000
c.downloads.prevent_mixed_content = False
c.fileselect.handler = 'external'
c.fileselect.single_file.command = ['kitty', 'nnn', '-n', '-p', '{}']
c.fileselect.multiple_files.command = [
    'kitty', 'nnn', '-n', '-p', '{}'
]
c.fileselect.folder.command = ['kitty', 'nnn', '-n', '-p', '{}']

c.window.hide_decoration = True
c.window.transparent = True
# c.colors.webpage.darkmode.enabled = True
c.fonts.default_size = '12pt'
c.fonts.web.family.standard = 'Manjari'
c.fonts.web.size.default = 17
c.input.insert_mode.auto_load = True

c.colors.contextmenu.disabled.fg = 'grey'
c.colors.contextmenu.disabled.bg = 'white'
c.colors.contextmenu.menu.fg = 'black'
c.colors.contextmenu.menu.bg = 'white'
c.colors.contextmenu.selected.fg = 'blue'
c.colors.contextmenu.selected.bg = 'white'

c.qt.force_platform = 'wayland'
c.qt.args = [
    'widevine-path=/opt/google/chrome/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so',
    # Better to Give up, it is not working for flash
    # 'no-sandbox',
    # 'register-pepper-plugins=/home/jing/.local/lib/adobe-flashplugin/libpepflashplayer.so;application/x-shockwave-flash',
    # 'ppapi-flash-version=32.0.0.137'
]
c.content.tls.certificate_errors = 'ask-block-thirdparty'
c.tabs.show = 'switching'
c.statusbar.show = 'in-mode'
# c.url.start_pages = 'https://play.google.com/books/ebooks'
c.url.start_pages = 'https://www.poeticous.com'
c.url.searchengines['DEFAULT'] = 'https://www.google.com/search?q={}'

config.set('downloads.prevent_mixed_content', True,
           'https://scholar.google.com/scholar*')
config.set('content.javascript.can_access_clipboard', True,
           'https://github.com/*')
config.set('content.javascript.enabled', False, 'https://piratebay.live/*')
config.set('content.autoplay', True,
           'https://jingmatrix.github.io/private/chat/*')
config.set('content.notifications.enabled', False)

# try:
#     from qutebrowser.api import message
#     config.source('pyconfig/redirectors.py')

# except ImportError:
#     pass
