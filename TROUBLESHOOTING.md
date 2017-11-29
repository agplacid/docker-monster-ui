# docker-monster-ui troubleshooting


### Problem
Can't connect securely to websockets

### Try
* Try checking that domain is correct and matches TLS cert


### Problem
Number manager search is broken, network pane shows 401 to /v2/numbers/* uri.

### Try
Verify that `phonebook` key is commented out in `js/config.js `.
