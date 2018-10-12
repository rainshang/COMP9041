from app import app
import namespaces.post
import namespaces.auth
import namespaces.user
import namespaces.dummy

app.run(host='0', port=8007, debug=True)
