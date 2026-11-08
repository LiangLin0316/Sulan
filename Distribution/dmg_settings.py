from os.path import basename

application = defines["app"]
files = [application]
symlinks = {"Applications": "/Applications"}
icon = defines["icon"]
background = defines["background"]
format = "UDZO"

window_rect = ((150, 150), (600, 362))
icon_size = 88
text_size = 12
icon_locations = {basename(application): (164, 189), "Applications": (436, 189)}
