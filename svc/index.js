var fs = require('fs');
var app = require('express')();

const password = "s0meSuperSecr3tP@SSw0rd"

app.get('*', function (req, res) {
  let token = getToken()
  if (token === password) {
    console.log('endpoint called, token exists')
    res.json({success: true});
  } else {
    console.log(`endpoint called, token missing: ${token}`)
    res.status(500).send();
  }
})

function getToken() {
  var fileSecret = readFileSyncSafe('', process.env.LP_TOKEN_PATH).trim();
  var envSecret = process.env.LP_TOKEN

  console.log(`Internal Secrets. File: '${fileSecret}', Env: '${envSecret}'`)

  return fileSecret || envSecret || '';
}

function readFileSyncSafe(alt, path) {
  try {
    return fs.readFileSync(path, 'utf8')
  } catch (e) {
    console.log('Error while reading file: ', e)
    return alt
  }
}

var port = (process.env.PORT || 3000);
app.listen(port, function() {
	console.log('Listening on port: ' + port);
});
