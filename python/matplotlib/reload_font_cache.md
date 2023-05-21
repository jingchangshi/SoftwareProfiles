Sometimes, the Lato font is not pre-installed. After you put the Lato font into `~/.local/share/fonts/`, you need to rebuild the font cache for matplotlib. Do as follows,

```
rm -rf ~/.cache/matplotlib/*
python3
>>> import matplotlib.font_manager as fm
>>> fm._rebuild()
```

