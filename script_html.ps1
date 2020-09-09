$url = 'http://www.powertheshell.com'
$page = Invoke-WebRequest -Uri $url
$page.RawContent