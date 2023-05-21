if ($args[0] -eq $null) {
  Write-Error "Markdown file is not provided!"
  Exit 1
} else {
  $md_fname=$args[0]
  $md_fpath=$(Join-Path -Path $PWD -ChildPath $md_fname)
  $md_fpath=(Get-Item $md_fpath).Fullname
  $html_fpath=$(Join-Path -Path (Get-Item $md_fpath).DirectoryName -ChildPath (Get-Item $md_fpath).Basename)+".html"
  $tmpl_fname="article.reading.cn.template"
  $tmpl_fpath=$(Join-Path -Path $PSScriptRoot -ChildPath $tmpl_fname)
  pandoc -f markdown -t html --template=$tmpl_fpath --number-sections --number-offset=0 $md_fpath -o $html_fpath
}
