# Define the link function
def setLnk(fsrc,fdst):
    from os import symlink, rename, remove
    from os.path import dirname, exists, isfile, islink
    from pathlib import Path
    fdst_dir = dirname(fdst)
    if not exists(fdst_dir):
        Path(fdst_dir).mkdir(parents=True, exist_ok=True)
    if not exists(fdst):
        symlink(fsrc,fdst)
    else:
        if isfile(fdst):
            fdst_bkp=fdst+'.backup'
            if exists(fdst_bkp):
                remove(fdst)
            else:
                rename(fdst,fdst_bkp)
        elif islink(fdst):
            # is link
            remove(fdst)
        # not exist
        symlink(fsrc,fdst)
    if exists(fdst):
        print("%s is linked to %s"%(fdst,fsrc))
    else:
        print("ERROR: %s is not set up!"%(fdst))

def runCase(in_case):
    if in_case == 'pip':
        ## pip
        fdst = expandvars("%APPDATA%\pip\pip.ini")
        fsrc = join(src_base_dir, "python\pip.conf")
        setLnk(fsrc,fdst)
    elif in_case == 'PowerShell':
        ## PowerShell
        fdst = expandvars("%USERPROFILE%\Documents\WindowsPowerShell\profile.ps1")
        fsrc = join(src_base_dir, "WindowsPowerShell\profile.ps1")
        setLnk(fsrc,fdst)
    elif in_case == 'vim':
        ## vim
        # First download vim-plug
        # TBA
        # vimrc
        fdst = expandvars("%USERPROFILE%/.vimrc")
        fsrc = join(src_base_dir, "vim/vimrc")
        setLnk(fsrc,fdst)
        # vim-snippets
        fdst = expandvars("%USERPROFILE%/.vim/plugged/vim-snippets/snippets/markdown.snippets")
        fsrc = join(src_base_dir, "vim/vim-snippets/markdown.snippets")
        setLnk(fsrc,fdst)
        fdst = expandvars("%USERPROFILE%/.vim/plugged/vim-snippets/snippets/tex.snippets")
        fsrc = join(src_base_dir, "vim/vim-snippets/tex.snippets")
        setLnk(fsrc,fdst)
        # nerdtree
        fdst = expandvars("%USERPROFILE%/.vim/plugged/nerdtree/autoload/nerdtree/ui_glue.vim")
        fsrc = join(src_base_dir, "vim/nerdtree/autoload/nerdtree/ui_glue.vim")
        setLnk(fsrc,fdst)
        # spell
        fdst = expandvars("%USERPROFILE%/.vim/spell/en.utf-8.add")
        fsrc = join(src_base_dir, "vim/spell/en.utf-8.add")
        setLnk(fsrc,fdst)
        fdst = expandvars("%USERPROFILE%/.vim/spell/en.utf-8.add.spl")
        fsrc = join(src_base_dir, "vim/spell/en.utf-8.add.spl")
        setLnk(fsrc,fdst)
    elif in_case == 'git':
        ## git
        fdst = expandvars("%USERPROFILE%\.gitignore")
        fsrc = join(src_base_dir, "git\gitignore")
        setLnk(fsrc,fdst)
        fdst = expandvars("%USERPROFILE%\.gitconfig")
        fsrc = join(src_base_dir, "git\gitconfig")
        setLnk(fsrc,fdst)
    elif in_case == 'npm':
        ## npm
        fdst = expandvars("%USERPROFILE%\.npmrc")
        fsrc = join(src_base_dir, "npm\\npmrc")
        setLnk(fsrc,fdst)
        fdst = expandvars("%USERPROFILE%\.czrc")
        fsrc = join(src_base_dir, "npm\czrc")
        setLnk(fsrc,fdst)

# Execute the setup
from os.path import expandvars, join
src_base_dir = expandvars("%USERPROFILE%\software_profile")

runCase('vim')

