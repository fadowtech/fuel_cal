import urllib.request
import urllib.error
import json

def req(url, data=None, headers={}):
    if data:
        data = json.dumps(data).encode()
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=data, headers=headers)
    try:
        with urllib.request.urlopen(req) as f:
            return f.status, f.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

s, res = req('http://184.174.37.4:8001/auth/signup', {'first_name':'Test','last_name':'User','email':'test_reminder_debug_2@test.com','password':'password','currency_code':'USD'})
print(s, res)

s, res = req('http://184.174.37.4:8001/auth/login', {'email':'test_reminder_debug_2@test.com','password':'password'})
token = json.loads(res).get('access_token')
print('Token:', token)

if token:
    headers = {'Authorization': f'Bearer {token}'}
    data = {'category': 'Service', 'title': 'Test Reminder', 'due_date': '2026-05-31T12:00:00.000Z', 'priority': 'High', 'status': 'pending'}
    s, res = req('http://184.174.37.4:8001/reminders/', data, headers)
    print('Reminder creation:', s, res)
