#
#    ██████╗ ██╗   ██╗████████╗███████╗██████╗ ██████╗  ██████╗ ██╗    ██╗███████╗███████╗██████╗ 
#   ██╔═══██╗██║   ██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔════╝██╔══██╗
#   ██║   ██║██║   ██║   ██║   █████╗  ██████╔╝██████╔╝██║   ██║██║ █╗ ██║███████╗█████╗  ██████╔╝
#   ██║▄▄ ██║██║   ██║   ██║   ██╔══╝  ██╔══██╗██╔══██╗██║   ██║██║███╗██║╚════██║██╔══╝  ██╔══██╗
#   ╚██████╔╝╚██████╔╝   ██║   ███████╗██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝███████║███████╗██║  ██║
#    ╚══▀▀═╝  ╚═════╝    ╚═╝   ╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚══════╝╚═╝  ╚═╝
#


import os
wal_config = os.path.expanduser("~/.cache/wal/qutebrowser-config.py")
if os.path.exists(wal_config):
    with open(wal_config, "r") as f:
        exec(f.read())

# Load existing settings made via :set
config.load_autoconfig()

# === STARTUP OPTIMIZATIONS ===
# Session management
c.auto_save.session = False
c.auto_save.interval = 0
c.session.lazy_restore = True  # Load tabs only when accessed

# Disable resource-heavy features
c.spellcheck.languages = []  # Disable spellchecking for faster startup
c.tabs.favicons.show = 'never'  # Skip favicon loading
c.completion.web_history.max_items = 1000  # Reduce history items loaded

# Allow local content to access remote resources
c.content.local_content_can_access_remote_urls = True
c.content.local_content_can_access_file_urls = True

# Network optimizations
c.content.dns_prefetch = True  # Enable DNS prefetching
c.content.prefers_reduced_motion = True  # Reduce animations

# Reduce startup checks
c.content.autoplay = False  # Prevent autoplay media on startup pages
c.content.javascript.can_open_tabs_automatically = False

# === BASIC SETTINGS ===
c.url.default_page = 'file:///home/dustin/.config/qutebrowser/homepage/index.html'
c.url.start_pages = ['file:///home/dustin/.config/qutebrowser/homepage/index.html']
c.downloads.location.directory = '~/downloads'

# === APPEARANCE ===
c.fonts.default_family = 'Departure Mono'
c.fonts.default_size = '12pt'
c.zoom.default = '100%'

# === KEY BINDINGS ===
config.bind('<Ctrl+j>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl+k>', 'completion-item-focus prev', mode='command')

# === SEARCH ENGINES ===
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    'g': 'https://google.com/search?q={}',
    'gh': 'https://github.com/search?q={}',
}

# === NAVIGATION / SCROLLING ===
config.bind(',', 'back')
config.bind('.', 'forward')
config.bind('r', 'reload')

# === TABS ===
config.bind('t', 'open -t')
config.bind('T', 'open -p')
config.bind('x', 'tab-close')
config.bind('z', 'undo')          # reopen last closed tab
config.bind('j', 'tab-next')
config.bind('k', 'tab-prev')
config.bind('1', 'tab-focus 1')
config.bind('2', 'tab-focus 2')
config.bind('3', 'tab-focus 3')
config.bind('4', 'tab-focus 4')
config.bind('5', 'tab-focus 5')

# === HINTING / LINKS ===
config.bind('f', 'hint links')
config.bind('F', 'hint links tab')
config.bind('y', 'hint links yank')
config.bind('p', 'open -t {clipboard}')

# === SEARCHING ===
config.bind('/', 'cmd-set-text /')
config.bind('?', 'cmd-set-text ?')
config.bind('>', 'search-next')
config.bind('<', 'search-prev')

# === DOWNLOADS / BOOKMARKS ===
config.bind('d', 'download')
config.bind('m', 'bookmark-add')
config.bind('b', 'bookmark-list')

# === ZOOM ===
config.bind('+', 'zoom-in')
config.bind('-', 'zoom-out')
config.bind('=', 'zoom')          # reset zoom
